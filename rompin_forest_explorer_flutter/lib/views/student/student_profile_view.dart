import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../services/activity_data_service.dart';
import '../../models/student_activity_progress.dart';

class StudentProfileView extends StatefulWidget {
  const StudentProfileView({
    super.key,
    required this.participantID,
    required this.participantName,
  });

  final String participantID;
  final String participantName;

  @override
  State<StudentProfileView> createState() => _StudentProfileViewState();
}

class _StudentProfileViewState extends State<StudentProfileView> {
  int _discoveryCount = 0;
  Map<int, StudentActivityProgress> _progress = const {};
  bool _isLoadingStats = true;
  String? _statsError;
  StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>? _subscription;

  int get _completedCount =>
      _progress.values.where((activity) => activity.isCompleted).length;
  int get _activityCount =>
      _progress.values.where((activity) => activity.progress > 0).length;

  List<Map<String, dynamic>> get _badges => [
    {'emoji': '🌳', 'title': 'Penjelajah', 'unlocked': _discoveryCount >= 1},
    {'emoji': '🌿', 'title': 'Sahabat', 'unlocked': _activityCount >= 1},
    {'emoji': '🔍', 'title': 'Detektif', 'unlocked': _discoveryCount >= 5},
    {
      'emoji': '🎨',
      'title': 'Artis',
      'unlocked': _progress[4]?.isCompleted == true,
    },
    {'emoji': '⭐', 'title': 'Juara', 'unlocked': _completedCount >= 4},
    {
      'emoji': '🏆',
      'title': 'Master',
      'unlocked': _completedCount >= 4 && _discoveryCount >= 10,
    },
  ];

  @override
  void initState() {
    super.initState();
    _loadStats();
    _subscription = FirebaseFirestore.instance
        .collection('users')
        .doc(widget.participantID)
        .snapshots()
        .skip(1)
        .listen((_) {
          if (mounted && !_isLoadingStats) _loadStats();
        });
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  Future<void> _loadStats() async {
    if (mounted) {
      setState(() {
        _isLoadingStats = true;
        _statsError = null;
      });
    }
    try {
      final discoveriesFuture = ActivityDataService.instance
          .loadStudentDiscoveries(widget.participantID);
      final progressFuture = ActivityDataService.instance.loadStudentProgress(
        widget.participantID,
      );
      final discoveries = await discoveriesFuture;
      final progress = await progressFuture;
      if (!mounted) return;
      setState(() {
        _discoveryCount = discoveries.items.length;
        _progress = progress;
        _isLoadingStats = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _statsError = error.toString();
        _isLoadingStats = false;
      });
    }
  }

  void _showLogoutDialog(BuildContext context, AuthViewModel authVM) {
    print('[StudentProfileView] showing logout dialog');
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
        ),
        title: const Text(
          'Log Keluar',
          style: TextStyle(
            fontSize: AppTheme.fontSizeBody,
            fontWeight: AppTheme.weightSemiBold,
            color: AppTheme.onSurface,
          ),
        ),
        content: const Text(
          'Anda akan log keluar dari aplikasi.',
          style: TextStyle(
            fontSize: AppTheme.fontSizeBody,
            color: AppTheme.secondaryText,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              print('[StudentProfileView] logout cancelled');
              Navigator.of(ctx).pop();
            },
            child: const Text(
              'Batal',
              style: TextStyle(
                color: AppTheme.secondaryText,
                fontWeight: AppTheme.weightMedium,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              print('[StudentProfileView] logout confirmed');
              Navigator.of(ctx).pop();
              authVM.signOut();
            },
            child: const Text(
              'Log Keluar',
              style: TextStyle(
                color: AppTheme.softOrange,
                fontWeight: AppTheme.weightSemiBold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    print(
      '[StudentProfileView] build: participantID=${widget.participantID}, '
      'name=${widget.participantName}',
    );

    return Consumer<AuthViewModel>(
      builder: (context, authVM, _) {
        return Scaffold(
          backgroundColor: AppTheme.creamBackground,
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppTheme.paddingStandard),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),
                  _buildProfileHeader(),
                  const SizedBox(height: 20),
                  _buildStatsRow(),
                  if (_statsError != null) ...[
                    const SizedBox(height: 8),
                    TextButton.icon(
                      onPressed: _loadStats,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Muat semula statistik'),
                    ),
                  ],
                  const SizedBox(height: 20),
                  _buildAchievementsSection(),
                  const SizedBox(height: 20),
                  _buildBadgesGrid(),
                  const SizedBox(height: 24),
                  _buildLogoutButton(context, authVM),
                  const SizedBox(height: 12),
                  _buildDeleteAccountButton(context, authVM),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildProfileHeader() {
    print('[StudentProfileView] building profile header');
    return Center(
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
              Icons.person,
              size: 40,
              color: AppTheme.forestGreen,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            widget.participantName,
            style: const TextStyle(
              fontSize: AppTheme.fontSizeHeadline,
              fontWeight: AppTheme.weightSemiBold,
              color: AppTheme.onSurface,
            ),
          ),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
            decoration: BoxDecoration(
              color: AppTheme.forestGreen.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Text(
              'Pengembara Alam',
              style: TextStyle(
                fontSize: AppTheme.fontSizeCaption,
                fontWeight: AppTheme.weightMedium,
                color: AppTheme.forestGreen,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow() {
    print('[StudentProfileView] building stats row');
    final stats = [
      {
        'icon': Icons.star_outline,
        'value': '$_discoveryCount',
        'label': 'Penemuan',
      },
      {
        'icon': Icons.check_circle_outline,
        'value': '$_completedCount',
        'label': 'Selesai',
      },
      {
        'icon': Icons.park_outlined,
        'value': '$_activityCount',
        'label': 'Aktiviti',
      },
    ];

    return Row(
      children: stats.map((stat) {
        return Expanded(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 4),
            padding: const EdgeInsets.symmetric(vertical: 14),
            decoration: BoxDecoration(
              color: AppTheme.cardBackground,
              borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                Icon(
                  stat['icon'] as IconData,
                  size: 22,
                  color: AppTheme.forestGreen,
                ),
                const SizedBox(height: 6),
                Text(
                  _isLoadingStats ? '…' : stat['value'] as String,
                  style: const TextStyle(
                    fontSize: AppTheme.fontSizeHeadline,
                    fontWeight: AppTheme.weightBold,
                    color: AppTheme.onSurface,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  stat['label'] as String,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: AppTheme.fontSizeSmall,
                    color: AppTheme.secondaryText,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildAchievementsSection() {
    print('[StudentProfileView] building achievements section');
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppTheme.paddingMedium),
      decoration: BoxDecoration(
        color: AppTheme.cardBackground,
        borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
        border: Border.all(color: AppTheme.dividerColor),
      ),
      child: const Row(
        children: [
          Icon(
            Icons.emoji_events_outlined,
            size: 24,
            color: AppTheme.softOrange,
          ),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              'Teruskan penerokaan untuk membuka pencapaian!',
              style: TextStyle(
                fontSize: AppTheme.fontSizeCaption,
                color: AppTheme.secondaryText,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBadgesGrid() {
    print('[StudentProfileView] building badges grid');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Lencana',
          style: TextStyle(
            fontSize: AppTheme.fontSizeBody,
            fontWeight: AppTheme.weightSemiBold,
            color: AppTheme.onSurface,
          ),
        ),
        const SizedBox(height: 12),
        GridView.count(
          crossAxisCount: 3,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          childAspectRatio: 1.0,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          children: _badges.map((badge) {
            final isUnlocked = badge['unlocked'] as bool;
            return Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppTheme.cardBackground,
                borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Opacity(
                opacity: isUnlocked ? 1.0 : 0.4,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      badge['emoji'] as String,
                      style: TextStyle(
                        fontSize: 28,
                        color: isUnlocked ? null : Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      badge['title'] as String,
                      style: TextStyle(
                        fontSize: AppTheme.fontSizeSmall,
                        fontWeight: AppTheme.weightMedium,
                        color: isUnlocked
                            ? AppTheme.onSurface
                            : AppTheme.secondaryText,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    if (!isUnlocked)
                      const Icon(
                        Icons.lock_outline,
                        size: 12,
                        color: AppTheme.secondaryText,
                      ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildLogoutButton(BuildContext context, AuthViewModel authVM) {
    print('[StudentProfileView] building logout button');
    return ScaleButton(
      onTap: () => _showLogoutDialog(context, authVM),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: AppTheme.softOrange.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(AppTheme.radiusButton),
          border: Border.all(
            color: AppTheme.softOrange.withValues(alpha: 0.3),
            width: 1.5,
          ),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.logout_outlined, size: 20, color: AppTheme.softOrange),
            SizedBox(width: 8),
            Text(
              'Log Keluar',
              style: TextStyle(
                fontSize: AppTheme.fontSizeBody,
                fontWeight: AppTheme.weightSemiBold,
                color: AppTheme.softOrange,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDeleteAccountButton(BuildContext context, AuthViewModel authVM) {
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
                      'Semua penemuan, kemajuan dan gambar anda akan dipadam '
                      'secara kekal. Tindakan ini tidak boleh dibatalkan.',
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
