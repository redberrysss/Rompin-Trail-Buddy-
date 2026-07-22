import 'package:cloud_firestore/cloud_firestore.dart';

class Participant {
  const Participant({
    this.id,
    required this.ownerId,
    required this.name,
    this.avatarStoragePath,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  final String? id;
  final String ownerId;
  final String name;
  final String? avatarStoragePath;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  // ── Firestore helpers ──────────────────────────────────────────────────

  factory Participant.fromMap(Map<String, dynamic> map, {String? id}) {
    return Participant(
      id: id ?? map['id'] as String?,
      ownerId: map['ownerId'] as String? ?? '',
      name: map['name'] as String? ?? '',
      avatarStoragePath: map['avatarStoragePath'] as String?,
      notes: map['notes'] as String?,
      createdAt: _parseDateTime(map['createdAt']),
      updatedAt: _parseDateTime(map['updatedAt']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'ownerId': ownerId,
      'name': name,
      'avatarStoragePath': avatarStoragePath,
      'notes': notes,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  Map<String, dynamic> toUpdateMap() {
    return {
      'name': name,
      'avatarStoragePath': avatarStoragePath,
      'notes': notes,
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  // ── copyWith ───────────────────────────────────────────────────────────

  Participant copyWith({
    String? id,
    String? ownerId,
    String? name,
    String? avatarStoragePath,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Participant(
      id: id ?? this.id,
      ownerId: ownerId ?? this.ownerId,
      name: name ?? this.name,
      avatarStoragePath: avatarStoragePath ?? this.avatarStoragePath,
      notes: notes ?? this.notes,
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
      other is Participant &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          ownerId == other.ownerId &&
          name == other.name;

  @override
  int get hashCode => Object.hash(id, ownerId, name);

  @override
  String toString() => 'Participant(id: $id, ownerId: $ownerId, name: $name)';
}
