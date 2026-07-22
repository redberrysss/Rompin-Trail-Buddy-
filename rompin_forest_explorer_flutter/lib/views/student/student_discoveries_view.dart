import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../models/student_discovery.dart';
import '../../services/activity_data_service.dart';
import '../../theme/app_theme.dart';

class StudentDiscoveriesView extends StatefulWidget {
  const StudentDiscoveriesView({super.key, required this.participantID});

  final String participantID;

  @override
  State<StudentDiscoveriesView> createState() => _StudentDiscoveriesViewState();
}

class _StudentDiscoveriesViewState extends State<StudentDiscoveriesView> {
  List<StudentDiscovery> _discoveries = const [];
  List<String> _sourceWarnings = const [];
  String? _errorMessage;
  bool _isLoading = true;
  StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>? _subscription;

  @override
  void initState() {
    super.initState();
    debugPrint(
      '[StudentDiscoveriesView] initState: '
      'participantID=${widget.participantID}',
    );
    _fetchDiscoveries();
    _subscription = FirebaseFirestore.instance
        .collection('users')
        .doc(widget.participantID)
        .snapshots()
        .skip(1)
        .listen((_) {
          if (mounted && !_isLoading) _fetchDiscoveries();
        });
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant StudentDiscoveriesView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.participantID.trim() != widget.participantID.trim()) {
      _fetchDiscoveries();
    }
  }

  Future<void> _fetchDiscoveries() async {
    final participantId = widget.participantID.trim();
    if (participantId.isEmpty) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'ID peserta belum tersedia. Sila log masuk semula.';
        _discoveries = const [];
        _sourceWarnings = const [];
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _sourceWarnings = const [];
    });
    debugPrint(
      '[StudentDiscoveriesView] Loading discoveries for $participantId',
    );

    try {
      final result = await ActivityDataService.instance.loadStudentDiscoveries(
        participantId,
      );
      if (!mounted || participantId != widget.participantID.trim()) return;
      setState(() {
        _discoveries = result.items;
        _sourceWarnings = result.sourceErrors;
        _isLoading = false;
      });
      debugPrint(
        '[StudentDiscoveriesView] Loaded ${result.items.length} discoveries; '
        '${result.sourceErrors.length} source warnings.',
      );
    } catch (error, stackTrace) {
      debugPrint('[StudentDiscoveriesView] Discovery load failed: $error');
      debugPrintStack(stackTrace: stackTrace);
      if (!mounted || participantId != widget.participantID.trim()) return;
      setState(() {
        _isLoading = false;
        _errorMessage = _friendlyError(error);
        _discoveries = const [];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.creamBackground,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 12),
              if (_sourceWarnings.isNotEmpty && !_isLoading) ...[
                _buildSourceWarning(),
                const SizedBox(height: 12),
              ],
              Expanded(child: _buildBody()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        const Icon(Icons.star, size: 24, color: AppTheme.forestGreen),
        const SizedBox(width: 10),
        const Expanded(
          child: Text(
            'Penemuan Saya',
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: AppTheme.fontSizeHeadline,
              fontWeight: AppTheme.weightSemiBold,
              color: AppTheme.onSurface,
            ),
          ),
        ),
        IconButton(
          tooltip: 'Muat semula',
          onPressed: _isLoading ? null : _fetchDiscoveries,
          icon: const Icon(Icons.refresh),
        ),
      ],
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppTheme.forestGreen),
      );
    }
    if (_errorMessage != null) return _buildErrorState();
    if (_discoveries.isEmpty) return _buildEmptyState();
    return _buildDiscoveriesGrid();
  }

  Widget _buildErrorState() {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.cloud_off_outlined,
              size: 56,
              color: AppTheme.gentleCoral,
            ),
            const SizedBox(height: 16),
            const Text(
              'Penemuan tidak dapat dimuatkan',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: AppTheme.fontSizeHeadline,
                fontWeight: AppTheme.weightSemiBold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage!,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppTheme.secondaryText),
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: _fetchDiscoveries,
              icon: const Icon(Icons.refresh),
              label: const Text('Cuba Lagi'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSourceWarning() {
    return Material(
      color: AppTheme.softOrange.withValues(alpha: 0.12),
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.warning_amber_rounded, color: AppTheme.softOrange),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Sebahagian rekod lama tidak dapat dibaca. '
                'Penemuan yang berjaya dimuatkan masih dipaparkan.',
                style: const TextStyle(
                  fontSize: AppTheme.fontSizeCaption,
                  color: AppTheme.onSurface,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    debugPrint('[StudentDiscoveriesView] showing confirmed empty state');
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 112,
              height: 112,
              decoration: BoxDecoration(
                color: AppTheme.lightGreen.withValues(alpha: 0.3),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.remove_red_eye,
                size: 60,
                color: AppTheme.lightGreen,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Belum ada penemuan',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: AppTheme.fontSizeHeadline,
                fontWeight: AppTheme.weightSemiBold,
                color: AppTheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Terokai alam dan ambil gambar untuk mengumpul penemuan!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: AppTheme.fontSizeBody,
                color: AppTheme.secondaryText,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDiscoveriesGrid() {
    final textScale = MediaQuery.textScalerOf(context).scale(1);
    return LayoutBuilder(
      builder: (context, constraints) {
        final useSingleColumn = constraints.maxWidth < 330 || textScale > 1.45;
        return RefreshIndicator(
          onRefresh: _fetchDiscoveries,
          color: AppTheme.forestGreen,
          child: GridView.builder(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.only(bottom: 24),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: useSingleColumn ? 1 : 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              mainAxisExtent: useSingleColumn
                  ? 330
                  : 270 + (textScale - 1) * 35,
            ),
            itemCount: _discoveries.length,
            itemBuilder: (context, index) =>
                _buildDiscoveryCard(_discoveries[index]),
          ),
        );
      },
    );
  }

  Widget _buildDiscoveryCard(StudentDiscovery discovery) {
    final color = _typeColor(discovery.type);
    return Material(
      color: AppTheme.cardBackground,
      borderRadius: BorderRadius.circular(AppTheme.radiusCard),
      clipBehavior: Clip.antiAlias,
      elevation: 1,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: ColoredBox(
              color: color.withValues(alpha: 0.14),
              child: _buildImage(discovery, color),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  discovery.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: AppTheme.fontSizeCaption,
                    fontWeight: AppTheme.weightSemiBold,
                    color: AppTheme.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  discovery.subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: AppTheme.fontSizeSmall,
                    color: color,
                  ),
                ),
                if (discovery.createdAt != null) ...[
                  const SizedBox(height: 3),
                  Text(
                    _formatDate(discovery.createdAt!),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: AppTheme.fontSizeSmall,
                      color: AppTheme.secondaryText,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImage(StudentDiscovery discovery, Color color) {
    final imageUrl = discovery.imageUrl;
    if (imageUrl == null || !_isNetworkUrl(imageUrl)) {
      return _imageErrorPlaceholder(
        color,
        discovery.imageValue.isEmpty ? 'Tiada gambar' : 'Gambar tidak tersedia',
      );
    }
    return Image.network(
      imageUrl,
      width: double.infinity,
      fit: BoxFit.cover,
      loadingBuilder: (context, child, progress) {
        if (progress == null) return child;
        return const Center(
          child: SizedBox(
            width: 28,
            height: 28,
            child: CircularProgressIndicator(strokeWidth: 2.5),
          ),
        );
      },
      errorBuilder: (context, error, stackTrace) {
        debugPrint(
          '[StudentDiscoveriesView] Failed to load image: $imageUrl, '
          'error: $error',
        );
        return _imageErrorPlaceholder(color, 'Gambar gagal dimuatkan');
      },
    );
  }

  Widget _imageErrorPlaceholder(Color color, String label) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.broken_image_outlined, size: 38, color: color),
            const SizedBox(height: 6),
            Text(
              label,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: AppTheme.fontSizeSmall,
                color: AppTheme.secondaryText,
              ),
            ),
          ],
        ),
      ),
    );
  }

  static bool _isNetworkUrl(String value) {
    final uri = Uri.tryParse(value);
    return uri != null &&
        (uri.scheme == 'http' || uri.scheme == 'https') &&
        uri.host.isNotEmpty;
  }

  static String _formatDate(DateTime value) {
    final date = value.toLocal();
    String twoDigits(int number) => number.toString().padLeft(2, '0');
    return '${twoDigits(date.day)}/${twoDigits(date.month)}/${date.year}, '
        '${twoDigits(date.hour)}:${twoDigits(date.minute)}';
  }

  static Color _typeColor(StudentDiscoveryType type) => switch (type) {
    StudentDiscoveryType.observation => AppTheme.forestGreen,
    StudentDiscoveryType.sensory => AppTheme.softBlue,
    StudentDiscoveryType.treasure => AppTheme.softOrange,
    StudentDiscoveryType.artwork => AppTheme.lavender,
  };

  static String _friendlyError(Object error) {
    final text = error.toString();
    if (text.contains('permission-denied')) {
      return 'Firebase menolak akses kepada rekod penemuan. '
          'Semak Firestore security rules.';
    }
    if (text.contains('failed-precondition')) {
      return 'Pertanyaan Firestore memerlukan konfigurasi atau indeks tambahan.';
    }
    if (text.contains('unavailable') || text.contains('network')) {
      return 'Sambungan ke Firebase tidak tersedia. Semak internet dan cuba lagi.';
    }
    return text.replaceFirst('Exception: ', '');
  }
}
