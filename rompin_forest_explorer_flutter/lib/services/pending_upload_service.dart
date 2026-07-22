import 'package:hive/hive.dart';

class PendingUploadService {
  static final PendingUploadService instance = PendingUploadService._();
  PendingUploadService._();

  Box get _box => Hive.box('offlineData');

  Future<void> addPendingUpload(Map<String, dynamic> data) async {
    print('[PendingUploadService] addPendingUpload');
    final pending = List<Map<String, dynamic>>.from(
      _box.get('pendingUploads', defaultValue: []),
    );
    pending.add(data);
    await _box.put('pendingUploads', pending);
  }

  List<Map<String, dynamic>> getPendingUploads() {
    return List<Map<String, dynamic>>.from(
      _box.get('pendingUploads', defaultValue: []),
    );
  }

  Future<void> clearPendingUploads() async {
    await _box.put('pendingUploads', []);
  }

  Future<void> removePendingUpload(int index) async {
    final pending = getPendingUploads();
    if (index >= 0 && index < pending.length) {
      pending.removeAt(index);
      await _box.put('pendingUploads', pending);
    }
  }
}
