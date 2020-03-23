import 'package:flutter/foundation.dart';

class FlutterTruecallerScope {
  static const int FOOTER_TYPE_SKIP = 1;
  static const int FOOTER_TYPE_CONTINUE = 2;
  static const int CONSENT_MODE_POPUP = 4;
  static const int CONSENT_MODE_FULLSCREEN = 8;
  static const int SDK_OPTION_WITHOUT_OTP = 16;
  static const int SDK_OPTION_WITH_OTP = 32;
  static const int FOOTER_TYPE_NONE = 64;
  static const int CONSENT_MODE_BOTTOMSHEET = 128;
  static const int FOOTER_TYPE_ANOTHER_METHOD = 256;
  static const int FOOTER_TYPE_MANUALLY = 512;
  static const int BUTTON_SHAPE_ROUNDED = 1024;
  static const int BUTTON_SHAPE_RECTANGLE = 2048;
  static const int FOOTER_TYPE_LATER = 4096;
  static const int SDK_CONSENT_TITLE_LOG_IN = 0;
  static const int SDK_CONSENT_TITLE_SIGN_UP = 1;
  static const int SDK_CONSENT_TITLE_SIGN_IN = 2;
  static const int SDK_CONSENT_TITLE_VERIFY = 3;
  static const int SDK_CONSENT_TITLE_REGISTER = 4;
  static const int SDK_CONSENT_TITLE_GET_STARTED = 5;
  static const int LOGIN_TEXT_PREFIX_TO_GET_STARTED = 0;
  static const int LOGIN_TEXT_PREFIX_TO_CONTINUE = 1;
  static const int LOGIN_TEXT_PREFIX_TO_PLACE_ORDER = 2;
  static const int LOGIN_TEXT_PREFIX_TO_COMPLETE_YOUR_PURCHASE = 3;
  static const int LOGIN_TEXT_PREFIX_TO_CHECKOUT = 4;
  static const int LOGIN_TEXT_PREFIX_TO_COMPLETE_YOUR_BOOKING = 5;
  static const int LOGIN_TEXT_PREFIX_TO_PROCEED_WITH_YOUR_BOOKING = 6;
  static const int LOGIN_TEXT_PREFIX_TO_CONTINUE_WITH_YOUR_BOOKING = 7;
  static const int LOGIN_TEXT_PREFIX_TO_GET_DETAILS = 8;
  static const int LOGIN_TEXT_PREFIX_TO_VIEW_MORE = 9;
  static const int LOGIN_TEXT_PREFIX_TO_CONTINUE_READING = 10;
  static const int LOGIN_TEXT_PREFIX_TO_PROCEED = 11;
  static const int LOGIN_TEXT_PREFIX_FOR_NEW_UPDATES = 12;
  static const int LOGIN_TEXT_PREFIX_TO_GET_UPDATES = 13;
  static const int LOGIN_TEXT_PREFIX_TO_SUBSCRIBE = 14;
  static const int LOGIN_TEXT_PREFIX_TO_SUBSCRIBE_AND_GET_UPDATES = 15;
  static const int LOGIN_TEXT_SUFFIX_PLEASE_VERIFY_MOBILE_NO = 0;
  static const int LOGIN_TEXT_SUFFIX_PLEASE_LOGIN = 1;
  static const int LOGIN_TEXT_SUFFIX_PLEASE_SIGNUP = 2;
  static const int LOGIN_TEXT_SUFFIX_PLEASE_LOGIN_SIGNUP = 3;
  static const int LOGIN_TEXT_SUFFIX_PLEASE_REGISTER = 4;
  static const int LOGIN_TEXT_SUFFIX_PLEASE_SIGN_IN = 5;
  static const int CTA_TEXT_PREFIX_USE = 0;
  static const int CTA_TEXT_PREFIX_CONTINUE_WITH = 1;
  static const int CTA_TEXT_PREFIX_PROCEED_WITH = 2;
}

class Locales {
  static const String English = "en";
  static const String Hindi = "hi";
  static const String Marathi = "mr";
  static const String Telugu = "te";
  static const String Malayalam = "ml";
  static const String Urdu = "ur";
  static const String Punjabi = "pa";
  static const String Tamil = "ta";
  static const String Bengali = "bn";
  static const String Kannada = "kn";
  static const String Swahili = "sw";
}

String errorString(int raw) {
  switch (raw) {
    case 0:
      return "ERROR_TYPE_INTERNAL";
      break;
    case 1:
      return "ERROR_TYPE_NETWORK";
      break;
    case 2:
      return "ERROR_TYPE_USER_DENIED";
      break;
    case 3:
      return "ERROR_PROFILE_NOT_FOUND";
      break;
    case 4:
      return "ERROR_TYPE_UNAUTHORIZED_USER";
      break;
    case 5:
      return "ERROR_TYPE_TRUECALLER_CLOSED_UNEXPECTEDLY";
      break;
    case 6:
      return "ERROR_TYPE_TRUESDK_TOO_OLD";
      break;
    case 7:
      return "ERROR_TYPE_POSSIBLE_REQ_CODE_COLLISION";
      break;
    case 8:
      return "ERROR_TYPE_RESPONSE_SIGNATURE_MISMATCH";
      break;
    case 9:
      return "ERROR_TYPE_REQUEST_NONCE_MISMATCH";
      break;
    case 10:
      return "ERROR_TYPE_INVALID_ACCOUNT_STATE";
      break;
    case 11:
      return "ERROR_TYPE_TC_NOT_INSTALLED";
      break;
    case 12:
      return "ERROR_TYPE_PARTNER_INFO_NULL";
      break;
    case 13:
      return "ERROR_TYPE_USER_DENIED_WHILE_LOADING";
      break;
    case 14:
      return "ERROR_TYPE_CONTINUE_WITH_DIFFERENT_NUMBER";
      break;
    default:
      return "UNKNOWN ERROR";
  }
}

class TruecallerProfile {
  String _firstName;
  String _lastName;
  String _phoneNumber;
  String _gender;
  String _street;
  String _city;
  String _zipcode;
  String _countryCode;
  String _facebookId;
  String _twitterId;
  String _email;
  String _url;
  String _avatarUrl;
  bool _isTrueName;
  bool _isAmbassador;
  String _companyName;
  String _jobTitle;
  String _payload;
  String _signature;
  String _signatureAlgorithm;
  String _requestNonce;
  bool _isSimChanged;
  String _verificationMode;
  int _verificationTimestamp;
  String _userLocale;
  String _accessToken;

  String get firstName => _firstName;

  String get lastName => _lastName;

  String get phoneNumber => _phoneNumber;

  String get gender => _gender;

  String get street => _street;

  String get city => _city;

  String get zipcode => _zipcode;

  String get countryCode => _countryCode;

  String get facebookId => _facebookId;

  String get twitterId => _twitterId;

  String get email => _email;

  String get url => _url;

  String get avatarUrl => _avatarUrl;

  bool get isTrueName => _isTrueName;

  bool get isAmbassador => _isAmbassador;

  String get companyName => _companyName;

  String get jobTitle => _jobTitle;

  String get payload => _payload;

  String get signature => _signature;

  String get signatureAlgorithm => _signatureAlgorithm;

  String get requestNonce => _requestNonce;

  bool get isSimChanged => _isSimChanged;

  String get verificationMode => _verificationMode;

  int get verificationTimestamp => _verificationTimestamp;

  String get userLocale => _userLocale;

  String get accessToken => _accessToken;

  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = Map();
    map["firstName"] = _firstName;
    map["lastName"] = _lastName;
    map["phoneNumber"] = _phoneNumber;
    map["gender"] = _gender;
    map["street"] = _street;
    map["city"] = _city;
    map["zipcode"] = _zipcode;
    map["countryCode"] = _countryCode;
    map["facebookId"] = _facebookId;
    map["twitterId"] = _twitterId;
    map["email"] = _email;
    map["url"] = _url;
    map["avatarUrl"] = _avatarUrl;
    map["isTrueName"] = _isTrueName;
    map["isAmbassador"] = _isAmbassador;
    map["companyName"] = _companyName;
    map["jobTitle"] = _jobTitle;
    map["payload"] = _payload;
    map["signature"] = _signature;
    map["signatureAlgorithm"] = _signatureAlgorithm;
    map["requestNonce"] = _requestNonce;
    map["isSimChanged"] = _isSimChanged;
    map["verificationMode"] = _verificationMode;
    map["verificationTimestamp"] = _verificationTimestamp;
    map["userLocale"] = _userLocale;
    map["accessToken"] = _accessToken;
    return map;
  }

  TruecallerProfile.fromMap(Map<String, dynamic> map) {
    _firstName = map["firstName"];
    _lastName = map["lastName"];
    _phoneNumber = map["phoneNumber"];
    _gender = map["gender"];
    _street = map["street"];
    _city = map["city"];
    _zipcode = map["zipcode"];
    _countryCode = map["countryCode"];
    _facebookId = map["facebookId"];
    _twitterId = map["twitterId"];
    _email = map["email"];
    _url = map["url"];
    _avatarUrl = map["avatarUrl"];
    _isTrueName = map["isTrueName"];
    _isAmbassador = map["isAmbassador"];
    _companyName = map["companyName"];
    _jobTitle = map["jobTitle"];
    _payload = map["payload"];
    _signature = map["signature"];
    _signatureAlgorithm = map["signatureAlgorithm"];
    _requestNonce = map["requestNonce"];
    _isSimChanged = map["isSimChanged"];
    _verificationMode = map["verificationMode"];
    _verificationTimestamp = map["verificationTimestamp"];
    _userLocale = map["userLocale"];
    _accessToken = map["accessToken"];
  }
}
