import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import '../../theme/app_theme.dart';
import '../../services/activity_data_service.dart';
import '../../services/storage_service.dart';
import '../../services/roboflow_service.dart';
import '../../models/observation_record.dart';

class Activity1NatureWalkView extends StatefulWidget {
  const Activity1NatureWalkView({
    super.key,
    required this.participantID,
    required this.participantName,
  });

  final String participantID;
  final String participantName;

  @override
  State<Activity1NatureWalkView> createState() =>
      _Activity1NatureWalkViewState();
}

class _Activity1NatureWalkViewState extends State<Activity1NatureWalkView> {
  final PageController _pageController = PageController();
  final TextEditingController _nameController = TextEditingController();
  final ImagePicker _picker = ImagePicker();

  int _currentStep = 0;
  File? _capturedImage;
  String? _detectedLabel;
  double? _confidence;
  String _selectedCategory = '';
  bool _isSaving = false;

  final List<_ObservedItem> _items = [];

  static const _categories = [
    'Pokok',
    'Bunga',
    'Serangga',
    'Haiwan',
    'Batu',
    'Lain-lain',
  ];

  @override
  void dispose() {
    _pageController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  // ── Camera ────────────────────────────────────────────────────────────

  Future<void> _capturePhoto() async {
    print('[Activity1] _capturePhoto');
    final xfile = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 85,
    );
    if (xfile == null) return;
    final file = File(xfile.path);

    setState(() {
      _capturedImage = file;
      _detectedLabel = null;
      _confidence = null;
    });

    // Attempt AI classification
    try {
      final result = await RoboflowService.instance.classifyImage(xfile.path);
      if (result != null && mounted) {
        setState(() {
          _detectedLabel = result['label'] as String?;
          _confidence = (result['confidence'] as num?)?.toDouble();
        });
        print('[Activity1] detected: $_detectedLabel ($_confidence)');
      }
    } catch (e) {
      print('[Activity1] classifyImage error: $e');
    }
  }

  // ── Save observation ──────────────────────────────────────────────────

  Future<void> _saveObservation() async {
    if (_nameController.text.trim().isEmpty) return;
    print('[Activity1] _saveObservation: ${_nameController.text.trim()}');

    setState(() => _isSaving = true);

    try {
      String? imagePath;
      String? imageURL;

      if (_capturedImage != null) {
        final docId = const Uuid().v4();
        imagePath = 'users/${widget.participantID}/activity_1/$docId.jpg';
        imageURL = await StorageService.instance.uploadFile(
          imagePath,
          _capturedImage!,
        );
      }

      final now = DateTime.now();
      final record = ObservationRecord(
        id: const Uuid().v4(),
        ownerId: widget.participantID,
        participantId: widget.participantID,
        sessionId: 'session_${now.millisecondsSinceEpoch}',
        activityNumber: 1,
        category: _selectedCategory,
        objectName: _nameController.text.trim(),
        detectedLabel: _detectedLabel,
        confidence: _confidence,
        imageStoragePath: imagePath,
        imageDownloadURL: imageURL,
        createdAt: now,
        updatedAt: now,
      );

      await ActivityDataService.instance.saveRecord(
        personalCollection: 'observations',
        groupCollection: 'observations',
        id: record.id!,
        data: record.toMap(),
      );
      await ActivityDataService.instance.saveActivityProgress(
        participantId: widget.participantID,
        activityNumber: 1,
        progress: ((_items.length + 1) / 5).clamp(0.0, 1.0),
      );

      setState(() {
        _items.add(
          _ObservedItem(
            name: record.objectName,
            category: record.category,
            imagePath: _capturedImage?.path,
            imageURL: imageURL,
          ),
        );
      });

      print('[Activity1] saved: ${record.objectName}');
      _resetCapture();
    } catch (e) {
      print('[Activity1] save error: $e');
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Penemuan gagal disimpan: $e')));
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  void _resetCapture() {
    _capturedImage = null;
    _detectedLabel = null;
    _confidence = null;
    _nameController.clear();
    _selectedCategory = '';
  }

  void _skip() {
    print('[Activity1] skip');
    _resetCapture();
  }

  void _goToStep(int step) {
    print('[Activity1] goToStep: $step');
    _pageController.animateToPage(
      step,
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeInOut,
    );
  }

  Future<void> _finishActivity() async {
    if (_items.isEmpty) return;
    setState(() => _isSaving = true);
    try {
      await ActivityDataService.instance.saveActivityProgress(
        participantId: widget.participantID,
        activityNumber: 1,
        progress: 1,
      );
      if (mounted) Navigator.of(context).pop();
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Kemajuan gagal disimpan: $error')),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  // ── Build ─────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.creamBackground,
      appBar: AppBar(
        title: const Text('Jelajah Hutan'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () {
            if (_currentStep > 0) {
              _goToStep(_currentStep - 1);
            } else {
              Navigator.of(context).pop();
            }
          },
        ),
      ),
      body: Column(
        children: [
          _buildProgressIndicator(),
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              onPageChanged: (index) => setState(() => _currentStep = index),
              children: [
                _buildInstructionsPage(),
                _buildObservationPage(),
                _buildSummaryPage(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Progress indicator ────────────────────────────────────────────────

  Widget _buildProgressIndicator() {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.paddingLarge,
        vertical: AppTheme.paddingSmall,
      ),
      child: Row(
        children: [
          Text(
            'Langkah ${_currentStep + 1} daripada 3',
            style: const TextStyle(
              fontSize: AppTheme.fontSizeCaption,
              fontWeight: AppTheme.weightMedium,
              color: AppTheme.secondaryText,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: (_currentStep + 1) / 3,
                backgroundColor: AppTheme.dividerColor,
                valueColor: const AlwaysStoppedAnimation(AppTheme.forestGreen),
                minHeight: 6,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Step 0: Instructions ─────────────────────────────────────────────

  Widget _buildInstructionsPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppTheme.paddingLarge),
      child: Column(
        children: [
          const SizedBox(height: 24),
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: AppTheme.lightGreen.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.park_rounded,
              size: 64,
              color: AppTheme.forestGreen,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Jelajah Hutan',
            style: TextStyle(
              fontSize: AppTheme.fontSizeTitle,
              fontWeight: AppTheme.weightBold,
              color: AppTheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Teroka alam sekitar dan cari objek menarik',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: AppTheme.fontSizeBody,
              color: AppTheme.secondaryText,
            ),
          ),
          const SizedBox(height: 32),
          _buildInstructionItem(
            icon: Icons.camera_alt_outlined,
            text: 'Gunakan kamera',
            color: AppTheme.softBlue,
          ),
          const SizedBox(height: 12),
          _buildInstructionItem(
            icon: Icons.photo_camera_outlined,
            text: 'Ambil gambar objek',
            color: AppTheme.softOrange,
          ),
          const SizedBox(height: 12),
          _buildInstructionItem(
            icon: Icons.edit_outlined,
            text: 'Namakan penemuan',
            color: AppTheme.lavender,
          ),
          const SizedBox(height: 40),
          RoundedButton(
            text: 'Mulakan',
            icon: Icons.arrow_forward,
            onPressed: () => _goToStep(1),
          ),
        ],
      ),
    );
  }

  Widget _buildInstructionItem({
    required IconData icon,
    required String text,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppTheme.radiusDefault),
        border: Border.all(color: AppTheme.dividerColor),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 16),
          Text(
            text,
            style: const TextStyle(
              fontSize: AppTheme.fontSizeBody,
              fontWeight: AppTheme.weightSemiBold,
              color: AppTheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }

  // ── Step 1: Observation ──────────────────────────────────────────────

  Widget _buildObservationPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppTheme.paddingLarge),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Camera area
          GestureDetector(
            onTap: _capturePhoto,
            child: Container(
              width: double.infinity,
              height: 220,
              decoration: BoxDecoration(
                color: AppTheme.darkGreen.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(AppTheme.radiusCard),
                border: Border.all(
                  color: AppTheme.forestGreen.withValues(alpha: 0.3),
                  width: 1.5,
                ),
              ),
              child: _capturedImage != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(AppTheme.radiusCard),
                      child: Image.file(_capturedImage!, fit: BoxFit.cover),
                    )
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.camera_alt_rounded,
                          size: 56,
                          color: AppTheme.forestGreen.withValues(alpha: 0.4),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Ketik untuk mengambil gambar',
                          style: TextStyle(
                            fontSize: AppTheme.fontSizeCaption,
                            color: AppTheme.forestGreen.withValues(alpha: 0.6),
                          ),
                        ),
                      ],
                    ),
            ),
          ),
          const SizedBox(height: 16),
          RoundedButton(
            text: 'Ambil Gambar',
            icon: Icons.camera_alt,
            onPressed: _capturePhoto,
          ),

          // AI detection result
          if (_detectedLabel != null) ...[
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppTheme.lightGreen.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(AppTheme.radiusDefault),
                border: Border.all(color: AppTheme.lightGreen),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.auto_awesome,
                    color: AppTheme.forestGreen,
                    size: 20,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'AI detect: $_detectedLabel${_confidence != null ? ' (${(_confidence! * 100).toStringAsFixed(0)}%)' : ''}',
                      style: const TextStyle(
                        fontSize: AppTheme.fontSizeCaption,
                        fontWeight: AppTheme.weightMedium,
                        color: AppTheme.forestGreen,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 20),

          // Name input
          const Text(
            'Nama Objek',
            style: TextStyle(
              fontSize: AppTheme.fontSizeCaption,
              fontWeight: AppTheme.weightMedium,
              color: AppTheme.secondaryText,
            ),
          ),
          const SizedBox(height: 6),
          TextField(
            controller: _nameController,
            onChanged: (_) => setState(() {}),
            textInputAction: TextInputAction.done,
            decoration: const InputDecoration(
              hintText: 'cth: Pokok Oak, Bunga Raya...',
              prefixIcon: Icon(
                Icons.label_outline,
                color: AppTheme.secondaryText,
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Category chips
          const Text(
            'Kategori',
            style: TextStyle(
              fontSize: AppTheme.fontSizeCaption,
              fontWeight: AppTheme.weightMedium,
              color: AppTheme.secondaryText,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _categories.map((cat) {
              final isSelected = _selectedCategory == cat;
              return GestureDetector(
                onTap: () => setState(() => _selectedCategory = cat),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected ? AppTheme.forestGreen : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected
                          ? AppTheme.forestGreen
                          : AppTheme.dividerColor,
                      width: 1.5,
                    ),
                  ),
                  child: Text(
                    cat,
                    style: TextStyle(
                      fontSize: AppTheme.fontSizeCaption,
                      fontWeight: AppTheme.weightSemiBold,
                      color: isSelected ? Colors.white : AppTheme.onSurface,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: 24),

          // Save / Skip
          RoundedButton(
            text: _isSaving ? 'Menyimpan...' : 'Simpan',
            icon: Icons.check_circle_outline,
            onPressed: _isSaving
                ? null
                : (_nameController.text.trim().isEmpty
                      ? null
                      : _saveObservation),
            isLoading: _isSaving,
          ),
          const SizedBox(height: 12),
          Center(
            child: TextButton(
              onPressed: _skip,
              child: const Text(
                'Langkau',
                style: TextStyle(
                  fontSize: AppTheme.fontSizeCaption,
                  color: AppTheme.secondaryText,
                ),
              ),
            ),
          ),

          // Go to summary
          if (_items.isNotEmpty) ...[
            const SizedBox(height: 12),
            RoundedButton(
              text: 'Lihat Ringkasan (${_items.length})',
              backgroundColor: AppTheme.darkGreen,
              onPressed: () => _goToStep(2),
            ),
          ],
        ],
      ),
    );
  }

  // ── Step 2: Summary ──────────────────────────────────────────────────

  Widget _buildSummaryPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppTheme.paddingLarge),
      child: Column(
        children: [
          const SizedBox(height: 16),

          // Celebration
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppTheme.paddingLarge),
            decoration: BoxDecoration(
              gradient: AppTheme.warmGradient,
              borderRadius: BorderRadius.circular(AppTheme.radiusCard),
            ),
            child: Column(
              children: [
                const Text('🌟', style: TextStyle(fontSize: 48)),
                const SizedBox(height: 12),
                const Text(
                  'Aktiviti Selesai!',
                  style: TextStyle(
                    fontSize: AppTheme.fontSizeHeadline,
                    fontWeight: AppTheme.weightBold,
                    color: AppTheme.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${_items.length} penemuan direkodkan',
                  style: const TextStyle(
                    fontSize: AppTheme.fontSizeBody,
                    color: AppTheme.onSurface,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Checklist
          if (_items.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Text(
                'Tiada penemuan direkodkan.',
                style: TextStyle(
                  fontSize: AppTheme.fontSizeBody,
                  color: AppTheme.secondaryText,
                ),
              ),
            )
          else
            ...List.generate(_items.length, (i) {
              final item = _items[i];
              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(AppTheme.radiusDefault),
                  border: Border.all(color: AppTheme.dividerColor),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: AppTheme.successGreen.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.check,
                        color: AppTheme.successGreen,
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.name,
                            style: const TextStyle(
                              fontSize: AppTheme.fontSizeBody,
                              fontWeight: AppTheme.weightSemiBold,
                              color: AppTheme.onSurface,
                            ),
                          ),
                          Text(
                            item.category,
                            style: const TextStyle(
                              fontSize: AppTheme.fontSizeCaption,
                              color: AppTheme.secondaryText,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (item.imagePath != null)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.file(
                          File(item.imagePath!),
                          width: 44,
                          height: 44,
                          fit: BoxFit.cover,
                        ),
                      ),
                  ],
                ),
              );
            }),

          const SizedBox(height: 32),

          RoundedButton(
            text: _isSaving ? 'Menyimpan...' : 'Selesaikan Aktiviti',
            icon: Icons.home_outlined,
            isLoading: _isSaving,
            onPressed: _isSaving ? null : _finishActivity,
          ),
        ],
      ),
    );
  }
}

// ── Helper class ───────────────────────────────────────────────────────

class _ObservedItem {
  final String name;
  final String category;
  final String? imagePath;
  final String? imageURL;

  const _ObservedItem({
    required this.name,
    required this.category,
    this.imagePath,
    this.imageURL,
  });
}
