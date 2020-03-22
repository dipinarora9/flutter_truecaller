import 'dart:async';

import 'package:flutter/services.dart';

import 'constants.dart';

class FlutterTruecaller {
  static const MethodChannel _channel =
      const MethodChannel('fluttertruecaller');
  static StreamController<String> _result = StreamController.broadcast();

  static Stream<String> get result => _result.stream;

  Future<String> initializeSDK({
    int consentMode: FlutterTruecallerScope.CONSENT_MODE_BOTTOMSHEET,
    int consentTitleOptions: FlutterTruecallerScope.SDK_CONSENT_TITLE_VERIFY,
    int footerType: FlutterTruecallerScope.FOOTER_TYPE_SKIP,
    int sdkOptions: FlutterTruecallerScope.SDK_OPTION_WITH_OTP,
  }) async {
    final String version = await _channel.invokeMethod('initialize', {
      "consentMode": consentMode,
      "consentTitleOptions": consentTitleOptions,
      "footerType": footerType,
      "sdkOptions": sdkOptions
    });
    return version;
  }

  Future<bool> get isUsable async {
    final bool usable = await _channel.invokeMethod('isUsable');
    return usable;
  }

  Future _setListener() async {
    if (_result == null) {
      _result = StreamController.broadcast();
    }

    _channel.setMethodCallHandler((MethodCall call) {
      switch (call.method) {
        case "callback":
          _result.add(call.arguments.toString());
          break;
        default:
          throw new ArgumentError('Unknown method ${call.method}');
      }
      return null;
    });
  }

  getProfile() async {
    await _channel.invokeMethod('getProfile');
    _setListener();
  }

  Future<bool> requestVerification(String mobile) async {
    _setListener();
    bool otpRequired = await _channel.invokeMethod("phone", mobile);
    return otpRequired;
  }

  profileWithOTP(String firstName, String lastName, String otp) async {
    await _channel.invokeMethod("verifyOTP",
        {"firstName": firstName, "lastName": lastName, "otp": otp});
  }

  profileWithoutOTP(String firstName, String lastName) async {
    await _channel.invokeMethod(
        "verifyMissCall", {"firstName": firstName, "lastName": lastName});
  }
}
