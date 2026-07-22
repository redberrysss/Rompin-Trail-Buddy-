import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:image/image.dart' as img;
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

class CollageService {
  CollageService._();

  static final CollageService instance = CollageService._();

  Future<File> createCollage(List<String> imageUrls) async {
    if (imageUrls.isEmpty) {
      throw ArgumentError('Pilih sekurang-kurangnya satu gambar.');
    }

    final decoded = <img.Image>[];
    for (final url in imageUrls.take(4)) {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw HttpException('Gambar gagal dimuatkan (${response.statusCode}).');
      }
      final image = img.decodeImage(response.bodyBytes);
      if (image != null) decoded.add(image);
    }
    if (decoded.isEmpty) throw StateError('Tiada gambar sah untuk kolaj.');

    const canvasSize = 1200;
    const gap = 18;
    final canvas = img.Image(width: canvasSize, height: canvasSize);
    img.fill(canvas, color: img.ColorRgb8(250, 248, 239));

    final columns = decoded.length == 1 ? 1 : 2;
    final rows = (decoded.length / columns).ceil();
    final cellWidth = (canvasSize - gap * (columns + 1)) ~/ columns;
    final cellHeight = (canvasSize - gap * (rows + 1)) ~/ rows;

    for (var index = 0; index < decoded.length; index++) {
      final source = decoded[index];
      final scale = cellWidth / source.width > cellHeight / source.height
          ? cellWidth / source.width
          : cellHeight / source.height;
      final resized = img.copyResize(
        source,
        width: (source.width * scale).round(),
        height: (source.height * scale).round(),
        interpolation: img.Interpolation.average,
      );
      final cropped = img.copyCrop(
        resized,
        x: ((resized.width - cellWidth) / 2).round().clamp(
          0,
          resized.width - 1,
        ),
        y: ((resized.height - cellHeight) / 2).round().clamp(
          0,
          resized.height - 1,
        ),
        width: cellWidth.clamp(1, resized.width),
        height: cellHeight.clamp(1, resized.height),
      );
      final column = index % columns;
      final row = index ~/ columns;
      img.compositeImage(
        canvas,
        cropped,
        dstX: gap + column * (cellWidth + gap),
        dstY: gap + row * (cellHeight + gap),
      );
    }

    final directory = await getTemporaryDirectory();
    final file = File(
      path.join(directory.path, 'collage_${const Uuid().v4()}.jpg'),
    );
    await file.writeAsBytes(img.encodeJpg(canvas, quality: 90), flush: true);
    return file;
  }
}
