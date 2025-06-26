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

  Future<void> _init() async {
    final completer = Completer<void>();

    //   final registerSwScript = ScriptElement()
    //     ..type = 'application/javascript'
    //     ..text = '''
    //    navigator.serviceWorker.register("https://raw.githubusercontent.com/vuduchiieu/flutter_convert_wav_to_m4a/main/coi-serviceworker.js").then((reg) => {
    //     console.log("✅ SW registered from file!", reg.scope);
    //   }).catch((err) => {
    //     console.error("❌ SW register from file failed:", err);
    //   });
    // ''';

    //   document.body?.append(registerSwScript);

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

    //   final registerSwScript = ScriptElement()
    //     ..type = 'application/javascript'
    //     ..text = '''
    //   (async () => {
    //     const swCode = \`
    //       self.addEventListener("install", () => self.skipWaiting());
    //       self.addEventListener("activate", (event) => event.waitUntil(self.clients.claim()));
    //       self.addEventListener("fetch", (event) => {
    //         const r = event.request;
    //         if (r.cache === "only-if-cached" && r.mode !== "same-origin") return;
    //         event.respondWith(
    //           fetch(r).then((response) => {
    //             const newHeaders = new Headers(response.headers);
    //             newHeaders.set("Cross-Origin-Opener-Policy", "same-origin");
    //             newHeaders.set("Cross-Origin-Embedder-Policy", "require-corp");
    //             newHeaders.set("Cross-Origin-Resource-Policy", "cross-origin");

    //             return new Response(response.body, {
    //               status: response.status,
    //               statusText: response.statusText,
    //               headers: newHeaders,
    //             });
    //           })
    //         );
    //       });
    //     \`;

    //     const blob = new Blob([swCode], { type: "application/javascript" });
    //     const swUrl = URL.createObjectURL(blob);

    //     try {
    //       const reg = await navigator.serviceWorker.register(swUrl);
    //       console.log("✅ Virtual SW registered!", reg.scope);
    //     } catch (err) {
    //       console.error("❌ SW register failed:", err);
    //     }
    //   })();
    // ''';

    //   document.body?.append(registerSwScript);
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
