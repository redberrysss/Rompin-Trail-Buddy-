import 'package:cloud_firestore/cloud_firestore.dart';

class ActivitySession {
  const ActivitySession({
    this.id,
    required this.ownerId,
    required this.participantId,
    required this.activityNumber,
    required this.startedAt,
    this.completedAt,
    this.isCompleted = false,
    this.isSkipped = false,
    this.progress = 0.0,
    required this.createdAt,
    required this.updatedAt,
  });

  final String? id;
  final String ownerId;
  final String participantId;
  final int activityNumber;
  final DateTime startedAt;
  final DateTime? completedAt;
  final bool isCompleted;
  final bool isSkipped;
  final double progress;
  final DateTime createdAt;
  final DateTime updatedAt;

  // ── Firestore helpers ──────────────────────────────────────────────────

  factory ActivitySession.fromMap(Map<String, dynamic> map, {String? id}) {
    return ActivitySession(
      id: id ?? map['id'] as String?,
      ownerId: map['ownerId'] as String? ?? '',
      participantId: map['participantId'] as String? ?? '',
      activityNumber: (map['activityNumber'] as num?)?.toInt() ?? 0,
      startedAt: _parseDateTime(map['startedAt']),
      completedAt: map['completedAt'] != null
          ? _parseDateTime(map['completedAt'])
          : null,
      isCompleted: map['isCompleted'] as bool? ?? false,
      isSkipped: map['isSkipped'] as bool? ?? false,
      progress: (map['progress'] as num?)?.toDouble() ?? 0.0,
      createdAt: _parseDateTime(map['createdAt']),
      updatedAt: _parseDateTime(map['updatedAt']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'ownerId': ownerId,
      'participantId': participantId,
      'activityNumber': activityNumber,
      'startedAt': FieldValue.serverTimestamp(),
      'completedAt': completedAt != null
          ? Timestamp.fromDate(completedAt!)
          : null,
      'isCompleted': isCompleted,
      'isSkipped': isSkipped,
      'progress': progress,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  Map<String, dynamic> toUpdateMap() {
    return {
      'completedAt': completedAt != null
          ? Timestamp.fromDate(completedAt!)
          : null,
      'isCompleted': isCompleted,
      'isSkipped': isSkipped,
      'progress': progress,
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  // ── copyWith ───────────────────────────────────────────────────────────

  ActivitySession copyWith({
    String? id,
    String? ownerId,
    String? participantId,
    int? activityNumber,
    DateTime? startedAt,
    DateTime? completedAt,
    bool? isCompleted,
    bool? isSkipped,
    double? progress,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ActivitySession(
      id: id ?? this.id,
      ownerId: ownerId ?? this.ownerId,
      participantId: participantId ?? this.participantId,
      activityNumber: activityNumber ?? this.activityNumber,
      startedAt: startedAt ?? this.startedAt,
      completedAt: completedAt ?? this.completedAt,
      isCompleted: isCompleted ?? this.isCompleted,
      isSkipped: isSkipped ?? this.isSkipped,
      progress: progress ?? this.progress,
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
      other is ActivitySession &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          participantId == other.participantId &&
          activityNumber == other.activityNumber;

  @override
  int get hashCode => Object.hash(id, participantId, activityNumber);

  @override
  String toString() =>
      'ActivitySession(id: $id, participantId: $participantId, activityNumber: $activityNumber, isCompleted: $isCompleted)';
}
