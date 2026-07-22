import 'package:cloud_firestore/cloud_firestore.dart';

class ProgressService {
  static final ProgressService instance = ProgressService._();
  ProgressService._();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<Map<String, dynamic>?> getProgress(
    String userId,
    String activityId,
  ) async {
    print(
      '[ProgressService] getProgress: userId=$userId, activityId=$activityId',
    );
    final doc = await _firestore
        .collection('users')
        .doc(userId)
        .collection('progress')
        .doc(activityId)
        .get();
    return doc.data();
  }

  Future<void> saveProgress(
    String userId,
    String activityId,
    Map<String, dynamic> data,
  ) async {
    print(
      '[ProgressService] saveProgress: userId=$userId, activityId=$activityId',
    );
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('progress')
        .doc(activityId)
        .set(data, SetOptions(merge: true));
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> streamProgress(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('progress')
        .orderBy('updatedAt', descending: true)
        .snapshots();
  }
}
