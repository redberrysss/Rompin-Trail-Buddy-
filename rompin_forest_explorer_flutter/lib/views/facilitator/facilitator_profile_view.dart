import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../../viewmodels/auth_viewmodel.dart';

class FacilitatorProfileView extends StatefulWidget {
  const FacilitatorProfileView({super.key});

  @override
  State<FacilitatorProfileView> createState() => _FacilitatorProfileViewState();
}

class _FacilitatorProfileViewState extends State<FacilitatorProfileView> {
  @override
  Widget build(BuildContext context) {
    final authVM = context.watch<AuthViewModel>();
    final user = authVM.user;
    final userName = user?.displayName ?? 'Fasilitator';
    final userEmail = user?.email ?? '';

    return Scaffold(
      backgroundColor: AppTheme.creamBackground,
      appBar: AppBar(
        title: const Text('Profil'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppTheme.paddingStandard),
          child: Column(
            children: [
              const SizedBox(height: AppTheme.paddingLarge),
              _buildProfileHeader(userName, userEmail),
              const SizedBox(height: AppTheme.paddingLarge),
              _buildStatsRow(),
              const SizedBox(height: AppTheme.paddingLarge),
              _buildSignOutButton(authVM),
              const SizedBox(height: AppTheme.paddingSmall),
              _buildDeleteAccountButton(authVM),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeader(String name, String email) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppTheme.paddingLarge),
      decoration: BoxDecoration(
        color: AppTheme.cardBackground,
        borderRadius: BorderRadius.circular(AppTheme.radiusCard),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppTheme.forestGreen.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.settings_outlined,
              size: 40,
              color: AppTheme.forestGreen,
            ),
          ),
          const SizedBox(height: AppTheme.paddingMedium),
          Text(
            name,
            style: const TextStyle(
              fontSize: AppTheme.fontSizeHeadline,
              fontWeight: AppTheme.weightBold,
              color: AppTheme.onSurface,
            ),
          ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: AppTheme.forestGreen.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Text(
              'Fasilitator',
              style: TextStyle(
                fontSize: AppTheme.fontSizeCaption,
                fontWeight: AppTheme.weightSemiBold,
                color: AppTheme.forestGreen,
              ),
            ),
          ),
          if (email.isNotEmpty) ...[
            const SizedBox(height: AppTheme.paddingSmall),
            Text(
              email,
              style: const TextStyle(
                fontSize: AppTheme.fontSizeCaption,
                color: AppTheme.secondaryText,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatsRow() {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            icon: Icons.forest,
            label: 'Aktiviti',
            value: '4',
            color: AppTheme.forestGreen,
          ),
        ),
        const SizedBox(width: AppTheme.paddingSmall),
        Expanded(
          child: _buildStatCard(
            icon: Icons.star_outline,
            label: 'Sesi',
            value: '--',
            color: AppTheme.softOrange,
          ),
        ),
        const SizedBox(width: AppTheme.paddingSmall),
        Expanded(
          child: _buildStatCard(
            icon: Icons.emoji_events_outlined,
            label: 'Pingat',
            value: '--',
            color: AppTheme.softYellow,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: AppTheme.paddingMedium),
      decoration: BoxDecoration(
        color: AppTheme.cardBackground,
        borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: AppTheme.fontSizeBody,
              fontWeight: AppTheme.weightBold,
              color: color,
            ),
          ),
          Text(
            label,
            style: const TextStyle(
              fontSize: AppTheme.fontSizeSmall,
              color: AppTheme.secondaryText,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSignOutButton(AuthViewModel authVM) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: () async {
          print('[FacilitatorProfile] Sign out tapped');
          final confirmed = await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
              ),
              title: const Text('Log Keluar'),
              content: const Text('Anda pasti mahu log keluar?'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('Batal'),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: const Text(
                    'Log Keluar',
                    style: TextStyle(color: AppTheme.gentleCoral),
                  ),
                ),
              ],
            ),
          );

          if (confirmed == true && context.mounted) {
            await authVM.signOut();
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.gentleCoral,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTheme.radiusButton),
          ),
        ),
        child: const Text(
          'Log Keluar',
          style: TextStyle(
            fontSize: AppTheme.fontSizeBody,
            fontWeight: AppTheme.weightSemiBold,
          ),
        ),
      ),
    );
  }

  Widget _buildDeleteAccountButton(AuthViewModel authVM) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        icon: const Icon(Icons.delete_forever_outlined),
        label: const Text('Padam Akaun'),
        style: OutlinedButton.styleFrom(foregroundColor: AppTheme.gentleCoral),
        onPressed: authVM.isLoading
            ? null
            : () async {
                final confirmed = await showDialog<bool>(
                  context: context,
                  builder: (dialogContext) => AlertDialog(
                    title: const Text('Padam Akaun'),
                    content: const Text(
                      'Semua data, kemajuan dan gambar milik akaun ini akan '
                      'dipadam secara kekal. Tindakan ini tidak boleh dibatalkan.',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(dialogContext, false),
                        child: const Text('Batal'),
                      ),
                      FilledButton(
                        onPressed: () => Navigator.pop(dialogContext, true),
                        style: FilledButton.styleFrom(
                          backgroundColor: AppTheme.gentleCoral,
                        ),
                        child: const Text('Padam Kekal'),
                      ),
                    ],
                  ),
                );
                if (confirmed == true) await authVM.deleteAccount();
              },
      ),
    );
  }
}
