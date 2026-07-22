import 'package:cloud_firestore/cloud_firestore.dart';

class TreasureRecord {
  const TreasureRecord({
    this.id,
    required this.ownerId,
    required this.participantId,
    required this.sessionId,
    required this.itemName,
    this.imageStoragePath,
    this.imageDownloadURL,
    this.isFound = false,
    this.isSkipped = false,
    required this.createdAt,
    required this.updatedAt,
  });

  final String? id;
  final String ownerId;
  final String participantId;
  final String sessionId;
  final String itemName;
  final String? imageStoragePath;
  final String? imageDownloadURL;
  final bool isFound;
  final bool isSkipped;
  final DateTime createdAt;
  final DateTime updatedAt;

  // ── Firestore helpers ──────────────────────────────────────────────────

  factory TreasureRecord.fromMap(Map<String, dynamic> map, {String? id}) {
    return TreasureRecord(
      id: id ?? map['id'] as String?,
      ownerId: map['ownerId'] as String? ?? '',
      participantId: map['participantId'] as String? ?? '',
      sessionId: map['sessionId'] as String? ?? '',
      itemName: map['itemName'] as String? ?? '',
      imageStoragePath: map['imageStoragePath'] as String?,
      imageDownloadURL: map['imageDownloadURL'] as String?,
      isFound: map['isFound'] as bool? ?? false,
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
      'itemName': itemName,
      'imageStoragePath': imageStoragePath,
      'imageDownloadURL': imageDownloadURL,
      'isFound': isFound,
      'isSkipped': isSkipped,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  Map<String, dynamic> toUpdateMap() {
    return {
      'itemName': itemName,
      'imageStoragePath': imageStoragePath,
      'imageDownloadURL': imageDownloadURL,
      'isFound': isFound,
      'isSkipped': isSkipped,
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  // ── copyWith ───────────────────────────────────────────────────────────

  TreasureRecord copyWith({
    String? id,
    String? ownerId,
    String? participantId,
    String? sessionId,
    String? itemName,
    String? imageStoragePath,
    String? imageDownloadURL,
    bool? isFound,
    bool? isSkipped,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return TreasureRecord(
      id: id ?? this.id,
      ownerId: ownerId ?? this.ownerId,
      participantId: participantId ?? this.participantId,
      sessionId: sessionId ?? this.sessionId,
      itemName: itemName ?? this.itemName,
      imageStoragePath: imageStoragePath ?? this.imageStoragePath,
      imageDownloadURL: imageDownloadURL ?? this.imageDownloadURL,
      isFound: isFound ?? this.isFound,
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
      other is TreasureRecord &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          sessionId == other.sessionId &&
          itemName == other.itemName;

  @override
  int get hashCode => Object.hash(id, sessionId, itemName);

  @override
  String toString() =>
      'TreasureRecord(id: $id, itemName: $itemName, isFound: $isFound)';
}
