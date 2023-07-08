import 'dart:ffi';

import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:test_app/main.dart';
import 'package:test_app/pages/addDepartment.dart';
import 'package:test_app/pages/allTeacher.dart';
import 'package:test_app/pages/super_admin_activate_student.dart';
import 'package:test_app/pages/teacher_drawer.dart';
import 'package:test_app/pages/createTeachers.dart';
import 'package:test_app/pages/super_admin_drawer.dart';

class SuperAdminHomePage extends StatefulWidget {
  String Aname = "";
  SuperAdminHomePage(this.Aname);

  @override
  State<SuperAdminHomePage> createState() => _SuperAdminHomePageState(Aname);
}

class _SuperAdminHomePageState extends State<SuperAdminHomePage> {
  //!!Constructor
  String Aname = "";
  _SuperAdminHomePageState(this.Aname);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("ADMIN DASHBOARD"),
      ),
      drawer: SuperAdminDrawer(),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.03,
            ),
            Text(
              " Welcome... ",
              style: TextStyle(
                color: Color.fromARGB(255, 0, 0, 0),
                fontFamily: "Roboto",
                fontSize: 20,
              ),
            ),
            AnimatedTextKit(
              animatedTexts: [
                TypewriterAnimatedText(
                  "Mr. " + Aname,
                  textStyle: const TextStyle(
                    fontSize: 20,
                    color: Color.fromARGB(255, 0, 0, 0),
                    fontFamily: "Roboto",
                    fontWeight: FontWeight.bold,
                  ),
                  speed: const Duration(milliseconds: 300),
                  curve: Curves.linear,
                ),
              ],
              totalRepeatCount: 5,
              pause: const Duration(milliseconds: 100),
            ),
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.03,
            ),
            SvgPicture.asset(
              "assets/images/undraw_control_panel_re_y3ar (1).svg",
              height: MediaQuery.of(context).size.height * 0.218,
            ),
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.05,
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Material(
                  borderRadius: BorderRadius.circular(10),
                  color: Color.fromARGB(255, 101, 150, 234),
                  elevation: 5,
                  shadowColor: Colors.black,
                  child: InkWell(
                    splashColor: Color.fromARGB(255, 95, 170, 232),
                    borderRadius: BorderRadius.circular(10),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AdminDashBoard(),
                        ),
                      );
                    },
                    child: Container(
                      alignment: Alignment.center,
                      height: MediaQuery.of(context).size.height * 0.12,
                      width: MediaQuery.of(context).size.width * 0.85,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(
                            "assets/images/icons8-doorbell-100.png",
                            height: 50,
                          ),
                          // SvgPicture.asset(
                          //   "assets/images/undraw_switches_1js3.svg",
                          //   height: 50,
                          // ),
                          SizedBox(
                            width: 15,
                          ),
                          Text(
                            "Activate Students",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Color.fromARGB(255, 255, 255, 255),
                              fontSize: 20,
                              fontFamily: 'Ubuntu',
                            ),
                          ),
                        ],
                      ),
                      decoration: BoxDecoration(
                        color: Colors.transparent,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.02,
                ),
                Material(
                  borderRadius: BorderRadius.circular(10),
                  color: Color.fromARGB(255, 101, 150, 234),
                  elevation: 5,
                  shadowColor: Colors.black,
                  child: InkWell(
                    splashColor: Color.fromARGB(255, 168, 206, 250),
                    borderRadius: BorderRadius.circular(10),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AllTeacher(),
                        ),
                      );
                    },
                    child: Container(
                      alignment: Alignment.center,
                      height: MediaQuery.of(context).size.height * 0.12,
                      width: MediaQuery.of(context).size.width * 0.85,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(
                            "assets/images/icons8-add-user-group-man-man-100.png",
                            height: 50,
                          ),
                          SizedBox(
                            width: 15,
                          ),
                          Text(
                            "Add New Teachers",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Color.fromARGB(255, 255, 255, 255),
                              fontSize: 20,
                              fontFamily: 'Ubuntu',
                            ),
                          ),
                        ],
                      ),
                      decoration: BoxDecoration(
                        color: Colors.transparent,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.02,
                ),
                Material(
                  borderRadius: BorderRadius.circular(10),
                  color: Color.fromARGB(255, 101, 150, 234),
                  elevation: 5,
                  shadowColor: Colors.black,
                  child: InkWell(
                    splashColor: Color.fromARGB(255, 168, 206, 250),
                    borderRadius: BorderRadius.circular(10),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AddDepartment(),
                        ),
                      );
                    },
                    child: Container(
                      alignment: Alignment.center,
                      height: MediaQuery.of(context).size.height * 0.12,
                      width: MediaQuery.of(context).size.width * 0.85,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(
                            "assets/images/icons8-labels-100.png",
                            height: 50,
                          ),
                          SizedBox(
                            width: 15,
                          ),
                          Text(
                            "Add Department",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Color.fromARGB(255, 255, 255, 255),
                              fontSize: 20,
                              fontFamily: 'Ubuntu',
                            ),
                          ),
                        ],
                      ),
                      decoration: BoxDecoration(
                        color: Colors.transparent,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Spacer(),
          ],
        ),
      ),
    );
  }
}
