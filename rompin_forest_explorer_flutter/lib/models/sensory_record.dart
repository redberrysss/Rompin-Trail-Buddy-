import 'package:cloud_firestore/cloud_firestore.dart';

class SensoryRecord {
  const SensoryRecord({
    this.id,
    required this.ownerId,
    required this.participantId,
    required this.sessionId,
    required this.stationNumber,
    required this.senseType,
    required this.selectedValue,
    this.emotion,
    this.imageStoragePath,
    this.imageDownloadURL,
    this.audioStoragePath,
    this.audioDownloadURL,
    this.isSkipped = false,
    required this.createdAt,
    required this.updatedAt,
  });

  final String? id;
  final String ownerId;
  final String participantId;
  final String sessionId;
  final int stationNumber;
  final String senseType;
  final String selectedValue;
  final String? emotion;
  final String? imageStoragePath;
  final String? imageDownloadURL;
  final String? audioStoragePath;
  final String? audioDownloadURL;
  final bool isSkipped;
  final DateTime createdAt;
  final DateTime updatedAt;

  // ── Firestore helpers ──────────────────────────────────────────────────

  factory SensoryRecord.fromMap(Map<String, dynamic> map, {String? id}) {
    return SensoryRecord(
      id: id ?? map['id'] as String?,
      ownerId: map['ownerId'] as String? ?? '',
      participantId: map['participantId'] as String? ?? '',
      sessionId: map['sessionId'] as String? ?? '',
      stationNumber: (map['stationNumber'] as num?)?.toInt() ?? 0,
      senseType: map['senseType'] as String? ?? '',
      selectedValue: map['selectedValue'] as String? ?? '',
      emotion: map['emotion'] as String?,
      imageStoragePath: map['imageStoragePath'] as String?,
      imageDownloadURL: map['imageDownloadURL'] as String?,
      audioStoragePath: map['audioStoragePath'] as String?,
      audioDownloadURL: map['audioDownloadURL'] as String?,
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
      'stationNumber': stationNumber,
      'senseType': senseType,
      'selectedValue': selectedValue,
      'emotion': emotion,
      'imageStoragePath': imageStoragePath,
      'imageDownloadURL': imageDownloadURL,
      'audioStoragePath': audioStoragePath,
      'audioDownloadURL': audioDownloadURL,
      'isSkipped': isSkipped,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  Map<String, dynamic> toUpdateMap() {
    return {
      'senseType': senseType,
      'selectedValue': selectedValue,
      'emotion': emotion,
      'imageStoragePath': imageStoragePath,
      'imageDownloadURL': imageDownloadURL,
      'audioStoragePath': audioStoragePath,
      'audioDownloadURL': audioDownloadURL,
      'isSkipped': isSkipped,
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  // ── copyWith ───────────────────────────────────────────────────────────

  SensoryRecord copyWith({
    String? id,
    String? ownerId,
    String? participantId,
    String? sessionId,
    int? stationNumber,
    String? senseType,
    String? selectedValue,
    String? emotion,
    String? imageStoragePath,
    String? imageDownloadURL,
    String? audioStoragePath,
    String? audioDownloadURL,
    bool? isSkipped,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return SensoryRecord(
      id: id ?? this.id,
      ownerId: ownerId ?? this.ownerId,
      participantId: participantId ?? this.participantId,
      sessionId: sessionId ?? this.sessionId,
      stationNumber: stationNumber ?? this.stationNumber,
      senseType: senseType ?? this.senseType,
      selectedValue: selectedValue ?? this.selectedValue,
      emotion: emotion ?? this.emotion,
      imageStoragePath: imageStoragePath ?? this.imageStoragePath,
      imageDownloadURL: imageDownloadURL ?? this.imageDownloadURL,
      audioStoragePath: audioStoragePath ?? this.audioStoragePath,
      audioDownloadURL: audioDownloadURL ?? this.audioDownloadURL,
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
      other is SensoryRecord &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          sessionId == other.sessionId &&
          stationNumber == other.stationNumber &&
          senseType == other.senseType;

  @override
  int get hashCode => Object.hash(id, sessionId, stationNumber, senseType);

  @override
  String toString() =>
      'SensoryRecord(id: $id, stationNumber: $stationNumber, senseType: $senseType, selectedValue: $selectedValue)';
}
