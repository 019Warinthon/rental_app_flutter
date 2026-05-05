import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../core/config/colors.dart';
import '../providers/user_provider.dart';
import '../providers/settings_provider.dart';
import '../../booking/providers/booking_provider.dart';
import '../../auth/providers/auth_provider.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<UserProvider>(
      builder: (context, userProvider, _) {
        final user = userProvider.user;
        return Scaffold(
          backgroundColor: AppColors.background,
          body: CustomScrollView(
            slivers: [
              // Premium header
              SliverAppBar(
                expandedHeight: 260,
                pinned: true,
                backgroundColor: AppColors.secondary,
                flexibleSpace: FlexibleSpaceBar(
                  background: _buildProfileHeader(context, user, userProvider),
                ),
                actions: [
                  IconButton(
                    icon: const Icon(
                      LucideIcons.settings,
                      color: Colors.white,
                      size: 22,
                    ),
                    onPressed: () => _showSettingsSheet(context),
                  ),
                ],
              ),

              // Body
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Stats Row
                      if (userProvider.isLoggedIn)
                        Consumer<BookingProvider>(
                          builder: (context, bookingProvider, _) {
                            return _buildStatsRow(context, bookingProvider);
                          },
                        ),
                      if (userProvider.isLoggedIn) const SizedBox(height: 24),

                      // Account section
                      _buildSectionLabel('account'.tr()),
                      const SizedBox(height: 10),
                      if (!userProvider.isLoggedIn)
                        _buildMenuCard([
                          _MenuItem(
                            icon: LucideIcons.logIn,
                            label: 'Log In or Sign Up',
                            subtitle: 'Access your profile and bookings',
                            onTap: () => context.push('/login'),
                          ),
                        ])
                      else
                        _buildMenuCard([
                          _MenuItem(
                            icon: LucideIcons.userCircle2,
                            label: 'Edit Profile',
                            subtitle: 'Update your personal info',
                            onTap: () =>
                                _showEditProfileSheet(context, userProvider),
                          ),
                          _MenuItem(
                            icon: LucideIcons.calendarCheck,
                            label: 'my_bookings'.tr(),
                            subtitle: 'View your stay history',
                            onTap: () => context.push('/my-bookings'),
                          ),
                          _MenuItem(
                            icon: LucideIcons.heart,
                            label: 'Saved Rooms',
                            subtitle: 'Rooms you liked',
                            onTap: () {},
                          ),
                        ]),

                      const SizedBox(height: 20),

                      // Support section
                      _buildSectionLabel('support'.tr()),
                      const SizedBox(height: 10),
                      _buildMenuCard([
                        _MenuItem(
                          icon: LucideIcons.helpCircle,
                          label: 'Help & Support',
                          subtitle: 'FAQ and contact us',
                          onTap: () {},
                        ),
                        _MenuItem(
                          icon: LucideIcons.shieldCheck,
                          label: 'Privacy Policy',
                          subtitle: 'How we use your data',
                          onTap: () {},
                        ),
                        _MenuItem(
                          icon: LucideIcons.info,
                          label: 'About App',
                          subtitle: 'Version 1.0.0',
                          onTap: () {},
                        ),
                      ]),

                      const SizedBox(height: 20),

                      // Logout
                      if (userProvider.isLoggedIn) _buildLogoutButton(context),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildProfileHeader(
    BuildContext context,
    dynamic user,
    UserProvider provider,
  ) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.secondary, Color(0xFF1A1D2E)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(bottom: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              // Avatar
              Stack(
                alignment: Alignment.bottomRight,
                children: [
                  Container(
                    width: 90,
                    height: 90,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.primary.withValues(alpha: 0.2),
                      border: Border.all(
                        color: AppColors.primary.withValues(alpha: 0.5),
                        width: 2,
                      ),
                    ),
                    child: Center(
                      child: provider.isLoggedIn
                          ? Text(
                              user.name.substring(0, 1),
                              style: const TextStyle(
                                fontSize: 36,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                            )
                          : const Icon(
                              LucideIcons.user,
                              size: 40,
                              color: AppColors.primary,
                            ),
                    ),
                  ),
                  if (provider.isLoggedIn)
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: AppColors.accent,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.secondary,
                          width: 2,
                        ),
                      ),
                      child: const Icon(
                        LucideIcons.edit2,
                        size: 14,
                        color: Colors.white,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              // Name & Email
              Text(
                provider.isLoggedIn ? user.name : 'Guest User',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                provider.isLoggedIn ? user.email : 'Log in to unlock features',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.6),
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatsRow(BuildContext context, BookingProvider bookingProvider) {
    final confirmed = bookingProvider.bookings
        .where((b) => b.status.name == 'confirmed')
        .length;
    final total = bookingProvider.bookings.length;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          _buildStat(context, '$total', 'Bookings'),
          _buildDivider(),
          _buildStat(context, '$confirmed', 'Confirmed'),
          _buildDivider(),
          _buildStat(context, '0', 'Reviews'),
        ],
      ),
    );
  }

  Widget _buildStat(BuildContext context, String value, String label) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Container(height: 36, width: 1, color: AppColors.divider);
  }

  Widget _buildSectionLabel(String label) {
    return Text(
      label,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: AppColors.textSecondary,
        letterSpacing: 1.0,
      ),
    );
  }

  Widget _buildMenuCard(List<_MenuItem> items) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: items.asMap().entries.map((entry) {
          final i = entry.key;
          final item = entry.value;
          return Column(
            children: [
              ListTile(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 4,
                ),
                leading: Container(
                  padding: const EdgeInsets.all(9),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(item.icon, size: 18, color: AppColors.primary),
                ),
                title: Text(
                  item.label,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: AppColors.textPrimary,
                  ),
                ),
                subtitle: item.subtitle != null
                    ? Text(
                        item.subtitle!,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      )
                    : null,
                trailing: const Icon(
                  LucideIcons.chevronRight,
                  size: 18,
                  color: AppColors.textSecondary,
                ),
                onTap: item.onTap,
              ),
              if (i < items.length - 1)
                const Divider(
                  height: 1,
                  indent: 56,
                  endIndent: 16,
                  thickness: 0.5,
                ),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: () {
          showDialog(
            context: context,
            builder: (ctx) => AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: const Text(
                'Logout',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              content: const Text('Are you sure you want to logout?'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    Navigator.pop(ctx);
                    // 1. Clear Auth state & storage
                    await context.read<AuthProvider>().logout();
                    // 2. Clear User data in memory
                    if (context.mounted) {
                      context.read<UserProvider>().clearProfile();
                      context.go('/login');
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.error,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text('Logout'),
                ),
              ],
            ),
          );
        },
        icon: const Icon(LucideIcons.logOut, color: AppColors.error, size: 18),
        label: const Text(
          'Logout',
          style: TextStyle(color: AppColors.error, fontWeight: FontWeight.w600),
        ),
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: AppColors.error),
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
    );
  }

  void _showSettingsSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Consumer<SettingsProvider>(
        builder: (ctx, settings, _) => Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: AppColors.divider,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const Text(
                'Settings',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              SwitchListTile(
                title: const Text('Push Notifications'),
                subtitle: const Text('Receive booking updates'),
                value: settings.pushNotifications,
                onChanged: (_) => settings.togglePushNotifications(),
                activeThumbColor: AppColors.primary,
              ),
              SwitchListTile(
                title: const Text('Email Alerts'),
                subtitle: const Text('Get booking confirmations by email'),
                value: settings.emailAlerts,
                onChanged: (_) => settings.toggleEmailAlerts(),
                activeThumbColor: AppColors.primary,
              ),
              SwitchListTile(
                title: const Text('Dark Mode'),
                subtitle: const Text('Use a darker color scheme'),
                value: settings.darkMode,
                onChanged: (_) => settings.toggleDarkMode(),
                activeThumbColor: AppColors.primary,
              ),
              const Divider(),
              ListTile(
                title: const Text('Language'),
                subtitle: Text(
                  context.locale.languageCode == 'th' ? 'ภาษาไทย' : 'English',
                ),
                trailing: const Icon(
                  LucideIcons.languages,
                  color: AppColors.primary,
                ),
                onTap: () {
                  if (context.locale.languageCode == 'en') {
                    context.setLocale(const Locale('th'));
                  } else {
                    context.setLocale(const Locale('en'));
                  }
                  Navigator.pop(context);
                },
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  void _showEditProfileSheet(BuildContext context, UserProvider provider) {
    final nameController = TextEditingController(text: provider.user.name);
    final emailController = TextEditingController(text: provider.user.email);
    final phoneController = TextEditingController(text: provider.user.phone);
    final formKey = GlobalKey<FormState>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.fromLTRB(
            24,
            24,
            24,
            MediaQuery.of(ctx).viewInsets.bottom + 24,
          ),
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Handle bar
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 20),
                    decoration: BoxDecoration(
                      color: AppColors.divider,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const Text(
                  'Edit Profile',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                _buildFormField(
                  controller: nameController,
                  label: 'Full Name',
                  icon: LucideIcons.user,
                  validator: (v) =>
                      v!.trim().isEmpty ? 'Name is required' : null,
                ),
                const SizedBox(height: 14),
                _buildFormField(
                  controller: emailController,
                  label: 'Email',
                  icon: LucideIcons.mail,
                  keyboardType: TextInputType.emailAddress,
                  validator: (v) =>
                      v!.contains('@') ? null : 'Enter a valid email',
                ),
                const SizedBox(height: 14),
                _buildFormField(
                  controller: phoneController,
                  label: 'Phone Number',
                  icon: LucideIcons.phone,
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 24),
                StatefulBuilder(
                  builder: (ctx2, setState) {
                    return SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: provider.isSaving
                            ? null
                            : () async {
                                if (!formKey.currentState!.validate()) return;
                                final success = await provider.updateProfile(
                                  name: nameController.text.trim(),
                                  email: emailController.text.trim(),
                                  phone: phoneController.text.trim(),
                                );
                                if (success && ctx.mounted) {
                                  Navigator.pop(ctx);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Profile updated!'),
                                      backgroundColor: Colors.green,
                                    ),
                                  );
                                }
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: provider.isSaving
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text(
                                'Save Changes',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildFormField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, size: 18, color: AppColors.textSecondary),
        filled: true,
        fillColor: AppColors.background,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.divider),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.divider),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
      ),
    );
  }
}

class _MenuItem {
  final IconData icon;
  final String label;
  final String? subtitle;
  final VoidCallback onTap;

  const _MenuItem({
    required this.icon,
    required this.label,
    this.subtitle,
    required this.onTap,
  });
}
