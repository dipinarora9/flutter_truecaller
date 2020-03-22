import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  final FlutterTrueCaller caller = FlutterTrueCaller();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Plugin example app'),
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            OutlineButton(
              onPressed: () async {
                String result;
                try {
                  result = await caller.initializeSDK();
                } on PlatformException {
                  _result = 'Failed to get platform version.';
                }
                setState(() {
                  _result = result;
                });
              },
              child: Text('Initialize SDK'),
            ),
            OutlineButton(
              onPressed: () async {
                String result;
                try {
                  result = await caller.isUsable;
                } on PlatformException {
                  _result = 'Failed to get platform version.';
                }
                setState(() {
                  _result = result;
                });
              },
              child: Text('is usable'),
            ),
            OutlineButton(
              onPressed: () async {
                try {
                  caller.getProfile();
                } on PlatformException {
                  _result = 'Failed to get platform version.';
                }
              },
              child: Text('get profile'),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(_result ?? 'ERROR'),
            ),
            StreamBuilder<String>(
              stream: FlutterTrueCaller.result,
              builder: (context, snapshot) => Text(snapshot.data ?? ''),
            ),
            OutlineButton(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => Verify(),
                ),
              ),
              child: Text("Go to verify screen"),
            ),
          ],
        ),
      ),
    );
  }
}
