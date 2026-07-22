import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import '../../theme/app_theme.dart';
import '../../services/activity_data_service.dart';
import '../../services/storage_service.dart';
import '../../models/sensory_record.dart';

class Activity2SensoryView extends StatefulWidget {
  const Activity2SensoryView({
    super.key,
    required this.participantID,
    required this.participantName,
  });

  final String participantID;
  final String participantName;

  @override
  State<Activity2SensoryView> createState() => _Activity2SensoryViewState();
}

class _Activity2SensoryViewState extends State<Activity2SensoryView> {
  final PageController _pageController = PageController();
  final ImagePicker _picker = ImagePicker();

  int _currentStation = 0;
  bool _isSaving = false;

  // Per-station state
  final Map<int, String> _selectedValues = {};
  final Map<int, String?> _emotions = {};
  final Map<int, File?> _photos = {};

  static const _stations = [
    _SensoryStation(
      number: 1,
      senseType: 'penglihatan',
      emoji: '👁️',
      title: 'Apa yang anda nampak?',
      options: ['Pokok', 'Langit', 'Air', 'Batu', 'Bunga'],
    ),
    _SensoryStation(
      number: 2,
      senseType: 'pendengaran',
      emoji: '👂',
      title: 'Apa yang anda dengar?',
      options: ['Burung', 'Air', 'Angin', 'Serangga', 'Daun'],
    ),
    _SensoryStation(
      number: 3,
      senseType: 'sentuhan',
      emoji: '✋',
      title: 'Apa yang anda rasa?',
      options: ['Sejuk', 'Panas', 'Lembut', 'Keras', 'Basah'],
    ),
    _SensoryStation(
      number: 4,
      senseType: 'pembauan',
      emoji: '👃',
      title: 'Apa yang anda bau?',
      options: ['Bunga', 'Tanah', 'Kayu', 'Daun', 'Buah'],
    ),
  ];

  static const _emotionEmojis = ['😊', '😢', '😠', '😨', '😲'];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _capturePhoto(int stationIndex) async {
    print('[Activity2] _capturePhoto station=$stationIndex');
    final xfile = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 85,
    );
    if (xfile == null) return;
    setState(() => _photos[stationIndex] = File(xfile.path));
  }

  Future<void> _saveStationData(int stationIndex) async {
    final station = _stations[stationIndex];
    final selectedValue = _selectedValues[stationIndex] ?? '';
    if (selectedValue.isEmpty) return;

    print(
      '[Activity2] _saveStationData: station=${station.number}, type=${station.senseType}, value=$selectedValue',
    );

    setState(() => _isSaving = true);

    try {
      String? imagePath;
      String? imageURL;

      final photo = _photos[stationIndex];
      if (photo != null) {
        final docId = const Uuid().v4();
        imagePath =
            'users/${widget.participantID}/activity_2/${station.senseType}_$docId.jpg';
        imageURL = await StorageService.instance.uploadFile(imagePath, photo);
      }

      final now = DateTime.now();
      final record = SensoryRecord(
        id: const Uuid().v4(),
        ownerId: widget.participantID,
        participantId: widget.participantID,
        sessionId: 'session_${now.millisecondsSinceEpoch}',
        stationNumber: station.number,
        senseType: station.senseType,
        selectedValue: selectedValue,
        emotion: _emotions[stationIndex],
        imageStoragePath: imagePath,
        imageDownloadURL: imageURL,
        createdAt: now,
        updatedAt: now,
      );

      await ActivityDataService.instance.saveRecord(
        personalCollection: 'sensoryRecords',
        groupCollection: 'sensoryRecords',
        id: record.id!,
        data: record.toMap(),
      );
      await ActivityDataService.instance.saveActivityProgress(
        participantId: widget.participantID,
        activityNumber: 2,
        progress: (_selectedValues.length / _stations.length).clamp(0.0, 1.0),
      );

      print('[Activity2] saved: ${record.senseType}=${record.selectedValue}');
    } catch (e) {
      print('[Activity2] save error: $e');
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _goToNext() async {
    final hasSelection = (_selectedValues[_currentStation] ?? '').isNotEmpty;

    if (hasSelection) {
      await _saveStationData(_currentStation);
    }

    if (_currentStation < _stations.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
    } else {
      setState(() => _isSaving = true);
      try {
        await ActivityDataService.instance.saveActivityProgress(
          participantId: widget.participantID,
          activityNumber: 2,
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
  }

  void _goToPrevious() {
    if (_currentStation > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.creamBackground,
      appBar: AppBar(
        title: const Text('Aktiviti Sensori'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () {
            if (_currentStation > 0) {
              _goToPrevious();
            } else {
              Navigator.of(context).pop();
            }
          },
        ),
      ),
      body: Column(
        children: [
          _buildProgressDots(),
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _stations.length,
              onPageChanged: (index) => setState(() => _currentStation = index),
              itemBuilder: (context, index) => _buildStationPage(index),
            ),
          ),
        ],
      ),
    );
  }

  // ── Progress dots ────────────────────────────────────────────────────

  Widget _buildProgressDots() {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.paddingLarge,
        vertical: AppTheme.paddingSmall,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(_stations.length, (i) {
          final isActive = i == _currentStation;
          final isCompleted = (_selectedValues[i] ?? '').isNotEmpty;
          return AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            margin: const EdgeInsets.symmetric(horizontal: 5),
            width: isActive ? 28 : 10,
            height: 10,
            decoration: BoxDecoration(
              color: isCompleted
                  ? AppTheme.forestGreen
                  : isActive
                  ? AppTheme.softBlue
                  : AppTheme.dividerColor,
              borderRadius: BorderRadius.circular(5),
            ),
          );
        }),
      ),
    );
  }

  // ── Station page ─────────────────────────────────────────────────────

  Widget _buildStationPage(int index) {
    final station = _stations[index];
    final selectedValue = _selectedValues[index] ?? '';
    final emotion = _emotions[index];
    final photo = _photos[index];
    final isLast = index == _stations.length - 1;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppTheme.paddingLarge),
      child: Column(
        children: [
          const SizedBox(height: 16),

          // Emoji icon
          Text(station.emoji, style: const TextStyle(fontSize: 48)),
          const SizedBox(height: 16),

          // Question title
          Text(
            station.title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: AppTheme.fontSizeHeadline,
              fontWeight: AppTheme.weightBold,
              color: AppTheme.onSurface,
            ),
          ),

          const SizedBox(height: 24),

          // Station number label
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: AppTheme.forestGreen.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'Stesen ${station.number} daripada ${_stations.length}',
              style: const TextStyle(
                fontSize: AppTheme.fontSizeCaption,
                fontWeight: AppTheme.weightMedium,
                color: AppTheme.forestGreen,
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Option chips
          Wrap(
            spacing: 10,
            runSpacing: 10,
            alignment: WrapAlignment.center,
            children: station.options.map((option) {
              final isSelected = selectedValue == option;
              return GestureDetector(
                onTap: () => setState(() => _selectedValues[index] = option),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected ? AppTheme.forestGreen : Colors.white,
                    borderRadius: BorderRadius.circular(AppTheme.radiusDefault),
                    border: Border.all(
                      color: isSelected
                          ? AppTheme.forestGreen
                          : AppTheme.dividerColor,
                      width: isSelected ? 2 : 1.5,
                    ),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: AppTheme.forestGreen.withValues(
                                alpha: 0.2,
                              ),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ]
                        : [],
                  ),
                  child: Text(
                    option,
                    style: TextStyle(
                      fontSize: AppTheme.fontSizeBody,
                      fontWeight: AppTheme.weightSemiBold,
                      color: isSelected ? Colors.white : AppTheme.onSurface,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: 24),

          // Photo capture (for penglihatan and sentuhan)
          if (station.senseType == 'penglihatan' ||
              station.senseType == 'sentuhan') ...[
            GestureDetector(
              onTap: () => _capturePhoto(index),
              child: Container(
                width: double.infinity,
                height: 140,
                decoration: BoxDecoration(
                  color: AppTheme.softBlue.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(AppTheme.radiusCard),
                  border: Border.all(
                    color: AppTheme.softBlue.withValues(alpha: 0.3),
                    width: 1.5,
                  ),
                ),
                child: photo != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(
                          AppTheme.radiusCard,
                        ),
                        child: Image.file(photo, fit: BoxFit.cover),
                      )
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.camera_alt_rounded,
                            size: 40,
                            color: AppTheme.softBlue.withValues(alpha: 0.5),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Ambil gambar (pilihan)',
                            style: TextStyle(
                              fontSize: AppTheme.fontSizeCaption,
                              color: AppTheme.softBlue.withValues(alpha: 0.7),
                            ),
                          ),
                        ],
                      ),
              ),
            ),
            const SizedBox(height: 24),
          ],

          // Audio placeholder for pendengaran
          if (station.senseType == 'pendengaran') ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppTheme.lavender.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppTheme.radiusCard),
                border: Border.all(
                  color: AppTheme.lavender.withValues(alpha: 0.3),
                ),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.mic_rounded,
                    size: 40,
                    color: AppTheme.lavender.withValues(alpha: 0.6),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Dengar sekeliling anda',
                    style: TextStyle(
                      fontSize: AppTheme.fontSizeCaption,
                      color: AppTheme.lavender.withValues(alpha: 0.8),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],

          // Emotion picker
          const Text(
            'Bagaimana perasaan anda?',
            style: TextStyle(
              fontSize: AppTheme.fontSizeCaption,
              fontWeight: AppTheme.weightMedium,
              color: AppTheme.secondaryText,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: _emotionEmojis.map((e) {
              final isSelected = emotion == e;
              return GestureDetector(
                onTap: () => setState(() => _emotions[index] = e),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.symmetric(horizontal: 6),
                  width: isSelected ? 52 : 44,
                  height: isSelected ? 52 : 44,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppTheme.lightGreen.withValues(alpha: 0.2)
                        : Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected
                          ? AppTheme.forestGreen
                          : AppTheme.dividerColor,
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      e,
                      style: TextStyle(fontSize: isSelected ? 26 : 22),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: 32),

          // Navigation buttons
          RoundedButton(
            text: isLast ? 'Selesai Aktiviti' : 'Seterusnya',
            icon: isLast ? Icons.check_circle : Icons.arrow_forward,
            isLoading: _isSaving,
            onPressed: _isSaving ? null : _goToNext,
          ),
          if (!isLast) ...[
            const SizedBox(height: 12),
            Center(
              child: TextButton(
                onPressed: () {
                  _pageController.nextPage(
                    duration: const Duration(milliseconds: 350),
                    curve: Curves.easeInOut,
                  );
                },
                child: const Text(
                  'Langkau Stesen Ini',
                  style: TextStyle(
                    fontSize: AppTheme.fontSizeCaption,
                    color: AppTheme.secondaryText,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ── Data class ─────────────────────────────────────────────────────────

class _SensoryStation {
  const _SensoryStation({
    required this.number,
    required this.senseType,
    required this.emoji,
    required this.title,
    required this.options,
  });

  final int number;
  final String senseType;
  final String emoji;
  final String title;
  final List<String> options;
}
