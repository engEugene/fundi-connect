import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/theme/app_colors.dart';
import '../../../../config/theme/app_text_styles.dart';
import '../../../../core/widgets/profile_widgets.dart';
import '../../../auth/providers/auth_provider.dart';

/// Form for editing the signed-in client's own details (name, phone).
class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final user = ref.read(authProvider).authenticatedUser;
    _nameController = TextEditingController(text: user?.displayName ?? '');
    _phoneController = TextEditingController(text: user?.phone ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final notifier = ref.read(authProvider.notifier);
    final current = ref.read(authProvider).authenticatedUser;
    if (current == null) return _showMessage('Sign in to edit your profile.');

    setState(() => _isSaving = true);

    final updated = current.copyWith(
      displayName: _nameController.text.trim(),
      phone: _phoneController.text.trim(),
    );

    try {
      await ref.read(authRepositoryProvider).updateProfile(updated);
      notifier.updateUser(updated);
      _showMessage('Profile saved successfully');
      if (mounted) context.pop();
    } catch (_) {
      _showMessage('Failed to save profile. Please try again.');
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('My Profile'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
            children: [
              const ProfileFieldLabel('Full Name'),
              TextFormField(
                controller: _nameController,
                textCapitalization: TextCapitalization.words,
                textInputAction: TextInputAction.next,
                style: AppTextStyles.bodyLarge,
                cursorColor: AppColors.primary,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                validator: (value) => (value == null || value.trim().isEmpty)
                    ? 'Enter your full name'
                    : null,
                decoration: const InputDecoration(hintText: 'Jean Pierre Habimana'),
              ),
              const SizedBox(height: 20),

              const ProfileFieldLabel('Phone Number'),
              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                textInputAction: TextInputAction.done,
                style: AppTextStyles.bodyLarge,
                cursorColor: AppColors.primary,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(12),
                ],
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Enter your phone number';
                  }
                  if (value.trim().length < 9) {
                    return 'Enter a valid phone number';
                  }
                  return null;
                },
                decoration: const InputDecoration(
                  hintText: '0781234567',
                  prefixIcon: Icon(
                    Icons.phone_outlined,
                    size: 20,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
              const SizedBox(height: 32),

              ElevatedButton(
                onPressed: _isSaving ? null : _save,
                child: Text(_isSaving ? 'Saving...' : 'Save Changes'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
