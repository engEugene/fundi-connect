import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../../config/theme/app_colors.dart';
import '../../../config/theme/app_text_styles.dart';
import '../data/profile_mock.dart';
import '../widgets/profile_widgets.dart';


/// Form for editing the signed-in tradesman's own profile. Saving is a no-op
/// until Firebase lands — the button only validates and shows a confirmation.
class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameController;
  late final TextEditingController _rateController;
  late final TextEditingController _bioController;

  late String _category;
  late String _district;
  late List<String> _portfolio;

  @override
  void initState() {
    super.initState();
    final user = ProfileMock.currentUser;

    _nameController = TextEditingController(text: user.name);
    _rateController = TextEditingController(
      text: user.hourlyRate.toStringAsFixed(0),
    );
    _bioController = TextEditingController(text: user.about ?? '');
    _category = user.category;
    _district = ProfileMock.district;
    _portfolio = List<String>.from(user.pastWorkUrls);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _rateController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;

    // TODO: persist to Firestore once the backend phase starts.
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Profile saved')),
    );
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
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
            children: [
              Center(child: _AvatarPicker(imageUrl: ProfileMock.currentUser.imageUrl)),
              const SizedBox(height: 24),
              VerifiedBadge(
                label: 'Verified Tradesman',
                isVerified: ProfileMock.currentUser.isVerified,
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
                decoration: const InputDecoration(hintText: 'Jean Pierre Habimana'),
              ),
              const SizedBox(height: 20),

              const ProfileFieldLabel('Trade Category'),
              DropdownButtonFormField<String>(
                initialValue: _category,
                icon: const Icon(Icons.keyboard_arrow_down),
                style: AppTextStyles.bodyLarge,
                // keep the popup a compact card instead of a full-bleed list
                // that swallows the form behind it
                menuMaxHeight: 220,
                borderRadius: BorderRadius.circular(12),
                elevation: 2,
                decoration: const InputDecoration(),
                items: [
                  for (final category in ProfileMock.tradeCategories)
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
                onPressed: _save,
                child: const Text('Save Changes'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // TODO: swap for image_picker once uploads are wired to Cloud Storage.
  void _addPhoto() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Photo upload comes with the backend phase')),
    );
  }
}

/// Circular avatar with the gold camera badge from the design.
class _AvatarPicker extends StatelessWidget {
  const _AvatarPicker({required this.imageUrl});

  final String imageUrl;

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
                child: Image.network(
                  imageUrl,
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

/// Three-across grid of portfolio tiles, always showing one empty slot.
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
