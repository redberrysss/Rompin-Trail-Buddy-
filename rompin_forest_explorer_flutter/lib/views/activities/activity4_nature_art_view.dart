import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import '../../theme/app_theme.dart';
import '../../services/activity_data_service.dart';
import '../../services/storage_service.dart';
import '../../services/collage_service.dart';
import '../../models/artwork_record.dart';

class Activity4NatureArtView extends StatefulWidget {
  const Activity4NatureArtView({
    super.key,
    required this.participantID,
    required this.participantName,
  });

  final String participantID;
  final String participantName;

  @override
  State<Activity4NatureArtView> createState() => _Activity4NatureArtViewState();
}

class _Activity4NatureArtViewState extends State<Activity4NatureArtView> {
  final PageController _pageController = PageController();
  final TextEditingController _titleController = TextEditingController();
  final ImagePicker _picker = ImagePicker();

  int _currentStep = 0;
  bool _isSaving = false;
  bool _isLoadingGallery = false;

  String _artType = 'Collage';
  List<_GalleryImage> _galleryImages = [];
  final Set<String> _selectedImageIds = {};
  File? _newCapturedImage;

  static const _artTypes = ['Collage', 'Gambar Foto'];

  @override
  void dispose() {
    _pageController.dispose();
    _titleController.dispose();
    super.dispose();
  }

  // ── Load gallery from Firestore ──────────────────────────────────────

  Future<void> _loadGallery() async {
    print('[Activity4] _loadGallery for participant: ${widget.participantID}');
    setState(() => _isLoadingGallery = true);

    try {
      final discoveries = await ActivityDataService.instance
          .loadStudentDiscoveries(widget.participantID);
      final images = discoveries.items
          .where((item) => item.imageUrl != null)
          .map(
            (item) => _GalleryImage(
              id: '${item.type.name}:${item.id}',
              url: item.imageUrl!,
              source: item.type.name,
              label: item.title,
            ),
          )
          .toList();

      setState(() {
        _galleryImages = images;
        _isLoadingGallery = false;
      });

      print('[Activity4] loaded ${images.length} gallery images');
    } catch (e) {
      print('[Activity4] loadGallery error: $e');
      setState(() => _isLoadingGallery = false);
    }
  }

  // ── Camera capture ───────────────────────────────────────────────────

  Future<void> _captureNewPhoto() async {
    print('[Activity4] _captureNewPhoto');
    final xfile = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 85,
    );
    if (xfile == null) return;
    setState(() => _newCapturedImage = File(xfile.path));
  }

  // ── Save artwork ─────────────────────────────────────────────────────

  Future<void> _saveArtwork() async {
    if (_titleController.text.trim().isEmpty) return;
    if (_artType == 'Collage' && _selectedImageIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pilih sekurang-kurangnya satu gambar untuk kolaj.'),
        ),
      );
      return;
    }
    if (_artType == 'Gambar Foto' && _newCapturedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ambil gambar hasil karya dahulu.')),
      );
      return;
    }
    print(
      '[Activity4] _saveArtwork: title=${_titleController.text.trim()}, type=$_artType',
    );

    setState(() => _isSaving = true);

    try {
      String? artworkPath;
      String? artworkURL;

      File? artworkFile = _newCapturedImage;
      if (_artType == 'Collage') {
        final selectedUrls = _galleryImages
            .where((image) => _selectedImageIds.contains(image.id))
            .map((image) => image.url)
            .toList();
        artworkFile = await CollageService.instance.createCollage(selectedUrls);
      }

      if (artworkFile != null) {
        final docId = const Uuid().v4();
        artworkPath = 'users/${widget.participantID}/activity_4/$docId.jpg';
        artworkURL = await StorageService.instance.uploadFile(
          artworkPath,
          artworkFile,
        );
      }

      final now = DateTime.now();
      final record = ArtworkRecord(
        id: const Uuid().v4(),
        ownerId: widget.participantID,
        participantId: widget.participantID,
        sessionId: 'session_${now.millisecondsSinceEpoch}',
        title: _titleController.text.trim(),
        artworkStoragePath: artworkPath ?? '',
        artworkDownloadURL: artworkURL,
        sourceImageIds: _selectedImageIds.toList(),
        artworkType: _artType,
        createdAt: now,
        updatedAt: now,
      );

      await ActivityDataService.instance.saveRecord(
        personalCollection: 'artworks',
        groupCollection: 'artworks',
        id: record.id!,
        data: record.toMap(),
      );
      await ActivityDataService.instance.saveActivityProgress(
        participantId: widget.participantID,
        activityNumber: 4,
        progress: 1,
      );

      print('[Activity4] saved artwork: ${record.title}');

      if (mounted) {
        _showCelebration();
      }
    } catch (e) {
      print('[Activity4] save error: $e');
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Karya gagal disimpan: $e')));
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  void _showCelebration() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusCard),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('🌟', style: TextStyle(fontSize: 56)),
            const SizedBox(height: 16),
            const Text(
              'Karya Tersimpan!',
              style: TextStyle(
                fontSize: AppTheme.fontSizeHeadline,
                fontWeight: AppTheme.weightBold,
                color: AppTheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '"${_titleController.text.trim()}" telah disimpan.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: AppTheme.fontSizeCaption,
                color: AppTheme.secondaryText,
              ),
            ),
            const SizedBox(height: 20),
            RoundedButton(
              text: 'OK',
              onPressed: () {
                Navigator.of(ctx).pop();
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _goToStep(int step) {
    print('[Activity4] goToStep: $step');
    _pageController.animateToPage(
      step,
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeInOut,
    );
    if (step == 1) _loadGallery();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.creamBackground,
      appBar: AppBar(
        title: const Text('Seni Alam'),
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
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
        onPageChanged: (index) => setState(() => _currentStep = index),
        children: [_buildInstructionsPage(), _buildArtCreationPage()],
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
              color: AppTheme.lavender.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.brush, size: 64, color: AppTheme.lavender),
          ),
          const SizedBox(height: 24),
          const Text(
            'Seni Alam',
            style: TextStyle(
              fontSize: AppTheme.fontSizeTitle,
              fontWeight: AppTheme.weightBold,
              color: AppTheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Hasilkan karya seni dari penemuan anda!',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: AppTheme.fontSizeBody,
              color: AppTheme.secondaryText,
            ),
          ),
          const SizedBox(height: 32),
          RoundedButton(
            text: 'Mulakan',
            icon: Icons.arrow_forward,
            onPressed: () => _goToStep(1),
          ),
        ],
      ),
    );
  }

  // ── Art creation page ────────────────────────────────────────────────

  Widget _buildArtCreationPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppTheme.paddingLarge),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title input
          const Text(
            'Nama Karya Seni',
            style: TextStyle(
              fontSize: AppTheme.fontSizeCaption,
              fontWeight: AppTheme.weightMedium,
              color: AppTheme.secondaryText,
            ),
          ),
          const SizedBox(height: 6),
          TextField(
            controller: _titleController,
            onChanged: (_) => setState(() {}),
            textInputAction: TextInputAction.done,
            decoration: const InputDecoration(
              hintText: 'cth: Collage Hutan, Gambar Pokok...',
              prefixIcon: Icon(Icons.title, color: AppTheme.secondaryText),
            ),
          ),

          const SizedBox(height: 20),

          // Art type chips
          const Text(
            'Jenis Karya',
            style: TextStyle(
              fontSize: AppTheme.fontSizeCaption,
              fontWeight: AppTheme.weightMedium,
              color: AppTheme.secondaryText,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: _artTypes.map((type) {
              final isSelected = _artType == type;
              return Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _artType = type),
                  child: Container(
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: isSelected ? AppTheme.forestGreen : Colors.white,
                      borderRadius: BorderRadius.circular(
                        AppTheme.radiusDefault,
                      ),
                      border: Border.all(
                        color: isSelected
                            ? AppTheme.forestGreen
                            : AppTheme.dividerColor,
                        width: 1.5,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        type,
                        style: TextStyle(
                          fontSize: AppTheme.fontSizeCaption,
                          fontWeight: AppTheme.weightSemiBold,
                          color: isSelected ? Colors.white : AppTheme.onSurface,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: 24),

          // Gallery section header
          Row(
            children: [
              const Text(
                '📷 Galeri',
                style: TextStyle(
                  fontSize: AppTheme.fontSizeBody,
                  fontWeight: AppTheme.weightSemiBold,
                  color: AppTheme.onSurface,
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: _captureNewPhoto,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.forestGreen.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.camera_alt_rounded,
                        size: 16,
                        color: AppTheme.forestGreen,
                      ),
                      SizedBox(width: 4),
                      Text(
                        'Gambar Baharu',
                        style: TextStyle(
                          fontSize: AppTheme.fontSizeSmall,
                          fontWeight: AppTheme.weightSemiBold,
                          color: AppTheme.forestGreen,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          const Text(
            'Pilih gambar dari aktiviti sebelumnya',
            style: TextStyle(
              fontSize: AppTheme.fontSizeCaption,
              color: AppTheme.secondaryText,
            ),
          ),

          const SizedBox(height: 12),

          // Gallery grid
          if (_isLoadingGallery)
            const SizedBox(
              height: 120,
              child: Center(
                child: CircularProgressIndicator(color: AppTheme.forestGreen),
              ),
            )
          else if (_galleryImages.isEmpty)
            Container(
              width: double.infinity,
              height: 100,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(AppTheme.radiusDefault),
                border: Border.all(
                  color: AppTheme.dividerColor,
                  style: BorderStyle.solid,
                ),
              ),
              child: const Center(
                child: Text(
                  'Tiada gambar lagi. Ambil gambar baharu!',
                  style: TextStyle(
                    fontSize: AppTheme.fontSizeCaption,
                    color: AppTheme.secondaryText,
                  ),
                ),
              ),
            )
          else
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
              ),
              itemCount: _galleryImages.length,
              itemBuilder: (context, index) {
                final img = _galleryImages[index];
                final isSelected = _selectedImageIds.contains(img.id);
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      if (isSelected) {
                        _selectedImageIds.remove(img.id);
                      } else {
                        _selectedImageIds.add(img.id);
                      }
                    });
                  },
                  child: Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(
                          AppTheme.radiusDefault,
                        ),
                        child: Image.network(
                          img.url,
                          width: double.infinity,
                          height: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            color: AppTheme.dividerColor,
                            child: const Icon(
                              Icons.broken_image,
                              color: AppTheme.secondaryText,
                            ),
                          ),
                        ),
                      ),
                      if (isSelected)
                        Positioned(
                          top: 6,
                          right: 6,
                          child: Container(
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              color: AppTheme.forestGreen,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.2),
                                  blurRadius: 4,
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.check,
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                        ),
                      // Source label
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.5),
                            borderRadius: const BorderRadius.vertical(
                              bottom: Radius.circular(AppTheme.radiusDefault),
                            ),
                          ),
                          child: Text(
                            img.label,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 10,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),

          // New captured photo preview
          if (_newCapturedImage != null) ...[
            const SizedBox(height: 16),
            const Text(
              'Gambar Baharu:',
              style: TextStyle(
                fontSize: AppTheme.fontSizeCaption,
                fontWeight: AppTheme.weightMedium,
                color: AppTheme.secondaryText,
              ),
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(AppTheme.radiusDefault),
              child: Stack(
                children: [
                  Image.file(
                    _newCapturedImage!,
                    width: double.infinity,
                    height: 180,
                    fit: BoxFit.cover,
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: GestureDetector(
                      onTap: () => setState(() => _newCapturedImage = null),
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.5),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.close,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 16),

          // Selection summary
          if (_selectedImageIds.isNotEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.lightGreen.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(AppTheme.radiusDefault),
              ),
              child: Text(
                '${_selectedImageIds.length} gambar dipilih untuk collage',
                style: const TextStyle(
                  fontSize: AppTheme.fontSizeCaption,
                  fontWeight: AppTheme.weightMedium,
                  color: AppTheme.forestGreen,
                ),
              ),
            ),

          const SizedBox(height: 20),

          // Save button
          RoundedButton(
            text: _isSaving ? 'Menyimpan...' : 'Simpan Karya',
            icon: Icons.save_outlined,
            isLoading: _isSaving,
            onPressed: _isSaving
                ? null
                : (_titleController.text.trim().isEmpty ? null : _saveArtwork),
          ),
          const SizedBox(height: 12),
          Center(
            child: TextButton(
              onPressed: () {
                print('[Activity4] skip');
                Navigator.of(context).pop();
              },
              child: const Text(
                'Langkau',
                style: TextStyle(
                  fontSize: AppTheme.fontSizeCaption,
                  color: AppTheme.secondaryText,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Data class ─────────────────────────────────────────────────────────

class _GalleryImage {
  const _GalleryImage({
    required this.id,
    required this.url,
    required this.source,
    required this.label,
  });

  final String id;
  final String url;
  final String source;
  final String label;
}
