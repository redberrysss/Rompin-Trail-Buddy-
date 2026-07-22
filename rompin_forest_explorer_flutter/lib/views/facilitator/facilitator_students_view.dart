import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../services/activity_data_service.dart';
import '../../models/participant.dart';
import '../../models/activity_session.dart';
import 'facilitator_participant_detail_view.dart';

class FacilitatorStudentsView extends StatefulWidget {
  const FacilitatorStudentsView({super.key});

  @override
  State<FacilitatorStudentsView> createState() =>
      _FacilitatorStudentsViewState();
}

class _FacilitatorStudentsViewState extends State<FacilitatorStudentsView> {
  final TextEditingController _searchController = TextEditingController();

  List<Participant> _participants = [];
  List<Participant> _filteredParticipants = [];
  List<ActivitySession> _sessions = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    print('[FacilitatorStudents] initState');
    _loadData();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final query = _searchController.text.toLowerCase().trim();
    setState(() {
      if (query.isEmpty) {
        _filteredParticipants = List.from(_participants);
      } else {
        _filteredParticipants = _participants
            .where((p) => p.name.toLowerCase().contains(query))
            .toList();
      }
    });
  }

  Future<void> _loadData() async {
    print('[FacilitatorStudents] _loadData');
    setState(() => _isLoading = true);

    try {
      final bundle = await ActivityDataService.instance.loadForCurrentUser();
      _participants = bundle.participants
          .map((doc) => Participant.fromMap(doc.data(), id: doc.id))
          .toList();
      _sessions = bundle.sessions
          .map((doc) => ActivitySession.fromMap(doc.data(), id: doc.id))
          .toList();
      final existingIds = _participants
          .map((participant) => participant.id)
          .toSet();
      final recordIds = <String>{
        ..._sessions.map((record) => record.participantId),
        ...bundle.observations.map(
          (record) => record.data()['participantId'] as String? ?? '',
        ),
        ...bundle.sensoryRecords.map(
          (record) => record.data()['participantId'] as String? ?? '',
        ),
        ...bundle.treasureRecords.map(
          (record) => record.data()['participantId'] as String? ?? '',
        ),
        ...bundle.artworks.map(
          (record) => record.data()['participantId'] as String? ?? '',
        ),
        ...bundle.discoveries.map(
          (record) =>
              record.data()['participantId']?.toString() ??
              record.data()['userId']?.toString() ??
              record.data()['ownerId']?.toString() ??
              '',
        ),
      }..removeWhere((id) => id.isEmpty || existingIds.contains(id));
      final now = DateTime.now();
      _participants.addAll(
        recordIds.map(
          (id) => Participant(
            id: id,
            ownerId: id,
            name: 'Peserta',
            createdAt: now,
            updatedAt: now,
          ),
        ),
      );
      final representedOwners = _participants
          .map((participant) => participant.ownerId)
          .toSet();
      for (final member in bundle.members) {
        final data = member.data();
        final role = data['role']?.toString().toLowerCase() ?? '';
        final userId = data['userId']?.toString().trim() ?? member.id;
        if (role == 'facilitator' ||
            userId.isEmpty ||
            representedOwners.contains(userId) ||
            _participants.any((participant) => participant.id == userId)) {
          continue;
        }
        _participants.add(
          Participant(
            id: userId,
            ownerId: userId,
            name:
                (data['name'] ?? data['fullName'])
                        ?.toString()
                        .trim()
                        .isNotEmpty ==
                    true
                ? (data['name'] ?? data['fullName']).toString().trim()
                : 'Peserta',
            createdAt: now,
            updatedAt: now,
          ),
        );
      }
      _filteredParticipants = List.from(_participants);

      print(
        '[FacilitatorStudents] Loaded ${_participants.length} participants',
      );
    } catch (e) {
      print('[FacilitatorStudents] _loadData error: $e');
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
        title: const Text('Pelajar'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(AppTheme.paddingStandard),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Cari pelajar...',
                  prefixIcon: const Icon(
                    Icons.search,
                    color: AppTheme.secondaryText,
                  ),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(
                            Icons.clear,
                            color: AppTheme.secondaryText,
                          ),
                          onPressed: () {
                            _searchController.clear();
                          },
                        )
                      : null,
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: AppTheme.paddingMedium,
                    vertical: AppTheme.paddingMedium,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                    borderSide: const BorderSide(color: AppTheme.dividerColor),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                    borderSide: const BorderSide(color: AppTheme.dividerColor),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                    borderSide: const BorderSide(
                      color: AppTheme.forestGreen,
                      width: 2,
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: AppTheme.forestGreen,
                      ),
                    )
                  : _filteredParticipants.isEmpty
                  ? _buildEmptyState()
                  : RefreshIndicator(
                      onRefresh: _loadData,
                      color: AppTheme.forestGreen,
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppTheme.paddingStandard,
                        ),
                        itemCount: _filteredParticipants.length,
                        itemBuilder: (context, index) {
                          return _buildStudentRow(_filteredParticipants[index]);
                        },
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.paddingXLarge),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.person_off_outlined,
              size: 64,
              color: AppTheme.secondaryText,
            ),
            const SizedBox(height: AppTheme.paddingMedium),
            const Text(
              'Tiada pelajar',
              style: TextStyle(
                fontSize: AppTheme.fontSizeHeadline,
                fontWeight: AppTheme.weightSemiBold,
                color: AppTheme.onSurface,
              ),
            ),
            const SizedBox(height: AppTheme.paddingSmall),
            Text(
              _searchController.text.isNotEmpty
                  ? 'Tiada pelajar ditemui untuk carian ini'
                  : 'Tambah pelajar untuk memulakan',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: AppTheme.fontSizeBody,
                color: AppTheme.secondaryText,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStudentRow(Participant participant) {
    final participantSessions = _sessions
        .where((s) => s.participantId == participant.id)
        .toList();
    final completedCount = participantSessions
        .where((s) => s.isCompleted)
        .length;
    final totalSessions = participantSessions.length;
    final progress = totalSessions > 0
        ? participantSessions.fold<double>(
                0,
                (sum, session) => sum + session.progress,
              ) /
              totalSessions
        : 0.0;
    final scorePercent = (progress * 100).toInt();

    final initials = participant.name.isNotEmpty
        ? participant.name.substring(0, 1).toUpperCase()
        : '?';

    final avatarColors = [
      AppTheme.forestGreen,
      AppTheme.softBlue,
      AppTheme.softOrange,
      AppTheme.lavender,
    ];
    final colorIndex = participant.name.hashCode.abs() % avatarColors.length;

    // Star rating based on completion count (max 4)
    final starCount = completedCount > 4 ? 4 : completedCount;

    return GestureDetector(
      onTap: () {
        print('[FacilitatorStudents] Tap participant: ${participant.id}');
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => FacilitatorParticipantDetailView(
              participant: {
                'id': participant.id ?? '',
                'name': participant.name,
              },
            ),
          ),
        );
      },
      child: Container(
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
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: avatarColors[colorIndex].withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  initials,
                  style: TextStyle(
                    fontSize: AppTheme.fontSizeBody,
                    fontWeight: AppTheme.weightBold,
                    color: avatarColors[colorIndex],
                  ),
                ),
              ),
            ),
            const SizedBox(width: AppTheme.paddingMedium),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    participant.name,
                    style: const TextStyle(
                      fontSize: AppTheme.fontSizeBody,
                      fontWeight: AppTheme.weightSemiBold,
                      color: AppTheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: List.generate(4, (index) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 2),
                        child: Icon(
                          index < starCount ? Icons.star : Icons.star_border,
                          size: 16,
                          color: index < starCount
                              ? AppTheme.softYellow
                              : AppTheme.dividerColor,
                        ),
                      );
                    }),
                  ),
                ],
              ),
            ),
            Text(
              '$scorePercent%',
              style: const TextStyle(
                fontSize: AppTheme.fontSizeBody,
                fontWeight: AppTheme.weightBold,
                color: AppTheme.forestGreen,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
