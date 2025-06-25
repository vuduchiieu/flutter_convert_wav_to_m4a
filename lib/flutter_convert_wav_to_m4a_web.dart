// In order to *not* need this ignore, consider extracting the "web" version
// of your plugin as a separate package, instead of inlining it in the same
// package as the core of your plugin.
// ignore: avoid_web_libraries_in_flutter

import 'package:flutter_web_plugins/flutter_web_plugins.dart';
import 'package:web/web.dart' as web;

import 'flutter_convert_wav_to_m4a_platform_interface.dart';

/// A web implementation of the FlutterConvertWavToM4aPlatform of the FlutterConvertWavToM4a plugin.
class FlutterConvertWavToM4aWeb extends FlutterConvertWavToM4aPlatform {
  /// Constructs a FlutterConvertWavToM4aWeb
  FlutterConvertWavToM4aWeb();

  static void registerWith(Registrar registrar) {
    FlutterConvertWavToM4aPlatform.instance = FlutterConvertWavToM4aWeb();
  }

  /// Returns a [String] containing the version of the platform.
  @override
  Future<String?> getPlatformVersion() async {
    final version = web.window.navigator.userAgent;
    return version;
  }
}
