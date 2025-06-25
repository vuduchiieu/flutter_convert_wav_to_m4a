import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'flutter_convert_wav_to_m4a_method_channel.dart';

abstract class FlutterConvertWavToM4aPlatform extends PlatformInterface {
  /// Constructs a FlutterConvertWavToM4aPlatform.
  FlutterConvertWavToM4aPlatform() : super(token: _token);

  static final Object _token = Object();

  static FlutterConvertWavToM4aPlatform _instance = MethodChannelFlutterConvertWavToM4a();

  /// The default instance of [FlutterConvertWavToM4aPlatform] to use.
  ///
  /// Defaults to [MethodChannelFlutterConvertWavToM4a].
  static FlutterConvertWavToM4aPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [FlutterConvertWavToM4aPlatform] when
  /// they register themselves.
  static set instance(FlutterConvertWavToM4aPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
}
