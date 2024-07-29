import 'package:flutter/material.dart';
import 'feat/highlight_text/UI/flutter_challenge_page.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: FlutterChallenge(),
    );
  }
}