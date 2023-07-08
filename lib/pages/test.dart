import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:test_app/pages/assignExam.dart';
import 'package:test_app/pages/start_exam.dart';
import 'package:test_app/util/loadingPage.dart';
import 'package:http/http.dart' as http;

import '../model/exam.dart';
import '../model/question_model.dart';
import '../util/url.dart';

class TestPage extends StatefulWidget {
  const TestPage({Key? key}) : super(key: key);

  @override
  State<TestPage> createState() => _TestPageState();
}

class _TestPageState extends State<TestPage> {
  //**Exam list to show all Exams
  List<Exam> examlist = [];

//**SharederPreference variables to store the user_id
  late SharedPreferences sp;
  String user_roll = "";
  String user_id = "";

// **Variable for timer
  late int totalTime;

// **Hour,minute,second
  int h = 0;
  int m = 0;
  int second = 0;
  String timeCounter = "";
  Timer? timer;

//**Question list to show all question
  List<Question> questionlist = [];

//**SharedPreferrence Function to get the user_id
  Future getUserRoll() async {
    sp = await SharedPreferences.getInstance();
    user_roll = sp.getString('roll') ?? "";
    user_id = sp.getString('user_id') ?? "";
    setState(() {});
  }

  //**This function is used to get the  all exam details
  Future examList(String roll, String id) async {
    Map data = {
      'roll': roll,
      'id': id,
    };
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return LoadingPage("Loading...");
        });
    examlist.clear();
    try {
      var response = await http.post(
        Uri.http(
          MyUrl.hosturl,
          MyUrl.suburl + "all_exam_list.php",
        ),
        body: data,
      );

      var jsondata = jsonDecode(response.body);
      if (jsondata['status'] == "true") {
        Navigator.pop(context);
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
          backgroundColor: Color.fromARGB(255, 26, 132, 177),
          textColor: Colors.white,
        );
      }
    } catch (e) {
      Navigator.pop(context);
      Fluttertoast.showToast(
        msg: e.toString(),
        backgroundColor: Color.fromARGB(255, 71, 159, 221),
        textColor: Colors.white,
      );
    }
  }

  //**This function is used to get the  all Questions with right answer
  Future questionList(int exam_id) async {
    Map data = {
      'examid': exam_id.toString(),
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
          MyUrl.suburl + "getquestion.php",
        ),
        body: data,
      );
      var jsondata = jsonDecode(response.body);
      if (jsondata['status'] == "true") {
        Navigator.pop(context);
        questionlist.clear();
        for (var x in jsondata['data']) {
          setState(
            () {
              Question questions = Question(
                x['question'],
                x['opt_1'],
                x['opt_2'],
                x['opt_3'],
                x['opt_4'],
                int.parse(x['id']),
                int.parse(x['exam_id']),
                int.parse(x['correct_ans']),
              );
              questionlist.add(questions);
            },
          );
        }
      } else {
        Navigator.pop(context);
        Fluttertoast.showToast(
          msg: jsondata['msg'],
          backgroundColor: Color.fromARGB(255, 83, 124, 214),
          textColor: Colors.white,
        );
      }
    } catch (e) {
      Navigator.pop(context);
      Fluttertoast.showToast(
        msg: e.toString(),
        backgroundColor: Color.fromARGB(255, 66, 130, 203),
        textColor: Colors.white,
      );
    }
  }

//**this dialog box is used to take confirmation for logout
  examStartDailog(int examid, String examname, int examtime) => showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          title: Row(
            children: [
              Icon(
                Icons.book_rounded,
                color: Color.fromARGB(255, 11, 165, 254),
              ),
              SizedBox(
                width: 5,
              ),
              Text(
                "Start Exam...",
                style: TextStyle(
                  color: Color.fromARGB(255, 11, 165, 254),
                  fontSize: 22,
                ),
              ),
            ],
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          content: Text(
            "Do you want to start exam...?",
            style: TextStyle(
              fontFamily: 'Ubuntu',
              fontSize: 17,
            ),
          ),
          actions: [
            TextButton(
              style: TextButton.styleFrom(
                primary: Colors.white,
                backgroundColor: Colors.red,
                elevation: 3,
                shadowColor: Colors.red,
                minimumSize: Size(70, 30),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30)),
              ),
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text(
                "Cancel",
                style: TextStyle(
                  color: Color.fromARGB(255, 255, 255, 255),
                  fontFamily: 'Ubuntu',
                  fontSize: 16,
                ),
              ),
            ),
            SizedBox(
              width: 0,
            ),
            TextButton(
              style: TextButton.styleFrom(
                primary: Colors.white,
                backgroundColor: Color.fromARGB(255, 0, 149, 255),
                elevation: 3,
                shadowColor: Color.fromARGB(255, 0, 149, 255),
                minimumSize: Size(70, 30),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30)),
              ),
              onPressed: () {
                questionList(examid).whenComplete(() {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          StartExam(questionlist, examname, examid, examtime),
                    ),
                  );
                });
              },
              child: Text(
                "OK",
                style: TextStyle(
                  color: Color.fromARGB(255, 255, 255, 255),
                  fontFamily: 'Ubuntu',
                  fontSize: 16,
                  // fontWeight: FontWeight.w600
                ),
              ),
            ),
          ],
        ),
      );

// **Funtion to show total Time in format
  String formatDuration(int t) {
    if (t < 10) {
      return "0$t";
    } else {
      return t.toString();
    }
  }

// **Function to calculate total time
  String calculateTime(int t) {
    second = t;
    h = (second ~/ 3600);
    second = second % 3600;
    m = (second ~/ 60);
    second = second % 60;
    timeCounter = formatDuration(h) +
        ":" +
        formatDuration(m) +
        ":" +
        formatDuration(second);

    return timeCounter;
  }

//**this function is used to show the layout  when examlist is empty
  Widget layout() {
    return Container(
      width: 300,
      height: 200,
      decoration: BoxDecoration(
        color: Colors.transparent,
        image: DecorationImage(
          image: AssetImage(
            "assets/images/layout1-removebg-preview.png",
          ),
          opacity: 0.5,
        ),
      ),
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Text(
          "There is no exam right now",
          style: TextStyle(
            color: Colors.grey,
            fontFamily: "Ubuntu",
          ),
        ),
      ),
    );
  }

  // ! Init state
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) {
        getUserRoll().whenComplete(
          () => examList(user_roll, user_id),
        );
        timer = Timer.periodic(Duration(milliseconds: 100), (timer) {
          setState(() {});
        });
      },
    );
  }

// !!Disoper
  @override
  void dispose() {
    super.dispose();
    timer?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 3,
        title: Text(
          "Test Page",
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: InkWell(
          onTap: () {
            Navigator.pop(context);
          },
          child: Icon(Icons.arrow_back_ios_outlined),
        ),
      ),
      body: examlist.isNotEmpty
          ? Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 5,
                vertical: 8,
              ),
              child: ListView.builder(
                  itemCount: examlist.length,
                  itemBuilder: (BuildContext context, int index) {
                    return Container(
                      margin: EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      child: Container(
                        height: 180,
                        width: MediaQuery.of(context).size.width,
                        padding:
                            EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                        decoration: BoxDecoration(
                          color: Color.fromARGB(255, 255, 255, 255),
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                              color: Color.fromARGB(74, 0, 0, 0),
                              blurRadius: 8,
                              spreadRadius: 1,
                              offset: Offset(
                                -1,
                                3,
                              ),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Exam Name : ",
                                  style: TextStyle(
                                    fontFamily: 'Ubuntu-Bold',
                                    fontSize: 15.5,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  examlist[index].name,
                                  style: TextStyle(
                                    fontFamily: 'Ubuntu',
                                    fontSize: 15.5,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Full Marks : ",
                                  style: TextStyle(
                                    fontFamily: 'Ubuntu',
                                    fontSize: 15.5,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  examlist[index].full_marks.toString(),
                                  style: TextStyle(
                                    fontFamily: 'Ubuntu',
                                    fontSize: 15.5,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Per Questions : ",
                                  style: TextStyle(
                                    fontFamily: 'Ubuntu',
                                    fontSize: 15.5,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  examlist[index].mark_per_qns.toString(),
                                  style: TextStyle(
                                    fontFamily: 'Ubuntu',
                                    fontSize: 15.5,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Exam Duration : ",
                                  style: TextStyle(
                                    fontFamily: 'Ubuntu',
                                    fontSize: 15.5,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  calculateTime(examlist[index].exam_duration),
                                  style: TextStyle(
                                    fontFamily: 'Ubuntu',
                                    fontSize: 15.5,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Exam Time : ",
                                  style: TextStyle(
                                    fontFamily: 'Ubuntu',
                                    fontSize: 15.5,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  DateFormat('hh:mm a').format(DateTime.parse(
                                      "0000-00-00 " +
                                          examlist[index].start_time)),
                                  style: TextStyle(
                                    fontFamily: 'Ubuntu',
                                    fontSize: 15.5,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  " to ",
                                  style: TextStyle(
                                    fontFamily: 'Ubuntu',
                                    fontSize: 15.5,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  DateFormat('hh:mm a').format(DateTime.parse(
                                      "0000-00-00 " +
                                          examlist[index].end_time)),
                                  style: TextStyle(
                                    fontFamily: 'Ubuntu',
                                    fontSize: 15.5,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Exam Date : ",
                                  style: TextStyle(
                                    fontFamily: 'Ubuntu',
                                    fontSize: 15.5,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  DateFormat("dd-MM-yyyy").format(
                                      DateTime.parse(
                                          examlist[index].startdate)),
                                  style: TextStyle(
                                    fontFamily: 'Ubuntu',
                                    fontSize: 15.5,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  " to ",
                                  style: TextStyle(
                                    fontFamily: 'Ubuntu',
                                    fontSize: 15.5,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  DateFormat("dd-MM-yyyy").format(
                                      DateTime.parse(examlist[index].enddate)),
                                  style: TextStyle(
                                    fontFamily: 'Ubuntu',
                                    fontSize: 15.5,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                            Align(
                              alignment: Alignment.bottomRight,
                              child: DateTime.now().isAfter(DateTime.parse(
                                          examlist[index].startdate +
                                              " " +
                                              examlist[index].start_time)) &&
                                      DateTime.now().isBefore(DateTime.parse(
                                          examlist[index].enddate +
                                              " " +
                                              examlist[index].end_time))
                                  ? TextButton(
                                      style: TextButton.styleFrom(
                                        primary: Colors.white,
                                        backgroundColor: Colors.blue,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(6),
                                        ),
                                      ),
                                      onPressed: () {
                                        final timedelay = DateTime.now()
                                            .difference(DateTime.parse(
                                                examlist[index].startdate +
                                                    " " +
                                                    examlist[index].start_time))
                                            .inSeconds;
                                        examStartDailog(
                                            examlist[index].id,
                                            examlist[index].name,
                                            (examlist[index].exam_duration -
                                                timedelay));
                                      },
                                      child: Text(
                                        "Start Exam",
                                        style: TextStyle(
                                          fontFamily: 'Ubuntu',
                                          fontSize: 15,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    )
                                  : TextButton(
                                      style: TextButton.styleFrom(
                                        primary: Colors.white,
                                        backgroundColor:
                                            Color.fromARGB(255, 117, 117, 117),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(6),
                                        ),
                                      ),
                                      onPressed: () {
                                        Null;
                                      },
                                      child: Text(
                                        "Start Exam",
                                        style: TextStyle(
                                          color: Color.fromARGB(
                                              255, 255, 255, 255),
                                          fontFamily: 'Ubuntu',
                                          fontSize: 15,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
            )
          : Center(child: layout()),
    );
  }
}
