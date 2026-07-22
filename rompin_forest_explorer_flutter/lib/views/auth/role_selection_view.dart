import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class RoleSelectionView extends StatelessWidget {
  const RoleSelectionView({super.key, required this.onSelectRole});

  final void Function(String role) onSelectRole;

  @override
  Widget build(BuildContext context) {
    print('[RoleSelectionView] build');

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFE8F5E9),
              Color(0xFFF1F8E9),
              AppTheme.creamBackground,
            ],
          ),
        ),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) => SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: AppTheme.paddingLarge,
                vertical: AppTheme.paddingLarge,
              ),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight - AppTheme.paddingLarge * 2,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // ── App title ──
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: AppTheme.forestGreen.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.eco,
                        size: 40,
                        color: AppTheme.forestGreen,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Rompin Forest Explorer',
                      style: TextStyle(
                        fontSize: AppTheme.fontSizeTitle,
                        fontWeight: AppTheme.weightBold,
                        color: AppTheme.onSurface,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Siapa anda?',
                      style: TextStyle(
                        fontSize: AppTheme.fontSizeBody,
                        color: AppTheme.secondaryText,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 48),
                    // ── Role cards ──
                    _RoleCard(
                      label: 'Fasilitator',
                      subtitle: 'Urus peserta dan lihat kemajuan',
                      icon: Icons.person,
                      gradient: AppTheme.primaryGradient,
                      onTap: () {
                        print('[RoleSelectionView] selected: fasilitator');
                        onSelectRole('fasilitator');
                      },
                    ),
                    const SizedBox(height: 16),
                    _RoleCard(
                      label: 'Peserta',
                      subtitle: 'Teroka alam dan lengkapkan aktiviti',
                      icon: Icons.person,
                      gradient: const LinearGradient(
                        colors: [AppTheme.softBlue, AppTheme.lavender],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      onTap: () {
                        print('[RoleSelectionView] selected: pelajar');
                        onSelectRole('pelajar');
                      },
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _RoleCard extends StatelessWidget {
  const _RoleCard({
    required this.label,
    required this.subtitle,
    required this.icon,
    required this.gradient,
    required this.onTap,
  });

  final String label;
  final String subtitle;
  final IconData icon;
  final Gradient gradient;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(AppTheme.paddingLarge),
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(AppTheme.radiusCard),
          boxShadow: [
            BoxShadow(
              color: AppTheme.forestGreen.withValues(alpha: 0.2),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.25),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, color: Colors.white, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: AppTheme.fontSizeHeadline,
                      fontWeight: AppTheme.weightSemiBold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: AppTheme.fontSizeCaption,
                      color: Colors.white.withValues(alpha: 0.85),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: Colors.white.withValues(alpha: 0.8),
              size: 28,
            ),
          ],
        ),
      ),
    );
  }
}
