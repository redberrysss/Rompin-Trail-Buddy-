import 'package:cloud_firestore/cloud_firestore.dart';

class PendingUpload {
  const PendingUpload({
    this.id,
    required this.ownerId,
    required this.participantId,
    required this.activityNumber,
    required this.localFilePath,
    required this.storageDestinationPath,
    required this.recordType,
    required this.recordPayload,
    this.retryCount = 0,
    required this.createdAt,
  });

  final String? id;
  final String ownerId;
  final String participantId;
  final int activityNumber;
  final String localFilePath;
  final String storageDestinationPath;
  final String recordType;
  final String recordPayload;
  final int retryCount;
  final DateTime createdAt;

  // ── Firestore helpers ──────────────────────────────────────────────────

  factory PendingUpload.fromMap(Map<String, dynamic> map, {String? id}) {
    return PendingUpload(
      id: id ?? map['id'] as String?,
      ownerId: map['ownerId'] as String? ?? '',
      participantId: map['participantId'] as String? ?? '',
      activityNumber: (map['activityNumber'] as num?)?.toInt() ?? 0,
      localFilePath: map['localFilePath'] as String? ?? '',
      storageDestinationPath: map['storageDestinationPath'] as String? ?? '',
      recordType: map['recordType'] as String? ?? '',
      recordPayload: map['recordPayload'] as String? ?? '',
      retryCount: (map['retryCount'] as num?)?.toInt() ?? 0,
      createdAt: _parseDateTime(map['createdAt']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'ownerId': ownerId,
      'participantId': participantId,
      'activityNumber': activityNumber,
      'localFilePath': localFilePath,
      'storageDestinationPath': storageDestinationPath,
      'recordType': recordType,
      'recordPayload': recordPayload,
      'retryCount': retryCount,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }

  Map<String, dynamic> toUpdateMap() {
    return {'retryCount': retryCount};
  }

  // ── copyWith ───────────────────────────────────────────────────────────

  PendingUpload copyWith({
    String? id,
    String? ownerId,
    String? participantId,
    int? activityNumber,
    String? localFilePath,
    String? storageDestinationPath,
    String? recordType,
    String? recordPayload,
    int? retryCount,
    DateTime? createdAt,
  }) {
    return PendingUpload(
      id: id ?? this.id,
      ownerId: ownerId ?? this.ownerId,
      participantId: participantId ?? this.participantId,
      activityNumber: activityNumber ?? this.activityNumber,
      localFilePath: localFilePath ?? this.localFilePath,
      storageDestinationPath:
          storageDestinationPath ?? this.storageDestinationPath,
      recordType: recordType ?? this.recordType,
      recordPayload: recordPayload ?? this.recordPayload,
      retryCount: retryCount ?? this.retryCount,
      createdAt: createdAt ?? this.createdAt,
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
      other is PendingUpload &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          localFilePath == other.localFilePath &&
          recordType == other.recordType;

  @override
  int get hashCode => Object.hash(id, localFilePath, recordType);

  @override
  String toString() =>
      'PendingUpload(id: $id, recordType: $recordType, retryCount: $retryCount)';
}
