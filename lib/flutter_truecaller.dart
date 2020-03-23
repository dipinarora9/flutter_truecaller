import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'constants.dart';

class FlutterTruecaller {
  static const MethodChannel _channel =
      const MethodChannel('fluttertruecaller');
  static StreamController<String> _result = StreamController.broadcast();
  static StreamController<bool> _verificationRequired =
      StreamController.broadcast();
  static StreamController<TruecallerProfile> _profileStream =
      StreamController.broadcast();

  static Stream<String> get result => _result.stream;

  static Stream<bool> get verificationRequired => _verificationRequired.stream;

  static Stream<TruecallerProfile> get profile => _profileStream.stream;

  Future<String> initializeSDK({
    int consentMode: FlutterTruecallerScope.CONSENT_MODE_BOTTOMSHEET,
    int consentTitleOptions: FlutterTruecallerScope.SDK_CONSENT_TITLE_VERIFY,
    int footerType: FlutterTruecallerScope.FOOTER_TYPE_SKIP,
    int sdkOptions: FlutterTruecallerScope.SDK_OPTION_WITHOUT_OTP,
  }) async {
    try {
      final String result = await _channel.invokeMethod('initialize', {
        "consentMode": consentMode,
        "consentTitleOptions": consentTitleOptions,
        "footerType": footerType,
        "sdkOptions": sdkOptions
      });
      return result;
    } on PlatformException catch (e) {
      return e.message;
    }
  }

  Future<bool> get isUsable async {
    try {
      final bool usable = await _channel.invokeMethod('isUsable') ?? false;
      return usable;
    } on PlatformException catch (e) {
      _result.add(e.message);
      return false;
    }
  }

  Future _setListener() async {
    if (_result == null) {
      _result = StreamController.broadcast();
    }
    if (_verificationRequired == null) {
      _verificationRequired = StreamController.broadcast();
    }
    if (_profileStream == null) {
      _profileStream = StreamController.broadcast();
    }

    _channel.setMethodCallHandler((MethodCall call) {
      switch (call.method) {
        case "callback":
          if (int.tryParse(call.arguments) != null)
            _result.add(errorString(int.parse(call.arguments)));
          else
            _result.add(call.arguments.toString());
          break;
        case "profile":
          _profileStream.add(TruecallerProfile.fromMap(
              json.decode(call.arguments.toString())));
          break;
        case "verificationRequired":
          _verificationRequired.add(call.arguments);
          break;
        default:
          throw new ArgumentError('Unknown method ${call.method}');
      }
      return null;
    });
  }

  getProfile() async {
    try {
      await _channel.invokeMethod('getProfile');
      _setListener();
    } on PlatformException catch (e) {
      _result.add(e.message);
    }
  }

  Future<bool> requestVerification(String mobile) async {
    if (mobile.length != 10)
      throw Exception("Phone number must be of 10 digits");
    bool otpRequired = await _channel.invokeMethod("phone", mobile);
    _setListener();
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

  Future<String> setLocale(String locale) async {
    String result = await _channel.invokeMethod("setLocale", locale);
    return result;
  }
}
