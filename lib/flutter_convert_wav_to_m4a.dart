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
    // final metaOpener = MetaElement()
    //   ..httpEquiv = "Cross-Origin-Opener-Policy"
    //   ..content = "same-origin";

    // final metaEmbedder = MetaElement()
    //   ..httpEquiv = "Cross-Origin-Embedder-Policy"
    //   ..content = "require-corp";

    // document.head?.append(metaOpener);
    // document.head?.append(metaEmbedder);

    // registerServiceWorker();
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
      ..text = ffmpegJsCode;

    document.body?.append(converterScript);
  }

  Future<Uint8List?> convertWavToM4aInJS(Uint8List wavBytes, String fileName) {
    final base64 = base64Encode(wavBytes);
    final completer = Completer<Uint8List?>();

    void handleResult(dynamic result) {
      if (result is String) {
        completer.complete(base64Decode(result));
      } else {
        completer.complete(null);
      }
    }

    js.context.callMethod(
        'convertWavToM4a', [base64, fileName, js.allowInterop(handleResult)]);

    return completer.future;
  }
}
