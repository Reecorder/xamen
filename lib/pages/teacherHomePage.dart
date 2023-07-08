import 'dart:convert';
// import 'dart:html';

import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:test_app/pages/super_admin_activate_student.dart';
import 'package:test_app/pages/teacher_drawer.dart';
import 'package:test_app/pages/assignExam.dart';
import 'package:test_app/pages/createExam.dart';
import 'package:test_app/pages/exam_for_publish.dart';
import 'package:test_app/pages/publish_result.dart';
import 'package:test_app/pages/questionUploade.dart';
import 'package:test_app/pages/sideDrawer.dart';
import 'dart:io';
import 'package:csv/csv.dart';

class AdminPage extends StatefulWidget {
  int tid = 0;
  String tname = "";
  String tdept = "";
  String tdeptname = "";
  AdminPage(this.tid, this.tname, this.tdept, this.tdeptname);

  @override
  State<AdminPage> createState() =>
      _AdminPageState(this.tid, this.tname, this.tdept, this.tdeptname);
}

class _AdminPageState extends State<AdminPage> {
  int tid = 0;
  String tname = "";
  String tdept = "";
  String tdeptname = "";
  _AdminPageState(this.tid, this.tname, this.tdept, this.tdeptname);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 255, 255, 255),
      drawer: AdminDrawer(),
      appBar: AppBar(
        title: Text(
          "Teacher Panel",
          style: TextStyle(
            color: Colors.white,
            fontFamily: "Roboto",
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          SizedBox(
            height: 15,
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
                "Mr. " + tname,
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
            height: MediaQuery.of(context).size.height * 0.035,
          ),
          SvgPicture.asset(
            "assets/images/undraw_steps_re_odoy (5).svg",
            height: MediaQuery.of(context).size.height * 0.25,
          ),
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.03,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Material(
                borderRadius: BorderRadius.circular(10),
                color: Color.fromARGB(196, 72, 86, 245),
                elevation: 10,
                shadowColor: Colors.black,
                child: InkWell(
                  splashColor: Color.fromARGB(79, 195, 195, 195),
                  borderRadius: BorderRadius.circular(10),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AssignExam(tid, tdept, tdeptname),
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
                          "assets/images/icons8-test-passed-100.png",
                          height: 48,
                        ),
                        SizedBox(
                          width: 15,
                        ),
                        Text(
                          "Create Exam",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Color.fromARGB(255, 255, 255, 255),
                            fontSize: 22,
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
          SizedBox(
            height: 20,
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              primary: Color.fromARGB(196, 72, 86, 245),
              minimumSize: Size(340, 100),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              elevation: 15,
              shadowColor: Color.fromARGB(255, 0, 0, 0),
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ExamList(tid, tdept),
                ),
              );
            },
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(
                  "assets/images/icons8-people-64.png",
                  height: 46,
                ),
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.03,
                ),
                Text(
                  "Assign Test",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color.fromARGB(255, 255, 255, 255),
                    fontSize: 22,
                    fontFamily: 'Ubuntu',
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.025,
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              minimumSize: Size(340, 100),
              primary: Color.fromARGB(196, 72, 86, 245),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              elevation: 15,
              shadowColor: Color.fromARGB(255, 0, 0, 0),
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ExamForPublish(tid),
                ),
              );
            },
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(
                  "assets/images/icons8-documents-64.png",
                  height: 46,
                ),
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.03,
                ),
                Text(
                  "Publish Results",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color.fromARGB(255, 255, 255, 255),
                    fontSize: 22,
                    fontFamily: 'Ubuntu',
                  ),
                ),
              ],
            ),
          ),
          Spacer(),
        ],
      ),
    );
  }
}
