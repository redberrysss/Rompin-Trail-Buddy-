import 'package:flutter/material.dart';

import '../../models/student_activity_progress.dart';
import '../../services/activity_data_service.dart';
import '../../theme/app_theme.dart';
import '../activities/activity1_nature_walk_view.dart';
import '../activities/activity2_sensory_view.dart';
import '../activities/activity3_treasure_hunt_view.dart';
import '../activities/activity4_nature_art_view.dart';
import 'student_activities_view.dart';
import 'student_discoveries_view.dart';
import 'student_explore_view.dart';
import 'student_profile_view.dart';

class StudentHomeView extends StatefulWidget {
  const StudentHomeView({
    super.key,
    required this.participantID,
    required this.participantName,
  });

  final String participantID;
  final String participantName;

  @override
  State<StudentHomeView> createState() => _StudentHomeViewState();
}

class _StudentHomeViewState extends State<StudentHomeView> {
  static const _activities = [
    _HomeActivity(
      1,
      '🌳',
      'Jelajah Hutan',
      'Berjalan dan terokai alam sekitar',
    ),
    _HomeActivity(2, '🌿', 'Aktiviti Sensori', 'Gunakan semua deria anda'),
    _HomeActivity(3, '🗺️', 'Treasure Hunt', 'Cari objek alam tersembunyi'),
    _HomeActivity(4, '🎨', 'Seni Alam', 'Hasilkan kolaj atau karya foto'),
  ];

  Map<int, StudentActivityProgress> _progress = const {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProgress();
  }

  Future<void> _loadProgress() async {
    try {
      final progress = await ActivityDataService.instance.loadStudentProgress(
        widget.participantID,
      );
      if (!mounted) return;
      setState(() {
        _progress = progress;
        _isLoading = false;
      });
    } catch (error, stackTrace) {
      debugPrint('[StudentHomeView] Progress load failed: $error');
      debugPrintStack(stackTrace: stackTrace);
      if (mounted) setState(() => _isLoading = false);
    }
  }

  bool _isUnlocked(int number) =>
      number == 1 || _progress[number - 1]?.isCompleted == true;

  int get _currentActivityNumber {
    for (final activity in _activities) {
      if (_isUnlocked(activity.number) &&
          _progress[activity.number]?.isCompleted != true) {
        return activity.number;
      }
    }
    return 4;
  }

  Future<void> _openActivity(int number) async {
    if (!_isUnlocked(number)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Aktiviti $number masih dikunci.')),
      );
      return;
    }
    final page = switch (number) {
      1 => Activity1NatureWalkView(
        participantID: widget.participantID,
        participantName: widget.participantName,
      ),
      2 => Activity2SensoryView(
        participantID: widget.participantID,
        participantName: widget.participantName,
      ),
      3 => Activity3TreasureHuntView(
        participantID: widget.participantID,
        participantName: widget.participantName,
      ),
      4 => Activity4NatureArtView(
        participantID: widget.participantID,
        participantName: widget.participantName,
      ),
      _ => throw StateError('Aktiviti tidak sah.'),
    };
    await Navigator.of(context).push(MaterialPageRoute(builder: (_) => page));
    if (mounted) await _loadProgress();
  }

  Future<void> _push(Widget page) async {
    await Navigator.of(context).push(MaterialPageRoute(builder: (_) => page));
    if (mounted) await _loadProgress();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.creamBackground,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadProgress,
          color: AppTheme.forestGreen,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 110),
            children: [
              _buildWelcomeCard(),
              const SizedBox(height: 16),
              _buildScheduleCard(),
              const SizedBox(height: 16),
              _buildCurrentActivityCard(),
              const SizedBox(height: 16),
              _buildQuickActions(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomeCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: AppTheme.primaryGradient,
        borderRadius: BorderRadius.circular(AppTheme.radiusCard),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Hai, ${widget.participantName}!',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: AppTheme.fontSizeHeadline,
                    fontWeight: AppTheme.weightBold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Sedia untuk meneroka alam hari ini?',
                  style: TextStyle(color: Colors.white70),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.25),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.person, color: Colors.white, size: 30),
          ),
        ],
      ),
    );
  }

  Widget _buildScheduleCard() {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.calendar_month, color: AppTheme.forestGreen),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Jadual Hari Ini',
                  style: TextStyle(
                    fontWeight: AppTheme.weightSemiBold,
                    color: AppTheme.onSurface,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (_isLoading)
            const LinearProgressIndicator()
          else
            ..._activities.map((activity) {
              final unlocked = _isUnlocked(activity.number);
              final completed = _progress[activity.number]?.isCompleted == true;
              final current =
                  activity.number == _currentActivityNumber && !completed;
              return InkWell(
                onTap: unlocked ? () => _openActivity(activity.number) : null,
                borderRadius: BorderRadius.circular(10),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Row(
                    children: [
                      Container(
                        width: 38,
                        height: 38,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: completed
                              ? AppTheme.successGreen.withValues(alpha: 0.15)
                              : current
                              ? AppTheme.forestGreen.withValues(alpha: 0.15)
                              : AppTheme.dividerColor.withValues(alpha: 0.45),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(activity.emoji),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          activity.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: unlocked
                                ? AppTheme.onSurface
                                : AppTheme.secondaryText,
                            fontWeight: current
                                ? AppTheme.weightSemiBold
                                : AppTheme.weightRegular,
                          ),
                        ),
                      ),
                      if (completed)
                        const Icon(
                          Icons.check_circle,
                          color: AppTheme.successGreen,
                        )
                      else if (current)
                        const _CurrentBadge()
                      else
                        const Icon(
                          Icons.lock_outline,
                          color: AppTheme.secondaryText,
                        ),
                    ],
                  ),
                ),
              );
            }),
        ],
      ),
    );
  }

  Widget _buildCurrentActivityCard() {
    final activity = _activities[_currentActivityNumber - 1];
    final allCompleted = _activities.every(
      (item) => _progress[item.number]?.isCompleted == true,
    );
    return _card(
      color: AppTheme.lightGreen.withValues(alpha: 0.12),
      child: Column(
        children: [
          Text(activity.emoji, style: const TextStyle(fontSize: 48)),
          const SizedBox(height: 8),
          Text(
            allCompleted ? 'Semua Aktiviti Selesai!' : activity.title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: AppTheme.fontSizeHeadline,
              fontWeight: AppTheme.weightSemiBold,
              color: AppTheme.onSurface,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            allCompleted
                ? 'Tahniah, anda kini Nature Master!'
                : activity.description,
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppTheme.secondaryText),
          ),
          const SizedBox(height: 16),
          RoundedButton(
            text: allCompleted ? 'Lihat Semua Aktiviti' : 'Mulakan Aktiviti',
            icon: allCompleted ? Icons.emoji_events : Icons.arrow_forward,
            onPressed: allCompleted
                ? () => _push(
                    StudentActivitiesView(
                      participantID: widget.participantID,
                      participantName: widget.participantName,
                    ),
                  )
                : () => _openActivity(activity.number),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    final actions = [
      _QuickAction(
        Icons.star,
        'Penemuan',
        AppTheme.softYellow,
        () =>
            _push(StudentDiscoveriesView(participantID: widget.participantID)),
      ),
      _QuickAction(
        Icons.camera_alt,
        'Kamera',
        AppTheme.softBlue,
        () => _push(StudentExploreView(participantID: widget.participantID)),
      ),
      _QuickAction(
        Icons.emoji_events,
        'Pencapaian',
        AppTheme.softOrange,
        () => _push(
          StudentProfileView(
            participantID: widget.participantID,
            participantName: widget.participantName,
          ),
        ),
      ),
      _QuickAction(
        Icons.sentiment_satisfied,
        'Emosi',
        AppTheme.lavender,
        () => _isUnlocked(2)
            ? _openActivity(2)
            : ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Lengkapkan Jelajah Hutan dahulu.'),
                ),
              ),
      ),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Tindakan Pantas',
          style: TextStyle(fontWeight: AppTheme.weightSemiBold),
        ),
        const SizedBox(height: 12),
        Row(
          children: actions
              .map(
                (action) => Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 3),
                    child: InkWell(
                      onTap: action.onTap,
                      borderRadius: BorderRadius.circular(12),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Column(
                          children: [
                            Container(
                              width: 46,
                              height: 46,
                              decoration: BoxDecoration(
                                color: action.color,
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Icon(action.icon, color: Colors.white),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              action.label,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: AppTheme.fontSizeSmall,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              )
              .toList(),
        ),
      ],
    );
  }

  Widget _card({required Widget child, Color? color}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: color ?? AppTheme.cardBackground,
        borderRadius: BorderRadius.circular(AppTheme.radiusCard),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _CurrentBadge extends StatelessWidget {
  const _CurrentBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppTheme.forestGreen,
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Text(
        'Sekarang',
        style: TextStyle(fontSize: 10, color: Colors.white),
      ),
    );
  }
}

class _HomeActivity {
  const _HomeActivity(this.number, this.emoji, this.title, this.description);

  final int number;
  final String emoji;
  final String title;
  final String description;
}

class _QuickAction {
  const _QuickAction(this.icon, this.label, this.color, this.onTap);

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
}
