import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../services/activity_data_service.dart';
import '../../models/activity_session.dart';
import '../../models/observation_record.dart';
import '../../models/sensory_record.dart';
import '../../models/treasure_record.dart';
import '../../models/artwork_record.dart';

class FacilitatorParticipantDetailView extends StatefulWidget {
  const FacilitatorParticipantDetailView({
    super.key,
    required this.participant,
  });

  final Map<String, dynamic> participant;

  @override
  State<FacilitatorParticipantDetailView> createState() =>
      _FacilitatorParticipantDetailViewState();
}

class _FacilitatorParticipantDetailViewState
    extends State<FacilitatorParticipantDetailView> {
  String _participantName = '';
  List<ActivitySession> _sessions = [];
  List<ObservationRecord> _observations = [];
  List<SensoryRecord> _sensoryRecords = [];
  List<TreasureRecord> _treasureRecords = [];
  List<ArtworkRecord> _artworkRecords = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    print(
      '[FacilitatorParticipantDetail] initState: ${widget.participant['id']}',
    );
    _participantName = widget.participant['name'] as String? ?? '';
    _loadData();
  }

  Future<void> _loadData() async {
    print('[FacilitatorParticipantDetail] _loadData');
    setState(() => _isLoading = true);

    final participantId = widget.participant['id'] as String? ?? '';

    try {
      final bundle = await ActivityDataService.instance.loadForCurrentUser();
      _sessions = bundle.sessions
          .where((doc) => doc.data()['participantId'] == participantId)
          .map((doc) => ActivitySession.fromMap(doc.data(), id: doc.id))
          .toList();
      _observations = bundle.observations
          .where((doc) => doc.data()['participantId'] == participantId)
          .map((doc) => ObservationRecord.fromMap(doc.data(), id: doc.id))
          .toList();
      _sensoryRecords = bundle.sensoryRecords
          .where((doc) => doc.data()['participantId'] == participantId)
          .map((doc) => SensoryRecord.fromMap(doc.data(), id: doc.id))
          .toList();
      _treasureRecords = bundle.treasureRecords
          .where((doc) => doc.data()['participantId'] == participantId)
          .map((doc) => TreasureRecord.fromMap(doc.data(), id: doc.id))
          .toList();
      _artworkRecords = bundle.artworks
          .where((doc) => doc.data()['participantId'] == participantId)
          .map((doc) => ArtworkRecord.fromMap(doc.data(), id: doc.id))
          .toList();
      for (final document in bundle.discoveries) {
        final data = Map<String, dynamic>.from(document.data());
        final recordParticipantId =
            data['participantId']?.toString().trim() ??
            data['userId']?.toString().trim() ??
            data['ownerId']?.toString().trim() ??
            '';
        if (recordParticipantId != participantId) continue;
        data['participantId'] = recordParticipantId;
        _observations.add(ObservationRecord.fromMap(data, id: document.id));
      }

      if (_participantName.isEmpty) {
        for (final participant in bundle.participants) {
          if (participant.id == participantId) {
            _participantName = participant.data()['name'] as String? ?? '';
            break;
          }
        }
        for (final member in bundle.members) {
          final data = member.data();
          if ((data['userId']?.toString() ?? member.id) == participantId) {
            _participantName =
                (data['name'] ?? data['fullName'])?.toString() ?? 'Peserta';
            break;
          }
        }
      }

      print(
        '[FacilitatorParticipantDetail] Loaded: ${_sessions.length} sessions, '
        '${_observations.length} observations, '
        '${_sensoryRecords.length} sensory, '
        '${_treasureRecords.length} treasure, '
        '${_artworkRecords.length} artwork',
      );
    } catch (e) {
      print('[FacilitatorParticipantDetail] _loadData error: $e');
    }

    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  int get _totalActivities => _sessions.length;

  int get _completedActivities => _sessions.where((s) => s.isCompleted).length;

  double get _overallProgress => _totalActivities > 0
      ? _sessions.fold<double>(0, (sum, session) => sum + session.progress) /
            _totalActivities
      : 0.0;

  int get _overallScore => (_overallProgress * 100).toInt();

  String get _scoreEmoji {
    if (_overallScore >= 80) return '🌟';
    if (_overallScore >= 50) return '👍';
    return '💪';
  }

  String _getInitial() {
    if (_participantName.isEmpty) return '?';
    return _participantName.substring(0, 1).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.creamBackground,
      appBar: AppBar(
        title: const Text('Butiran Peserta'),
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
                      _buildProfileHeader(),
                      const SizedBox(height: AppTheme.paddingLarge),
                      _buildScoreSummary(),
                      const SizedBox(height: AppTheme.paddingLarge),
                      _buildActivityBreakdown(),
                      const SizedBox(height: AppTheme.paddingLarge),
                      _buildImageGallery(),
                      const SizedBox(height: AppTheme.paddingXLarge),
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    final initials = _getInitial();

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
              color: AppTheme.forestGreen.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                initials,
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: AppTheme.weightBold,
                  color: AppTheme.forestGreen,
                ),
              ),
            ),
          ),
          const SizedBox(height: AppTheme.paddingMedium),
          Text(
            _participantName,
            style: const TextStyle(
              fontSize: AppTheme.fontSizeHeadline,
              fontWeight: AppTheme.weightBold,
              color: AppTheme.onSurface,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '$_completedActivities / $_totalActivities aktiviti selesai',
            style: const TextStyle(
              fontSize: AppTheme.fontSizeBody,
              color: AppTheme.secondaryText,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScoreSummary() {
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
          Text(_scoreEmoji, style: const TextStyle(fontSize: 40)),
          const SizedBox(height: AppTheme.paddingSmall),
          const Text(
            'Skor Keseluruhan',
            style: TextStyle(
              fontSize: AppTheme.fontSizeCaption,
              color: AppTheme.secondaryText,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '$_overallScore%',
            style: const TextStyle(
              fontSize: 40,
              fontWeight: AppTheme.weightBold,
              color: AppTheme.forestGreen,
            ),
          ),
          const SizedBox(height: AppTheme.paddingMedium),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: _overallProgress,
              backgroundColor: AppTheme.dividerColor,
              valueColor: const AlwaysStoppedAnimation<Color>(
                AppTheme.forestGreen,
              ),
              minHeight: 8,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityBreakdown() {
    final activities = [
      {
        'emoji': '🌳',
        'name': 'Jelajah Hutan',
        'count': _observations.length,
        'progress': _activityProgress(1),
      },
      {
        'emoji': '🌿',
        'name': 'Sensori Alam',
        'count': _sensoryRecords.length,
        'progress': _activityProgress(2),
      },
      {
        'emoji': '🗺️',
        'name': 'Treasure Hunt',
        'count': _treasureRecords.length,
        'progress': _activityProgress(3),
      },
      {
        'emoji': '🎨',
        'name': 'Seni Alam',
        'count': _artworkRecords.length,
        'progress': _activityProgress(4),
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Pecahan Aktiviti',
          style: TextStyle(
            fontSize: AppTheme.fontSizeBody,
            fontWeight: AppTheme.weightSemiBold,
            color: AppTheme.onSurface,
          ),
        ),
        const SizedBox(height: AppTheme.paddingSmall),
        ...activities.map((activity) {
          final progress = (activity['progress'] as double).clamp(0.0, 1.0);
          final count = activity['count'] as int;
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      activity['emoji'] as String,
                      style: const TextStyle(fontSize: 20),
                    ),
                    const SizedBox(width: AppTheme.paddingSmall),
                    Expanded(
                      child: Text(
                        activity['name'] as String,
                        style: const TextStyle(
                          fontSize: AppTheme.fontSizeBody,
                          fontWeight: AppTheme.weightSemiBold,
                          color: AppTheme.onSurface,
                        ),
                      ),
                    ),
                    Text(
                      '$count item',
                      style: const TextStyle(
                        fontSize: AppTheme.fontSizeCaption,
                        color: AppTheme.secondaryText,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: progress,
                    backgroundColor: AppTheme.dividerColor,
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      AppTheme.forestGreen,
                    ),
                    minHeight: 6,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${(progress * 100).toInt()}%',
                  style: const TextStyle(
                    fontSize: AppTheme.fontSizeCaption,
                    fontWeight: AppTheme.weightMedium,
                    color: AppTheme.forestGreen,
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildImageGallery() {
    // Collect all image URLs from records
    final List<Map<String, String>> images = [];

    for (final obs in _observations) {
      if (obs.imageDownloadURL != null && obs.imageDownloadURL!.isNotEmpty) {
        images.add({'url': obs.imageDownloadURL!, 'label': obs.objectName});
      }
    }
    for (final sensory in _sensoryRecords) {
      if (sensory.imageDownloadURL != null &&
          sensory.imageDownloadURL!.isNotEmpty) {
        images.add({
          'url': sensory.imageDownloadURL!,
          'label': sensory.senseType,
        });
      }
    }
    for (final treasure in _treasureRecords) {
      if (treasure.imageDownloadURL != null &&
          treasure.imageDownloadURL!.isNotEmpty) {
        images.add({
          'url': treasure.imageDownloadURL!,
          'label': treasure.itemName,
        });
      }
    }
    for (final artwork in _artworkRecords) {
      if (artwork.artworkDownloadURL != null &&
          artwork.artworkDownloadURL!.isNotEmpty) {
        images.add({
          'url': artwork.artworkDownloadURL!,
          'label': artwork.title,
        });
      }
    }

    if (images.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Galeri Gambar',
          style: TextStyle(
            fontSize: AppTheme.fontSizeBody,
            fontWeight: AppTheme.weightSemiBold,
            color: AppTheme.onSurface,
          ),
        ),
        const SizedBox(height: AppTheme.paddingSmall),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: AppTheme.paddingSmall,
            crossAxisSpacing: AppTheme.paddingSmall,
            childAspectRatio: 1,
          ),
          itemCount: images.length,
          itemBuilder: (context, index) {
            final image = images[index];
            return Container(
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
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(AppTheme.radiusSmall),
                        topRight: Radius.circular(AppTheme.radiusSmall),
                      ),
                      child: Image.network(
                        image['url']!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stack) {
                          return Container(
                            color: AppTheme.dividerColor.withValues(alpha: 0.3),
                            child: const Icon(
                              Icons.image_outlined,
                              color: AppTheme.secondaryText,
                              size: 32,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(6),
                    child: Text(
                      image['label'] ?? '',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: AppTheme.fontSizeSmall,
                        color: AppTheme.secondaryText,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  double _activityProgress(int activityNumber) {
    final sessions = _sessions
        .where((session) => session.activityNumber == activityNumber)
        .toList();
    if (sessions.isEmpty) return 0;
    return sessions.fold<double>(0, (sum, session) => sum + session.progress) /
        sessions.length;
  }
}
