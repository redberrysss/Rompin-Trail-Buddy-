import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../services/activity_data_service.dart';
import '../../models/participant.dart';
import '../../models/activity_session.dart';

class FacilitatorReportsView extends StatefulWidget {
  const FacilitatorReportsView({super.key});

  @override
  State<FacilitatorReportsView> createState() => _FacilitatorReportsViewState();
}

class _FacilitatorReportsViewState extends State<FacilitatorReportsView> {
  List<Participant> _participants = [];
  List<ActivitySession> _sessions = [];
  bool _isLoading = true;

  static const List<Map<String, String>> _activityNames = [
    {'number': '1', 'name': 'Jelajah Hutan'},
    {'number': '2', 'name': 'Aktiviti Sensori'},
    {'number': '3', 'name': 'Treasure Hunt'},
    {'number': '4', 'name': 'Seni Alam'},
  ];

  @override
  void initState() {
    super.initState();
    print('[FacilitatorReports] initState');
    _loadData();
  }

  Future<void> _loadData() async {
    print('[FacilitatorReports] _loadData');
    setState(() => _isLoading = true);

    try {
      final bundle = await ActivityDataService.instance.loadForCurrentUser();
      _participants = bundle.participants
          .map((doc) => Participant.fromMap(doc.data(), id: doc.id))
          .toList();
      _sessions = bundle.sessions
          .map((doc) => ActivitySession.fromMap(doc.data(), id: doc.id))
          .toList();

      print(
        '[FacilitatorReports] Loaded ${_participants.length} participants, ${_sessions.length} sessions',
      );
    } catch (e) {
      print('[FacilitatorReports] _loadData error: $e');
    }

    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  int get _totalStudents => _participants.length;

  int get _totalCompleted => _sessions.where((s) => s.isCompleted).length;

  double get _completionRate =>
      _totalStudents > 0 ? (_totalCompleted / (_totalStudents * 4)) * 100 : 0.0;

  List<ActivitySession> get _recentSessions {
    final sorted = List<ActivitySession>.from(_sessions);
    sorted.sort((a, b) => b.startedAt.compareTo(a.startedAt));
    return sorted.take(5).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.creamBackground,
      appBar: AppBar(
        title: const Text('Laporan'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(color: AppTheme.forestGreen),
              )
            : RefreshIndicator(
                onRefresh: _loadData,
                color: AppTheme.forestGreen,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(AppTheme.paddingStandard),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSummaryCard(),
                      const SizedBox(height: AppTheme.paddingMedium),
                      _buildActivityCompletionCard(),
                      const SizedBox(height: AppTheme.paddingMedium),
                      _buildRecentActivityCard(),
                      const SizedBox(height: AppTheme.paddingXLarge),
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildSummaryCard() {
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppTheme.forestGreen.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.assessment_outlined,
                  color: AppTheme.forestGreen,
                  size: 20,
                ),
              ),
              const SizedBox(width: AppTheme.paddingSmall),
              const Text(
                'Ringkasan Kumpulan',
                style: TextStyle(
                  fontSize: AppTheme.fontSizeBody,
                  fontWeight: AppTheme.weightSemiBold,
                  color: AppTheme.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.paddingMedium),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Expanded(
                child: _buildStatItem(
                  label: 'Pelajar',
                  value: '$_totalStudents',
                  color: AppTheme.forestGreen,
                ),
              ),
              Container(width: 1, height: 40, color: AppTheme.dividerColor),
              Expanded(
                child: _buildStatItem(
                  label: 'Selesai',
                  value: '$_totalCompleted',
                  color: AppTheme.successGreen,
                ),
              ),
              Container(width: 1, height: 40, color: AppTheme.dividerColor),
              Expanded(
                child: _buildStatItem(
                  label: 'Kadar',
                  value: '${_completionRate.toInt()}%',
                  color: AppTheme.softBlue,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: AppTheme.fontSizeHeadline,
            fontWeight: AppTheme.weightBold,
            color: color,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: AppTheme.fontSizeCaption,
            color: AppTheme.secondaryText,
          ),
        ),
      ],
    );
  }

  Widget _buildActivityCompletionCard() {
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Aktiviti',
            style: TextStyle(
              fontSize: AppTheme.fontSizeBody,
              fontWeight: AppTheme.weightSemiBold,
              color: AppTheme.onSurface,
            ),
          ),
          const SizedBox(height: AppTheme.paddingMedium),
          ..._activityNames.map((activity) {
            final activityNumber = int.parse(activity['number']!);
            final completedCount = _sessions
                .where(
                  (s) => s.activityNumber == activityNumber && s.isCompleted,
                )
                .length;
            return Padding(
              padding: const EdgeInsets.only(bottom: AppTheme.paddingSmall),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      activity['name']!,
                      style: const TextStyle(
                        fontSize: AppTheme.fontSizeBody,
                        color: AppTheme.onSurface,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: completedCount > 0
                          ? AppTheme.successGreen.withValues(alpha: 0.12)
                          : AppTheme.dividerColor.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '$completedCount selesai',
                      style: TextStyle(
                        fontSize: AppTheme.fontSizeCaption,
                        fontWeight: AppTheme.weightMedium,
                        color: completedCount > 0
                            ? AppTheme.successGreen
                            : AppTheme.secondaryText,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildRecentActivityCard() {
    final recent = _recentSessions;

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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Aktiviti Terkini',
            style: TextStyle(
              fontSize: AppTheme.fontSizeBody,
              fontWeight: AppTheme.weightSemiBold,
              color: AppTheme.onSurface,
            ),
          ),
          const SizedBox(height: AppTheme.paddingMedium),
          if (recent.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(AppTheme.paddingMedium),
                child: Text(
                  'Tiada aktiviti lagi',
                  style: TextStyle(
                    fontSize: AppTheme.fontSizeCaption,
                    color: AppTheme.secondaryText,
                  ),
                ),
              ),
            )
          else
            ...recent.map((session) {
              final activityNames = {
                1: 'Jelajah Hutan',
                2: 'Aktiviti Sensori',
                3: 'Treasure Hunt',
                4: 'Seni Alam',
              };
              final name =
                  activityNames[session.activityNumber] ??
                  'Aktiviti ${session.activityNumber}';
              final isCompleted = session.isCompleted;

              return Padding(
                padding: const EdgeInsets.only(bottom: AppTheme.paddingSmall),
                child: Row(
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: isCompleted
                            ? AppTheme.successGreen
                            : AppTheme.softOrange,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: AppTheme.paddingSmall),
                    Expanded(
                      child: Text(
                        name,
                        style: const TextStyle(
                          fontSize: AppTheme.fontSizeBody,
                          color: AppTheme.onSurface,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: isCompleted
                            ? AppTheme.successGreen.withValues(alpha: 0.12)
                            : AppTheme.softOrange.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        isCompleted ? 'Selesai' : 'Dalam proses',
                        style: TextStyle(
                          fontSize: AppTheme.fontSizeCaption,
                          fontWeight: AppTheme.weightMedium,
                          color: isCompleted
                              ? AppTheme.successGreen
                              : AppTheme.softOrange,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }
}
