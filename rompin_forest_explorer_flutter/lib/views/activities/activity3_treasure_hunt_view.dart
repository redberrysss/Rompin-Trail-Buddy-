import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import '../../theme/app_theme.dart';
import '../../services/activity_data_service.dart';
import '../../services/storage_service.dart';
import '../../models/treasure_record.dart';

class Activity3TreasureHuntView extends StatefulWidget {
  const Activity3TreasureHuntView({
    super.key,
    required this.participantID,
    required this.participantName,
  });

  final String participantID;
  final String participantName;

  @override
  State<Activity3TreasureHuntView> createState() =>
      _Activity3TreasureHuntViewState();
}

class _Activity3TreasureHuntViewState extends State<Activity3TreasureHuntView> {
  final PageController _pageController = PageController();
  final ImagePicker _picker = ImagePicker();

  int _currentStep = 0;
  bool _isSaving = false;
  String? _feedbackMessage;

  static const _treasures = [
    _TreasureItem(emoji: '🌳', name: 'Pokok Besar'),
    _TreasureItem(emoji: '🌸', name: 'Bunga Liar'),
    _TreasureItem(emoji: '🪨', name: 'Batu Unik'),
    _TreasureItem(emoji: '🦋', name: 'Rama-rama'),
    _TreasureItem(emoji: '🐛', name: 'Serangga'),
    _TreasureItem(emoji: '🍃', name: 'Daun Berwarna'),
    _TreasureItem(emoji: '🌿', name: 'Lumut'),
    _TreasureItem(emoji: '🪺', name: 'Sarang Burung'),
  ];

  final List<bool> _foundStatus = List.filled(8, false);
  final Map<int, File?> _capturedImages = {};

  int get _foundCount => _foundStatus.where((f) => f).length;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  // ── Capture photo for a treasure item ────────────────────────────────

  Future<void> _captureForItem(int index) async {
    print(
      '[Activity3] _captureForItem: index=$index, item=${_treasures[index].name}',
    );
    final xfile = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 85,
    );
    if (xfile == null) return;

    final file = File(xfile.path);
    setState(() {
      _capturedImages[index] = file;
      _foundStatus[index] = true;
      _feedbackMessage = 'Hebat! Anda jumpa ${_treasures[index].name}!';
    });

    // Save to Firestore
    await _saveTreasureRecord(index, file);

    // Clear feedback after a delay
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _feedbackMessage = null;
        });
      }
    });
  }

  Future<void> _saveTreasureRecord(int index, File imageFile) async {
    print('[Activity3] _saveTreasureRecord: ${_treasures[index].name}');
    setState(() => _isSaving = true);

    try {
      final docId = const Uuid().v4();
      final storagePath = 'users/${widget.participantID}/activity_3/$docId.jpg';
      final imageURL = await StorageService.instance.uploadFile(
        storagePath,
        imageFile,
      );

      final now = DateTime.now();
      final record = TreasureRecord(
        id: docId,
        ownerId: widget.participantID,
        participantId: widget.participantID,
        sessionId: 'session_${now.millisecondsSinceEpoch}',
        itemName: _treasures[index].name,
        imageStoragePath: storagePath,
        imageDownloadURL: imageURL,
        isFound: true,
        createdAt: now,
        updatedAt: now,
      );

      await ActivityDataService.instance.saveRecord(
        personalCollection: 'treasureRecords',
        groupCollection: 'treasureRecords',
        id: record.id!,
        data: record.toMap(),
      );
      await ActivityDataService.instance.saveActivityProgress(
        participantId: widget.participantID,
        activityNumber: 3,
        progress: (_foundCount / _treasures.length).clamp(0.0, 1.0),
      );

      print('[Activity3] saved: ${record.itemName}');
    } catch (e) {
      print('[Activity3] save error: $e');
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  void _goToStep(int step) {
    print('[Activity3] goToStep: $step');
    _pageController.animateToPage(
      step,
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeInOut,
    );
  }

  Future<void> _finishActivity() async {
    if (_foundCount == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Ambil sekurang-kurangnya satu gambar dahulu.'),
        ),
      );
      return;
    }
    setState(() => _isSaving = true);
    try {
      await ActivityDataService.instance.saveActivityProgress(
        participantId: widget.participantID,
        activityNumber: 3,
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.creamBackground,
      appBar: AppBar(
        title: const Text('Nature Treasure Hunt'),
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
        actions: [
          if (_currentStep == 1)
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.forestGreen.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '$_foundCount / 8 Dijumpai',
                    style: const TextStyle(
                      fontSize: AppTheme.fontSizeCaption,
                      fontWeight: AppTheme.weightSemiBold,
                      color: AppTheme.forestGreen,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
        onPageChanged: (index) => setState(() => _currentStep = index),
        children: [_buildInstructionsPage(), _buildHuntPage()],
      ),
    );
  }

  // ── Instructions page ────────────────────────────────────────────────

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
              color: AppTheme.softOrange.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.map_rounded,
              size: 64,
              color: AppTheme.softOrange,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Nature Treasure Hunt',
            style: TextStyle(
              fontSize: AppTheme.fontSizeTitle,
              fontWeight: AppTheme.weightBold,
              color: AppTheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Cari dan ambil gambar objek semula jadi!',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: AppTheme.fontSizeBody,
              color: AppTheme.secondaryText,
            ),
          ),
          const SizedBox(height: 28),

          // Item checklist preview
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppTheme.paddingMedium),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(AppTheme.radiusCard),
              border: Border.all(color: AppTheme.dividerColor),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Senarai Harta Karun:',
                  style: TextStyle(
                    fontSize: AppTheme.fontSizeBody,
                    fontWeight: AppTheme.weightSemiBold,
                    color: AppTheme.onSurface,
                  ),
                ),
                const SizedBox(height: 12),
                ...List.generate(_treasures.length, (i) {
                  final t = _treasures[i];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        Text(t.emoji, style: const TextStyle(fontSize: 20)),
                        const SizedBox(width: 10),
                        Text(
                          t.name,
                          style: const TextStyle(
                            fontSize: AppTheme.fontSizeCaption,
                            color: AppTheme.onSurface,
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),

          const SizedBox(height: 32),
          RoundedButton(
            text: 'Mulakan',
            icon: Icons.play_arrow_rounded,
            onPressed: () => _goToStep(1),
          ),
        ],
      ),
    );
  }

  // ── Main hunt page ───────────────────────────────────────────────────

  Widget _buildHuntPage() {
    return Stack(
      children: [
        Column(
          children: [
            // Feedback banner
            AnimatedOpacity(
              opacity: _feedbackMessage != null ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 300),
              child: _feedbackMessage != null
                  ? Container(
                      width: double.infinity,
                      margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppTheme.lightGreen.withValues(alpha: 0.3),
                            AppTheme.softYellow.withValues(alpha: 0.3),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(
                          AppTheme.radiusDefault,
                        ),
                        border: Border.all(
                          color: AppTheme.successGreen.withValues(alpha: 0.4),
                        ),
                      ),
                      child: Row(
                        children: [
                          const Text('🎉', style: TextStyle(fontSize: 24)),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              _feedbackMessage!,
                              style: const TextStyle(
                                fontSize: AppTheme.fontSizeBody,
                                fontWeight: AppTheme.weightSemiBold,
                                color: AppTheme.forestGreen,
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  : const SizedBox.shrink(),
            ),

            // Treasure list
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(AppTheme.paddingLarge),
                itemCount: _treasures.length,
                itemBuilder: (context, index) => _buildTreasureItem(index),
              ),
            ),

            // Bottom button
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppTheme.paddingLarge,
                0,
                AppTheme.paddingLarge,
                AppTheme.paddingLarge,
              ),
              child: RoundedButton(
                text: _isSaving ? 'Menyimpan...' : 'Selesai',
                icon: Icons.check_circle_outline,
                isLoading: _isSaving,
                onPressed: _isSaving ? null : _finishActivity,
              ),
            ),
          ],
        ),

        // Saving overlay
        if (_isSaving)
          Container(
            color: Colors.black.withValues(alpha: 0.15),
            child: const Center(
              child: CircularProgressIndicator(color: AppTheme.forestGreen),
            ),
          ),
      ],
    );
  }

  Widget _buildTreasureItem(int index) {
    final item = _treasures[index];
    final isFound = _foundStatus[index];
    final image = _capturedImages[index];

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isFound
            ? AppTheme.lightGreen.withValues(alpha: 0.08)
            : Colors.white,
        borderRadius: BorderRadius.circular(AppTheme.radiusDefault),
        border: Border.all(
          color: isFound
              ? AppTheme.successGreen.withValues(alpha: 0.4)
              : AppTheme.dividerColor,
          width: isFound ? 1.5 : 1,
        ),
      ),
      child: Row(
        children: [
          // Emoji
          Text(item.emoji, style: const TextStyle(fontSize: 32)),
          const SizedBox(width: 14),

          // Name + status
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
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      isFound
                          ? Icons.check_circle
                          : Icons.radio_button_unchecked,
                      size: 16,
                      color: isFound
                          ? AppTheme.successGreen
                          : AppTheme.secondaryText,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      isFound ? 'Dijumpai' : 'Belum',
                      style: TextStyle(
                        fontSize: AppTheme.fontSizeCaption,
                        fontWeight: AppTheme.weightMedium,
                        color: isFound
                            ? AppTheme.successGreen
                            : AppTheme.secondaryText,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Image preview or camera button
          if (image != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.file(
                image,
                width: 56,
                height: 56,
                fit: BoxFit.cover,
              ),
            )
          else
            ScaleButton(
              onTap: () => _captureForItem(index),
              child: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppTheme.forestGreen.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.camera_alt_rounded,
                  color: AppTheme.forestGreen,
                  size: 22,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ── Data class ─────────────────────────────────────────────────────────

class _TreasureItem {
  const _TreasureItem({required this.emoji, required this.name});

  final String emoji;
  final String name;
}
