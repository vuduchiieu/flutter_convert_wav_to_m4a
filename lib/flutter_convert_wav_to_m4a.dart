import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/services.dart';

import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

class FlutterConvertWavToM4a {
  Future<Uint8List?> convertWavToM4a(Uint8List wavBytes) async {
    final stopwatch = Stopwatch()..start();

    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse(
            'https://wav-to-m4a-api.onrender.com/api/convert-file-to-m4a'),
      );

      request.files.add(
        http.MultipartFile.fromBytes(
          'file',
          wavBytes,
          filename: 'input.wav',
          contentType: MediaType('audio', 'wav'),
        ),
      );

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      stopwatch.stop();

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        final m4aBase64 = json['m4aBase64'].toString();

        final originalSize = wavBytes.lengthInBytes;
        final convertedSize = base64Decode(m4aBase64).lengthInBytes;

        double toMB(int bytes) => bytes / (1024 * 1024);

        final diffMB = toMB(originalSize - convertedSize);
        final percentReduced =
            ((originalSize - convertedSize) / originalSize) * 100;

        print('🔊 WAV: ${toMB(originalSize).toStringAsFixed(2)} MB');
        print('🎵 M4A: ${toMB(convertedSize).toStringAsFixed(2)} MB');
        print(
            '📉 Giảm ${diffMB.toStringAsFixed(2)} MB (~${percentReduced.toStringAsFixed(2)}%)');
        print('⏱️ Thời gian convert mất: ${stopwatch.elapsed.inSeconds} s');
        return base64Decode(m4aBase64);
      }
    } catch (e) {}
    return null;
  }
}
