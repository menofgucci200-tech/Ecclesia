import 'package:flutter/foundation.dart' show defaultTargetPlatform, debugPrint, debugPrintStack;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart' as ll;
import 'package:url_launcher/url_launcher.dart';

import '../../../core/network/api_exception.dart';
import '../../home/presentation/theme/home_palette.dart';
import '../data/discover_providers.dart';
import '../data/nearby_parish_model.dart';

enum _LocationState { loading, serviceDisabled, permissionDenied, ready, error }

/// "Découvrir" — a map of parishes around the faithful's current position.
/// Partner parishes (blue) vs. non-partner (red); search by name, tap a
/// marker for an info sheet with distance and directions in the device's
/// own maps app.
class DiscoverScreen extends ConsumerStatefulWidget {
  const DiscoverScreen({super.key});

  @override
  ConsumerState<DiscoverScreen> createState() => _DiscoverScreenState();
}

class _DiscoverScreenState extends ConsumerState<DiscoverScreen> with SingleTickerProviderStateMixin {
  static const double _defaultRadiusKm = 50;

  final _mapController = MapController();
  final _searchController = TextEditingController();
  final _searchFocus = FocusNode();

  late final AnimationController _cameraAnim = AnimationController(vsync: this, duration: const Duration(milliseconds: 550));
  VoidCallback? _cameraListener;

  _LocationState _state = _LocationState.loading;
  ll.LatLng? _position;
  final double _radiusKm = _defaultRadiusKm;
  String _query = '';

  @override
  void initState() {
    super.initState();
    _locate();
    _searchController.addListener(() => setState(() => _query = _searchController.text.trim()));
  }

  @override
  void dispose() {
    _cameraAnim.dispose();
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
        _position = ll.LatLng(position.latitude, position.longitude);
        _state = _LocationState.ready;
      });
      _mapController.move(_position!, 12);
    } catch (e, st) {
      // Logged (not surfaced) so a real device failure is diagnosable from
      // `flutter run` output instead of a generic on-screen message.
      debugPrint('Discover: getCurrentPosition failed — $e');
      debugPrintStack(stackTrace: st);

      // A fresh fix can fail (weak signal, no Play Services) even though the
      // device already has a recent one cached — better to show a slightly
      // stale map than an error screen.
      try {
        final last = await Geolocator.getLastKnownPosition();
        if (last != null && mounted) {
          setState(() {
            _position = ll.LatLng(last.latitude, last.longitude);
            _state = _LocationState.ready;
          });
          _mapController.move(_position!, 12);
          return;
        }
      } catch (_) {
        // Fall through to the error state below.
      }

      if (mounted) setState(() => _state = _LocationState.error);
    }
  }

  /// Eases the camera to [dest]/[destZoom] instead of an abrupt jump.
  void _animateCameraTo(ll.LatLng dest, double destZoom) {
    final camera = _mapController.camera;
    final latTween = Tween<double>(begin: camera.center.latitude, end: dest.latitude);
    final lngTween = Tween<double>(begin: camera.center.longitude, end: dest.longitude);
    final zoomTween = Tween<double>(begin: camera.zoom, end: destZoom);
    final curved = CurvedAnimation(parent: _cameraAnim, curve: Curves.easeInOutCubic);

    if (_cameraListener != null) _cameraAnim.removeListener(_cameraListener!);
    _cameraListener = () {
      _mapController.move(ll.LatLng(latTween.evaluate(curved), lngTween.evaluate(curved)), zoomTween.evaluate(curved));
    };
    _cameraAnim
      ..addListener(_cameraListener!)
      ..forward(from: 0);
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
    _animateCameraTo(ll.LatLng(parish.latitude, parish.longitude), 15);
    _showParishSheet(parish);
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
    final results = _query.isEmpty
        ? const <NearbyParish>[]
        : parishes.where((p) => '${p.name} ${p.locationLine}'.toLowerCase().contains(_query.toLowerCase())).take(6).toList();

    return Stack(
      children: [
        FlutterMap(
          mapController: _mapController,
          options: MapOptions(initialCenter: position, initialZoom: 12, maxZoom: 18, minZoom: 3),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.example.ecclesia_',
            ),
            MarkerLayer(
              markers: [
                Marker(point: position, width: 22, height: 22, child: const _UserDot()),
                ...parishes.map(
                  (p) => Marker(
                    point: ll.LatLng(p.latitude, p.longitude),
                    width: 120,
                    height: 64,
                    alignment: Alignment.topCenter,
                    child: GestureDetector(
                      onTap: () => _showParishSheet(p),
                      child: _ParishPin(parish: p),
                    ),
                  ),
                ),
              ],
            ),
          ],
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

class _UserDot extends StatelessWidget {
  const _UserDot();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: HomePalette.navy,
        border: Border.all(color: Colors.white, width: 3),
        boxShadow: [BoxShadow(color: HomePalette.navy.withValues(alpha: .4), blurRadius: 8, spreadRadius: 1)],
      ),
    );
  }
}

class _ParishPin extends StatelessWidget {
  const _ParishPin({required this.parish});

  final NearbyParish parish;

  @override
  Widget build(BuildContext context) {
    final color = parish.isPartner ? const Color(0xFF1A6B9E) : const Color(0xFFCE3B3B);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.location_on, size: 36, color: color, shadows: const [Shadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2))]),
        Container(
          constraints: const BoxConstraints(maxWidth: 108),
          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(100),
            border: Border.all(color: color.withValues(alpha: .35)),
            boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 3, offset: Offset(0, 1))],
          ),
          child: Text(
            parish.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: HomePalette.navy),
          ),
        ),
      ],
    ).animate().fadeIn(duration: 220.ms).scale(begin: const Offset(.7, .7), end: const Offset(1, 1), duration: 220.ms, curve: Curves.easeOutBack);
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
