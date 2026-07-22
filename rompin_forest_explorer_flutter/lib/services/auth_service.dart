import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'storage_service.dart';
import 'group_service.dart';

class AuthService {
  static final AuthService instance = AuthService._();
  AuthService._();

  FirebaseAuth? _auth;
  FirebaseFirestore? _firestore;

  FirebaseAuth get auth {
    _auth ??= FirebaseAuth.instance;
    return _auth!;
  }

  FirebaseFirestore get firestore {
    _firestore ??= FirebaseFirestore.instance;
    return _firestore!;
  }

  User? get currentUser {
    try {
      return auth.currentUser;
    } catch (e) {
      print('[AuthService] currentUser error: $e');
      return null;
    }
  }

  bool get isFirebaseReady {
    try {
      FirebaseAuth.instance;
      FirebaseFirestore.instance;
      return true;
    } catch (e) {
      print('[AuthService] Firebase not ready: $e');
      return false;
    }
  }

  Future<UserCredential> signIn(String email, String password) async {
    print('[AuthService] signIn: email=$email');
    try {
      final credential = await auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      print('[AuthService] signIn: success uid=${credential.user?.uid}');
      return credential;
    } catch (e) {
      print('[AuthService] signIn error: $e');
      rethrow;
    }
  }

  Future<User> register(
    String fullName,
    String email,
    String password,
    String role,
  ) async {
    print(
      '[AuthService] register: email=$email, fullName=$fullName, role=$role',
    );
    User? createdUser;
    try {
      if (role != 'student' && role != 'facilitator') {
        throw ArgumentError.value(role, 'role', 'Unsupported account role');
      }
      final credential = await auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = credential.user;
      if (user == null) throw Exception('User creation returned null');
      createdUser = user;

      await user.updateDisplayName(fullName);

      await firestore.collection('users').doc(user.uid).set({
        'fullName': fullName,
        'email': email,
        'role': role,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      print('[AuthService] register: success uid=${user.uid}');
      return user;
    } catch (e) {
      print('[AuthService] register error: $e');
      if (createdUser != null) {
        try {
          await firestore.collection('users').doc(createdUser.uid).delete();
          await createdUser.delete();
        } catch (_) {
          await auth.signOut();
        }
      }
      rethrow;
    }
  }

  Future<String?> fetchUserRole(String uid) async {
    print('[AuthService] fetchUserRole: uid=$uid');
    try {
      final doc = await firestore.collection('users').doc(uid).get();
      if (!doc.exists) {
        print('[AuthService] fetchUserRole: document not found');
        return null;
      }

      final data = doc.data();
      if (data == null) {
        print('[AuthService] fetchUserRole: data is null');
        return null;
      }

      final role = roleFromData(data);
      if (role != null) {
        print('[AuthService] fetchUserRole: found role="$role"');
        return role;
      }

      print('[AuthService] fetchUserRole: no role found');
      return null;
    } catch (e) {
      print('[AuthService] fetchUserRole error: $e');
      rethrow;
    }
  }

  String? roleFromData(Map<String, dynamic> data) {
    const roleKeys = [
      'role',
      'userRole',
      'user_type',
      'userType',
      'accountType',
      'type',
    ];

    for (final key in roleKeys) {
      final value = data[key]?.toString().trim();
      if (value != null && value.isNotEmpty) return value;
    }

    for (final containerKey in const ['profile', 'account']) {
      final container = data[containerKey];
      if (container is! Map) continue;
      final nested = Map<String, dynamic>.from(container);
      for (final key in roleKeys) {
        final value = nested[key]?.toString().trim();
        if (value != null && value.isNotEmpty) return value;
      }
    }
    return null;
  }

  Future<void> signOut() async {
    print('[AuthService] signOut');
    try {
      await auth.signOut();
      print('[AuthService] signOut: success');
    } catch (e) {
      print('[AuthService] signOut error: $e');
      rethrow;
    }
  }

  Future<void> resetPassword(String email) async {
    print('[AuthService] resetPassword: email=$email');
    try {
      await auth.sendPasswordResetEmail(email: email);
      print('[AuthService] resetPassword: success');
    } catch (e) {
      print('[AuthService] resetPassword error: $e');
      rethrow;
    }
  }

  Future<void> deleteAccount() async {
    final user = currentUser;
    if (user == null) {
      print('[AuthService] deleteAccount: no current user');
      return;
    }

    print('[AuthService] deleteAccount: uid=${user.uid}');
    try {
      final uid = user.uid;
      final userDocRef = firestore.collection('users').doc(uid);

      final userSnapshot = await userDocRef.get();
      final groupCode = userSnapshot.data()?['groupCode']?.toString().trim();

      final subcollectionNames = [
        'participants',
        'activitySessions',
        'observations',
        'sensoryRecords',
        'treasureRecords',
        'artworks',
        'discoveries',
        'uploads',
        'pendingUploads',
        'progress',
        'reports',
      ];

      for (final subcollectionName in subcollectionNames) {
        await _deleteCollection(userDocRef.collection(subcollectionName));
      }

      await StorageService.instance.deleteUserFiles(uid);

      if (groupCode != null && groupCode.isNotEmpty) {
        final group = firestore.collection('groups').doc(groupCode);
        for (final collection in const [
          'participants',
          'sessions',
          'observations',
          'sensoryRecords',
          'treasureRecords',
          'artworks',
          'discoveries',
          'uploads',
          'progress',
          'reports',
        ]) {
          await _deleteOwnedRecords(group.collection(collection), uid);
        }
        await group.collection('members').doc(uid).delete();
      }

      for (final collection in const [
        'participants',
        'activity_sessions',
        'activitySessions',
        'observations',
        'observation_records',
        'sensory_records',
        'sensoryRecords',
        'treasure_records',
        'treasureRecords',
        'artworks',
        'artwork_records',
        'discoveries',
        'student_discoveries',
        'uploads',
        'progress',
        'reports',
      ]) {
        await _deleteOwnedRecords(firestore.collection(collection), uid);
      }

      await userDocRef.delete();
      print('[AuthService] deleteAccount: deleted user document');

      await user.delete();
      await GroupService.instance.leaveGroup();
      print('[AuthService] deleteAccount: success');
    } catch (e) {
      print('[AuthService] deleteAccount error: $e');
      rethrow;
    }
  }

  Future<void> _deleteCollection(
    CollectionReference<Map<String, dynamic>> collection,
  ) async {
    while (true) {
      final snapshot = await collection.limit(200).get();
      if (snapshot.docs.isEmpty) return;
      final batch = firestore.batch();
      for (final document in snapshot.docs) {
        batch.delete(document.reference);
      }
      await batch.commit();
    }
  }

  Future<void> _deleteOwnedRecords(
    CollectionReference<Map<String, dynamic>> collection,
    String uid,
  ) async {
    final references = <String, DocumentReference<Map<String, dynamic>>>{};
    for (final field in const ['ownerId', 'userId', 'participantId']) {
      final snapshot = await collection.where(field, isEqualTo: uid).get();
      for (final document in snapshot.docs) {
        references[document.reference.path] = document.reference;
      }
    }
    for (final chunk in _chunks(references.values.toList(), 400)) {
      final batch = firestore.batch();
      for (final reference in chunk) {
        batch.delete(reference);
      }
      await batch.commit();
    }
  }

  Iterable<List<T>> _chunks<T>(List<T> values, int size) sync* {
    for (var start = 0; start < values.length; start += size) {
      final end = (start + size).clamp(0, values.length);
      yield values.sublist(start, end);
    }
  }

  String mapFirebaseError(dynamic error) {
    String code = '';
    String? message;

    if (error is FirebaseAuthException) {
      code = error.code;
      message = error.message;
    } else if (error is FirebaseException) {
      code = error.code;
      message = error.message;
    } else {
      return 'Ralat tidak diketahui berlaku. Sila cuba lagi.';
    }

    print('[AuthService] mapFirebaseError: code=$code, message=$message');

    switch (code) {
      case 'invalid-email':
        return 'Alamat e-mel tidak sah.';
      case 'wrong-password':
      case 'invalid-credential':
        return 'E-mel atau kata laluan salah.';
      case 'user-not-found':
        return 'Tiada akaun ditemui dengan e-mel ini.';
      case 'email-already-in-use':
        return 'E-mel ini sudah digunakan oleh akaun lain.';
      case 'weak-password':
        return 'Kata laluan terlalu lemah. Gunakan sekurang-kurangnya 6 aksara.';
      case 'network-request-failed':
        return 'Ralat rangkaian. Sila semak sambungan internet anda.';
      case 'too-many-requests':
        return 'Terlalu banyak percubaan. Sila tunggu seketika dan cuba lagi.';
      case 'user-disabled':
        return 'Akaun ini telah dilumpuhkan. Sila hubungi pentadbir.';
      case '7': // PERMISSION_DENIED
        return 'Akses ditolak. Anda tidak mempunyai kebenaran untuk melakukan tindakan ini.';
      case '5': // NOT_FOUND
        return 'Data tidak ditemui.';
      case '14': // UNAVAILABLE
        return 'Perkhidmatan tidak tersedia buat masa ini. Sila cuba lagi kemudian.';
      default:
        return 'Ralat berlaku: $message';
    }
  }

  String normalizeRole(String role) {
    print('[AuthService] normalizeRole: input="$role"');
    final normalized = role
        .trim()
        .toLowerCase()
        .replaceAll(RegExp(r'\s+'), '')
        .replaceAll('-', '')
        .replaceAll('_', '');

    if (normalized.isEmpty) {
      print('[AuthService] normalizeRole: empty input, returning ""');
      return '';
    }

    const fasilitatorVariants = [
      'fasilitator',
      'facilitator',
      'admin',
      'teacher',
      'guru',
      'cikgu',
      'therapist',
      'terapis',
    ];

    const pelajarVariants = [
      'pelajar',
      'student',
      'participant',
      'peserta',
      'anak',
      'child',
      'kanak',
    ];

    for (final variant in fasilitatorVariants) {
      if (normalized == variant) {
        print('[AuthService] normalizeRole: mapped to "fasilitator"');
        return 'fasilitator';
      }
    }

    for (final variant in pelajarVariants) {
      if (normalized == variant) {
        print('[AuthService] normalizeRole: mapped to "pelajar"');
        return 'pelajar';
      }
    }

    print('[AuthService] normalizeRole: unrecognized role, returning ""');
    return '';
  }
}
