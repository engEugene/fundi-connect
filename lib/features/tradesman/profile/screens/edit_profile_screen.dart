import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../config/theme/app_colors.dart';
import '../../../../config/theme/app_text_styles.dart';
import '../../../../core/models/worker.dart';
import '../../../../core/widgets/profile_widgets.dart';
import '../../../auth/providers/auth_provider.dart';
// The worker profile repository + category list live under client/profile and
// client/discover per ARCHITECTURE.md §6, even though only tradesmen edit here.
import '../../../client/discover/providers/discover_provider.dart';
import '../../../client/profile/providers/profile_provider.dart';
import '../data/profile_mock.dart';

class TradesmanEditProfileScreen extends ConsumerStatefulWidget {
  const TradesmanEditProfileScreen({super.key});

  @override
  ConsumerState<TradesmanEditProfileScreen> createState() =>
      _TradesmanEditProfileScreenState();
}

class _TradesmanEditProfileScreenState
    extends ConsumerState<TradesmanEditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _picker = ImagePicker();

  final _nameController = TextEditingController();
  final _rateController = TextEditingController();
  final _bioController = TextEditingController();

  String _category = ProfileMock.tradeCategories.first;
  String _district = ProfileMock.districts.first;
  List<String> _portfolio = [];
  String? _avatarUrl;
  bool _isSaving = false;
  bool _hydrated = false;

  /// Holds fields the form cannot edit (rating, jobsDone, verification) so
  /// [_save] writes them back untouched instead of resetting them.
  Worker? _loadedProfile;

  @override
  void dispose() {
    _nameController.dispose();
    _rateController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  void _hydrate(Worker? worker) {
    _hydrated = true;
    _loadedProfile = worker;
    if (worker == null) {
      _nameController.text =
          ref.read(authProvider).authenticatedUser?.displayName ?? '';
      return;
    }

    _nameController.text = worker.name;
    _rateController.text = worker.hourlyRate > 0
        ? worker.hourlyRate.toStringAsFixed(0)
        : '';
    _bioController.text = worker.about ?? '';
    _portfolio = List<String>.from(worker.pastWorkUrls);
    _avatarUrl = worker.imageUrl.isEmpty ? null : worker.imageUrl;
    if (ProfileMock.districts.contains(worker.district)) {
      _district = worker.district!;
    }
    _category = worker.category;
  }

  String? get _uid => ref.read(authProvider).authenticatedUser?.uid;

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _pickAvatar() async {
    final uid = _uid;
    if (uid == null) return _showMessage('Sign in to edit your profile.');

    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile == null) return;

    try {
      final url = await ref
          .read(workerProfileRepositoryProvider)
          .uploadAvatar(uid: uid, file: File(pickedFile.path));
      setState(() => _avatarUrl = url);
    } catch (_) {
      _showMessage('Photo upload failed. Please try again.');
    }
  }

  Future<void> _addPhoto() async {
    final uid = _uid;
    if (uid == null) return _showMessage('Sign in to edit your profile.');

    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile == null) return;

    try {
      final url = await ref
          .read(workerProfileRepositoryProvider)
          .uploadPortfolioPhoto(uid: uid, file: File(pickedFile.path));
      setState(() => _portfolio.add(url));
    } catch (_) {
      _showMessage('Photo upload failed. Please try again.');
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final uid = _uid;
    if (uid == null) return _showMessage('Sign in to edit your profile.');

    setState(() => _isSaving = true);

    final previous = _loadedProfile;
    final updatedWorker = Worker(
      id: uid,
      name: _nameController.text.trim(),
      role: _category,
      category: _category,
      imageUrl: _avatarUrl ?? '',
      rating: previous?.rating ?? 0,
      reviewCount: previous?.reviewCount ?? 0,
      distanceKm: previous?.distanceKm ?? 0,
      hourlyRate: double.tryParse(_rateController.text.trim()) ?? 0,
      isVerified: previous?.isVerified ?? false,
      isOpen: previous?.isOpen ?? true,
      about: _bioController.text.trim(),
      jobsDone: previous?.jobsDone,
      yearsExp: previous?.yearsExp,
      district: _district,
      pastWorkUrls: _portfolio,
    );

    try {
      await ref
          .read(workerProfileRepositoryProvider)
          .updateWorkerProfile(updatedWorker);
      ref.invalidate(workerProfileProvider);

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
    final profileAsync = ref.watch(workerProfileProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Edit Profile'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: profileAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
        error: (_, _) => const Center(
          child: Text("Couldn't load your profile. Please try again."),
        ),
        data: (worker) {
          if (!_hydrated) _hydrate(worker);
          return _buildForm(context);
        },
      ),
    );
  }

  Widget _buildForm(BuildContext context) {
    // `_category` is folded in so a stored trade that is no longer an active
    // category still renders, instead of tripping the dropdown's assert.
    final remote = ref
        .watch(categoriesStreamProvider)
        .valueOrNull
        ?.map((c) => c.name);
    final tradeOptions = <String>{
      ...(remote == null || remote.isEmpty
          ? ProfileMock.tradeCategories
          : remote),
      _category,
    }.toList();

    return SafeArea(
      child: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
          children: [
            Center(
              child: GestureDetector(
                onTap: _pickAvatar,
                child: _AvatarPicker(imageUrl: _avatarUrl),
              ),
            ),
            const SizedBox(height: 24),
            VerifiedBadge(
              label: 'Verified Tradesman',
              isVerified: _loadedProfile?.isVerified ?? false,
            ),
            const SizedBox(height: 24),
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
              decoration: const InputDecoration(
                hintText: 'Jean Pierre Habimana',
              ),
            ),
            const SizedBox(height: 20),
            const ProfileFieldLabel('Trade Category'),
            DropdownButtonFormField<String>(
              initialValue: _category,
              icon: const Icon(Icons.keyboard_arrow_down),
              style: AppTextStyles.bodyLarge,
              menuMaxHeight: 220,
              borderRadius: BorderRadius.circular(12),
              elevation: 2,
              decoration: const InputDecoration(),
              items: [
                for (final category in tradeOptions)
                  DropdownMenuItem(value: category, child: Text(category)),
              ],
              onChanged: (value) {
                if (value != null) setState(() => _category = value);
              },
            ),
            const SizedBox(height: 20),
            const ProfileFieldLabel('Hourly Rate (Rwf)'),
            TextFormField(
              controller: _rateController,
              keyboardType: TextInputType.number,
              textInputAction: TextInputAction.next,
              style: AppTextStyles.bodyLarge,
              cursorColor: AppColors.primary,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(7),
              ],
              validator: (value) {
                final rate = int.tryParse(value?.trim() ?? '');
                if (rate == null || rate <= 0) return 'Enter your hourly rate';
                return null;
              },
              decoration: const InputDecoration(hintText: '6,000'),
            ),
            const SizedBox(height: 20),
            const ProfileFieldLabel('Location / District'),
            DropdownButtonFormField<String>(
              initialValue: _district,
              icon: const Icon(Icons.keyboard_arrow_down),
              style: AppTextStyles.bodyLarge,
              menuMaxHeight: 220,
              borderRadius: BorderRadius.circular(12),
              elevation: 2,
              decoration: const InputDecoration(
                prefixIcon: Icon(
                  Icons.location_on_outlined,
                  size: 20,
                  color: AppColors.textSecondary,
                ),
              ),
              items: [
                for (final district in ProfileMock.districts)
                  DropdownMenuItem(value: district, child: Text(district)),
              ],
              onChanged: (value) {
                if (value != null) setState(() => _district = value);
              },
            ),
            const SizedBox(height: 20),
            const ProfileFieldLabel('Bio / Description'),
            TextFormField(
              controller: _bioController,
              maxLines: 4,
              maxLength: 300,
              textCapitalization: TextCapitalization.sentences,
              style: AppTextStyles.bodyLarge,
              cursorColor: AppColors.primary,
              decoration: const InputDecoration(
                hintText: 'Licensed electrician with 6+ years of experience...',
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: 12),
            ProfileSectionTitle(
              'Portfolio Photos',
              trailing: TextButton.icon(
                onPressed: _addPhoto,
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Add'),
              ),
            ),
            const SizedBox(height: 12),
            _PortfolioGrid(
              imageUrls: _portfolio,
              onAdd: _addPhoto,
              onRemove: (index) => setState(() => _portfolio.removeAt(index)),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _isSaving ? null : _save,
              child: _isSaving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        color: AppColors.onPrimary,
                        strokeWidth: 2,
                      ),
                    )
                  : const Text('Save Changes'),
            ),
          ],
        ),
      ),
    );
  }
}

class _AvatarPicker extends StatelessWidget {
  const _AvatarPicker({required this.imageUrl});

  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Stack(
          alignment: Alignment.bottomRight,
          children: [
            Container(
              width: 104,
              height: 104,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.tertiaryDark, width: 3),
              ),
              child: ClipOval(
                child: imageUrl == null
                    ? Container(
                        color: AppColors.tertiary,
                        child: const Icon(
                          Icons.person,
                          size: 48,
                          color: AppColors.textMuted,
                        ),
                      )
                    : Image.network(
                        imageUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          color: AppColors.tertiary,
                          child: const Icon(
                            Icons.person,
                            size: 48,
                            color: AppColors.textMuted,
                          ),
                        ),
                      ),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                color: AppColors.secondary,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.background, width: 2),
              ),
              child: const Icon(
                Icons.photo_camera,
                size: 16,
                color: AppColors.onSecondary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Text('Tap to upload photo', style: AppTextStyles.bodySmall),
      ],
    );
  }
}

class _PortfolioGrid extends StatelessWidget {
  const _PortfolioGrid({
    required this.imageUrls,
    required this.onAdd,
    required this.onRemove,
  });

  final List<String> imageUrls;
  final VoidCallback onAdd;
  final ValueChanged<int> onRemove;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: imageUrls.length + 1,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemBuilder: (context, index) {
        if (index == imageUrls.length) {
          return PortfolioTile(onTap: onAdd);
        }
        return PortfolioTile(
          imageUrl: imageUrls[index],
          onRemove: () => onRemove(index),
        );
      },
    );
  }
}
