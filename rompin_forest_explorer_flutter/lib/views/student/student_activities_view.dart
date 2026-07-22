import 'package:flutter/material.dart';

import '../../models/student_activity_progress.dart';
import '../../services/activity_data_service.dart';
import '../../theme/app_theme.dart';
import '../activities/activity1_nature_walk_view.dart';
import '../activities/activity2_sensory_view.dart';
import '../activities/activity3_treasure_hunt_view.dart';
import '../activities/activity4_nature_art_view.dart';

class StudentActivitiesView extends StatefulWidget {
  const StudentActivitiesView({
    super.key,
    required this.participantID,
    this.participantName = 'Peserta',
  });

  final String participantID;
  final String participantName;

  @override
  State<StudentActivitiesView> createState() => _StudentActivitiesViewState();
}

class _StudentActivitiesViewState extends State<StudentActivitiesView> {
  static const _activities = [
    _ActivityDefinition(
      1,
      '🌳',
      'Jelajah Hutan',
      'Terokai alam sekitar',
      AppTheme.forestGreen,
    ),
    _ActivityDefinition(
      2,
      '🌿',
      'Aktiviti Sensori',
      'Gunakan deria anda',
      AppTheme.softBlue,
    ),
    _ActivityDefinition(
      3,
      '🗺️',
      'Nature Treasure Hunt',
      'Cari objek tersembunyi',
      AppTheme.softOrange,
    ),
    _ActivityDefinition(
      4,
      '🎨',
      'Seni Alam',
      'Hasilkan karya seni',
      AppTheme.lavender,
    ),
  ];

  Map<int, StudentActivityProgress> _progress = const {};
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadProgress();
  }

  Future<void> _loadProgress() async {
    if (widget.participantID.trim().isEmpty) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'ID peserta belum tersedia.';
      });
      return;
    }
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
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
      debugPrint('[StudentActivitiesView] Progress load failed: $error');
      debugPrintStack(stackTrace: stackTrace);
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = error.toString();
      });
    }
  }

  bool _isUnlocked(int number) {
    if (number == 1) return true;
    return _progress[number - 1]?.isCompleted == true;
  }

  Future<void> _openActivity(_ActivityDefinition activity) async {
    if (!_isUnlocked(activity.number)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Lengkapkan ${_activities[activity.number - 2].title} dahulu.',
          ),
        ),
      );
      return;
    }

    final page = switch (activity.number) {
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

  @override
  Widget build(BuildContext context) {
    final textScale = MediaQuery.textScalerOf(context).scale(1);
    return Scaffold(
      backgroundColor: AppTheme.creamBackground,
      appBar: AppBar(title: const Text('Aktiviti')),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadProgress,
          color: AppTheme.forestGreen,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                sliver: SliverToBoxAdapter(child: _buildHeader()),
              ),
              if (_isLoading)
                const SliverFillRemaining(
                  child: Center(
                    child: CircularProgressIndicator(
                      color: AppTheme.forestGreen,
                    ),
                  ),
                )
              else if (_errorMessage != null)
                SliverFillRemaining(child: _buildError())
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 110),
                  sliver: SliverGrid(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: textScale > 1.5 ? 1 : 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      mainAxisExtent: textScale > 1.5 ? 245 : 225,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) =>
                          _buildActivityCard(_activities[index]),
                      childCount: _activities.length,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppTheme.cardBackground,
        borderRadius: BorderRadius.circular(AppTheme.radiusCard),
      ),
      child: const Column(
        children: [
          Icon(Icons.rectangle_outlined, size: 36, color: AppTheme.forestGreen),
          SizedBox(height: 8),
          Text(
            'Aktiviti Eksplorasi',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: AppTheme.fontSizeHeadline,
              fontWeight: AppTheme.weightSemiBold,
              color: AppTheme.onSurface,
            ),
          ),
          SizedBox(height: 4),
          Text(
            'Lengkapkan aktiviti mengikut turutan untuk menjadi Nature Master!',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppTheme.secondaryText),
          ),
        ],
      ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cloud_off_outlined, size: 48),
            const SizedBox(height: 12),
            Text(_errorMessage!, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: _loadProgress,
              icon: const Icon(Icons.refresh),
              label: const Text('Cuba Lagi'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityCard(_ActivityDefinition activity) {
    final progress = _progress[activity.number]?.progress ?? 0;
    final completed = _progress[activity.number]?.isCompleted == true;
    final unlocked = _isUnlocked(activity.number);
    return Material(
      color: AppTheme.cardBackground,
      borderRadius: BorderRadius.circular(AppTheme.radiusCard),
      elevation: unlocked ? 1 : 0,
      child: InkWell(
        onTap: () => _openActivity(activity),
        borderRadius: BorderRadius.circular(AppTheme.radiusCard),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(activity.emoji, style: const TextStyle(fontSize: 40)),
                  const SizedBox(height: 8),
                  Text(
                    activity.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontWeight: AppTheme.weightSemiBold,
                      color: AppTheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    activity.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: AppTheme.fontSizeCaption,
                      color: AppTheme.secondaryText,
                    ),
                  ),
                  const SizedBox(height: 12),
                  LinearProgressIndicator(
                    value: progress,
                    minHeight: 6,
                    color: activity.color,
                    backgroundColor: AppTheme.dividerColor,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    completed ? 'Selesai' : '${(progress * 100).round()}%',
                    style: TextStyle(
                      fontSize: AppTheme.fontSizeSmall,
                      color: completed ? AppTheme.successGreen : activity.color,
                    ),
                  ),
                ],
              ),
            ),
            if (!unlocked)
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.78),
                    borderRadius: BorderRadius.circular(AppTheme.radiusCard),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.lock,
                      size: 34,
                      color: AppTheme.secondaryText,
                    ),
                  ),
                ),
              ),
            if (completed)
              const Positioned(
                top: 10,
                right: 10,
                child: Icon(Icons.check_circle, color: AppTheme.successGreen),
              ),
          ],
        ),
      ),
    );
  }
}

class _ActivityDefinition {
  const _ActivityDefinition(
    this.number,
    this.emoji,
    this.title,
    this.description,
    this.color,
  );

  final int number;
  final String emoji;
  final String title;
  final String description;
  final Color color;
}
