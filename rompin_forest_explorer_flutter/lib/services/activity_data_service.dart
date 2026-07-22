import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../models/student_discovery.dart';
import '../models/student_activity_progress.dart';
import 'firestore_service.dart';
import 'group_service.dart';
import 'storage_service.dart';
import 'auth_service.dart';

class ActivityDataBundle {
  const ActivityDataBundle({
    required this.groupCode,
    required this.members,
    required this.participants,
    required this.sessions,
    required this.observations,
    required this.sensoryRecords,
    required this.treasureRecords,
    required this.artworks,
    required this.discoveries,
  });

  final String? groupCode;
  final List<QueryDocumentSnapshot<Map<String, dynamic>>> members;
  final List<QueryDocumentSnapshot<Map<String, dynamic>>> participants;
  final List<QueryDocumentSnapshot<Map<String, dynamic>>> sessions;
  final List<QueryDocumentSnapshot<Map<String, dynamic>>> observations;
  final List<QueryDocumentSnapshot<Map<String, dynamic>>> sensoryRecords;
  final List<QueryDocumentSnapshot<Map<String, dynamic>>> treasureRecords;
  final List<QueryDocumentSnapshot<Map<String, dynamic>>> artworks;
  final List<QueryDocumentSnapshot<Map<String, dynamic>>> discoveries;
}

class ActivityDataService {
  ActivityDataService._();

  static final ActivityDataService instance = ActivityDataService._();

  final FirestoreService _firestore = FirestoreService.instance;
  final GroupService _groups = GroupService.instance;
  final FirebaseFirestore _firebase = FirebaseFirestore.instance;
  final StorageService _storage = StorageService.instance;

  Future<ActivityDataBundle> loadForCurrentUser() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw StateError('Sila log masuk.');

    final storedRole = await AuthService.instance.fetchUserRole(user.uid);
    if (AuthService.instance.normalizeRole(storedRole ?? '') == 'fasilitator') {
      return _loadAllStudentDataForFacilitator();
    }

    String? groupCode;
    try {
      groupCode = await _groups.restoreGroupForUser(user.uid);
    } catch (_) {
      groupCode = await _groups.getCurrentGroupCode();
    }

    if (groupCode == null) {
      final results = await Future.wait([
        _firestore.userCollection(user.uid, 'participants').get(),
        _firestore.userCollection(user.uid, 'activitySessions').get(),
        _firestore.userCollection(user.uid, 'observations').get(),
        _firestore.userCollection(user.uid, 'sensoryRecords').get(),
        _firestore.userCollection(user.uid, 'treasureRecords').get(),
        _firestore.userCollection(user.uid, 'artworks').get(),
        _firestore.userCollection(user.uid, 'discoveries').get(),
      ]);
      return ActivityDataBundle(
        groupCode: null,
        members: const [],
        participants: results[0].docs,
        sessions: results[1].docs,
        observations: results[2].docs,
        sensoryRecords: results[3].docs,
        treasureRecords: results[4].docs,
        artworks: results[5].docs,
        discoveries: results[6].docs,
      );
    }

    final groupResults = await Future.wait([
      _firestore.groupCollection(groupCode, 'members').get(),
      _firestore.groupCollection(groupCode, 'participants').get(),
      _firestore.groupCollection(groupCode, 'sessions').get(),
      _firestore.groupCollection(groupCode, 'observations').get(),
      _firestore.groupCollection(groupCode, 'sensoryRecords').get(),
      _firestore.groupCollection(groupCode, 'treasureRecords').get(),
      _firestore.groupCollection(groupCode, 'artworks').get(),
      _firestore.groupCollection(groupCode, 'discoveries').get(),
    ]);

    final memberIds = groupResults[0].docs
        .map((document) => document.data()['userId']?.toString().trim() ?? '')
        .where((id) => id.isNotEmpty)
        .toSet();
    final personalResults = await Future.wait(
      memberIds.map((memberId) async {
        final snapshots = await Future.wait([
          _firestore.userCollection(memberId, 'participants').get(),
          _firestore.userCollection(memberId, 'activitySessions').get(),
          _firestore.userCollection(memberId, 'observations').get(),
          _firestore.userCollection(memberId, 'sensoryRecords').get(),
          _firestore.userCollection(memberId, 'treasureRecords').get(),
          _firestore.userCollection(memberId, 'artworks').get(),
          _firestore.userCollection(memberId, 'discoveries').get(),
        ]);
        return snapshots;
      }),
    );

    List<QueryDocumentSnapshot<Map<String, dynamic>>> combined(
      int groupIndex,
      int personalIndex,
    ) {
      final byIdentity =
          <String, QueryDocumentSnapshot<Map<String, dynamic>>>{};
      for (final document in groupResults[groupIndex].docs) {
        final data = document.data();
        final owner = data['ownerId'] ?? data['userId'] ?? '';
        byIdentity['$owner:${document.id}'] = document;
      }
      for (final memberSnapshots in personalResults) {
        for (final document in memberSnapshots[personalIndex].docs) {
          final data = document.data();
          final owner = data['ownerId'] ?? data['userId'] ?? '';
          byIdentity.putIfAbsent('$owner:${document.id}', () => document);
        }
      }
      return byIdentity.values.toList();
    }

    return ActivityDataBundle(
      groupCode: groupCode,
      members: groupResults[0].docs,
      participants: combined(1, 0),
      sessions: combined(2, 1),
      observations: combined(3, 2),
      sensoryRecords: combined(4, 3),
      treasureRecords: combined(5, 4),
      artworks: combined(6, 5),
      discoveries: combined(7, 6),
    );
  }

  Future<ActivityDataBundle> _loadAllStudentDataForFacilitator() async {
    final users = await _firebase.collection('users').get();
    final students = users.docs.where((document) {
      final role = AuthService.instance.roleFromData(document.data()) ?? '';
      return AuthService.instance.normalizeRole(role) == 'pelajar';
    }).toList();

    debugPrint(
      '[FacilitatorData] User profiles: ${users.docs.length}; '
      'student profiles: ${students.length}',
    );

    final results = await Future.wait(
      users.docs.map((owner) async {
        return Future.wait([
          _firestore.userCollection(owner.id, 'participants').get(),
          _firestore.userCollection(owner.id, 'activitySessions').get(),
          _firestore.userCollection(owner.id, 'observations').get(),
          _firestore.userCollection(owner.id, 'sensoryRecords').get(),
          _firestore.userCollection(owner.id, 'treasureRecords').get(),
          _firestore.userCollection(owner.id, 'artworks').get(),
          _firestore.userCollection(owner.id, 'discoveries').get(),
        ]);
      }),
    );

    final legacy = await Future.wait([
      _readOptionalTopLevel('participants'),
      _readOptionalTopLevel('activity_sessions'),
      _readOptionalTopLevel('activitySessions'),
      _readOptionalTopLevel('observations'),
      _readOptionalTopLevel('observation_records'),
      _readOptionalTopLevel('sensory_records'),
      _readOptionalTopLevel('sensoryRecords'),
      _readOptionalTopLevel('treasure_records'),
      _readOptionalTopLevel('treasureRecords'),
      _readOptionalTopLevel('artworks'),
      _readOptionalTopLevel('artwork_records'),
      _readOptionalTopLevel('discoveries'),
      _readOptionalTopLevel('student_discoveries'),
    ]);

    List<QueryDocumentSnapshot<Map<String, dynamic>>> combined(
      int personalIndex,
      List<int> legacyIndexes,
    ) {
      final unique = <String, QueryDocumentSnapshot<Map<String, dynamic>>>{};
      for (final owner in results) {
        for (final document in owner[personalIndex].docs) {
          final data = document.data();
          final identity =
              data['ownerId'] ?? data['userId'] ?? data['participantId'] ?? '';
          unique['$identity:${document.id}'] = document;
        }
      }
      for (final index in legacyIndexes) {
        for (final document in legacy[index]) {
          final data = document.data();
          final identity =
              data['ownerId'] ?? data['userId'] ?? data['participantId'] ?? '';
          unique.putIfAbsent('$identity:${document.id}', () => document);
        }
      }
      return unique.values.toList();
    }

    final participants = combined(0, const [0]);
    final sessions = combined(1, const [1, 2]);
    final observations = combined(2, const [3, 4]);
    final sensoryRecords = combined(3, const [5, 6]);
    final treasureRecords = combined(4, const [7, 8]);
    final artworks = combined(5, const [9, 10]);
    final discoveries = combined(6, const [11, 12]);

    debugPrint(
      '[FacilitatorData] participants=${participants.length}, '
      'sessions=${sessions.length}, observations=${observations.length}, '
      'sensory=${sensoryRecords.length}, treasures=${treasureRecords.length}, '
      'artworks=${artworks.length}, discoveries=${discoveries.length}',
    );

    return ActivityDataBundle(
      groupCode: null,
      members: students,
      participants: participants,
      sessions: sessions,
      observations: observations,
      sensoryRecords: sensoryRecords,
      treasureRecords: treasureRecords,
      artworks: artworks,
      discoveries: discoveries,
    );
  }

  Future<List<QueryDocumentSnapshot<Map<String, dynamic>>>>
  _readOptionalTopLevel(String collection) async {
    try {
      return (await _firebase.collection(collection).get()).docs;
    } on FirebaseException catch (error, stackTrace) {
      debugPrint(
        '[FacilitatorData] Optional collection $collection unavailable: '
        '${error.code} ${error.message}',
      );
      debugPrintStack(stackTrace: stackTrace);
      return const [];
    }
  }

  Future<void> saveRecord({
    required String personalCollection,
    required String groupCollection,
    required String id,
    required Map<String, dynamic> data,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw StateError('Sila log masuk.');
    await _firestore.setUserDoc(user.uid, personalCollection, id, data);
    await _firebase.collection('users').doc(user.uid).set({
      'lastDataUpdatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    String? groupCode;
    try {
      groupCode = await _groups.restoreGroupForUser(user.uid);
    } on FirebaseException catch (error, stackTrace) {
      debugPrint(
        '[ActivityDataService] Unable to restore group before upload: '
        '${error.code} ${error.message}',
      );
      debugPrintStack(stackTrace: stackTrace);
      groupCode = await _groups.getCurrentGroupCode();
    }
    if (groupCode != null) {
      try {
        await _firestore.setGroupDoc(groupCode, groupCollection, id, data);
      } on FirebaseException catch (error, stackTrace) {
        debugPrint(
          '[ActivityDataService] Personal record saved, but group mirror '
          'failed: ${error.code} ${error.message}',
        );
        debugPrintStack(stackTrace: stackTrace);
      }
    }
  }

  Future<Map<int, StudentActivityProgress>> loadStudentProgress(
    String participantId,
  ) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw StateError('Sila log masuk.');
    final normalizedId = participantId.trim();
    if (normalizedId.isEmpty || normalizedId != user.uid) {
      throw StateError('ID peserta tidak sepadan dengan pengguna semasa.');
    }

    final snapshot = await _firestore
        .userCollection(user.uid, 'activitySessions')
        .get();
    final result = <int, StudentActivityProgress>{};
    for (final document in snapshot.docs) {
      try {
        final data = document.data();
        if (data['participantId']?.toString().trim() != normalizedId) {
          continue;
        }
        final progress = StudentActivityProgress.fromMap(data);
        if (progress.activityNumber < 1 || progress.activityNumber > 4) {
          continue;
        }
        final existing = result[progress.activityNumber];
        if (existing == null || progress.progress > existing.progress) {
          result[progress.activityNumber] = progress;
        }
      } catch (error, stackTrace) {
        debugPrint(
          '[ActivityDataService] Invalid progress document '
          '${document.id}: $error',
        );
        debugPrintStack(stackTrace: stackTrace);
      }
    }
    return result;
  }

  Future<void> saveActivityProgress({
    required String participantId,
    required int activityNumber,
    required double progress,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw StateError('Sila log masuk.');
    final normalizedProgress = progress.clamp(0.0, 1.0);
    final id = '${participantId}_activity_$activityNumber';
    final data = <String, dynamic>{
      'id': id,
      'ownerId': user.uid,
      'participantId': participantId,
      'activityNumber': activityNumber,
      'startedAt': FieldValue.serverTimestamp(),
      'completedAt': normalizedProgress >= 1
          ? FieldValue.serverTimestamp()
          : null,
      'isCompleted': normalizedProgress >= 1,
      'isSkipped': false,
      'progress': normalizedProgress,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
    await saveRecord(
      personalCollection: 'activitySessions',
      groupCollection: 'sessions',
      id: id,
      data: data,
    );
  }

  Future<StudentDiscoveryResult> loadStudentDiscoveries(
    String participantId,
  ) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw StateError('Sila log masuk.');
    final normalizedId = participantId.trim();
    if (normalizedId.isEmpty) {
      throw ArgumentError.value(
        participantId,
        'participantId',
        'ID peserta kosong.',
      );
    }
    if (normalizedId != user.uid) {
      throw StateError(
        'ID peserta tidak sepadan dengan pengguna yang sedang log masuk.',
      );
    }

    debugPrint('[Discoveries] Current auth UID: ${user.uid}');
    debugPrint('[Discoveries] Participant ID: $normalizedId');
    debugPrint('[Discoveries] Query field: participantId');

    final sources = <_DiscoverySource>[
      _DiscoverySource.user('observations', StudentDiscoveryType.observation),
      _DiscoverySource.user('sensoryRecords', StudentDiscoveryType.sensory),
      _DiscoverySource.user('treasureRecords', StudentDiscoveryType.treasure),
      _DiscoverySource.user('artworks', StudentDiscoveryType.artwork),
      _DiscoverySource.user('discoveries', StudentDiscoveryType.observation),
      _DiscoverySource.legacy('observations', StudentDiscoveryType.observation),
      _DiscoverySource.legacy(
        'observation_records',
        StudentDiscoveryType.observation,
      ),
      _DiscoverySource.legacy('sensory_records', StudentDiscoveryType.sensory),
      _DiscoverySource.legacy(
        'treasure_records',
        StudentDiscoveryType.treasure,
      ),
      _DiscoverySource.legacy('artworks', StudentDiscoveryType.artwork),
      _DiscoverySource.legacy('artwork_records', StudentDiscoveryType.artwork),
      _DiscoverySource.legacy('discoveries', StudentDiscoveryType.observation),
      _DiscoverySource.legacy(
        'student_discoveries',
        StudentDiscoveryType.observation,
      ),
    ];

    final items = <StudentDiscovery>[];
    final errors = <String>[];
    var successfulSources = 0;

    for (final source in sources) {
      final path = source.isLegacy
          ? source.collection
          : 'users/${user.uid}/${source.collection}';
      debugPrint('[Discoveries] Query collection: $path');
      try {
        final snapshot = source.isLegacy
            ? await _firebase
                  .collection(source.collection)
                  .where('participantId', isEqualTo: normalizedId)
                  .get()
            : await _firestore
                  .userCollection(user.uid, source.collection)
                  .get();
        successfulSources++;
        debugPrint(
          '[Discoveries] Query result count for $path: ${snapshot.docs.length}',
        );

        for (final document in snapshot.docs) {
          final data = document.data();
          debugPrint('[Discoveries] Document $path/${document.id}: $data');
          try {
            final documentParticipantId = _firstString(data, const [
              'participantId',
              'studentId',
              'userId',
              'ownerId',
              'uid',
              'createdBy',
            ]);
            if (documentParticipantId != normalizedId) {
              debugPrint(
                '[Discoveries] Skipped ${document.id}: participant '
                '"$documentParticipantId" does not match "$normalizedId".',
              );
              continue;
            }

            final imageValue = _imageValue(data, source.type);
            final imageUrl = await _storage.resolveImageUrl(imageValue);
            if (imageValue.isEmpty) {
              debugPrint(
                '[Discoveries] Document ${document.id} has no image value.',
              );
            } else if (imageUrl == null) {
              debugPrint(
                '[Discoveries] Document ${document.id} has an unusable image '
                'value: $imageValue',
              );
            }
            items.add(
              StudentDiscovery(
                id: document.id,
                participantId: documentParticipantId,
                title: _title(data, source.type),
                subtitle: _subtitle(data, source.type),
                type: source.type,
                createdAt: _parseDateTime(
                  data['createdAt'] ?? data['uploadedAt'] ?? data['timestamp'],
                ),
                imageValue: imageValue,
                imageUrl: imageUrl,
                source: path,
              ),
            );
          } catch (error, stackTrace) {
            debugPrint(
              '[Discoveries] Malformed document $path/${document.id}: $error',
            );
            debugPrintStack(stackTrace: stackTrace);
          }
        }
      } on FirebaseException catch (error, stackTrace) {
        final message = '$path: ${error.code} ${error.message ?? ''}'.trim();
        errors.add(message);
        debugPrint('[Discoveries] Firestore error $message');
        debugPrintStack(stackTrace: stackTrace);
      }
    }

    if (successfulSources == 0 && errors.isNotEmpty) {
      throw FirebaseException(
        plugin: 'cloud_firestore',
        code: 'discovery-load-failed',
        message: errors.join('\n'),
      );
    }

    final unique = <String, StudentDiscovery>{};
    for (final item in items) {
      final key = '${item.type.name}:${item.id}:${item.imageValue}';
      unique[key] = item;
    }
    final sorted = unique.values.toList()
      ..sort((a, b) {
        final aDate = a.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
        final bDate = b.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
        return bDate.compareTo(aDate);
      });
    debugPrint('[Discoveries] Combined discovery count: ${sorted.length}');
    if (sorted.isEmpty && errors.isNotEmpty) {
      throw FirebaseException(
        plugin: 'cloud_firestore',
        code: 'partial-discovery-load-failed',
        message: errors.join('\n'),
      );
    }
    return StudentDiscoveryResult(items: sorted, sourceErrors: errors);
  }

  static String _firstString(Map<String, dynamic> data, List<String> keys) {
    for (final key in keys) {
      final value = data[key];
      if (value != null && value.toString().trim().isNotEmpty) {
        return value.toString().trim();
      }
    }
    return '';
  }

  static String _imageValue(
    Map<String, dynamic> data,
    StudentDiscoveryType type,
  ) {
    final keys = type == StudentDiscoveryType.artwork
        ? const [
            'artworkDownloadURL',
            'artworkDownloadUrl',
            'artworkStoragePath',
            'artworkImagePath',
            'imageDownloadURL',
            'imageUrl',
          ]
        : const [
            'imageDownloadURL',
            'imageDownloadUrl',
            'imageUrl',
            'photoUrl',
            'downloadUrl',
            'storageUrl',
            'imageStoragePath',
            'localPath',
          ];
    return _firstString(data, keys);
  }

  static String _title(Map<String, dynamic> data, StudentDiscoveryType type) {
    final value = switch (type) {
      StudentDiscoveryType.observation => _firstString(data, const [
        'objectName',
        'detectedLabel',
        'title',
        'name',
      ]),
      StudentDiscoveryType.sensory => _firstString(data, const [
        'selectedValue',
        'senseType',
        'title',
      ]),
      StudentDiscoveryType.treasure => _firstString(data, const [
        'itemName',
        'title',
        'name',
      ]),
      StudentDiscoveryType.artwork => _firstString(data, const [
        'title',
        'artworkType',
        'name',
      ]),
    };
    return value.isEmpty ? _typeLabel(type) : value;
  }

  static String _subtitle(
    Map<String, dynamic> data,
    StudentDiscoveryType type,
  ) {
    if (type == StudentDiscoveryType.sensory) {
      final station = data['stationNumber'];
      return station == null ? 'Sensori Alam' : 'Sensori Stesen $station';
    }
    return _typeLabel(type);
  }

  static String _typeLabel(StudentDiscoveryType type) => switch (type) {
    StudentDiscoveryType.observation => 'Jelajah Hutan',
    StudentDiscoveryType.sensory => 'Sensori Alam',
    StudentDiscoveryType.treasure => 'Treasure Hunt',
    StudentDiscoveryType.artwork => 'Seni Alam',
  };

  static DateTime? _parseDateTime(dynamic value) {
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value);
    if (value is num) return DateTime.fromMillisecondsSinceEpoch(value.toInt());
    return null;
  }
}

class _DiscoverySource {
  const _DiscoverySource.user(this.collection, this.type) : isLegacy = false;
  const _DiscoverySource.legacy(this.collection, this.type) : isLegacy = true;

  final String collection;
  final StudentDiscoveryType type;
  final bool isLegacy;
}
