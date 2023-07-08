import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:test_app/pages/assignExam.dart';
import 'package:test_app/pages/rankPage.dart';
import 'package:test_app/pages/start_exam.dart';
import 'package:test_app/util/loadingPage.dart';
import 'package:http/http.dart' as http;

import '../model/exam.dart';
import '../model/question_model.dart';
import '../util/url.dart';

class RankforExam extends StatefulWidget {
  const RankforExam({super.key});

  @override
  State<RankforExam> createState() => _RankforExamState();
}

class _RankforExamState extends State<RankforExam> {
  //**Exam list to show all Exams
  List<Exam> examlist = [];

//**SharederPreference variables to store the user_id
  late SharedPreferences sp;
  String user_roll = "";

//**SharedPreferrence Function to get the user_id
  Future getUserRoll() async {
    sp = await SharedPreferences.getInstance();
    user_roll = sp.getString('roll') ?? "";
    setState(() {});
  }

  //**This function is used to get the  all exam details
  Future examList(String roll) async {
    Map data = {
      'roll': roll,
    };
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return LoadingPage("Loading...");
        });
    try {
      var response = await http.post(
        Uri.http(
          MyUrl.hosturl,
          MyUrl.suburl + "exam_for_rank.php",
        ),
        body: data,
      );
      var jsondata = jsonDecode(response.body);
      if (jsondata['status'] == "true") {
        Navigator.pop(context);
        examlist.clear();
        for (var x in jsondata['data']) {
          setState(
            () {
              Exam exam = Exam(
                x['exam_name'],
                x['start_date'],
                x['end_date'],
                x['start_time'],
                x['end_time'],
                int.parse(x['id']),
                int.parse(x['batch_id']),
                int.parse(x['full_marks']),
                int.parse(x['marks_per_qns']),
                int.parse(x['exam_duration']),
              );
              examlist.add(exam);
            },
          );
        }
      } else {
        Navigator.pop(context);
        Fluttertoast.showToast(
          msg: jsondata['msg'],
          backgroundColor: Colors.green,
          textColor: Colors.white,
        );
      }
    } catch (e) {
      Navigator.pop(context);
      Fluttertoast.showToast(
        msg: e.toString(),
        backgroundColor: Colors.green,
        textColor: Colors.white,
      );
    }
  }

  // ! Init state
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) {
        getUserRoll().whenComplete(
          () => examList(user_roll),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Exams"),
        leading: InkWell(
          onTap: () {
            Navigator.pop(context);
          },
          child: Icon(Icons.arrow_back_ios_outlined),
        ),
      ),
      body: ListView.builder(
          itemCount: examlist.length,
          itemBuilder: (BuildContext context, int index) {
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MyRank(examlist[index].id),
                    ),
                  );
                },
                child: ListTile(
                  title: Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: Colors.purple,
                        child: Text(
                          examlist[index].name[0],
                        ),
                      ),
                      SizedBox(
                        width: 15,
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(examlist[index].name),
                          Text(
                            examlist[index].startdate,
                            style: TextStyle(
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      Spacer(),
                      Icon(
                        Icons.keyboard_arrow_right,
                        size: 28,
                        color: Color.fromARGB(255, 149, 0, 255),
                      )
                    ],
                  ),
                  contentPadding: EdgeInsets.all(8),
                  tileColor: Color.fromARGB(164, 162, 146, 191),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
              ),
            );
          }),
    );
  }
}
