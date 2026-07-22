class RoboflowService {
  static final RoboflowService instance = RoboflowService._();
  RoboflowService._();

  Future<Map<String, dynamic>?> classifyImage(String imagePath) async {
    print('[RoboflowService] classifyImage: $imagePath');
    return null;
  }
}
