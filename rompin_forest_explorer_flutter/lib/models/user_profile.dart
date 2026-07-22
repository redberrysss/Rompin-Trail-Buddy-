import 'package:cloud_firestore/cloud_firestore.dart';

class UserProfile {
  const UserProfile({
    this.id,
    required this.fullName,
    required this.email,
    required this.role,
    required this.createdAt,
    required this.updatedAt,
  });

  final String? id;
  final String fullName;
  final String email;
  final String role;
  final DateTime createdAt;
  final DateTime updatedAt;

  // ── Firestore helpers ──────────────────────────────────────────────────

  factory UserProfile.fromMap(Map<String, dynamic> map, {String? id}) {
    return UserProfile(
      id: id ?? map['id'] as String?,
      fullName: map['fullName'] as String? ?? '',
      email: map['email'] as String? ?? '',
      role: map['role'] as String? ?? 'therapist',
      createdAt: _parseDateTime(map['createdAt']),
      updatedAt: _parseDateTime(map['updatedAt']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'fullName': fullName,
      'email': email,
      'role': role,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  Map<String, dynamic> toUpdateMap() {
    return {
      'fullName': fullName,
      'email': email,
      'role': role,
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  // ── copyWith ───────────────────────────────────────────────────────────

  UserProfile copyWith({
    String? id,
    String? fullName,
    String? email,
    String? role,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserProfile(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      role: role ?? this.role,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // ── Helpers ────────────────────────────────────────────────────────────

  static DateTime _parseDateTime(dynamic value) {
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value) ?? DateTime.now();
    return DateTime.now();
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserProfile &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          email == other.email;

  @override
  int get hashCode => Object.hash(id, email);

  @override
  String toString() =>
      'UserProfile(id: $id, fullName: $fullName, email: $email, role: $role)';
}
