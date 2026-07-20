import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../config/routes/route_names.dart';
import '../../../config/theme/app_colors.dart';
import '../../../config/theme/app_text_styles.dart';
import '../../auth/providers/auth_provider.dart';
import '../data/profile_mock.dart';
import '../widgets/profile_widgets.dart';

/// Owner: Profile team (Feature 5)
///
/// Preferences, role switching and log out. Toggles are local state only until
/// Firebase lands.
class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _availableForWork = true;
  bool _pushNotifications = true;
  bool _emailUpdates = false;

  @override
  Widget build(BuildContext context) {
    final user = ProfileMock.currentUser;
    final role = ref.watch(authProvider).selectedRole;
    final isWorker = role == UserRole.worker;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Settings'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
          children: [
            _AccountCard(
              name: user.name,
              subtitle: ProfileMock.phone,
              imageUrl: user.imageUrl,
              onTap: () => context.push(RouteNames.editProfile),
            ),
            const SizedBox(height: 24),

            SettingsGroup(
              title: 'Account',
              children: [
                SettingsTile(
                  icon: Icons.person_outline,
                  label: 'Edit Profile',
                  subtitle: 'Name, photo, bio and skills',
                  onTap: () => context.push(RouteNames.editProfile),
                ),
                SettingsTile(
                  icon: Icons.mail_outline,
                  label: 'Email',
                  subtitle: ProfileMock.email,
                  onTap: () {},
                ),
                SettingsTile(
                  icon: Icons.lock_outline,
                  label: 'Change Password',
                  onTap: () => context.push(RouteNames.forgotPassword),
                ),
              ],
            ),
            const SizedBox(height: 24),

            SettingsGroup(
              title: 'Preferences',
              children: [
                if (isWorker)
                  SettingsTile(
                    icon: Icons.work_outline,
                    label: 'Available for Work',
                    subtitle: _availableForWork
                        ? 'Clients can book you'
                        : 'Hidden from search results',
                    trailing: Switch(
                      value: _availableForWork,
                      onChanged: (value) =>
                          setState(() => _availableForWork = value),
                    ),
                  ),
                SettingsTile(
                  icon: Icons.notifications_none,
                  label: 'Push Notifications',
                  trailing: Switch(
                    value: _pushNotifications,
                    onChanged: (value) =>
                        setState(() => _pushNotifications = value),
                  ),
                ),
                SettingsTile(
                  icon: Icons.markunread_mailbox_outlined,
                  label: 'Email Updates',
                  trailing: Switch(
                    value: _emailUpdates,
                    onChanged: (value) => setState(() => _emailUpdates = value),
                  ),
                ),
                SettingsTile(
                  icon: Icons.language,
                  label: 'Language',
                  subtitle: 'English',
                  onTap: () {},
                ),
              ],
            ),
            const SizedBox(height: 24),

            SettingsGroup(
              title: 'Support',
              children: [
                SettingsTile(
                  icon: Icons.help_outline,
                  label: 'Help Center',
                  onTap: () {},
                ),
                SettingsTile(
                  icon: Icons.description_outlined,
                  label: 'Terms & Privacy',
                  onTap: () {},
                ),
                SettingsTile(
                  icon: Icons.info_outline,
                  label: 'App Version',
                  subtitle: '1.0.0',
                ),
              ],
            ),
            const SizedBox(height: 24),

            _RoleSwitcher(
              isWorker: isWorker,
              onSwitch: () {
                ref
                    .read(authProvider.notifier)
                    .selectRole(isWorker ? UserRole.client : UserRole.worker);
              },
            ),
            const SizedBox(height: 12),

            OutlinedButton.icon(
              onPressed: _confirmLogOut,
              icon: const Icon(Icons.logout, size: 20),
              label: const Text('Log Out'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.error,
                side: const BorderSide(color: AppColors.error),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmLogOut() async {
    final shouldLogOut = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('Log out?', style: AppTextStyles.titleLarge),
        content: Text(
          'You will need to sign in again to book or manage jobs.',
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Log Out'),
          ),
        ],
      ),
    );

    if (shouldLogOut != true || !mounted) return;

    ref.read(authProvider.notifier).signOut();
    if (mounted) context.go(RouteNames.onboarding);
  }
}

/// Navy summary card at the top, echoing the profile header.
class _AccountCard extends StatelessWidget {
  const _AccountCard({
    required this.name,
    required this.subtitle,
    required this.imageUrl,
    required this.onTap,
  });

  final String name;
  final String subtitle;
  final String imageUrl;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.primary,
      borderRadius: BorderRadius.circular(20),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              ClipOval(
                child: Image.network(
                  imageUrl,
                  width: 56,
                  height: 56,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    width: 56,
                    height: 56,
                    color: AppColors.primaryLight,
                    child: const Icon(
                      Icons.person,
                      color: AppColors.onPrimary,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: AppTextStyles.titleMedium.copyWith(
                        color: AppColors.onPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.onPrimary.withValues(alpha: 0.8),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: AppColors.onPrimary.withValues(alpha: 0.8),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Gold-accented card for flipping between the client and tradesman apps.
class _RoleSwitcher extends StatelessWidget {
  const _RoleSwitcher({required this.isWorker, required this.onSwitch});

  final bool isWorker;
  final VoidCallback onSwitch;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.secondary.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.secondary.withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isWorker ? 'Tradesman account' : 'Client account',
                  style: AppTextStyles.titleSmall,
                ),
                const SizedBox(height: 4),
                Text(
                  isWorker
                      ? 'Switch to browse and book other tradesmen.'
                      : 'Switch to offer your services and receive jobs.',
                  style: AppTextStyles.bodySmall,
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          TextButton(
            onPressed: onSwitch,
            style: TextButton.styleFrom(
              foregroundColor: AppColors.primary,
              backgroundColor: AppColors.secondary,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              shape: const StadiumBorder(),
            ),
            child: const Text('Switch'),
          ),
        ],
      ),
    );
  }
}
