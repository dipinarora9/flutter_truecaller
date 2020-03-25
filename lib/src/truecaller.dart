/// Truecaller SDK plugin for Flutter applications.
///
/// This library uses native API of [Truecaller SDK 2.0](https://docs.truecaller.com/truecaller-sdk/v/2.0/)
/// to provide functionality for Flutter applications.
///
/// Currently only Android platform is supported.
import 'dart:async';
import 'dart:convert';

import 'package:flutter/services.dart';

import 'constants.dart';

/// All non-widget functions such as initialization, changing locale,
/// fetching profile and verifying users are enclosed in this class.
///
/// Initialize the Truecaller SDK by calling the [initializeSDK]
/// function.
class FlutterTruecaller {
  static const MethodChannel _channel =
      const MethodChannel('flutter_truecaller');
  static StreamController<String> _callback = StreamController.broadcast();
  static StreamController<String> _errors = StreamController.broadcast();
  static StreamController<bool> _manualVerificationRequired =
      StreamController.broadcast();
  static StreamController<TruecallerProfile> _profileStream =
      StreamController.broadcast();

  /// Stream to receive callback from the Truecaller SDK
  static Stream<String> get callback => _callback.stream;

  /// Stream to receive errors from the Truecaller SDK
  static Stream<String> get errors => _errors.stream;

  /// Stream to receive boolean to know if manual verification is required
  static Stream<bool> get manualVerificationRequired =>
      _manualVerificationRequired.stream;

  /// Stream to receive the verified user's profile
  static Stream<TruecallerProfile> get trueProfile => _profileStream.stream;

  /// Initializes the Truecaller SDK
  ///  By default this method sets these constraints while initializing
  ///
  ///  consentMode: FlutterTruecallerScope.CONSENT_MODE_BOTTOMSHEET,
  ///  consentTitleOptions: FlutterTruecallerScope.SDK_CONSENT_TITLE_VERIFY,
  /// footerType: FlutterTruecallerScope.FOOTER_TYPE_SKIP,
  /// sdkOptions: FlutterTruecallerScope.SDK_OPTION_WITHOUT_OTP
  ///
  ///  These can be changed as needed by passing the optional parameters while initializing.
  ///
  ///  If you want to use the SDK for verification of Truecaller users only,
  ///  you should provide the scope value as FlutterTruecallerScope.SDK_OPTION_WITHOUT_OTP
  ///
  /// If you want to use the SDK for verification of Truecaller users as well
  /// as non-Truecaller users powered by Truecaller's drop call / OTP,
  /// you should provide the scope value as FlutterTruecallerScope.SDK_OPTION_WITH_OTP
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

  /// Once you initialise the TruecallerSDK using the init() method,
  /// if you are using the SDK for verification of only Truecaller users
  /// ( by setting the sdkOptions scope as  FlutterTruecallerScope.SDK_OPTION_WITHOUT_OTP ),
  /// you can check if the Truecaller app is present on the user's device
  /// or not by using the following method
  Future<bool> get isUsable async {
    try {
      final bool usable = await _channel.invokeMethod('isUsable') ?? false;
      return usable;
    } on PlatformException catch (e) {
      _callback.add(e.message);
      return false;
    }
  }

  Future _setListener() async {
    if (_callback == null) {
      _callback = StreamController.broadcast();
    }
    if (_manualVerificationRequired == null) {
      _manualVerificationRequired = StreamController.broadcast();
    }
    if (_profileStream == null) {
      _profileStream = StreamController.broadcast();
    }
    if (_errors == null) {
      _errors = StreamController.broadcast();
    }

    _channel.setMethodCallHandler((MethodCall call) {
      switch (call.method) {
        case "callback":
          if (int.tryParse(call.arguments) != null)
            _callback.add(errorString(int.parse(call.arguments)));
          else
            _callback.add(call.arguments.toString());
          break;
        case "profile":
          _profileStream.add(TruecallerProfile.fromMap(
              json.decode(call.arguments.toString())));
          break;
        case "error":
          if (int.tryParse(call.arguments) != null)
            _errors.add(errorString(int.parse(call.arguments)));
          else
            _errors.add(call.arguments.toString());
          break;
        case "verificationRequired":
          _manualVerificationRequired.add(call.arguments);
          break;
        default:
          throw new ArgumentError('Unknown method ${call.method}');
      }
      return null;
    });
  }

  /// You can trigger the Truecaller profile verification dialog
  /// anywhere in your app flow by calling the following method
  getProfile() async {
    try {
      await _channel.invokeMethod('getProfile');
      _setListener();
    } on PlatformException catch (e) {
      _callback.add(e.message);
    }
  }

  /// You can initiate the verification for the non-Truecaller user by
  /// calling the following method:
  ///
  /// Truecaller SDK v2.0 currently supports the verification for
  /// non-Truecaller users for Indian numbers only
  Future<bool> requestVerification(String mobile) async {
    if (mobile.length != 10)
      throw Exception("Phone number must be of 10 digits");
    bool otpRequired = await _channel.invokeMethod("phone", mobile);
    _setListener();
    return otpRequired;
  }

  /// You need to call this method once you have received callback
  /// as "OTP is successfully detected" in your callback stream
  verifyOtp(String firstName, String lastName, String otp) async {
    await _channel.invokeMethod("verifyOTP",
        {"firstName": firstName, "lastName": lastName, "otp": otp});
    _setListener();
  }

  /// You need to call this method once you have received callback
  /// as "drop call is successfully detected" in your callback stream
  verifyMissedCall(String firstName, String lastName) async {
    await _channel.invokeMethod(
        "verifyMissCall", {"firstName": firstName, "lastName": lastName});
    _setListener();
  }

  /// To customise the profile dialog in any of the supported Indian languages
  ///
  /// Currently supported languages :
  /// - English (en)
  // - Hindi (hi)
  // - Marathi (mr)
  // - Telugu (te)
  // - Malayalam (ml)
  // - Urdu (ur)
  // - Punjabi (pa)
  // - Tamil (ta)
  // - Bengali (bn)
  // - Kannada (kn)
  // - Swahili (sw)
  Future<String> setLocale(String locale) async {
    String result = await _channel.invokeMethod("setLocale", locale);
    return result;
  }
}
