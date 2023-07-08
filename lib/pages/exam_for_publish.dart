import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:test_app/main.dart';
import 'package:test_app/pages/publish_result.dart';
import 'package:test_app/util/loadingPage.dart';

import '../model/exam.dart';
import '../util/url.dart ';
import 'package:http/http.dart' as http;

class ExamForPublish extends StatefulWidget {
  int tid = 0;
  ExamForPublish(this.tid);

  @override
  State<ExamForPublish> createState() => _ExamForPublishState(tid);
}

class _ExamForPublishState extends State<ExamForPublish> {
  int tid = 0;
  _ExamForPublishState(this.tid);
  //**Exam list to show all Exams
  List<Exam> examlist = [];

//**This function is used to get the  all exam details
  Future examList() async {
    Map data = {
      'teacherid': tid.toString(),
      // 'batchid': BatchId,
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
          MyUrl.suburl + "getexam3.php",
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
        examList();
      },
    );
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Publish Results"),
        leading: InkWell(
          onTap: () {
            Navigator.pop(context);
          },
          child: Icon(Icons.arrow_back_ios_outlined),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 5,
          vertical: 7,
        ),
        child: examlist.isNotEmpty
            ? ListView.builder(
                itemCount: examlist.length,
                itemBuilder: (BuildContext context, int index) {
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              PublishResult(examlist[index].id),
                        ),
                      );
                    },
                    child: Container(
                      height: 100,
                      width: MediaQuery.of(context).size.width,
                      padding:
                          EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                      margin: EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Color.fromARGB(255, 214, 248, 248),
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
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "Exam Name: " + examlist[index].name,
                                style: TextStyle(
                                  fontFamily: 'Ubuntu',
                                  fontSize: 15.5,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Exam time: " +
                                    examlist[index].exam_duration.toString(),
                                style: TextStyle(
                                  fontFamily: 'Ubuntu',
                                  fontSize: 15.5,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Icon(
                                Icons.keyboard_arrow_right,
                                size: 30,
                                color: Color.fromARGB(255, 72, 156, 26),
                              ),
                            ],
                          ),
                          Text(
                            "Start Date: " + examlist[index].startdate,
                            style: TextStyle(
                              fontFamily: 'Ubuntu',
                              fontSize: 15.5,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                })
            : Center(child: layout()),
      ),
    );
  }
}
