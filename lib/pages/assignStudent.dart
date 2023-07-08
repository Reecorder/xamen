import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:test_app/model/student_batch.dart';
import 'package:test_app/util/loadingPage2.dart';
import 'package:test_app/util/url.dart%20';
import 'package:http/http.dart' as http;
import '../util/loadingPage.dart';

class AssignStudent extends StatefulWidget {
  //Stateful Widget Constructor
  int batchid;
  int examid;
  AssignStudent(this.batchid, this.examid);

  @override
  State<AssignStudent> createState() =>
      _AssignStudentState(this.batchid, this.examid);
}

class _AssignStudentState extends State<AssignStudent> {
  //!Stateful Widget Constructor
  int batchid;
  int examid;
  _AssignStudentState(this.batchid, this.examid);

//**List to store student details(StudentBatch modal list)
  List<StudentBatch> studentList = [];

//**List to store student roll when checkbox is true
  List statusvalue = [];

//**String to store roll from statusvalue List and send roll to db
  String status = "";
  String assign_student = "";

//**List to store checkboxlisttile value(default value false)
  List<bool> checkBoxValue = [];

//**variable for checkbox list tile
  bool checked = false;

//**This function is used to get student(model) corresponding to batch id for setting status
  Future getBatchStudent() async {
    Map data = {
      'batchid': batchid.toString(),
    };
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return LoadingPage("Loading...");
        });
    try {
      var student = await http.post(
        Uri.http(
          MyUrl.hosturl,
          MyUrl.suburl + "getstudent.php",
        ),
        body: data,
      );
      List assign_student_list = assign_student.split(", ");
      print(assign_student_list);
      var jsondata = jsonDecode(student.body);
      if (jsondata['status'] == "true") {
        Navigator.pop(context);
        studentList.clear();
        for (var x in jsondata['data']) {
          setState(() {
            StudentBatch student = StudentBatch(
              x['name'],
              x['roll'],
            );
            studentList.add(student);

            if (assign_student_list.contains(x['roll'])) {
              checkBoxValue.add(true);
              statusvalue.add(x['roll']);
            } else {
              checkBoxValue.add(false);
            }
          });
        }
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
        backgroundColor: Color.fromARGB(255, 0, 124, 181),
        textColor: Colors.white,
      );
    }
  }

//**This function is used to set status corresponding to student
  Future setStatus() async {
    statusvalue.isEmpty ? statusvalue.add(null) : statusvalue.remove(null);
    Map data = {
      'roll': statusvalue.toString(),
      'examid': examid.toString(),
    };
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return LoadingPage2("Please wait..!");
        });
    try {
      var response = await http.post(
        Uri.http(
          MyUrl.hosturl,
          MyUrl.suburl + "set_status.php",
        ),
        body: data,
      );
      var jsondata = jsonDecode(response.body);
      if (jsondata['status'] == "true") {
        Navigator.pop(context);
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
        backgroundColor: Color.fromARGB(255, 0, 124, 181),
        textColor: Colors.white,
      );
    }
  }

// **This function is used to check previously assigned student
  Future assigned_student() async {
    Map data = {
      'examid': examid.toString(),
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
          MyUrl.suburl + "status_check.php",
        ),
        body: data,
      );
      var jsondata = jsonDecode(response.body);
      if (jsondata['status'] == "true") {
        assign_student = jsondata['std_assign'].toString();
        Navigator.pop(context);

        // Fluttertoast.showToast(
        //   msg: jsondata['msg'],
        //   backgroundColor: Color.fromARGB(255, 21, 111, 180),
        //   textColor: Colors.white,
        // );
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
        backgroundColor: Color.fromARGB(255, 0, 124, 181),
        textColor: Colors.white,
      );
    }
  }

//**This is a custom widget to creat a checkbox
  Widget myCheckBox(int index) {
    return CheckboxListTile(
      activeColor: Color.fromARGB(255, 30, 124, 23),
      tileColor: Color.fromARGB(255, 250, 226, 156),
      side: BorderSide(
        color: Color.fromARGB(255, 0, 0, 0),
        width: 1.5,
      ),
      checkboxShape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(4),
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      value: checkBoxValue[index],
      onChanged: (value) {
        setState(() {
          checkBoxValue[index] = value!;
          // status += '$studentList[index].roll,';
          // print(status);
          if (value == true) {
            statusvalue.add(studentList[index].roll);
            print(statusvalue);
            //   for (var i in statusvalue) {
            //     if (status.contains(i)) {
            //       continue;
            //     } else {
            //       status += "$i,";
            //     }
            //     print(status);

          } else {
            statusvalue.remove(studentList[index].roll);
            print(statusvalue);
            // print(status);
          }
        });
      },
      title: Row(
        children: [
          CircleAvatar(
            child: Text(
              studentList[index].name[0],
            ),
          ),
          SizedBox(
            width: 12,
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(studentList[index].name),
              Text(studentList[index].roll),
            ],
          )
        ],
      ),
    );
  }

//!Init state to creat student list when widget is first building
  @override
  void initState() {
    print(batchid);
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) {
        assigned_student().whenComplete(() => getBatchStudent());
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 1,
        title: Text("Student Assign"),
        leading: InkWell(
          onTap: () {
            Navigator.pop(context);
          },
          child: Icon(Icons.arrow_back_ios_outlined),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 18),
            child: Checkbox(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
                side: BorderSide(
                  color: Color.fromARGB(255, 255, 255, 255),
                  width: 1.5,
                ),
                activeColor: Color.fromARGB(255, 30, 124, 23),
                value: checked,
                onChanged: (value) {
                  setState(() {
                    checked = value!;
                    statusvalue.clear();
                    if (value) {
                      for (int i = 0; i < checkBoxValue.length; i++) {
                        checkBoxValue[i] = true;
                        statusvalue.add(studentList[i].roll);
                        print(statusvalue);
                        // for (var i in statusvalue) {
                        //   if (status.contains(i)) {
                        //     continue;
                        //   } else {
                        //     status += "$i,";
                        //   }
                        //   print(status);
                        // }
                      }
                    } else {
                      for (int i = 0; i < checkBoxValue.length; i++) {
                        checkBoxValue[i] = false;
                        statusvalue.remove(studentList[i].roll);
                        print(statusvalue);
                      }
                    }
                  });
                }),
          )
        ],
      ),
      body: ListView.builder(
          itemCount: studentList.length,
          itemBuilder: (BuildContext context, int index) {
            return Container(
              margin: EdgeInsets.symmetric(horizontal: 5, vertical: 5),
              child: myCheckBox(index),
            );
          }),
      floatingActionButton: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: 15,
          horizontal: 10,
        ),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            minimumSize: Size(60, 60),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(50),
            ),
            elevation: 15,
            shadowColor: Color.fromARGB(255, 0, 0, 0),
          ),
          onPressed: () {
            setStatus();
          },
          child: Icon(
            Icons.check,
            color: Color.fromARGB(255, 255, 255, 255),
          ),
        ),
      ),
    );
  }
}
