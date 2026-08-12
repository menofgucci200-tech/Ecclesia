import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart' show defaultTargetPlatform, debugPrint, debugPrintStack;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/network/api_exception.dart';
import '../../home/presentation/theme/home_palette.dart';
import '../data/discover_providers.dart';
import '../data/nearby_parish_model.dart';

enum _LocationState { loading, serviceDisabled, permissionDenied, ready, error }

/// "Découvrir" — a Google Maps view of parishes around the faithful's
/// current position. Partner parishes (blue) vs. non-partner (red), each
/// pin labelled with the parish name; search by name; tap a marker for an
/// info sheet with distance and directions in the device's own maps app.
class DiscoverScreen extends ConsumerStatefulWidget {
  const DiscoverScreen({super.key});

  @override
  ConsumerState<DiscoverScreen> createState() => _DiscoverScreenState();
}

class _DiscoverScreenState extends ConsumerState<DiscoverScreen> {
  static const double _defaultRadiusKm = 50;

  GoogleMapController? _mapController;
  final _searchController = TextEditingController();
  final _searchFocus = FocusNode();

  _LocationState _state = _LocationState.loading;
  LatLng? _position;
  final double _radiusKm = _defaultRadiusKm;
  String _query = '';

  // Marker bitmaps are generated once per (name, partner-status) pair and
  // reused — regenerating a canvas image on every rebuild would be wasteful.
  final Map<String, BitmapDescriptor> _iconCache = {};
  List<NearbyParish> _lastParishes = const [];
  Set<Marker> _markers = {};

  @override
  void initState() {
    super.initState();
    _locate();
    _searchController.addListener(() => setState(() => _query = _searchController.text.trim()));
  }

  @override
  void dispose() {
    _mapController?.dispose();
    _searchController.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  Future<void> _locate() async {
    setState(() => _state = _LocationState.loading);

    if (!await Geolocator.isLocationServiceEnabled()) {
      if (mounted) setState(() => _state = _LocationState.serviceDisabled);
      return;
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
      if (mounted) setState(() => _state = _LocationState.permissionDenied);
      return;
    }

    try {
      final position = await Geolocator.getCurrentPosition(
        locationSettings: defaultTargetPlatform == TargetPlatform.android
            ? AndroidSettings(
                accuracy: LocationAccuracy.medium,
                timeLimit: const Duration(seconds: 15),
                // Some devices common in this app's market ship without a
                // working Google Play Services fused location provider,
                // which fails silently; the native LocationManager doesn't
                // depend on it.
                forceLocationManager: true,
              )
            : const LocationSettings(accuracy: LocationAccuracy.medium, timeLimit: Duration(seconds: 15)),
      );
      if (!mounted) return;
      setState(() {
        _position = LatLng(position.latitude, position.longitude);
        _state = _LocationState.ready;
      });
    } catch (e, st) {
      debugPrint('Discover: getCurrentPosition failed — $e');
      debugPrintStack(stackTrace: st);

      try {
        final last = await Geolocator.getLastKnownPosition();
        if (last != null && mounted) {
          setState(() {
            _position = LatLng(last.latitude, last.longitude);
            _state = _LocationState.ready;
          });
          return;
        }
      } catch (_) {
        // Fall through to the error state below.
      }

      if (mounted) setState(() => _state = _LocationState.error);
    }
  }

  Future<void> _animateCameraTo(LatLng dest, double zoom) async {
    final controller = _mapController;
    if (controller == null) return;
    await controller.animateCamera(CameraUpdate.newLatLngZoom(dest, zoom));
  }

  Future<void> _openDirections(NearbyParish parish) async {
    HapticFeedback.selectionClick();
    final label = Uri.encodeComponent(parish.name);
    final geoUri = Uri.parse('geo:0,0?q=${parish.latitude},${parish.longitude}($label)');
    final webUri = Uri.parse('https://www.google.com/maps/dir/?api=1&destination=${parish.latitude},${parish.longitude}');

    if (await canLaunchUrl(geoUri)) {
      await launchUrl(geoUri);
    } else {
      await launchUrl(webUri, mode: LaunchMode.externalApplication);
    }
  }

  void _showParishSheet(NearbyParish parish) {
    HapticFeedback.selectionClick();
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => _ParishSheet(parish: parish, onDirections: () => _openDirections(parish)),
    );
  }

  void _selectSearchResult(NearbyParish parish) {
    _searchController.clear();
    _searchFocus.unfocus();
    setState(() => _query = '');
    _animateCameraTo(LatLng(parish.latitude, parish.longitude), 15);
    _showParishSheet(parish);
  }

  /// Rebuilds [_markers] for a new parish list, generating any missing
  /// custom pin+label bitmaps first (cached by name/partner-status).
  Future<void> _updateMarkers(List<NearbyParish> parishes) async {
    if (identical(parishes, _lastParishes)) return;
    _lastParishes = parishes;

    final pixelRatio = MediaQuery.of(context).devicePixelRatio;
    final markers = <Marker>{};

    for (final p in parishes) {
      final cacheKey = '${p.name}|${p.isPartner}';
      final icon = _iconCache[cacheKey] ??= await _buildMarkerBitmap(p.name, p.isPartner, pixelRatio);
      markers.add(
        Marker(
          markerId: MarkerId('parish-${p.id}'),
          position: LatLng(p.latitude, p.longitude),
          icon: icon,
          anchor: const Offset(0.5, 0.42),
          onTap: () => _showParishSheet(p),
        ),
      );
    }

    if (mounted) setState(() => _markers = markers);
  }

  /// Draws a colored pin with the parish name in a pill underneath, as a PNG
  /// — native Google Maps markers only accept bitmaps, not live widgets.
  Future<BitmapDescriptor> _buildMarkerBitmap(String label, bool isPartner, double pixelRatio) async {
    final color = isPartner ? const Color(0xFF1A6B9E) : const Color(0xFFCE3B3B);
    final scale = pixelRatio.clamp(1.0, 3.0);

    final textPainter = TextPainter(
      text: TextSpan(text: label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: HomePalette.navy)),
      textDirection: TextDirection.ltr,
      maxLines: 1,
      ellipsis: '…',
    )..layout(maxWidth: 130);

    const pinRadius = 11.0;
    const pinBorder = 2.5;
    const labelPadH = 7.0;
    const labelPadV = 3.0;
    const gap = 4.0;

    final labelWidth = textPainter.width + labelPadH * 2;
    final labelHeight = textPainter.height + labelPadV * 2;
    final canvasWidth = math.max(labelWidth, pinRadius * 2 + 6);
    final pinCenter = Offset(canvasWidth / 2, pinRadius + pinBorder + 1);
    final labelTop = pinCenter.dy + pinRadius + gap;
    final canvasHeight = labelTop + labelHeight + 1;

    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder, Rect.fromLTWH(0, 0, canvasWidth, canvasHeight));
    canvas.scale(scale);

    canvas.drawCircle(pinCenter, pinRadius, Paint()..color = color);
    canvas.drawCircle(pinCenter, pinRadius - pinBorder / 2, Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = pinBorder);
    canvas.drawCircle(pinCenter, pinRadius * 0.34, Paint()..color = Colors.white);

    final labelRect = RRect.fromRectAndRadius(
      Rect.fromLTWH((canvasWidth - labelWidth) / 2, labelTop, labelWidth, labelHeight),
      const Radius.circular(100),
    );
    canvas.drawRRect(labelRect, Paint()..color = Colors.white);
    canvas.drawRRect(labelRect, Paint()
      ..color = color.withValues(alpha: .4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1);
    textPainter.paint(canvas, Offset((canvasWidth - labelWidth) / 2 + labelPadH, labelTop + labelPadV));

    final picture = recorder.endRecording();
    final image = await picture.toImage((canvasWidth * scale).ceil(), (canvasHeight * scale).ceil());
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    return BitmapDescriptor.bytes(bytes!.buffer.asUint8List(), imagePixelRatio: scale);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: HomePalette.screenBg,
      appBar: AppBar(title: const Text('Découvrir')),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 220),
        child: switch (_state) {
          _LocationState.loading => const Center(key: ValueKey('loading'), child: CircularProgressIndicator(color: HomePalette.navy)),
          _LocationState.serviceDisabled => _LocationMessage(
              key: const ValueKey('service-disabled'),
              icon: Icons.location_off_outlined,
              message: 'Activez la localisation de votre téléphone pour voir les paroisses autour de vous.',
              actionLabel: 'Activer la localisation',
              onAction: () async {
                await Geolocator.openLocationSettings();
                _locate();
              },
            ),
          _LocationState.permissionDenied => _LocationMessage(
              key: const ValueKey('permission-denied'),
              icon: Icons.location_off_outlined,
              message: "Ecclesia a besoin d'accéder à votre position pour trouver les paroisses proches.",
              actionLabel: 'Autoriser',
              onAction: _locate,
            ),
          _LocationState.error => _LocationMessage(
              key: const ValueKey('error'),
              icon: Icons.error_outline,
              message: "Impossible d'obtenir votre position pour le moment.",
              actionLabel: 'Réessayer',
              onAction: _locate,
            ),
          _LocationState.ready => KeyedSubtree(key: const ValueKey('ready'), child: _map()),
        },
      ),
    );
  }

  Widget _map() {
    final position = _position!;
    final async = ref.watch(nearbyParishesProvider((lat: position.latitude, lng: position.longitude, radiusKm: _radiusKm)));
    final parishes = async.asData?.value ?? const <NearbyParish>[];

    if (async.hasValue) {
      // Fire-and-forget: rebuilds `_markers` asynchronously as bitmaps are ready.
      _updateMarkers(parishes);
    }

    final results = _query.isEmpty
        ? const <NearbyParish>[]
        : parishes.where((p) => '${p.name} ${p.locationLine}'.toLowerCase().contains(_query.toLowerCase())).take(6).toList();

    return Stack(
      children: [
        GoogleMap(
          initialCameraPosition: CameraPosition(target: position, zoom: 12),
          onMapCreated: (controller) => _mapController = controller,
          myLocationEnabled: true,
          myLocationButtonEnabled: false,
          zoomControlsEnabled: false,
          markers: _markers,
        ),
        Positioned(
          top: 10,
          left: 16,
          right: 16,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _SearchBar(controller: _searchController, focusNode: _searchFocus),
              if (results.isNotEmpty)
                _SearchResults(results: results, onSelect: _selectSearchResult).animate().fadeIn(duration: 160.ms).slideY(begin: -.05, end: 0, duration: 160.ms),
              if (_query.isEmpty) ...[
                const SizedBox(height: 8),
                _Legend(count: async.asData?.value.length, radiusKm: _radiusKm),
              ],
            ],
          ),
        ),
        if (async.isLoading)
          const Positioned(
            top: 66,
            left: 0,
            right: 0,
            child: Center(child: _Pill(child: CircularProgressIndicator(strokeWidth: 2, color: HomePalette.navy))),
          ),
        if (async.hasError)
          Positioned(
            top: 66,
            left: 16,
            right: 16,
            child: _Pill(
              child: Text(
                async.error is ApiException ? (async.error as ApiException).message : 'Impossible de charger les paroisses.',
                style: const TextStyle(fontSize: 12.5, color: HomePalette.textBody),
              ),
            ),
          ),
        Positioned(
          right: 16,
          bottom: 16,
          child: FloatingActionButton(
            heroTag: 'discover-recenter',
            backgroundColor: Colors.white,
            foregroundColor: HomePalette.navy,
            onPressed: () {
              _animateCameraTo(position, 13);
              HapticFeedback.selectionClick();
            },
            child: const Icon(Icons.my_location_rounded),
          ),
        ),
      ],
    );
  }
}

class _SearchBar extends StatelessWidget {
  const _SearchBar({required this.controller, required this.focusNode});

  final TextEditingController controller;
  final FocusNode focusNode;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 46,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(100),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: .12), blurRadius: 10, offset: const Offset(0, 3))],
      ),
      child: Row(
        children: [
          const Icon(Icons.search, size: 20, color: HomePalette.textMuted),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: controller,
              focusNode: focusNode,
              decoration: const InputDecoration(
                hintText: 'Chercher une paroisse…',
                hintStyle: TextStyle(fontSize: 13.5, color: HomePalette.textMuted),
                border: InputBorder.none,
                isDense: true,
              ),
              style: const TextStyle(fontSize: 13.5, color: HomePalette.navy),
            ),
          ),
          ValueListenableBuilder(
            valueListenable: controller,
            builder: (context, value, _) => value.text.isEmpty
                ? const SizedBox.shrink()
                : GestureDetector(
                    onTap: () {
                      HapticFeedback.selectionClick();
                      controller.clear();
                      focusNode.unfocus();
                    },
                    child: const Icon(Icons.close_rounded, size: 18, color: HomePalette.textMuted),
                  ),
          ),
        ],
      ),
    );
  }
}

class _SearchResults extends StatelessWidget {
  const _SearchResults({required this.results, required this.onSelect});

  final List<NearbyParish> results;
  final ValueChanged<NearbyParish> onSelect;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: .12), blurRadius: 10, offset: const Offset(0, 3))],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final (i, p) in results.indexed) ...[
            if (i > 0) const Divider(height: 1, color: HomePalette.hairline),
            InkWell(
              onTap: () => onSelect(p),
              borderRadius: BorderRadius.vertical(
                top: i == 0 ? const Radius.circular(16) : Radius.zero,
                bottom: i == results.length - 1 ? const Radius.circular(16) : Radius.zero,
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
                child: Row(
                  children: [
                    Icon(Icons.location_on, size: 16, color: p.isPartner ? const Color(0xFF1A6B9E) : const Color(0xFFCE3B3B)),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(p.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: HomePalette.navy)),
                          if (p.locationLine.isNotEmpty)
                            Text(p.locationLine, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 11.5, color: HomePalette.textMuted)),
                        ],
                      ),
                    ),
                    Text('${p.distanceKm} km', style: const TextStyle(fontSize: 11, color: HomePalette.textFaint)),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _Legend extends StatelessWidget {
  const _Legend({required this.count, required this.radiusKm});

  final int? count;
  final double radiusKm;

  @override
  Widget build(BuildContext context) {
    return _Pill(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(width: 10, height: 10, decoration: const BoxDecoration(color: Color(0xFF1A6B9E), shape: BoxShape.circle)),
          const SizedBox(width: 5),
          const Text('Partenaire', style: TextStyle(fontSize: 11.5, color: HomePalette.navy, fontWeight: FontWeight.w600)),
          const SizedBox(width: 12),
          Container(width: 10, height: 10, decoration: const BoxDecoration(color: Color(0xFFCE3B3B), shape: BoxShape.circle)),
          const SizedBox(width: 5),
          const Text('Autre paroisse', style: TextStyle(fontSize: 11.5, color: HomePalette.navy, fontWeight: FontWeight.w600)),
          if (count != null) ...[
            const Spacer(),
            Text('$count · ${radiusKm.round()} km', style: const TextStyle(fontSize: 11.5, color: HomePalette.textMuted)),
          ],
        ],
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(100),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: .12), blurRadius: 10, offset: const Offset(0, 3))],
      ),
      child: child,
    );
  }
}

class _LocationMessage extends StatelessWidget {
  const _LocationMessage({super.key, required this.icon, required this.message, required this.actionLabel, required this.onAction});

  final IconData icon;
  final String message;
  final String actionLabel;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 44, color: HomePalette.textFaint),
            const SizedBox(height: 16),
            Text(message, textAlign: TextAlign.center, style: const TextStyle(fontSize: 14, color: HomePalette.textBody, height: 1.5)),
            const SizedBox(height: 18),
            FilledButton(
              style: FilledButton.styleFrom(backgroundColor: HomePalette.navy, padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12)),
              onPressed: onAction,
              child: Text(actionLabel),
            ),
          ],
        ),
      ),
    );
  }
}

class _ParishSheet extends StatelessWidget {
  const _ParishSheet({required this.parish, required this.onDirections});

  final NearbyParish parish;
  final VoidCallback onDirections;

  @override
  Widget build(BuildContext context) {
    final color = parish.isPartner ? const Color(0xFF1A6B9E) : const Color(0xFFCE3B3B);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 14, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: HomePalette.cardBorder, borderRadius: BorderRadius.circular(2)))),
            const SizedBox(height: 16),
            Row(
              children: [
                Container(
                  width: 46,
                  height: 46,
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(color: color.withValues(alpha: .12), borderRadius: BorderRadius.circular(14)),
                  child: parish.logoUrl != null
                      ? Image.network(parish.logoUrl!, fit: BoxFit.cover, errorBuilder: (_, _, _) => Icon(Icons.church, color: color))
                      : Icon(Icons.church, color: color),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(parish.name, style: const TextStyle(fontSize: 16.5, fontWeight: FontWeight.w800, color: HomePalette.navy)),
                      if (parish.locationLine.isNotEmpty)
                        Text(parish.locationLine, style: const TextStyle(fontSize: 12.5, color: HomePalette.textMuted)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(color: color.withValues(alpha: .1), borderRadius: BorderRadius.circular(100)),
                  child: Text(
                    parish.isPartner ? 'Paroisse partenaire' : 'Paroisse',
                    style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: color),
                  ),
                ),
                const SizedBox(width: 10),
                Icon(Icons.directions_walk, size: 15, color: HomePalette.textMuted),
                const SizedBox(width: 4),
                Text('${parish.distanceKm} km', style: const TextStyle(fontSize: 12.5, color: HomePalette.textMuted)),
              ],
            ),
            if ((parish.address ?? '').isNotEmpty) ...[
              const SizedBox(height: 10),
              Text(parish.address!, style: const TextStyle(fontSize: 13, color: HomePalette.textBody, height: 1.4)),
            ],
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                style: FilledButton.styleFrom(backgroundColor: HomePalette.navy, padding: const EdgeInsets.symmetric(vertical: 14)),
                onPressed: onDirections,
                icon: const Icon(Icons.directions_rounded, size: 18),
                label: const Text('Itinéraire', style: TextStyle(fontWeight: FontWeight.w700)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
