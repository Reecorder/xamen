import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:test_app/pages/teacherHomePage.dart';
import 'package:test_app/pages/homePage.dart';
import 'package:test_app/pages/super_admin_homePage.dart';

import 'login.dart';

class SpalshScreen extends StatefulWidget {
  const SpalshScreen({Key? key}) : super(key: key);

  @override
  State<SpalshScreen> createState() => _SpalshScreenState();
}

class _SpalshScreenState extends State<SpalshScreen> {
//**SharederPreference variables to store the  data
  late SharedPreferences sp;
  String name = "";
  String email = "";
  String roll = "";
  String image = "";
  String dept = "";
  String batch = "";
  int tid = 0;
  String tname = "";
  String tdept = "";
  String tdeptname = "";
  String Aname = "";

//**SharedPreferrence Function to get the data
  Future getDetails() async {
    sp = await SharedPreferences.getInstance();
    name = sp.getString('name') ?? "";
    email = sp.getString('email') ?? "";
    roll = sp.getString('roll') ?? "";
    image = sp.getString('image') ?? "";
    dept = sp.getString('dept') ?? "";
    batch = sp.getString('batch') ?? "";
    tname = sp.getString('tname') ?? "";
    tid = int.parse(sp.getString('tid') ?? "0");
    tdept = sp.getString('tdept') ?? "";
    tdeptname = sp.getString('tdeptname') ?? "";
    Aname = sp.getString('Aname') ?? "";
    setState(() {});
  }

  @override

  //**This initState is called when then Widget is created
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
    ));
    getDetails();
    Timer(Duration(milliseconds: 1700), () {
      if (email.isNotEmpty) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => HomePage(),
          ),
        );
      } else if (tname.isNotEmpty && tdept.isNotEmpty && tdeptname.isNotEmpty) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => AdminPage(tid, tname, tdept, tdeptname),
          ),
        );
      } else if (Aname.isNotEmpty) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => SuperAdminHomePage(Aname),
          ),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => LogIn(),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    return Material(
      child: Container(
        color: Colors.white,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset('assets/images/download.png'),
                  Text(
                    "Xamen",
                    style: TextStyle(
                      fontFamily: "Ubuntu",
                      fontSize: 18,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.only(bottom: 20),
              child: Text(
                "Devloped by Reetam | version 1.0",
                // style: GoogleFonts.roboto(color: Colors.grey),
                style: TextStyle(
                  fontFamily: 'Roboto',
                  fontSize: 13,
                  color: Colors.grey,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
