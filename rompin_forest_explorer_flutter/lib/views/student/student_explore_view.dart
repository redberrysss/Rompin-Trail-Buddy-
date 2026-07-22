import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';

import '../../models/observation_record.dart';
import '../../models/student_discovery.dart';
import '../../services/activity_data_service.dart';
import '../../services/storage_service.dart';
import '../../theme/app_theme.dart';

class StudentExploreView extends StatefulWidget {
  const StudentExploreView({super.key, required this.participantID});

  final String participantID;

  @override
  State<StudentExploreView> createState() => _StudentExploreViewState();
}

class _StudentExploreViewState extends State<StudentExploreView> {
  final ImagePicker _imagePicker = ImagePicker();
  bool _isCapturing = false;
  bool _isLoadingRecent = true;
  List<StudentDiscovery> _recentDiscoveries = const [];

  @override
  void initState() {
    super.initState();
    _loadRecentDiscoveries();
  }

  Future<void> _loadRecentDiscoveries() async {
    try {
      final result = await ActivityDataService.instance.loadStudentDiscoveries(
        widget.participantID,
      );
      if (!mounted) return;
      setState(() {
        _recentDiscoveries = result.items.take(3).toList();
        _isLoadingRecent = false;
      });
    } catch (error) {
      debugPrint('[StudentExploreView] Recent discoveries failed: $error');
      if (mounted) setState(() => _isLoadingRecent = false);
    }
  }

  static const List<Map<String, String>> _categories = [
    {'emoji': '🌳', 'title': 'Pokok', 'description': 'Kenali spesies pokok'},
    {'emoji': '🌸', 'title': 'Bunga', 'description': 'Temui bunga cantik'},
    {'emoji': '🦋', 'title': 'Serangga', 'description': 'Perhatikan serangga'},
    {'emoji': '🐦', 'title': 'Burung', 'description': 'Dengar kicauan burung'},
  ];

  @override
  Widget build(BuildContext context) {
    print('[StudentExploreView] build');

    return Scaffold(
      backgroundColor: AppTheme.creamBackground,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppTheme.paddingStandard),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              _buildExploreHeader(),
              const SizedBox(height: 20),
              _buildCameraButton(context),
              const SizedBox(height: 24),
              _buildCategoriesHeader(),
              const SizedBox(height: 12),
              _buildCategoryGrid(context),
              const SizedBox(height: 24),
              _buildRecentDiscoveries(),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildExploreHeader() {
    print('[StudentExploreView] building header');
    return Center(
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppTheme.forestGreen.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.remove_red_eye,
              size: 48,
              color: AppTheme.forestGreen,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Apa yang anda nampak?',
            textAlign: TextAlign.center,
            maxLines: 2,
            style: TextStyle(
              fontSize: AppTheme.fontSizeHeadline,
              fontWeight: AppTheme.weightSemiBold,
              color: AppTheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Gunakan kamera untuk terokai alam sekitar',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: AppTheme.fontSizeCaption,
              color: AppTheme.secondaryText.withValues(alpha: 0.8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCameraButton(BuildContext context) {
    print('[StudentExploreView] building camera button');
    return RoundedButton(
      text: _isCapturing ? 'Menyimpan...' : 'Buka Kamera',
      icon: Icons.camera_alt_outlined,
      onPressed: _isCapturing ? null : _captureDiscovery,
    );
  }

  Future<void> _captureDiscovery() async {
    try {
      final photo = await _imagePicker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
        preferredCameraDevice: CameraDevice.rear,
      );
      if (photo == null || !mounted) return;

      final details = await _requestDiscoveryDetails(photo.path);
      if (details == null || !mounted) return;
      setState(() => _isCapturing = true);

      final id = const Uuid().v4();
      final storagePath = 'users/${widget.participantID}/activity_1/$id.jpg';
      final downloadURL = await StorageService.instance.uploadFile(
        storagePath,
        File(photo.path),
      );
      final now = DateTime.now();
      final record = ObservationRecord(
        id: id,
        ownerId: widget.participantID,
        participantId: widget.participantID,
        sessionId: 'camera_${now.millisecondsSinceEpoch}',
        activityNumber: 1,
        category: details.category,
        objectName: details.name,
        imageStoragePath: storagePath,
        imageDownloadURL: downloadURL,
        createdAt: now,
        updatedAt: now,
      );
      await ActivityDataService.instance.saveRecord(
        personalCollection: 'observations',
        groupCollection: 'observations',
        id: id,
        data: record.toMap(),
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Penemuan dan gambar berjaya disimpan.')),
      );
      await _loadRecentDiscoveries();
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Kamera tidak dapat digunakan: $error'),
          backgroundColor: AppTheme.gentleCoral,
        ),
      );
    } finally {
      if (mounted) setState(() => _isCapturing = false);
    }
  }

  Future<_DiscoveryDetails?> _requestDiscoveryDetails(String imagePath) async {
    final nameController = TextEditingController();
    String category = 'Lain-lain';
    final result = await showDialog<_DiscoveryDetails>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Simpan Penemuan'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.file(
                    File(imagePath),
                    height: 180,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: nameController,
                  autofocus: true,
                  decoration: const InputDecoration(
                    labelText: 'Nama objek',
                    hintText: 'Contoh: Bunga raya',
                  ),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: category,
                  decoration: const InputDecoration(labelText: 'Kategori'),
                  items:
                      const [
                            'Pokok',
                            'Bunga',
                            'Serangga',
                            'Burung',
                            'Lain-lain',
                          ]
                          .map(
                            (value) => DropdownMenuItem(
                              value: value,
                              child: Text(value),
                            ),
                          )
                          .toList(),
                  onChanged: (value) {
                    if (value != null) setDialogState(() => category = value);
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Batal'),
            ),
            FilledButton(
              onPressed: () {
                final name = nameController.text.trim();
                if (name.isNotEmpty) {
                  Navigator.pop(
                    dialogContext,
                    _DiscoveryDetails(name: name, category: category),
                  );
                }
              },
              child: const Text('Simpan'),
            ),
          ],
        ),
      ),
    );
    nameController.dispose();
    return result;
  }

  Widget _buildCategoriesHeader() {
    return const Text(
      'Kategori',
      style: TextStyle(
        fontSize: AppTheme.fontSizeBody,
        fontWeight: AppTheme.weightSemiBold,
        color: AppTheme.onSurface,
      ),
    );
  }

  Widget _buildCategoryGrid(BuildContext context) {
    print('[StudentExploreView] building category grid');
    final textScale = MediaQuery.textScalerOf(context).scale(1);
    return LayoutBuilder(
      builder: (context, constraints) {
        final useSingleColumn = constraints.maxWidth < 330 || textScale > 1.4;
        return GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: useSingleColumn ? 1 : 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            mainAxisExtent: useSingleColumn
                ? 150 + (textScale - 1).clamp(0, 1) * 40
                : 180 + (textScale - 1).clamp(0, 1) * 80,
          ),
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _categories.length,
          itemBuilder: (context, index) {
            final cat = _categories[index];
            return ScaleButton(
              onTap: () {
                print(
                  '[StudentExploreView] → category tapped: ${cat['title']}',
                );
              },
              child: Container(
                padding: const EdgeInsets.all(AppTheme.paddingMedium),
                decoration: BoxDecoration(
                  color: AppTheme.cardBackground,
                  borderRadius: BorderRadius.circular(AppTheme.radiusCard),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.06),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Flexible(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          cat['emoji']!,
                          style: const TextStyle(fontSize: 44),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      cat['title']!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: AppTheme.fontSizeBody,
                        fontWeight: AppTheme.weightSemiBold,
                        color: AppTheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      cat['description']!,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: AppTheme.fontSizeCaption,
                        color: AppTheme.secondaryText,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildRecentDiscoveries() {
    print('[StudentExploreView] building recent discoveries');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Penemuan Terkini',
          style: TextStyle(
            fontSize: AppTheme.fontSizeBody,
            fontWeight: AppTheme.weightSemiBold,
            color: AppTheme.onSurface,
          ),
        ),
        const SizedBox(height: 12),
        if (_isLoadingRecent)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: CircularProgressIndicator(color: AppTheme.forestGreen),
            ),
          )
        else if (_recentDiscoveries.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 20),
            decoration: BoxDecoration(
              color: AppTheme.cardBackground,
              borderRadius: BorderRadius.circular(AppTheme.radiusCard),
              border: Border.all(color: AppTheme.dividerColor, width: 1),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.search,
                  size: 40,
                  color: AppTheme.secondaryText.withValues(alpha: 0.4),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Belum ada penemuan.',
                  style: TextStyle(
                    fontSize: AppTheme.fontSizeBody,
                    fontWeight: AppTheme.weightMedium,
                    color: AppTheme.secondaryText,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Mulakan penerokaan!',
                  style: TextStyle(
                    fontSize: AppTheme.fontSizeCaption,
                    color: AppTheme.secondaryText,
                  ),
                ),
              ],
            ),
          )
        else
          SizedBox(
            height: 150,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _recentDiscoveries.length,
              separatorBuilder: (_, __) => const SizedBox(width: 10),
              itemBuilder: (context, index) {
                final discovery = _recentDiscoveries[index];
                return SizedBox(
                  width: 135,
                  child: Material(
                    color: AppTheme.cardBackground,
                    borderRadius: BorderRadius.circular(12),
                    clipBehavior: Clip.antiAlias,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(
                          child: discovery.imageUrl == null
                              ? const Icon(Icons.broken_image_outlined)
                              : Image.network(
                                  discovery.imageUrl!,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) =>
                                      const Icon(Icons.broken_image_outlined),
                                ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8),
                          child: Text(
                            discovery.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: AppTheme.fontSizeSmall,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
      ],
    );
  }
}

class _DiscoveryDetails {
  const _DiscoveryDetails({required this.name, required this.category});

  final String name;
  final String category;
}
