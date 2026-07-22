import 'package:cloud_firestore/cloud_firestore.dart';

class ObservationRecord {
  const ObservationRecord({
    this.id,
    required this.ownerId,
    required this.participantId,
    required this.sessionId,
    required this.activityNumber,
    required this.category,
    required this.objectName,
    this.detectedLabel,
    this.confidence,
    this.ocrText,
    this.imageStoragePath,
    this.imageDownloadURL,
    this.notes,
    this.isConfirmed = false,
    this.isSkipped = false,
    required this.createdAt,
    required this.updatedAt,
  });

  final String? id;
  final String ownerId;
  final String participantId;
  final String sessionId;
  final int activityNumber;
  final String category;
  final String objectName;
  final String? detectedLabel;
  final double? confidence;
  final String? ocrText;
  final String? imageStoragePath;
  final String? imageDownloadURL;
  final String? notes;
  final bool isConfirmed;
  final bool isSkipped;
  final DateTime createdAt;
  final DateTime updatedAt;

  // ── Firestore helpers ──────────────────────────────────────────────────

  factory ObservationRecord.fromMap(Map<String, dynamic> map, {String? id}) {
    return ObservationRecord(
      id: id ?? map['id'] as String?,
      ownerId: map['ownerId'] as String? ?? '',
      participantId: map['participantId'] as String? ?? '',
      sessionId: map['sessionId'] as String? ?? '',
      activityNumber: (map['activityNumber'] as num?)?.toInt() ?? 0,
      category: map['category'] as String? ?? '',
      objectName: map['objectName'] as String? ?? '',
      detectedLabel: map['detectedLabel'] as String?,
      confidence: (map['confidence'] as num?)?.toDouble(),
      ocrText: map['ocrText'] as String?,
      imageStoragePath: map['imageStoragePath'] as String?,
      imageDownloadURL: map['imageDownloadURL'] as String?,
      notes: map['notes'] as String?,
      isConfirmed: map['isConfirmed'] as bool? ?? false,
      isSkipped: map['isSkipped'] as bool? ?? false,
      createdAt: _parseDateTime(map['createdAt']),
      updatedAt: _parseDateTime(map['updatedAt']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'ownerId': ownerId,
      'participantId': participantId,
      'sessionId': sessionId,
      'activityNumber': activityNumber,
      'category': category,
      'objectName': objectName,
      'detectedLabel': detectedLabel,
      'confidence': confidence,
      'ocrText': ocrText,
      'imageStoragePath': imageStoragePath,
      'imageDownloadURL': imageDownloadURL,
      'notes': notes,
      'isConfirmed': isConfirmed,
      'isSkipped': isSkipped,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  Map<String, dynamic> toUpdateMap() {
    return {
      'detectedLabel': detectedLabel,
      'confidence': confidence,
      'ocrText': ocrText,
      'imageStoragePath': imageStoragePath,
      'imageDownloadURL': imageDownloadURL,
      'notes': notes,
      'isConfirmed': isConfirmed,
      'isSkipped': isSkipped,
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  // ── copyWith ───────────────────────────────────────────────────────────

  ObservationRecord copyWith({
    String? id,
    String? ownerId,
    String? participantId,
    String? sessionId,
    int? activityNumber,
    String? category,
    String? objectName,
    String? detectedLabel,
    double? confidence,
    String? ocrText,
    String? imageStoragePath,
    String? imageDownloadURL,
    String? notes,
    bool? isConfirmed,
    bool? isSkipped,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ObservationRecord(
      id: id ?? this.id,
      ownerId: ownerId ?? this.ownerId,
      participantId: participantId ?? this.participantId,
      sessionId: sessionId ?? this.sessionId,
      activityNumber: activityNumber ?? this.activityNumber,
      category: category ?? this.category,
      objectName: objectName ?? this.objectName,
      detectedLabel: detectedLabel ?? this.detectedLabel,
      confidence: confidence ?? this.confidence,
      ocrText: ocrText ?? this.ocrText,
      imageStoragePath: imageStoragePath ?? this.imageStoragePath,
      imageDownloadURL: imageDownloadURL ?? this.imageDownloadURL,
      notes: notes ?? this.notes,
      isConfirmed: isConfirmed ?? this.isConfirmed,
      isSkipped: isSkipped ?? this.isSkipped,
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
      other is ObservationRecord &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          sessionId == other.sessionId &&
          objectName == other.objectName;

  @override
  int get hashCode => Object.hash(id, sessionId, objectName);

  @override
  String toString() =>
      'ObservationRecord(id: $id, objectName: $objectName, category: $category, isConfirmed: $isConfirmed)';
}
