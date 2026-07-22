import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../services/firestore_service.dart';
import '../../services/activity_data_service.dart';
import '../../services/group_service.dart';
import '../../models/participant.dart';
import '../../models/activity_session.dart';
import '../../models/observation_record.dart';
import '../../models/sensory_record.dart';
import '../../models/treasure_record.dart';
import '../../models/artwork_record.dart';
import 'facilitator_students_view.dart';
import 'facilitator_activities_view.dart';
import 'facilitator_reports_view.dart';
import 'facilitator_participant_detail_view.dart';

class FacilitatorDashboardView extends StatefulWidget {
  const FacilitatorDashboardView({super.key});

  @override
  State<FacilitatorDashboardView> createState() =>
      _FacilitatorDashboardViewState();
}

class _FacilitatorDashboardViewState extends State<FacilitatorDashboardView> {
  final FirestoreService _firestore = FirestoreService.instance;

  List<Participant> _participants = [];
  List<ActivitySession> _sessions = [];
  List<ObservationRecord> _observations = [];
  List<SensoryRecord> _sensoryRecords = [];
  List<TreasureRecord> _treasureRecords = [];
  List<ArtworkRecord> _artworks = [];
  bool _isLoading = true;
  String _userName = '';
  String? _groupCode;
  String? _loadError;
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _usersSubscription;
  Timer? _reloadTimer;

  @override
  void initState() {
    super.initState();
    print('[FacilitatorDashboard] initState');
    _loadData();
    _usersSubscription = FirebaseFirestore.instance
        .collection('users')
        .snapshots()
        .listen((_) {
          _reloadTimer?.cancel();
          _reloadTimer = Timer(const Duration(milliseconds: 400), () {
            if (mounted && !_isLoading) _loadData();
          });
        });
  }

  @override
  void dispose() {
    _reloadTimer?.cancel();
    _usersSubscription?.cancel();
    super.dispose();
  }

  Future<void> _loadData() async {
    print('[FacilitatorDashboard] _loadData');
    setState(() => _isLoading = true);

    try {
      final authVM = context.read<AuthViewModel>();
      final user = authVM.user;
      if (user != null) {
        final userDoc = await _firestore.getDoc('users', user.uid);
        if (userDoc.exists) {
          final data = userDoc.data();
          _userName = data?['fullName'] as String? ?? user.displayName ?? '';
        }
      }

      final bundle = await ActivityDataService.instance.loadForCurrentUser();
      _groupCode = bundle.groupCode;
      _participants = _parseDocuments(
        bundle.participants,
        'participant',
        (document) => Participant.fromMap(document.data(), id: document.id),
      );
      _sessions = _parseDocuments(
        bundle.sessions,
        'session',
        (document) => ActivitySession.fromMap(document.data(), id: document.id),
      );
      _observations = _parseDocuments(
        bundle.observations,
        'observation',
        (document) =>
            ObservationRecord.fromMap(document.data(), id: document.id),
      );
      _sensoryRecords = _parseDocuments(
        bundle.sensoryRecords,
        'sensory',
        (document) => SensoryRecord.fromMap(document.data(), id: document.id),
      );
      _treasureRecords = _parseDocuments(
        bundle.treasureRecords,
        'treasure',
        (document) => TreasureRecord.fromMap(document.data(), id: document.id),
      );
      _artworks = _parseDocuments(
        bundle.artworks,
        'artwork',
        (document) => ArtworkRecord.fromMap(document.data(), id: document.id),
      );

      for (final document in bundle.discoveries) {
        final data = Map<String, dynamic>.from(document.data());
        data['participantId'] = _recordParticipantId(data);
        _observations.add(ObservationRecord.fromMap(data, id: document.id));
      }

      _addStudentMembers(bundle.members);

      _addParticipantsReferencedByRecords();
      _loadError = null;

      print(
        '[FacilitatorDashboard] Loaded: ${_participants.length} participants, ${_sessions.length} sessions, ${_observations.length} observations',
      );
    } catch (e) {
      print('[FacilitatorDashboard] _loadData error: $e');
      _loadError = e.toString();
    }

    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  int get _activeSessions =>
      _sessions.where((s) => !s.isCompleted && !s.isSkipped).length;

  int get _completedSessions => _sessions.where((s) => s.isCompleted).length;

  int get _participantCount => _participants.length;

  int get _discoveryCount =>
      _observations.length +
      _sensoryRecords.length +
      _treasureRecords.length +
      _artworks.length;

  List<T> _parseDocuments<T>(
    List<QueryDocumentSnapshot<Map<String, dynamic>>> documents,
    String type,
    T Function(QueryDocumentSnapshot<Map<String, dynamic>>) parser,
  ) {
    final parsed = <T>[];
    for (final document in documents) {
      try {
        parsed.add(parser(document));
      } catch (error, stackTrace) {
        debugPrint(
          '[FacilitatorDashboard] Invalid $type ${document.reference.path}: '
          '$error',
        );
        debugPrintStack(stackTrace: stackTrace);
      }
    }
    return parsed;
  }

  String _recordParticipantId(Map<String, dynamic> data) {
    for (final field in const [
      'participantId',
      'studentId',
      'userId',
      'ownerId',
      'uid',
    ]) {
      final value = data[field]?.toString().trim() ?? '';
      if (value.isNotEmpty) return value;
    }
    return '';
  }

  void _addStudentMembers(
    List<QueryDocumentSnapshot<Map<String, dynamic>>> members,
  ) {
    final representedOwners = _participants
        .map((participant) => participant.ownerId)
        .where((id) => id.isNotEmpty)
        .toSet();
    final representedIds = _participants
        .map((participant) => participant.id)
        .toSet();
    final now = DateTime.now();
    for (final member in members) {
      final data = member.data();
      final role = data['role']?.toString().toLowerCase() ?? '';
      final userId = data['userId']?.toString().trim() ?? member.id;
      if (role == 'facilitator' ||
          userId.isEmpty ||
          representedOwners.contains(userId) ||
          representedIds.contains(userId)) {
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
  }

  void _addParticipantsReferencedByRecords() {
    final existing = _participants.map((participant) => participant.id).toSet();
    final ids = <String>{
      ..._sessions.map((record) => record.participantId),
      ..._observations.map((record) => record.participantId),
      ..._sensoryRecords.map((record) => record.participantId),
      ..._treasureRecords.map((record) => record.participantId),
      ..._artworks.map((record) => record.participantId),
    }..removeWhere((id) => id.isEmpty || existing.contains(id));
    final now = DateTime.now();
    _participants.addAll(
      ids.map(
        (id) => Participant(
          id: id,
          ownerId: id,
          name: 'Peserta',
          createdAt: now,
          updatedAt: now,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.creamBackground,
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
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppTheme.paddingStandard,
                    vertical: AppTheme.paddingMedium,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildWelcomeHeader(),
                      const SizedBox(height: AppTheme.paddingLarge),
                      _buildGroupStatus(),
                      const SizedBox(height: AppTheme.paddingLarge),
                      if (_loadError != null) ...[
                        _buildLoadError(),
                        const SizedBox(height: AppTheme.paddingLarge),
                      ],
                      _buildStatsGrid(),
                      const SizedBox(height: AppTheme.paddingLarge),
                      _buildQuickActions(),
                      const SizedBox(height: AppTheme.paddingLarge),
                      _buildParticipantsSection(),
                      const SizedBox(height: AppTheme.paddingXLarge),
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildWelcomeHeader() {
    return Container(
      padding: const EdgeInsets.all(AppTheme.paddingLarge),
      decoration: BoxDecoration(
        gradient: AppTheme.primaryGradient,
        borderRadius: BorderRadius.circular(AppTheme.radiusCard),
        boxShadow: [
          BoxShadow(
            color: AppTheme.forestGreen.withValues(alpha: 0.3),
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
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.settings_outlined,
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(width: AppTheme.paddingMedium),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Selamat datang, ${_userName.isNotEmpty ? _userName : 'Fasilitator'}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: AppTheme.fontSizeHeadline,
                    fontWeight: AppTheme.weightBold,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Panel kawalan kumpulan',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: AppTheme.fontSizeBody,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsGrid() {
    final textScale = MediaQuery.textScalerOf(context).scale(1);
    final stats = [
      _StatItem(
        label: 'Peserta',
        value: '$_participantCount',
        icon: Icons.people_outline,
        color: AppTheme.forestGreen,
        bgColor: AppTheme.lightGreen.withValues(alpha: 0.3),
      ),
      _StatItem(
        label: 'Aktif',
        value: '$_activeSessions',
        icon: Icons.play_circle_outline,
        color: AppTheme.softBlue,
        bgColor: AppTheme.softBlue.withValues(alpha: 0.15),
      ),
      _StatItem(
        label: 'Selesai',
        value: '$_completedSessions',
        icon: Icons.check_circle_outline,
        color: AppTheme.successGreen,
        bgColor: AppTheme.successGreen.withValues(alpha: 0.15),
      ),
      _StatItem(
        label: 'Penemuan',
        value: '$_discoveryCount',
        icon: Icons.star_outline,
        color: AppTheme.softOrange,
        bgColor: AppTheme.softOrange.withValues(alpha: 0.15),
      ),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: AppTheme.paddingSmall,
        crossAxisSpacing: AppTheme.paddingSmall,
        mainAxisExtent: 135 + (textScale - 1).clamp(0, 1) * 45,
      ),
      itemCount: stats.length,
      itemBuilder: (context, index) {
        final stat = stats[index];
        return Container(
          padding: const EdgeInsets.all(AppTheme.paddingMedium),
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
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: stat.bgColor,
                  shape: BoxShape.circle,
                ),
                child: Icon(stat.icon, color: stat.color, size: 20),
              ),
              const SizedBox(height: AppTheme.paddingSmall),
              Text(
                stat.value,
                style: TextStyle(
                  fontSize: AppTheme.fontSizeHeadline,
                  fontWeight: AppTheme.weightBold,
                  color: stat.color,
                ),
              ),
              Flexible(
                child: Text(
                  stat.label,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: AppTheme.fontSizeCaption,
                    color: AppTheme.secondaryText,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildGroupStatus() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppTheme.paddingMedium),
      decoration: BoxDecoration(
        color: AppTheme.cardBackground,
        borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
        border: Border.all(color: AppTheme.dividerColor),
      ),
      child: Row(
        children: [
          const Icon(Icons.groups_rounded, color: AppTheme.forestGreen),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _groupCode == null
                      ? 'Tiada kumpulan aktif'
                      : 'Kumpulan $_groupCode',
                  style: const TextStyle(fontWeight: AppTheme.weightSemiBold),
                ),
                Text(
                  _groupCode == null
                      ? 'Cipta atau sertai kumpulan untuk melihat data peserta.'
                      : 'Data dan gambar peserta diselaraskan melalui kumpulan ini.',
                  style: const TextStyle(
                    fontSize: AppTheme.fontSizeCaption,
                    color: AppTheme.secondaryText,
                  ),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: _showGroupDialog,
            child: Text(_groupCode == null ? 'Urus' : 'Tukar'),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadError() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.gentleCoral.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        'Sebahagian data tidak dapat dimuatkan. Tarik ke bawah untuk cuba lagi.\n$_loadError',
        style: const TextStyle(color: AppTheme.gentleCoral),
      ),
    );
  }

  Future<void> _showGroupDialog() async {
    final controller = TextEditingController();
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Urus Kumpulan'),
        content: TextField(
          controller: controller,
          textCapitalization: TextCapitalization.characters,
          decoration: const InputDecoration(hintText: 'Kod kumpulan'),
        ),
        actions: [
          TextButton(
            onPressed: () async {
              final user = context.read<AuthViewModel>().user;
              if (user == null) return;
              final code = await GroupService.instance.createGroup(
                facilitatorId: user.uid,
                facilitatorName: _userName.isEmpty ? 'Fasilitator' : _userName,
              );
              if (!dialogContext.mounted) return;
              Navigator.pop(dialogContext);
              setState(() => _groupCode = code);
              await _loadData();
            },
            child: const Text('Cipta Baru'),
          ),
          FilledButton(
            onPressed: () async {
              final user = context.read<AuthViewModel>().user;
              if (user == null || controller.text.trim().length < 6) return;
              await GroupService.instance.joinGroup(
                code: controller.text,
                userId: user.uid,
                userName: _userName.isEmpty ? 'Fasilitator' : _userName,
                role: 'facilitator',
              );
              if (!dialogContext.mounted) return;
              Navigator.pop(dialogContext);
              await _loadData();
            },
            child: const Text('Sertai'),
          ),
        ],
      ),
    );
    controller.dispose();
  }

  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Tindakan Pantas',
          style: TextStyle(
            fontSize: AppTheme.fontSizeBody,
            fontWeight: AppTheme.weightSemiBold,
            color: AppTheme.onSurface,
          ),
        ),
        const SizedBox(height: AppTheme.paddingSmall),
        Row(
          children: [
            Expanded(
              child: _QuickActionCard(
                label: 'Tambah Pelajar',
                icon: Icons.person_add_outlined,
                color: AppTheme.forestGreen,
                onTap: () {
                  print('[FacilitatorDashboard] Navigate to Students');
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const FacilitatorStudentsView(),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(width: AppTheme.paddingSmall),
            Expanded(
              child: _QuickActionCard(
                label: 'Aktiviti',
                icon: Icons.forest_outlined,
                color: AppTheme.softBlue,
                onTap: () {
                  print('[FacilitatorDashboard] Navigate to Activities');
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const FacilitatorActivitiesView(),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(width: AppTheme.paddingSmall),
            Expanded(
              child: _QuickActionCard(
                label: 'Laporan',
                icon: Icons.assessment_outlined,
                color: AppTheme.softOrange,
                onTap: () {
                  print('[FacilitatorDashboard] Navigate to Reports');
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const FacilitatorReportsView(),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildParticipantsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Senarai Peserta',
              style: TextStyle(
                fontSize: AppTheme.fontSizeBody,
                fontWeight: AppTheme.weightSemiBold,
                color: AppTheme.onSurface,
              ),
            ),
            Text(
              '${_participants.length} orang',
              style: const TextStyle(
                fontSize: AppTheme.fontSizeCaption,
                color: AppTheme.secondaryText,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppTheme.paddingSmall),
        if (_participants.isEmpty)
          _buildEmptyState()
        else
          ..._participants.map(
            (participant) => _buildParticipantRow(participant),
          ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppTheme.paddingLarge),
      decoration: BoxDecoration(
        color: AppTheme.cardBackground,
        borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
        border: Border.all(color: AppTheme.dividerColor),
      ),
      child: const Column(
        children: [
          Icon(
            Icons.person_off_outlined,
            size: 48,
            color: AppTheme.secondaryText,
          ),
          SizedBox(height: AppTheme.paddingSmall),
          Text(
            'Tiada peserta lagi',
            style: TextStyle(
              fontSize: AppTheme.fontSizeBody,
              fontWeight: AppTheme.weightMedium,
              color: AppTheme.secondaryText,
            ),
          ),
          SizedBox(height: 4),
          Text(
            'Tambah pelajar untuk bermula',
            style: TextStyle(
              fontSize: AppTheme.fontSizeCaption,
              color: AppTheme.secondaryText,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildParticipantRow(Participant participant) {
    final participantSessions = _sessions
        .where((s) => s.participantId == participant.id)
        .toList();
    final progressByActivity = <int, double>{};
    for (final session in participantSessions) {
      progressByActivity.update(
        session.activityNumber,
        (value) => value > session.progress ? value : session.progress,
        ifAbsent: () => session.progress,
      );
    }
    final completedCount = progressByActivity.values
        .where((progress) => progress >= 1)
        .length;
    const totalSessions = 4;
    final progress =
        progressByActivity.values.fold<double>(0, (a, b) => a + b) / 4;
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

    return InkWell(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => FacilitatorParticipantDetailView(
            participant: {'id': participant.id, 'name': participant.name},
          ),
        ),
      ),
      borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
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
              width: 44,
              height: 44,
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
                  const SizedBox(height: 2),
                  Text(
                    '$completedCount / $totalSessions aktiviti',
                    style: const TextStyle(
                      fontSize: AppTheme.fontSizeCaption,
                      color: AppTheme.secondaryText,
                    ),
                  ),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: progress.toDouble(),
                      backgroundColor: AppTheme.dividerColor,
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        AppTheme.forestGreen,
                      ),
                      minHeight: 4,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppTheme.paddingSmall),
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

class _StatItem {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final Color bgColor;

  const _StatItem({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    required this.bgColor,
  });
}

class _QuickActionCard extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionCard({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          vertical: AppTheme.paddingMedium,
          horizontal: AppTheme.paddingSmall,
        ),
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
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: AppTheme.fontSizeCaption,
                fontWeight: AppTheme.weightSemiBold,
                color: AppTheme.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
