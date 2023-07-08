import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:test_app/pages/sideDrawer.dart';
import 'package:test_app/pages/signup.dart';
import 'package:test_app/pages/spalshscreen.dart';
import 'package:test_app/util/loadingPage.dart';

void main() {
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
  ));
  runApp(
    const MaterialApp(
      home: SpalshScreen(),
      title: "Test App",
      debugShowCheckedModeBanner: false,
    ),
  );
}
