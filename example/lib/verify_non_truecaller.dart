import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_truecaller/flutter_truecaller.dart';

class Verify extends StatefulWidget {
  @override
  _VerifyState createState() => _VerifyState();
}

class _VerifyState extends State<Verify> {
  final TextEditingController _mobile = TextEditingController();

  final TextEditingController _firstName = TextEditingController();

  final TextEditingController _lastName = TextEditingController();

  final TextEditingController _otp = TextEditingController();

  final FlutterTrueCaller caller = FlutterTrueCaller();

  bool otpRequired = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Verify non truecaller'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: _mobile,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(labelText: "Mobile"),
              ),
            ),
            OutlineButton(
              onPressed: () async {
                try {
                  otpRequired = await caller.verify(_mobile.text);
                } on PlatformException {
                  debugPrint('ERROR');
                }
                setState(() {});
              },
              child: Text("Verify"),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: _firstName,
                decoration: InputDecoration(labelText: "First Name"),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: _lastName,
                decoration: InputDecoration(labelText: "Last Name"),
              ),
            ),
            if (otpRequired)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  controller: _otp,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(labelText: "OTP"),
                ),
              ),
            OutlineButton(
              onPressed: () async {
                try {
                  if (otpRequired)
                    await caller.profileWithOTP(
                        _firstName.text, _lastName.text, _otp.text);
                  else
                    await caller.profileWithoutOTP(
                        _firstName.text, _lastName.text);
                } on PlatformException {
                  debugPrint('ERROR');
                }
              },
              child: Text("Submit"),
            ),
            StreamBuilder<String>(
              stream: FlutterTrueCaller.result,
              builder: (context, snapshot) => Text(snapshot.data ?? ''),
            ),
          ],
        ),
      ),
    );
  }
}