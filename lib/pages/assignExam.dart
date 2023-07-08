import 'dart:convert';
// import 'dart:html';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:test_app/pages/createExam.dart';
import 'package:test_app/pages/assignStudent.dart';
import 'package:test_app/pages/questionUploade.dart';

import '../model/exam.dart';
import '../util/loadingPage.dart';
import 'package:http/http.dart' as http;

import '../util/url.dart ';

class ExamList extends StatefulWidget {
  int tid = 0;
  String tdept = "";
  ExamList(this.tid, this.tdept);

  @override
  State<ExamList> createState() => _ExamListState(tid, tdept);
}

class _ExamListState extends State<ExamList> {
  int tid = 0;
  String tdept = "";
  _ExamListState(this.tid, this.tdept);

//**Exam list to show all Exams
  List<Exam> examlist = [];

// **These are varialbes are used for file upload
  FilePickerResult? result;
  String filepath = "";
  PlatformFile? pickedfile;
  bool path = false;

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
          MyUrl.suburl + "getexam2.php",
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

//**This function is used to pick csv file from folder
  Future filePicker() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['csv'],
      );
      if (result == null) return;

      PlatformFile Pickedfile = result.files.first;
      setState(() {
        filepath = Pickedfile.path!;
      });

      print(filepath);
    } catch (e) {
      print(e);
    }
  }

// **this function is used to Upload Questions
  Future uploadQns(int id) async {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return LoadingPage("Loading...");
        });

    var request = http.MultipartRequest(
        'POST',
        Uri.parse(
            'http://' + MyUrl.hosturl + '/' + MyUrl.suburl + 'insert_qns.php'));
    request.fields['examId'] = id.toString();
    request.files.add(await http.MultipartFile.fromPath('questions', filepath));
    var response = await request.send();
    var respond = await http.Response.fromStream(response);

    try {
      var jsondata = jsonDecode(respond.body);
      if (jsondata['status'] == "true") {
        Navigator.pop(context);

        Fluttertoast.showToast(
          msg: jsondata['msg'],
          backgroundColor: Color.fromARGB(255, 21, 111, 180),
          textColor: Colors.white,
        );
      } else {
        Navigator.pop(context);
        Fluttertoast.showToast(
          msg: jsondata['msg'],
          backgroundColor: Color.fromARGB(255, 21, 111, 180),
          textColor: Colors.white,
        );
      }
    } catch (e) {
      Navigator.pop(context);
      Fluttertoast.showToast(
        msg: e.toString(),
        backgroundColor: Color.fromARGB(255, 21, 111, 180),
        textColor: Colors.white,
      );
    }
  }

//**Alert box for question upload
  uploadQuestionDialog(int id) {
    int ExamId = id;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Row(
            children: [
              Icon(
                Icons.file_open,
                color: Color.fromARGB(255, 34, 111, 244),
              ),
              SizedBox(
                width: 7,
              ),
              Text(
                "Upload Question",
                style: TextStyle(
                  color: Color.fromARGB(255, 34, 111, 244),
                  fontSize: 22,
                  fontFamily: 'Ubuntu',
                ),
              ),
            ],
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          content: path == false
              ? ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    primary: Color.fromARGB(105, 236, 213, 213),
                    // minimumSize: Size(190, 150),
                    minimumSize: Size(MediaQuery.of(context).size.width, 60),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: () async {
                    await filePicker().whenComplete(() {
                      setState(() {
                        if (filepath != "") {
                          path = true;
                        }
                      });
                    });
                  },
                  child: Text(
                    "Insert File",
                    style: TextStyle(
                      color: Color.fromARGB(168, 0, 0, 0),
                      fontSize: 20,
                    ),
                  ),
                )
              : ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    primary: Color.fromARGB(253, 13, 191, 255),
                    minimumSize: Size(MediaQuery.of(context).size.width, 60),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: () {},
                  child: Text(
                    "File Already Inserted",
                    style: TextStyle(
                      color: Color.fromARGB(255, 255, 255, 255),
                      fontSize: 20,
                    ),
                  ),
                ),
          actions: [
            TextButton(
              style: TextButton.styleFrom(
                primary: Colors.white,
                backgroundColor: Color.fromARGB(255, 255, 0, 0),
                elevation: 1,
                shadowColor: Color.fromARGB(255, 255, 0, 0),
                minimumSize: Size(70, 30),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: () {
                setState(() {
                  path = false;
                  filepath = "";
                });
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
                backgroundColor: Color.fromARGB(255, 54, 158, 244),
                elevation: 1,
                shadowColor: Color.fromARGB(255, 54, 143, 244),
                minimumSize: Size(70, 30),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: () {
                Navigator.pop(context);
                uploadQns(ExamId);

                setState(() {
                  path = false;
                  filepath = "";
                });
              },
              child: Text(
                "Upload",
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
      ),
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

// !!INIT State
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) {
        examList();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 3,
        title: Text(
          "Exam List",
        ),
        leading: InkWell(
          onTap: () {
            Navigator.pop(context);
          },
          child: Icon(Icons.arrow_back_ios_outlined),
        ),
      ),
      body: examlist.isNotEmpty
          ? ListView.builder(
              itemCount: examlist.length,
              itemBuilder: (BuildContext context, int index) {
                return Container(
                  margin: EdgeInsets.symmetric(
                    horizontal: 5,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.only(top: 8, left: 4, right: 4),
                    child: ListTile(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      tileColor: Colors.amber[100],
                      title: Text(examlist[index].name),
                      subtitle: Column(
                        children: [
                          Row(
                            children: [
                              Text(examlist[index].startdate),
                              SizedBox(
                                width: 20,
                                child: Text(
                                  "to",
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              Text(examlist[index].enddate),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              TextButton(
                                style: TextButton.styleFrom(
                                  primary: Colors.white,
                                  backgroundColor: Colors.blue,
                                ),
                                onPressed: () {
                                  uploadQuestionDialog(examlist[index].id);
                                },
                                child: Text("Upload Question"),
                              ),
                              SizedBox(
                                width: 10,
                              ),
                              TextButton(
                                style: TextButton.styleFrom(
                                  primary: Colors.white,
                                  backgroundColor: Colors.greenAccent,
                                ),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (cotext) => AssignStudent(
                                          examlist[index].batchid,
                                          examlist[index].id),
                                    ),
                                  );
                                },
                                child: Text("Assign"),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            )
          : Center(child: layout()),
    );
  }
}
