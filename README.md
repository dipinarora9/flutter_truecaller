  # flutter_truecaller  
[Truecaller SDK](https://docs.truecaller.com/truecaller-sdk/) plugin for Flutter applications.

**Note: This plugin currently supports android only.**
## Steps for Plugin Integration

### 1. Generating App key and Configure signing in gradle:
Use [this](https://flutter.dev/docs/deployment/android) link to create an configure your app for signing key. (Also configure your debug build to sign using this key). Check out the build.gradle for the example app [here](https://github.com/dipinarora9/flutter_truecaller/blob/master/example/android/app/build.gradle).


Sign up [here](https://developer.truecaller.com/sign-up) for truecaller developers account.

Refer to [this](https://docs.truecaller.com/truecaller-sdk/android/generating-app-key) official documentation for generating app key.


### 2. App Key Configuration
Open your AndroidManifest.xml and add a meta-data element to the application element.
```xml
<application ...>  
...  
<activity ...>  
.. </activity>  
<meta-data android:name="com.truecaller.android.sdk.PartnerKey" android:value="YOUR_PARTNER_KEY_HERE"/>  
...  
</application>  
```
Check out the AndroidManifest.xml in the example app [here](https://github.com/dipinarora9/flutter_truecaller/blob/master/example/android/app/src/main/AndroidManifest.xml).

### 3. For Truecaller Overlay
Note that flutter_truecaller plugin requires the use of a FragmentActivity as opposed to Activity.

If you receive this error: com.example.flutter_truecaller_example.mainactivity cannot be cast to androidx.fragment.app.fragmentactivity

Then you need to do this step. Change FlutterActivity to FlutterFragmentActivity in MainActivity.kt.

```
package [your.package]

import androidx.annotation.NonNull;
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugins.GeneratedPluginRegistrant

class MainActivity: FlutterFragmentActivity() {
    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        GeneratedPluginRegistrant.registerWith(flutterEngine);
    }
}
```

Check out the MainActivity in the example app [here](https://github.com/dipinarora9/flutter_truecaller/blob/master/example/android/app/src/main/kotlin/dipinarora9/flutter_truecaller_example/MainActivity.kt).

### 4a. Verification flow (Supported Globally)

![Verification Flow](https://raw.githubusercontent.com/dipinarora9/flutter_truecaller/master/verification.png)
### 4b. Verifying non-truecaller users (Currently supports Indian numbers only)
In order to verify non Truecaller users, the SDK requires the below mentioned permissions in your AndroidManifest.xml.

_Check out the AndroidManifest.xml in the example app [here](https://github.com/dipinarora9/flutter_truecaller/blob/master/example/android/app/src/main/AndroidManifest.xml)._

For Android 8 and above :
```xml
<uses-permission android:name="android.permission.READ_PHONE_STATE"/>
<uses-permission android:name="android.permission.READ_CALL_LOG"/>
<uses-permission android:name="android.permission.ANSWER_PHONE_CALLS"/>
```

For Android 7 and below :
```xml
<uses-permission android:name="android.permission.READ_PHONE_STATE"/>
<uses-permission android:name="android.permission.READ_CALL_LOG"/>
<uses-permission android:name="android.permission.CALL_PHONE"/>
```
For users who don't have Truecaller app present on their smartphones, the SDK enables user verification by means of drop call, which is triggered to the user's number in background to complete the verification flow (_currently supported only for Indian numbers only_).

In case these permissions are not granted to your app by the user, the SDK would fallback to use OTP as the verification medium to complete the verification.

Refer to [this](https://docs.truecaller.com/truecaller-sdk/android/user-flows-for-verification-truecaller-+-non-truecaller-users) documentation for examples.

# Usage

Add the following imports to your Dart code:

```dart
import 'package:flutter_truecaller/flutter_truecaller.dart';  
```

Initialize  `TruecallerSDK` :

```dart
final FlutterTruecaller caller = FlutterTruecaller();  
/*  
By default this method sets these constraints while initializing  
  
consentMode: FlutterTruecallerScope.CONSENT_MODE_BOTTOMSHEET,
buttonColor: Colors.blue,
buttonTextColor: Colors.white,
loginTextPrefix: FlutterTruecallerScope.LOGIN_TEXT_PREFIX_TO_GET_STARTED,
loginTextSuffix: FlutterTruecallerScope.LOGIN_TEXT_SUFFIX_PLEASE_SIGNUP,
ctaTextPrefix: FlutterTruecallerScope.CTA_TEXT_PREFIX_USE,
buttonShapeOptions: FlutterTruecallerScope.BUTTON_SHAPE_ROUNDED,
privacyPolicyUrl: "",
termsOfServiceUrl: "",
footerType: FlutterTruecallerScope.FOOTER_TYPE_SKIP,
consentTitleOptions: FlutterTruecallerScope.SDK_CONSENT_TITLE_VERIFY,
sdkOptions: FlutterTruecallerScope.SDK_OPTION_WITHOUT_OTP
  
These can be changed as needed by passing the optional parameters while initializing.  
*/  
String result = await caller.initializeSDK();  
  
OR  
  
String result = await caller.initializeSDK(    
 consentMode:    
  FlutterTruecallerScope.CONSENT_MODE_BOTTOMSHEET,    
  consentTitleOptions:    
  FlutterTruecallerScope.SDK_CONSENT_TITLE_LOG_IN,    
  footerType: FlutterTruecallerScope.FOOTER_TYPE_LATER,    
  sdkOptions: FlutterTruecallerScope.SDK_OPTION_WITH_OTP,    
);  
```

Check if the Truecaller app is present on the user's device or not by using the following method, e.g.

```dart
bool result = await caller.isUsable;  
```
You can change the locale for the truecaller overlay using the `setLocale` method.
```dart
caller.setLocale(FlutterTruecallerLocales.Hindi);  
```
You can trigger the Truecaller profile verification dialog anywhere in your app flow by calling the following method.
```dart
caller.getProfile();  
  
/*  
If you are integrating for both truecaller and non-truecaller users  
then you can listen to the "manualVerificationRequired" stream which returns false or true based on the scenerio if truecaller app is present or not.  
So that you can show different UI.  
*/  
FlutterTruecaller.manualVerificationRequired.listen((required) {      
   if (required)    
      Navigator.of(context).push(    
         MaterialPageRoute(    
            builder: (_) => Verify(),    
         ),    
      );    
   else   
      print("Verification automatically done via truecaller overlay");  
});  
```

>a.) When the user has agreed to share his profile information with your app by clicking on the "Continue" button on the Truecaller dialog  
b.) When a non Truecaller user is already verified previously on the same device. This would only happen when the ``TruecallerSdkScope#SDK_OPTION_WITH_OTP`` is selected while initialising the SDK to provision for the verification of non-Truecaller users also.

Truecaller profiles are returned in the `trueProfile` stream.
```dart
FlutterTruecaller.trueProfile;  
```
### For verifying non-truecaller users
You can initiate the verification for the user by calling the `requestVerification` method which initiates the verification and returns a boolean value which tells us that if the verification method initiated by truecaller is either a missed call method or an OTP based method.
```dart
/*   
If otpRequired is true then OTP based verification is initiated  
if false then missed call verification is initiated  
*/  
bool otpRequired = await caller.requestVerification("PHONE_NUMBER_HERE");  
```
>There is no option in the Truecaller SDK to specify which verification method to use. It decides it on its own. Use the boolean value `otpRequired` returned to change your UI as needed.

The following logic can be used to call the required function.
```dart
if(otpRequired)  
   caller.verifyOtp(String firstName, String lastName, String otp);  
else  
   caller.verifyMissedCall(String firstName, String lastName);  
```
#### Most debugging results are returned in `FlutterTruecaller.callback` stream.

#### All the errors are returned in `FlutterTruecaller.errors` stream.

The errors are of FlutterTruecallerException type. They have two getters:

>`errorCode` for error code.

>`errorMessage` for error message.


#### Scenerios when verifying non-truecaller users.

- When drop call is successfully initiated for the input mobile number. In this case, you will get the _callback_ as `VerificationCallback.TYPE_MISSED_CALL_INITIATED`
- When drop call is successfully detected on that device by the SDK present in your app. In this case, you will get the _callback_ as `VerificationCallback.TYPE_MISSED_CALL_RECEIVED`
- When OTP is successfully triggered for the input mobile number. In this case, you will get the _callback_ as `VerificationCallback.TYPE_OTP_INITIATED`
- When OTP is successfully detected on that device by the SDK present in your app. In this case, you will get the _callback_ as `VerificationCallback.TYPE_OTP_RECEIVED`
- When the verification is successful for a particular number. In this case, you will get the _callback_ as `VerificationCallback.TYPE_VERIFICATION_COMPLETE`
- When the user is already verified on that particular device before. In this case, you will get the _callback_ as `VerificationCallback.TYPE_PROFILE_VERIFIED_BEFORE`


### Error Codes

##### Some of the possible error scenerios while verifying truecaller users

| Error Code | What it means                                   |
|:-----------|:------------------------------------------------|
| 0          | Truecaller internal error                       |
| 1          | Network Failure                                 |
| 2          | User pressed back                               |
| 3          | Incorrect Partner key                           |
| 4 & 10     | User not Verified on Truecaller*                |
| 5          | Truecaller App Internal Error                   |
| 11         | Truecaller not installed                        |
| 12         | Partner Info null                               |
| 13         | User pressed back while verification in process |
| 14         | User pressed "SKIP/ USE ANOTHER NUMBER"         |

>*Error Type 4 and Error Type 10 could arise in different conditions depending on whether the user has not registered on Truecaller app on their smartphone or if the user has deactivated their Truecaller profile at any point of time from the app.

##### Handling error responses for cases of verifying non-Truecaller users


| Error Code | What it means                 |
|:-----------|:------------------------------|
| 1          | Unknown Error                 |
| 2          | Internal service error        |
| 3          | Call createInstallation first |
| 4          | Required permissions missing  |
| 5          | Incomplete info               |
| 6          | OTP timed out                 |
| 7          | Missed call timed out         |

## NOTE

> If you are using verification method for non-truecaller users, make sure to **DISABLE** R8 shrinker. To disable R8, pass the --no-shrink flag to flutter build apk or flutter build appbundle.

Ensure that your Minimum SDK version is at least API level 16 or above ( Android 4.1 ). In case your android project compiles for API level below 16, you can include the following line in your AndroidManifest.xml file to avoid any compilation issues :

``` xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android"  
xmlns:tools="http://schemas.android.com/tools"  
package="YOUR_PACKAGE_NAME">  
<uses-sdk tools:overrideLibrary="com.truecaller.android.sdk"/>  
  
...  
  
</manifest>  
```

Using this would ensure that the sdk works normally for API level 16 & above, and would be disabled for API level < 16 Please make sure that you put the necessary API level checks before accessing the SDK methods in case compiling for API level < 16

> This plugin has AndroidX dependencies, please migrate your app to AndroidX if you haven't already. [Android's Migrating to Android X Guide](https://developer.android.com/jetpack/androidx/migrate).

## TODO
>IOS support

>Advanced steps for validating the request-response correlation

>Server Side Response Validation