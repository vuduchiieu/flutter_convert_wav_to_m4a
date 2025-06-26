import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/services.dart';
import 'package:flutter_convert_wav_to_m4a/js_inlined.dart';
import 'dart:js' as js;

import 'dart:html';

// https://unpkg.com/@ffmpeg/ffmpeg@0.10.1/dist/ffmpeg.min.js

class FlutterConvertWavToM4a {
  static FlutterConvertWavToM4a? _instance;

  FlutterConvertWavToM4a._();

  static Future<FlutterConvertWavToM4a> getInstance() async {
    if (_instance == null) {
      _instance = FlutterConvertWavToM4a._();
      await _instance!._init();
    }
    return _instance!;
  }

  void registerServiceWorker() {
    if (js.context.hasProperty('navigator')) {
      final navigator = js.context['navigator'];
      if (navigator.hasProperty('serviceWorker')) {
        navigator['serviceWorker']
            .callMethod('register', ['/coi-serviceworker.min.js']);
      }
    }
  }

  Future<void> _init() async {
    final completer = Completer<void>();

    // final initCOEPServiceWorkerScript = ScriptElement()
    //   ..type = 'application/javascript'
    //   ..text = JsInlined.initCOEPJsCode;
    // document.body?.append(initCOEPServiceWorkerScript);

    final registerSwScript = ScriptElement()
      ..type = 'application/javascript'
      ..text = '''
     navigator.serviceWorker.register("/coi-serviceworker.js").then((reg) => {
      console.log("✅ SW registered from file!", reg.scope);
    }).catch((err) => {
      console.error("❌ SW register from file failed:", err);
    });
  ''';

    document.body?.append(registerSwScript);

    final ffmpegScript = ScriptElement()
      ..src = "https://unpkg.com/@ffmpeg/ffmpeg@0.10.1/dist/ffmpeg.min.js"
      ..type = "application/javascript"
      ..onLoad.listen((_) {
        completer.complete();
      })
      ..onError.listen((err) {
        completer.completeError(err);
      });

    document.body?.append(ffmpegScript);
    await completer.future;

    final converterScript = ScriptElement()
      ..type = 'application/javascript'
      ..text = JsInlined.ffmpegJsCode;

    document.body?.append(converterScript);
  }

  Future<Uint8List?> convertWavToM4aInJS(Uint8List wavBytes, String fileName) {
    final base64 = base64Encode(wavBytes);
    final completer = Completer<Uint8List?>();

    void handleResult(dynamic result) {
      if (result is String) {
        completer.complete(base64Decode(result));
        final originalSize = wavBytes.lengthInBytes;
        final convertedSize = base64Decode(result).lengthInBytes;

        double toMB(int bytes) => bytes / (1024 * 1024);

        final diffMB = toMB(originalSize - convertedSize);
        final percentReduced =
            ((originalSize - convertedSize) / originalSize) * 100;

        print('🔊 WAV: ${toMB(originalSize).toStringAsFixed(2)} MB');
        print('🎵 M4A: ${toMB(convertedSize).toStringAsFixed(2)} MB');
        print(
            '📉 Giảm ${diffMB.toStringAsFixed(2)} MB (~${percentReduced.toStringAsFixed(2)}%)');
      } else {
        completer.complete(null);
      }
    }

    js.context.callMethod(
        'convertWavToM4a', [base64, fileName, js.allowInterop(handleResult)]);

    return completer.future;
  }
}
