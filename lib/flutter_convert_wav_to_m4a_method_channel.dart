import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'flutter_convert_wav_to_m4a_platform_interface.dart';

/// An implementation of [FlutterConvertWavToM4aPlatform] that uses method channels.
class MethodChannelFlutterConvertWavToM4a extends FlutterConvertWavToM4aPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('flutter_convert_wav_to_m4a');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }
}
