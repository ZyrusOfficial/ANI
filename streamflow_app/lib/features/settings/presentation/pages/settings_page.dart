import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/widgets/glass_container.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  // Settings state
  bool _notificationsEnabled = true;
  bool _autoplayEnabled = true;
  bool _downloadOnWifiOnly = true;
  bool _dataSaverMode = false;
  String _defaultQuality = '1080p';
  String _downloadQuality = '720p';
  String _subtitleLanguage = 'English';

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: isMobile ? 16 : 48,
            vertical: 24,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context),
              const SizedBox(height: 40),
              
              // Account Section
              _buildSection('Account', [
                _buildSettingTile(
                  icon: Icons.person_outline,
                  title: 'Edit Profile',
                  subtitle: 'Change your name, bio, and avatar',
                  onTap: () {},
                ),
                _buildSettingTile(
                  icon: Icons.security,
                  title: 'Privacy & Security',
                  subtitle: 'Password, 2FA, and login sessions',
                  onTap: () {},
                ),
                _buildSettingTile(
                  icon: Icons.credit_card,
                  title: 'Subscription',
                  subtitle: 'Premium • Renews Feb 2025',
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      'ACTIVE',
                      style: AppTextStyles.labelSmall.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 9,
                      ),
                    ),
                  ),
                  onTap: () {},
                ),
              ]),
              const SizedBox(height: 32),
              
              // Playback Section
              _buildSection('Playback', [
                _buildToggleTile(
                  icon: Icons.play_circle_outline,
                  title: 'Autoplay Next Episode',
                  subtitle: 'Automatically play the next episode',
                  value: _autoplayEnabled,
                  onChanged: (v) => setState(() => _autoplayEnabled = v),
                ),
                _buildDropdownTile(
                  icon: Icons.hd,
                  title: 'Default Quality',
                  subtitle: 'Streaming quality on cellular/wifi',
                  value: _defaultQuality,
                  options: ['Auto', '480p', '720p', '1080p', '4K'],
                  onChanged: (v) => setState(() => _defaultQuality = v!),
                ),
                _buildDropdownTile(
                  icon: Icons.subtitles,
                  title: 'Subtitle Language',
                  subtitle: 'Default subtitle language',
                  value: _subtitleLanguage,
                  options: ['Off', 'English', 'Japanese', 'Spanish', 'French'],
                  onChanged: (v) => setState(() => _subtitleLanguage = v!),
                ),
              ]),
              const SizedBox(height: 32),
              
              // Downloads Section
              _buildSection('Downloads', [
                _buildDropdownTile(
                  icon: Icons.download,
                  title: 'Download Quality',
                  subtitle: 'Quality for offline downloads',
                  value: _downloadQuality,
                  options: ['480p', '720p', '1080p'],
                  onChanged: (v) => setState(() => _downloadQuality = v!),
                ),
                _buildToggleTile(
                  icon: Icons.wifi,
                  title: 'Download on Wi-Fi Only',
                  subtitle: 'Prevent downloads on mobile data',
                  value: _downloadOnWifiOnly,
                  onChanged: (v) => setState(() => _downloadOnWifiOnly = v),
                ),
                _buildToggleTile(
                  icon: Icons.data_saver_on,
                  title: 'Data Saver Mode',
                  subtitle: 'Reduce data usage while streaming',
                  value: _dataSaverMode,
                  onChanged: (v) => setState(() => _dataSaverMode = v),
                ),
              ]),
              const SizedBox(height: 32),
              
              // Notifications Section
              _buildSection('Notifications', [
                _buildToggleTile(
                  icon: Icons.notifications_outlined,
                  title: 'Push Notifications',
                  subtitle: 'New episodes and recommendations',
                  value: _notificationsEnabled,
                  onChanged: (v) => setState(() => _notificationsEnabled = v),
                ),
              ]),
              const SizedBox(height: 32),
              
              // About Section
              _buildSection('About', [
                _buildSettingTile(
                  icon: Icons.info_outline,
                  title: 'App Version',
                  subtitle: '1.0.0 (Build 2024.02.06)',
                  onTap: () {},
                ),
                _buildSettingTile(
                  icon: Icons.description_outlined,
                  title: 'Terms of Service',
                  onTap: () {},
                ),
                _buildSettingTile(
                  icon: Icons.privacy_tip_outlined,
                  title: 'Privacy Policy',
                  onTap: () {},
                ),
                _buildSettingTile(
                  icon: Icons.help_outline,
                  title: 'Help & Support',
                  onTap: () {},
                ),
              ]),
              const SizedBox(height: 40),
              
              // Logout Button
              Center(
                child: TextButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.logout, color: AppColors.primary),
                  label: Text(
                    'Sign Out',
                    style: AppTextStyles.labelLarge.copyWith(color: AppColors.primary),
                  ),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        GestureDetector(
          onTap: () => Navigator.of(context).pop(),
          child: Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.05),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
            ),
            child: const Center(
              child: Icon(Icons.arrow_back, color: Colors.white, size: 16),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          'Settings',
          style: AppTextStyles.heading.copyWith(
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title.toUpperCase(),
          style: AppTextStyles.labelSmall.copyWith(
            color: AppColors.textSecondary,
            letterSpacing: 1.5,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        GlassContainer(
          color: Colors.white.withValues(alpha: 0.03),
          blur: 10,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
          padding: EdgeInsets.zero,
          child: Column(
            children: children.asMap().entries.map((entry) {
              final index = entry.key;
              final child = entry.value;
              return Column(
                children: [
                  child,
                  if (index < children.length - 1)
                    Divider(
                      color: Colors.white.withValues(alpha: 0.05),
                      height: 1,
                      indent: 56,
                    ),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildSettingTile({
    required IconData icon,
    required String title,
    String? subtitle,
    Widget? trailing,
    required VoidCallback onTap,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: Colors.white, size: 20),
      ),
      title: Text(
        title,
        style: AppTextStyles.titleSmall.copyWith(fontWeight: FontWeight.w500),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle,
              style: AppTextStyles.labelSmall.copyWith(
                color: AppColors.textSecondary,
              ),
            )
          : null,
      trailing: trailing ?? Icon(
        Icons.chevron_right,
        color: Colors.white.withValues(alpha: 0.3),
      ),
      onTap: onTap,
    );
  }

  Widget _buildToggleTile({
    required IconData icon,
    required String title,
    String? subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: Colors.white, size: 20),
      ),
      title: Text(
        title,
        style: AppTextStyles.titleSmall.copyWith(fontWeight: FontWeight.w500),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle,
              style: AppTextStyles.labelSmall.copyWith(
                color: AppColors.textSecondary,
              ),
            )
          : null,
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: AppColors.primary,
        trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
        inactiveThumbColor: Colors.white.withValues(alpha: 0.5),
        inactiveTrackColor: Colors.white.withValues(alpha: 0.1),
      ),
    );
  }

  Widget _buildDropdownTile({
    required IconData icon,
    required String title,
    String? subtitle,
    required String value,
    required List<String> options,
    required ValueChanged<String?> onChanged,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: Colors.white, size: 20),
      ),
      title: Text(
        title,
        style: AppTextStyles.titleSmall.copyWith(fontWeight: FontWeight.w500),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle,
              style: AppTextStyles.labelSmall.copyWith(
                color: AppColors.textSecondary,
              ),
            )
          : null,
      trailing: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: value,
            icon: const Icon(Icons.keyboard_arrow_down, color: Colors.white, size: 18),
            dropdownColor: const Color(0xFF1A1A1A),
            style: AppTextStyles.labelMedium,
            items: options.map((option) => DropdownMenuItem(
              value: option,
              child: Text(option),
            )).toList(),
            onChanged: onChanged,
          ),
        ),
      ),
    );
  }
}
