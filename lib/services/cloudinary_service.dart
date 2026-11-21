import 'dart:convert';

import 'package:http/http.dart' as http;

import '../core/constants/cloudinary_config.dart';
import '../core/utils/firestore_value.dart';

class CloudinaryUploadResult {
  const CloudinaryUploadResult({
    required this.secureUrl,
    required this.publicId,
    required this.resourceType,
  });

  final String secureUrl;
  final String publicId;
  final String resourceType;
}

class CloudinaryUploadException implements Exception {
  const CloudinaryUploadException(this.message, {this.statusCode});

  final String message;
  final int? statusCode;

  @override
  String toString() => 'CloudinaryUploadException: $message';
}

class CloudinaryService {
  CloudinaryService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  Future<CloudinaryUploadResult> uploadFile({
    required String path,
    required String folder,
    String? publicId,
  }) async {
    try {
      final http.MultipartRequest request = http.MultipartRequest(
        'POST',
        CloudinaryConfig.uploadUri(),
      )
        ..fields['upload_preset'] = CloudinaryConfig.unsignedUploadPreset
        ..fields['folder'] = folder;
      if (publicId != null && publicId.isNotEmpty) {
        request.fields['public_id'] = publicId;
      }
      request.files.add(await http.MultipartFile.fromPath('file', path));

      final http.StreamedResponse streamed = await _client
          .send(request)
          .timeout(const Duration(seconds: 60));
      final http.Response response = await http.Response.fromStream(streamed);

      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw CloudinaryUploadException(
          _errorMessage(response.body),
          statusCode: response.statusCode,
        );
      }

      final Object? decoded = jsonDecode(response.body);
      if (decoded is! Map) {
        throw const CloudinaryUploadException('Unexpected upload response.');
      }
      final Map<String, dynamic> data = Map<String, dynamic>.from(decoded);
      final String? secureUrl = data['secure_url'] as String?;
      if (secureUrl == null || secureUrl.isEmpty) {
        throw const CloudinaryUploadException('Missing secure_url in response.');
      }

      return CloudinaryUploadResult(
        secureUrl: secureUrl,
        publicId: stringFrom(data['public_id']),
        resourceType: stringFrom(data['resource_type']),
      );
    } on CloudinaryUploadException {
      rethrow;
    } catch (error) {
      throw CloudinaryUploadException(error.toString());
    }
  }

  String _errorMessage(String body) {
    try {
      final Object? decoded = jsonDecode(body);
      if (decoded is Map) {
        final Object? error = decoded['error'];
        if (error is Map && error['message'] != null) {
          return error['message'].toString();
        }
      }
    } catch (_) {
      return 'Upload failed. Check your Cloudinary preset and try again.';
    }
    return body.isEmpty ? 'Upload failed.' : body;
  }
}
