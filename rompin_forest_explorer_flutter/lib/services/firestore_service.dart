import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  static final FirestoreService instance = FirestoreService._();
  FirestoreService._();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<DocumentSnapshot<Map<String, dynamic>>> getDoc(
    String collection,
    String id,
  ) {
    return _firestore.collection(collection).doc(id).get();
  }

  Future<void> setDoc(String collection, String id, Map<String, dynamic> data) {
    return _firestore.collection(collection).doc(id).set(data);
  }

  Future<void> updateDoc(
    String collection,
    String id,
    Map<String, dynamic> data,
  ) {
    return _firestore.collection(collection).doc(id).update(data);
  }

  Future<void> deleteDoc(String collection, String id) {
    return _firestore.collection(collection).doc(id).delete();
  }

  Stream<DocumentSnapshot<Map<String, dynamic>>> streamDoc(
    String collection,
    String id,
  ) {
    return _firestore.collection(collection).doc(id).snapshots();
  }

  Query<Map<String, dynamic>> query(String collection) {
    return _firestore.collection(collection);
  }

  CollectionReference<Map<String, dynamic>> userCollection(
    String userId,
    String collection,
  ) {
    return _firestore.collection('users').doc(userId).collection(collection);
  }

  CollectionReference<Map<String, dynamic>> groupCollection(
    String groupCode,
    String collection,
  ) {
    return _firestore
        .collection('groups')
        .doc(groupCode)
        .collection(collection);
  }

  Future<void> setUserDoc(
    String userId,
    String collection,
    String id,
    Map<String, dynamic> data,
  ) {
    return userCollection(userId, collection).doc(id).set(data);
  }

  Future<void> setGroupDoc(
    String groupCode,
    String collection,
    String id,
    Map<String, dynamic> data,
  ) {
    return groupCollection(groupCode, collection).doc(id).set(data);
  }
}
