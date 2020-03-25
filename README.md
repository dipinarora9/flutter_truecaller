
  
# flutter_truecaller
[Truecaller SDK](https://docs.truecaller.com/truecaller-sdk/v/2.0/) plugin for Flutter applications.

**Note: Truecaller SDK 2.0 is available for android only.** 

## Integration

### 1. Generating App key:
Please refer to [this](https://docs.truecaller.com/truecaller-sdk/v/2.0/android/generating-app-key) official documentation for generating app key.

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
Note that flutter_truecaller plugin requires the use of a FragmentActivity as opposed to Activity. This can be easily done by switching to use `FlutterFragmentActivity` as opposed to `FlutterActivity` in your MainActivity (or your own Activity class if you are extending the base class).

Check out the MainActivity in the example app [here](https://github.com/dipinarora9/flutter_truecaller/blob/master/example/android/app/src/main/kotlin/dipinarora9/flutter_truecaller_example/MainActivity.kt).

### 4a. Verification flow (Supported Globally)

![Verification Flow](https://raw.githubusercontent.com/dipinarora9/flutter_truecaller/master/verification.png)
### 4b. Verifying non-truecaller users (Currently available only for India)
In order to verify non Truecaller users, the SDK requires the below mentioned permissions in your AndroidManifest.xml.

_Check out the AndroidManifest.xml in the example app [here](https://github.com/dipinarora9/flutter_truecaller/blob/master/example/android/app/src/main/AndroidManifest.xml)._
```xml
<uses-permission android:name="android.permission.READ_PHONE_STATE"/>
<uses-permission android:name="android.permission.READ_CALL_LOG"/>
<uses-permission android:name="android.permission.ANSWER_PHONE_CALLS"/>
```
For users who don't have Truecaller app present on their smartphones, the SDK enables user verification by means of drop call, which is triggered to the user's number in background to complete the verification flow ( _currently supported only for India_ ).

Refer to [this](https://docs.truecaller.com/truecaller-sdk/v/2.0/android/user-flows-for-verification-truecaller-+-non-truecaller-users) documentation for examples.

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
consentTitleOptions: FlutterTruecallerScope.SDK_CONSENT_TITLE_VERIFY,  
footerType: FlutterTruecallerScope.FOOTER_TYPE_SKIP,  
sdkOptions: FlutterTruecallerScope.SDK_OPTION_WITH_OTP

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
  sdkOptions: FlutterTruecallerScope.SDK_OPTION_WITHOUT_OTP,  
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
then you can listen to the "verificationRequired" stream which returns false or true based on the scenerio if truecaller app is present or not.
So that you can show different UI.
*/
FlutterTruecaller.verificationRequired.listen((required) {    
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

Truecaller profiles are returned in the `profile` stream.
```dart
FlutterTruecaller.profile;
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
>There is no option in the truecallerSDK to specify which verification method to use. It decides it on its own. Use the boolean value returned to change your UI as needed.

The following logic can be used to call the required function.
```dart
if(otpRequired)
	caller.profileWithOTP(String firstName, String lastName, String otp);
else
	caller.profileWithoutOTP(String firstName, String lastName);
```
#### Most debugging results are returned in `FlutterTruecaller.callback` stream.

#### All the errors are returned in `FlutterTruecaller.error` stream.

## Error Codes
| Error Code  | What it means  |
|---|---|
|1|Network Failure|
|2|User pressed back|
|  3|Incorrect Partner Key|
|4 & 10|User not Verified on Truecaller*|
|5|Truecaller App Internal Error|
|13|User pressed back while verification in process|
|14 |User pressed "SKIP / USE ANOTHER NUMBER"|

**_Error Type 4_** _and_ **_Error Type 10_** _could arise in different conditions depending on whether the user has not registered on Truecaller app on their smartphone_ **_or_** _if the user has deactivated their Truecaller profile at any point of time from the app._

>Scenerios when verifying non-truecaller users.
-   When drop call is successfully initiated for the input mobile number. In this case, you will get the _requestCode_ as `VerificationCallback.TYPE_MISSED_CALL_INITIATED`
-   When drop call is successfully detected on that device by the SDK present in your app. In this case, you will get the _requestCode_ as `VerificationCallback.TYPE_MISSED_CALL_RECEIVED`
-   When OTP is successfully triggered for the input mobile number. In this case, you will get the _requestCode_ as `VerificationCallback.TYPE_OTP_INITIATED`
-   When OTP is successfully detected on that device by the SDK present in your app. In this case, you will get the _requestCode_ as `VerificationCallback.TYPE_OTP_RECEIVED`
-   When the verification is successful for a particular number. In this case, you will get the requestCode as `VerificationCallback.TYPE_VERIFICATION_COMPLETE`
-   When the user is already verified on that particular device before. In this case, you will get the requestCode as `VerificationCallback.TYPE_PROFILE_VERIFIED_BEFORE`

## Handling error responses for cases of verifying non-Truecaller users
-   When the user has exceeded the maximum number of allowed verification attempts within a span of 24 hours from the time the first verification attempt was made Error Message : `"`**`user reached the limit`**`"`
-   When the partner key ( app key ) you have configured in your project is incorrect Error Message : `"`**`Invalid partner credentials.`**`"`
-   When the input mobile number is not a valid mobile number Error Message : `"`**`invalid phone number`**`"`
-   In case of Truecaller internal service error Error Message : `"`**`Something went wrong: Failed to create installation.`**`"`

Apart from these, there can be certain cases when the drop call attempt fails on the user's number or the call might not reach the user's smartphone where the verification attempt in being made. For these cases, the SDK will throw a timeout error after the TTL of 40s is over with error message as `"missed call timed out, please try again"`

## NOTE
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


## TODO
>Advanced steps for validating the request-response correlation

>Server Side Response Validation