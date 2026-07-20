import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/network/api_exception.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../auth/presentation/providers/session_controller.dart';
import '../../data/profile_remote_data_source.dart';

class ProfileEditScreen extends ConsumerStatefulWidget {
  const ProfileEditScreen({super.key});

  @override
  ConsumerState<ProfileEditScreen> createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends ConsumerState<ProfileEditScreen> {
  late final TextEditingController _first;
  late final TextEditingController _last;
  late final TextEditingController _email;
  String? _pickedPath;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final u = ref.read(currentUserProvider);
    _first = TextEditingController(text: u?.firstName ?? '');
    _last = TextEditingController(text: u?.lastName ?? '');
    _email = TextEditingController(text: u?.email ?? '');
  }

  @override
  void dispose() {
    _first.dispose();
    _last.dispose();
    _email.dispose();
    super.dispose();
  }

  Future<void> _pick() async {
    final file = await ImagePicker().pickImage(source: ImageSource.gallery, maxWidth: 1024, imageQuality: 85);
    if (file != null) setState(() => _pickedPath = file.path);
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      final user = await ref.read(profileDataSourceProvider).updateProfile(
            firstName: _first.text.trim(),
            lastName: _last.text.trim(),
            email: _email.text.trim().isEmpty ? null : _email.text.trim(),
            avatarPath: _pickedPath,
          );
      ref.read(sessionControllerProvider.notifier).updateUser(user);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Profil mis à jour'), behavior: SnackBarBehavior.floating));
        Navigator.of(context).pop();
      }
    } on ApiException catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message), behavior: SnackBarBehavior.floating));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final u = ref.watch(currentUserProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Éditer mon profil')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Center(
            child: Stack(
              children: [
                CircleAvatar(
                  radius: 48,
                  backgroundColor: AppColors.navy,
                  backgroundImage: _pickedPath != null
                      ? FileImage(File(_pickedPath!))
                      : (u?.avatarUrl != null ? NetworkImage(u!.avatarUrl!) : null) as ImageProvider?,
                  child: (_pickedPath == null && u?.avatarUrl == null)
                      ? Text(
                          ((u?.firstName.isNotEmpty ?? false ? u!.firstName[0] : '') + (u?.lastName.isNotEmpty ?? false ? u!.lastName[0] : '')).toUpperCase(),
                          style: const TextStyle(color: Colors.white, fontSize: 30, fontWeight: FontWeight.w700),
                        )
                      : null,
                ),
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Material(
                    color: AppColors.gold,
                    shape: const CircleBorder(),
                    child: InkWell(
                      customBorder: const CircleBorder(),
                      onTap: _pick,
                      child: const Padding(padding: EdgeInsets.all(8), child: Icon(Icons.camera_alt, size: 18, color: AppColors.navyDark)),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          _Field(label: 'Prénom', controller: _first),
          const SizedBox(height: 14),
          _Field(label: 'Nom', controller: _last),
          const SizedBox(height: 14),
          _Field(label: 'E-mail', controller: _email, keyboardType: TextInputType.emailAddress),
          const SizedBox(height: 28),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.navy, padding: const EdgeInsets.symmetric(vertical: 15)),
            onPressed: _saving ? null : _save,
            child: _saving
                ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : const Text('Enregistrer', style: TextStyle(fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }
}

class _Field extends StatelessWidget {
  const _Field({required this.label, required this.controller, this.keyboardType});
  final String label;
  final TextEditingController controller;
  final TextInputType? keyboardType;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: AppColors.textPrimary)),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            filled: true,
            fillColor: AppColors.surfaceMuted,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
          ),
        ),
      ],
    );
  }
}
