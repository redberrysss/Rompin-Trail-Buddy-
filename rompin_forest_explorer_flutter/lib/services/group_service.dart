import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GroupService {
  GroupService._();

  static final GroupService instance = GroupService._();
  static const _groupCodeKey = 'groupCode';

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<String?> getCurrentGroupCode() async {
    final preferences = await SharedPreferences.getInstance();
    return preferences.getString(_groupCodeKey);
  }

  Future<void> _setCurrentGroupCode(String? code) async {
    final preferences = await SharedPreferences.getInstance();
    if (code == null) {
      await preferences.remove(_groupCodeKey);
    } else {
      await preferences.setString(_groupCodeKey, code);
    }
  }

  Future<String?> restoreGroupForUser(String userId) async {
    final savedCode = await getCurrentGroupCode();
    if (savedCode != null && savedCode.isNotEmpty) return savedCode;

    final userDocument = await _firestore.collection('users').doc(userId).get();
    final profileCode = userDocument.data()?['groupCode']?.toString().trim();
    if (profileCode != null && profileCode.isNotEmpty) {
      await _setCurrentGroupCode(profileCode);
      return profileCode;
    }

    final snapshot = await _firestore
        .collectionGroup('members')
        .where('userId', isEqualTo: userId)
        .limit(1)
        .get();
    if (snapshot.docs.isEmpty) return null;

    final code = snapshot.docs.first.reference.parent.parent?.id;
    if (code != null && code.isNotEmpty) {
      await _firestore.collection('users').doc(userId).set({
        'groupCode': code,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    }
    await _setCurrentGroupCode(code);
    return code;
  }

  Future<String> createGroup({
    required String facilitatorId,
    required String facilitatorName,
  }) async {
    const characters = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
    final random = Random.secure();
    final code = List.generate(
      6,
      (_) => characters[random.nextInt(characters.length)],
    ).join();
    final group = _firestore.collection('groups').doc(code);
    final batch = _firestore.batch();
    batch.set(group, {
      'code': code,
      'facilitatorId': facilitatorId,
      'facilitatorName': facilitatorName,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
    batch.set(group.collection('members').doc(facilitatorId), {
      'userId': facilitatorId,
      'name': facilitatorName,
      'role': 'facilitator',
      'joinedAt': FieldValue.serverTimestamp(),
    });
    await batch.commit();
    await _firestore.collection('users').doc(facilitatorId).set({
      'groupCode': code,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
    await _setCurrentGroupCode(code);
    return code;
  }

  Future<void> joinGroup({
    required String code,
    required String userId,
    required String userName,
    required String role,
  }) async {
    final normalizedCode = code.trim().toUpperCase();
    final group = _firestore.collection('groups').doc(normalizedCode);
    if (!(await group.get()).exists) {
      throw StateError('Kumpulan tidak dijumpai. Pastikan kod kumpulan betul.');
    }
    await group.collection('members').doc(userId).set({
      'userId': userId,
      'name': userName,
      'role': role,
      'joinedAt': FieldValue.serverTimestamp(),
    });
    await _firestore.collection('users').doc(userId).set({
      'groupCode': normalizedCode,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
    if (role == 'participant') {
      await group.collection('participants').doc(userId).set({
        'id': userId,
        'ownerId': userId,
        'name': userName,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    }
    await _setCurrentGroupCode(normalizedCode);
  }

  Future<void> leaveGroup() => _setCurrentGroupCode(null);

  CollectionReference<Map<String, dynamic>> groupCollection(
    String code,
    String collection,
  ) => _firestore.collection('groups').doc(code).collection(collection);
}
