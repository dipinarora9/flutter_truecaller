import 'package:flutter/material.dart';
import 'package:flutter_truecaller/constants.dart';
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
  String _result = 'Unknown';
  final FlutterTruecaller caller = FlutterTruecaller();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Truecaller Plugin Example'),
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            OutlineButton(
              onPressed: () async {
                String result = await caller.initializeSDK(
                  sdkOptions: FlutterTruecallerScope.SDK_OPTION_WITHOUT_OTP,
                  footerType: FlutterTruecallerScope.FOOTER_TYPE_ANOTHER_METHOD,
                  consentTitleOptions:
                      FlutterTruecallerScope.SDK_CONSENT_TITLE_VERIFY,
                  consentMode: FlutterTruecallerScope.CONSENT_MODE_POPUP,
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
                String result = await caller.setLocale(Locales.Hindi);
                setState(() {
                  _result = result;
                });
              },
              child: Text('Change Locale'),
            ),
            OutlineButton(
              onPressed: () async {
                await caller.getProfile();
                FlutterTruecaller.verificationRequired.listen((required) {
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
              stream: FlutterTruecaller.result,
              builder: (context, snapshot) => Text(snapshot.data ?? ''),
            ),
            StreamBuilder<TruecallerProfile>(
              stream: FlutterTruecaller.profile,
              builder: (context, snapshot) =>
                  Text(snapshot.hasData ? snapshot.data.firstName : ''),
            ),
          ],
        ),
      ),
    );
  }
}
