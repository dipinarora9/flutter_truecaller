import 'package:flutter/material.dart';
import 'package:flutter_truecaller/flutter_truecaller.dart';

import 'verify_non_truecaller.dart';

void main() => runApp(
      MaterialApp(
        home: MyApp(),
        debugShowCheckedModeBanner: false,
      ),
    );

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _result = '';
  final FlutterTruecaller caller = FlutterTruecaller();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Truecaller Plugin Example'),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              OutlineButton(
                onPressed: () async {
                  String result = await caller.initializeSDK(
                    buttonColor: Colors.black,
                    buttonTextColor: Colors.white,
                    loginTextPrefix:
                        FlutterTruecallerScope.LOGIN_TEXT_PREFIX_TO_CONTINUE,
                    loginTextSuffix: FlutterTruecallerScope
                        .LOGIN_TEXT_SUFFIX_PLEASE_VERIFY_MOBILE_NO,
                    ctaTextPrefix:
                        FlutterTruecallerScope.CTA_TEXT_PREFIX_CONTINUE_WITH,
                    buttonShapeOptions:
                        FlutterTruecallerScope.BUTTON_SHAPE_RECTANGLE,
                    privacyPolicyUrl: "https://www.truecaller.com",
                    termsOfServiceUrl: "https://www.truecaller.com",
                    footerType: FlutterTruecallerScope.FOOTER_TYPE_LATER,
                    consentTitleOptions:
                        FlutterTruecallerScope.SDK_CONSENT_TITLE_VERIFY,
                    sdkOptions: FlutterTruecallerScope.SDK_OPTION_WITH_OTP,
                  );
                  setState(() {
                    _result = result;
                  });
                },
                child: Text('Initialize SDK'),
              ),
              OutlineButton(
                onPressed: () async {
                  bool isUsable = await caller.isUsable;
                  setState(() {
                    _result = isUsable ? "Usable" : "Not usable";
                  });
                },
                child: Text('Is usable?'),
              ),
              OutlineButton(
                onPressed: () async {
                  String result =
                      await caller.setLocale(FlutterTruecallerLocales.Hindi);
                  setState(() {
                    _result = result;
                  });
                },
                child: Text('Change Locale'),
              ),
              OutlineButton(
                onPressed: () async {
                  await caller.getProfile();
                  FlutterTruecaller.manualVerificationRequired
                      .listen((required) {
                    if (required)
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => Verify(),
                        ),
                      );
                  });
                },
                child: Text('Get Profile'),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(_result ?? 'ERROR'),
              ),
              StreamBuilder<String>(
                stream: FlutterTruecaller.callback,
                builder: (context, snapshot) => Text(snapshot.data ?? ''),
              ),
              StreamBuilder<FlutterTruecallerException>(
                stream: FlutterTruecaller.errors,
                builder: (context, snapshot) =>
                    Text(snapshot.hasData ? snapshot.data.errorMessage : ''),
              ),
              StreamBuilder<TruecallerProfile>(
                stream: FlutterTruecaller.trueProfile,
                builder: (context, snapshot) =>
                    Text(snapshot.hasData ? snapshot.data.firstName : ''),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
