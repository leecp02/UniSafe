import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_picker/image_picker.dart';

class AttachmentStorageService {
  static const int _maxBytesBeforeBase64 = 320 * 1024;
  static const int _maxTotalBytesBeforeBase64 = 700 * 1024;

  Future<List<Map<String, String>>> buildInlineImageAttachments(
    List<XFile> files,
  ) async {
    final attachments = <Map<String, String>>[];
    int totalBytes = 0;

    for (final file in files) {
      final _InlineImageAttachmentPayload payload =
          await _buildInlineImageAttachmentPayload(file);
      totalBytes += payload.byteLength;

      if (totalBytes > _maxTotalBytesBeforeBase64) {
        throw Exception(
          'Selected images exceed Firestore size limits. '
          'Please choose fewer images or lower-resolution photos.',
        );
      }

      attachments.add(payload.attachment);
    }

    return attachments;
  }

  Future<Map<String, String>> buildInlineImageAttachment(
    XFile file,
  ) async {
    final payload = await _buildInlineImageAttachmentPayload(file);
    return payload.attachment;
  }

  Future<_InlineImageAttachmentPayload> _buildInlineImageAttachmentPayload(
    XFile file,
  ) async {
    final Uint8List originalBytes = await file.readAsBytes();

    if (originalBytes.isEmpty) {
      throw Exception("Selected image file cannot be read from device.");
    }

    Uint8List finalBytes = originalBytes;

    // Reduce payload aggressively for faster Firestore writes.
    for (final config in const [
      (quality: 40, size: 900),
      (quality: 32, size: 780),
      (quality: 26, size: 640),
      (quality: 22, size: 560),
    ]) {
      final Uint8List compressed = await FlutterImageCompress.compressWithList(
        originalBytes,
        quality: config.quality,
        minWidth: config.size,
        minHeight: config.size,
        format: CompressFormat.jpeg,
        keepExif: false,
      );

      if (compressed.isNotEmpty) {
        finalBytes = compressed;
      }

      if (finalBytes.length <= _maxBytesBeforeBase64) {
        break;
      }
    }

    if (finalBytes.length > _maxBytesBeforeBase64) {
      throw Exception(
        "Image is still too large for Firestore storage. "
        "Please crop it or choose a lower-resolution image.",
      );
    }

    return _InlineImageAttachmentPayload(
      byteLength: finalBytes.length,
      attachment: {
        'attachmentType': 'image',
        'attachmentUrl': '',
        'attachmentMime': 'image/jpeg',
        'attachmentData': base64Encode(finalBytes),
      },
    );
  }
}

class _InlineImageAttachmentPayload {
  final int byteLength;
  final Map<String, String> attachment;

  const _InlineImageAttachmentPayload({
    required this.byteLength,
    required this.attachment,
  });
}