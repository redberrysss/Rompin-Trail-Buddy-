import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../services/activity_data_service.dart';
import '../../models/activity_session.dart';

class FacilitatorActivitiesView extends StatefulWidget {
  const FacilitatorActivitiesView({super.key});

  @override
  State<FacilitatorActivitiesView> createState() =>
      _FacilitatorActivitiesViewState();
}

class _FacilitatorActivitiesViewState extends State<FacilitatorActivitiesView> {
  List<ActivitySession> _sessions = [];
  bool _isLoading = true;

  static const List<Map<String, dynamic>> _activities = [
    {
      'number': 1,
      'name': 'Jelajah Hutan',
      'icon': '🌳',
      'color': AppTheme.forestGreen,
    },
    {
      'number': 2,
      'name': 'Aktiviti Sensori',
      'icon': '🌿',
      'color': AppTheme.softBlue,
    },
    {
      'number': 3,
      'name': 'Treasure Hunt',
      'icon': '🗺️',
      'color': AppTheme.softOrange,
    },
    {
      'number': 4,
      'name': 'Seni Alam',
      'icon': '🎨',
      'color': AppTheme.lavender,
    },
  ];

  @override
  void initState() {
    super.initState();
    print('[FacilitatorActivities] initState');
    _loadData();
  }

  Future<void> _loadData() async {
    print('[FacilitatorActivities] _loadData');
    setState(() => _isLoading = true);

    try {
      final bundle = await ActivityDataService.instance.loadForCurrentUser();
      _sessions = bundle.sessions
          .map((doc) => ActivitySession.fromMap(doc.data(), id: doc.id))
          .toList();
      print('[FacilitatorActivities] Loaded ${_sessions.length} sessions');
    } catch (e) {
      print('[FacilitatorActivities] _loadData error: $e');
    }

    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.creamBackground,
      appBar: AppBar(
        title: const Text('Aktiviti'),
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
                child: ListView.builder(
                  padding: const EdgeInsets.all(AppTheme.paddingStandard),
                  itemCount: _activities.length,
                  itemBuilder: (context, index) {
                    return _buildActivityRow(_activities[index]);
                  },
                ),
              ),
      ),
    );
  }

  Widget _buildActivityRow(Map<String, dynamic> activity) {
    final int activityNumber = activity['number'] as int;
    final String name = activity['name'] as String;
    final String icon = activity['icon'] as String;
    final Color color = activity['color'] as Color;

    final activitySessions = _sessions
        .where((s) => s.activityNumber == activityNumber)
        .toList();
    final participantCount = activitySessions
        .map((s) => s.participantId)
        .toSet()
        .length;
    final completedCount = activitySessions.where((s) => s.isCompleted).length;
    final hasCompleted = completedCount > 0;

    return Container(
      margin: const EdgeInsets.only(bottom: AppTheme.paddingSmall),
      padding: const EdgeInsets.all(AppTheme.paddingMedium),
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
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(AppTheme.radiusDefault),
            ),
            child: Center(
              child: Text(icon, style: const TextStyle(fontSize: 24)),
            ),
          ),
          const SizedBox(width: AppTheme.paddingMedium),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: AppTheme.fontSizeBody,
                    fontWeight: AppTheme.weightSemiBold,
                    color: AppTheme.onSurface,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '$participantCount peserta',
                  style: const TextStyle(
                    fontSize: AppTheme.fontSizeCaption,
                    color: AppTheme.secondaryText,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '$completedCount selesai',
                style: const TextStyle(
                  fontSize: AppTheme.fontSizeCaption,
                  fontWeight: AppTheme.weightMedium,
                  color: AppTheme.secondaryText,
                ),
              ),
              const SizedBox(height: 4),
              if (hasCompleted)
                const Icon(
                  Icons.check_circle,
                  color: AppTheme.successGreen,
                  size: 20,
                )
              else
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.dividerColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'Belum',
                    style: TextStyle(
                      fontSize: AppTheme.fontSizeSmall,
                      color: AppTheme.secondaryText,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
