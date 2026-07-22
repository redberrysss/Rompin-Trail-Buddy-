import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';
import '../services/group_service.dart';
import '../services/firestore_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

enum AuthState { loading, unauthenticated, authenticated }

class AuthViewModel extends ChangeNotifier {
  AuthViewModel({bool initialize = true}) {
    print('[AuthViewModel] init');
    _authState = AuthState.loading;
    if (initialize) {
      _init();
    } else {
      _authState = AuthState.unauthenticated;
    }
  }

  final AuthService _authService = AuthService.instance;
  StreamSubscription<User?>? _authSubscription;
  bool _isAuthOperationInProgress = false;

  // ── State ──────────────────────────────────────────────────────────────
  AuthState _authState = AuthState.loading;
  AuthState get authState => _authState;

  User? _user;
  User? get user => _user;

  String? _userRole;
  String? get userRole => _userRole;

  String? _selectedRole;
  String? get selectedRole => _selectedRole;
  set selectedRole(String? value) {
    print('[AuthViewModel] selectedRole set: "$value"');
    _selectedRole = value;
    notifyListeners();
  }

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  // ── Init ───────────────────────────────────────────────────────────────

  void _init() {
    print('[AuthViewModel] _init: listening to authStateChanges');

    try {
      _authSubscription = _authService.auth.authStateChanges().listen(
        _onAuthChanged,
      );
    } catch (e) {
      print('[AuthViewModel] _init: authStateChanges failed: $e');
      _authSubscription = null;
    }

    final currentUser = _authService.currentUser;
    if (currentUser != null) {
      print(
        '[AuthViewModel] _init: currentUser already exists uid=${currentUser.uid}',
      );
      _user = currentUser;
      _loadUserRole(currentUser.uid);
    } else {
      print('[AuthViewModel] _init: no current user');
      _authState = AuthState.unauthenticated;
      notifyListeners();
    }
  }

  Future<void> _onAuthChanged(User? user) async {
    print('[AuthViewModel] _onAuthChanged: user=${user?.uid}');
    if (user != null) {
      _user = user;
      if (_isAuthOperationInProgress) return;
      await _loadUserRole(user.uid);
    } else {
      _user = null;
      _userRole = null;
      _authState = AuthState.unauthenticated;
      notifyListeners();
    }
  }

  Future<void> _loadUserRole(String uid) async {
    print('[AuthViewModel] _loadUserRole: uid=$uid');
    try {
      final role = await _authService.fetchUserRole(uid);
      _userRole = role != null ? _authService.normalizeRole(role) : null;
      if (_userRole == null || _userRole!.isEmpty) {
        throw StateError('Peranan akaun tidak ditemui dalam pangkalan data.');
      }
      print('[AuthViewModel] _loadUserRole: normalized role="$_userRole"');
      _authState = AuthState.authenticated;
    } catch (e) {
      print('[AuthViewModel] _loadUserRole error: $e');
      _userRole = null;
      _errorMessage = 'Gagal memuatkan peranan pengguna. Sila cuba lagi.';
      _authState = AuthState.unauthenticated;
    }
    notifyListeners();
  }

  // ── Sign In ────────────────────────────────────────────────────────────

  Future<void> signIn(String email, String password) async {
    print('[AuthViewModel] signIn: email=$email');
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final requestedRole = _authService.normalizeRole(_selectedRole ?? '');
    if (requestedRole.isEmpty) {
      _errorMessage = 'Sila pilih peranan sebelum log masuk.';
      _isLoading = false;
      notifyListeners();
      return;
    }

    _isAuthOperationInProgress = true;
    try {
      final credential = await _authService.signIn(email, password);
      final user = credential.user;
      if (user == null) throw StateError('Akaun tidak dapat dimuatkan.');
      final storedValue = await _authService.fetchUserRole(user.uid);
      final storedRole = _authService.normalizeRole(storedValue ?? '');
      if (storedRole.isEmpty) {
        await _authService.signOut();
        throw StateError('Peranan akaun tidak ditemui dalam pangkalan data.');
      }
      if (storedRole != requestedRole) {
        await _authService.signOut();
        final registeredLabel = storedRole == 'fasilitator'
            ? 'Facilitator'
            : 'Student';
        final selectedLabel = storedRole == 'fasilitator'
            ? 'Facilitator'
            : 'Student';
        _errorMessage =
            'This account is registered as a $registeredLabel. '
            'Please select the $selectedLabel role.';
        _user = null;
        _userRole = null;
        _authState = AuthState.unauthenticated;
        return;
      }
      _user = user;
      _userRole = storedRole;
      _authState = AuthState.authenticated;
    } catch (e) {
      print('[AuthViewModel] signIn error: $e');
      _errorMessage ??= e is FirebaseException
          ? _authService.mapFirebaseError(e)
          : e.toString().replaceFirst('Bad state: ', '');
    } finally {
      _isAuthOperationInProgress = false;
      _isLoading = false;
      notifyListeners();
    }
  }

  // ── Register ───────────────────────────────────────────────────────────

  Future<void> register(
    String fullName,
    String email,
    String password,
    String role, {
    String? groupCode,
  }) async {
    print(
      '[AuthViewModel] register: email=$email, fullName=$fullName, role=$role',
    );
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final normalizedRole = _authService.normalizeRole(role);
    if (normalizedRole.isEmpty) {
      _errorMessage = 'Peranan pendaftaran tidak sah.';
      _isLoading = false;
      notifyListeners();
      return;
    }
    final storedRole = normalizedRole == 'fasilitator'
        ? 'facilitator'
        : 'student';
    _selectedRole = normalizedRole;
    _isAuthOperationInProgress = true;
    try {
      final user = await _authService.register(
        fullName,
        email,
        password,
        storedRole,
      );
      if (normalizedRole == 'pelajar') {
        await FirestoreService.instance
            .setUserDoc(user.uid, 'participants', user.uid, {
              'id': user.uid,
              'ownerId': user.uid,
              'name': fullName,
              'createdAt': FieldValue.serverTimestamp(),
              'updatedAt': FieldValue.serverTimestamp(),
            });
      }
      if (normalizedRole == 'pelajar' &&
          groupCode != null &&
          groupCode.trim().isNotEmpty) {
        await GroupService.instance.joinGroup(
          code: groupCode,
          userId: user.uid,
          userName: fullName,
          role: 'participant',
        );
      }
      _user = user;
      _userRole = normalizedRole;
      _authState = AuthState.authenticated;
    } catch (e) {
      print('[AuthViewModel] register error: $e');
      _errorMessage = _authService.mapFirebaseError(e);
    } finally {
      _isAuthOperationInProgress = false;
      _isLoading = false;
      notifyListeners();
    }
  }

  // ── Sign Out ───────────────────────────────────────────────────────────

  Future<void> signOut() async {
    print('[AuthViewModel] signOut');
    _isLoading = true;
    notifyListeners();

    try {
      await _authService.signOut();
      _selectedRole = null;
      _user = null;
      _userRole = null;
      _authState = AuthState.unauthenticated;
    } catch (e) {
      print('[AuthViewModel] signOut error: $e');
      _errorMessage = _authService.mapFirebaseError(e);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> deleteAccount() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      await _authService.deleteAccount();
      _selectedRole = null;
      _user = null;
      _userRole = null;
      _authState = AuthState.unauthenticated;
      return true;
    } catch (error) {
      _errorMessage = error is FirebaseException
          ? _authService.mapFirebaseError(error)
          : 'Akaun tidak dapat dipadam: $error';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ── Reset Password ─────────────────────────────────────────────────────

  Future<bool> resetPassword(String email) async {
    print('[AuthViewModel] resetPassword: email=$email');
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _authService.resetPassword(email);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      print('[AuthViewModel] resetPassword error: $e');
      _errorMessage = _authService.mapFirebaseError(e);
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // ── Helpers ────────────────────────────────────────────────────────────

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void setValidationError(String message) {
    _errorMessage = message;
    notifyListeners();
  }

  bool get isFasilitator => _userRole == 'fasilitator';
  bool get isPelajar => _userRole == 'pelajar';

  // ── Lifecycle ──────────────────────────────────────────────────────────

  @override
  void dispose() {
    print('[AuthViewModel] dispose');
    _authSubscription?.cancel();
    super.dispose();
  }
}
