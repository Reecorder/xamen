import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:test_app/model/student_batch.dart';
import 'package:test_app/util/loadingPage.dart';

import '../util/url.dart';
import 'package:http/http.dart' as http;

class AssignExam extends StatefulWidget {
  int tid = 0;
  String tdept = "";
  String tdeptname = "";
  AssignExam(this.tid, this.tdept, this.tdeptname);

  @override
  State<AssignExam> createState() => _AssignExamState(tid, tdept, tdeptname);
}

class _AssignExamState extends State<AssignExam> {
  int tid = 0;
  String tdept = "";
  String tdeptname = "";
  _AssignExamState(this.tid, this.tdept, this.tdeptname);

  //**From Key to validate the update form fields
  final formkey = GlobalKey<FormState>();

  //!getdepartment function is called inside INIT state
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      getBatch();
    });
  }

//**Controlers for picking value from TextFormField
  TextEditingController examName = new TextEditingController();
  TextEditingController startDate = new TextEditingController();
  TextEditingController endDate = new TextEditingController();
  TextEditingController startTime = new TextEditingController();
  TextEditingController endTime = new TextEditingController();
  TextEditingController totalTime = new TextEditingController();
  TextEditingController totalMarks = new TextEditingController();
  TextEditingController marks_per_question = new TextEditingController();

//**This variables are used to create the department dropdown
  List<String> departmentlist = [];
  String? departmentname;
  List<String> dept_id_list = [];
  // late String DeptId;

//**This variables are used to create the batch dropdown
  List<String> batchlist = [];
  String? batchname;
  List<String> batch_id_list = [];
  late String BatchId;

// ** Date Time calculater
  DateTime? date1;
  DateTime? date2;
  String formattedTime1 = "00:00:00";
  String formattedTime2 = "00:00:00";
  String formattedDate1 = "0000-00-00";
  String formattedDate2 = "0000-00-00";
  int timeInSecond = 0;
  String totalTimeInSecond = "";

  // // **this function is used  for get department from DB
  // Future getDepartment() async {
  //   var dept = await http.get(
  //     Uri.http(
  //       MyUrl.hosturl,
  //       MyUrl.suburl + "getdept.php",
  //     ),
  //   );
  //   var jsondata = jsonDecode(dept.body);
  //   if (jsondata['status'] == "true") {
  //     departmentlist.clear();
  //     for (var x in jsondata['data']) {
  //       setState(() {
  //         departmentlist.add(x['dept_name']);
  //         dept_id_list.add(x['dept_id']);
  //       });
  //     }
  //   }
  // }

/////**this function is used to get Dept Id
  // void getDeptId() {
  //   for (int i = 0; i < departmentlist.length; i++) {
  //     if (departmentname == departmentlist[i]) {
  //       DeptId = dept_id_list[i];
  //       break;
  //     }
  //   }
  //   setState(() {});
  // }

//**this function is used to get Batch Id
  void getBatchId() {
    for (int i = 0; i < batchlist.length; i++) {
      if (batchname == batchlist[i]) {
        BatchId = batch_id_list[i];
        break;
      }
    }
    setState(() {});
  }

//** */ this function is used for get batch coresponding departmentId from DB
  Future getBatch() async {
    // getDeptId();
    Map data = {
      'deptid': tdept,
    };
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return LoadingPage("Loading...");
        });
    try {
      var dept = await http.post(
        Uri.http(
          MyUrl.hosturl,
          MyUrl.suburl + "getbatch.php",
        ),
        body: data,
      );
      var jsondata = jsonDecode(dept.body);
      if (jsondata['status'] == "true") {
        Navigator.pop(context);
        batchlist.clear();
        for (var x in jsondata['data']) {
          setState(() {
            batchlist.add(x['batch_name']);
            batch_id_list.add(x['batch_id']);
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

//**this funtion is used to creat exam
  Future assignExam() async {
    Map data = {
      "teacherid": tid.toString(),
      'batchid': BatchId,
      'exam': examName.text,
      'start_date': startDate.text,
      'end_date': endDate.text,
      'start_time': startTime.text,
      'end_time': endTime.text,
      'total_time': timeInSecond.toString(),
      'total_marks': totalMarks.text,
      'marks_per_qns': marks_per_question.text,
    };
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return LoadingPage("Loading...");
        });
    try {
      var dept = await http.post(
        Uri.http(
          MyUrl.hosturl,
          MyUrl.suburl + "insert_exam.php",
        ),
        body: data,
      );
      var jsondata = jsonDecode(dept.body);
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

//**this funtion is used to validate create exam
  examValid() {
    if (formkey.currentState!.validate()) {
      assignExam();
    }
  }

// **Time format for total time
  String formatDuration(int t) {
    if (t < 10) {
      return "0$t";
    } else {
      return t.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Create Exam",
          style: TextStyle(
            color: Colors.white,
            fontFamily: "Ubuntu",
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        leading: InkWell(
          onTap: () {
            Navigator.pop(context);
          },
          child: Icon(Icons.arrow_back_ios_outlined),
        ),
      ),
      body: Form(
          key: formkey,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 17),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  SizedBox(
                    height: 15,
                  ),
                  // DropdownButtonFormField(
                  //   decoration: InputDecoration(
                  //     prefixIcon: Icon(Icons.book),
                  //     border: OutlineInputBorder(
                  //       borderRadius: BorderRadius.all(
                  //         Radius.circular(15),
                  //       ),
                  //     ),
                  //   ),
                  //   value: departmentname,
                  //   isExpanded: true,
                  //   hint: Text(
                  //     "Department : " + tdeptname,
                  //   ),
                  //   items: departmentlist.map((value) {
                  //     return DropdownMenuItem(
                  //       value: value,
                  //       child: Text(
                  //         value,
                  //       ),
                  //     );
                  //   }).toList(),
                  //   onChanged: (value) {
                  //     setState(() {
                  //       departmentname = value.toString()
                  //       getBatch();
                  //     });
                  //   },
                  // ),
                  TextFormField(
                    enabled: false,
                    decoration: InputDecoration(
                      prefixIcon: Padding(
                        padding: EdgeInsets.only(left: 1),
                        child: Icon(Icons.school),
                      ),
                      labelText: "Department : " + tdeptname,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 15,
                  ),
                  DropdownButtonFormField(
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.book),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(
                          Radius.circular(30 / 2),
                        ),
                      ),
                    ),
                    value: batchlist.contains(batchname) ? batchname : null,
                    isExpanded: true,
                    hint: Text(
                      "select batch",
                    ),
                    items: batchlist.map((data) {
                      return DropdownMenuItem(
                        value: data,
                        child: Text(
                          data,
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        batchname = value.toString();
                        getBatchId();
                        print(BatchId);
                        // getStudent();
                      });
                    },
                  ),
                  SizedBox(
                    height: 15,
                  ),
                  TextFormField(
                    controller: examName,
                    validator: (val) {
                      return val!.isEmpty ? "Provide exam name" : null;
                    },
                    decoration: InputDecoration(
                      prefixIcon: Padding(
                        padding: EdgeInsets.only(left: 1),
                        child: Icon(Icons.text_format),
                      ),
                      labelText: "Exam Name",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 15,
                  ),
                  TextFormField(
                    controller: startDate,
                    validator: (val) {
                      return val!.isEmpty ? "Provide start date" : null;
                    },
                    decoration: InputDecoration(
                      prefixIcon: Padding(
                        padding: EdgeInsets.only(left: 1),
                        child: Icon(Icons.calendar_month),
                      ),
                      labelText: "Enter Start Date",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    readOnly: true,
                    onTap: () async {
                      DateTime? pickedDate = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(
                          2000,
                        ),
                        lastDate: DateTime(
                          2101,
                        ),
                      );
                      if (pickedDate != null) {
                        String formattedDate =
                            DateFormat('dd-MM-yyyy').format(pickedDate);
                        formattedDate1 =
                            DateFormat('yyyy-MM-dd').format(pickedDate);
                        date1 = DateTime.parse(
                            formattedDate1 + " " + formattedTime1);
                        date2 = DateTime.parse(
                            formattedDate2 + " " + formattedTime2);

                        timeInSecond = date2!.difference(date1!).inSeconds;

                        int temptime = timeInSecond;
                        int h = (temptime / 3600).toInt();
                        temptime = temptime % 3600;
                        int m = (temptime / 60).toInt();
                        temptime = temptime % 60;
                        totalTimeInSecond = formatDuration(h) +
                            ":" +
                            formatDuration(m) +
                            ":" +
                            formatDuration(temptime);

                        setState(() {
                          startDate.text = formattedDate1;
                          totalTime.text = totalTimeInSecond;
                        });
                      } else {
                        print("Date is not selected");
                      }
                    },
                  ),
                  SizedBox(
                    height: 15,
                  ),
                  TextFormField(
                    controller: endDate,
                    validator: (val) {
                      return val!.isEmpty ? "Provide end date" : null;
                    },
                    decoration: InputDecoration(
                      prefixIcon: Padding(
                        padding: EdgeInsets.only(left: 1),
                        child: Icon(Icons.calendar_month),
                      ),
                      labelText: "Enter End Date",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    readOnly: true,
                    onTap: () async {
                      DateTime? pickedDate = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(
                          2000,
                        ),
                        lastDate: DateTime(
                          2101,
                        ),
                      );
                      if (pickedDate != null) {
                        String formattedDate =
                            DateFormat('dd-MM-yyyy').format(pickedDate);
                        formattedDate2 =
                            DateFormat('yyyy-MM-dd').format(pickedDate);

                        date1 = DateTime.parse(
                            formattedDate1 + " " + formattedTime1);
                        date2 = DateTime.parse(
                            formattedDate2 + " " + formattedTime2);

                        timeInSecond = date2!.difference(date1!).inSeconds;

                        int temptime = timeInSecond;
                        int h = (temptime / 3600).toInt();
                        temptime = temptime % 3600;
                        int m = (temptime / 60).toInt();
                        temptime = temptime % 60;
                        totalTimeInSecond = formatDuration(h) +
                            ":" +
                            formatDuration(m) +
                            ":" +
                            formatDuration(temptime);

                        setState(() {
                          endDate.text = formattedDate2;
                          totalTime.text = totalTimeInSecond;
                        });
                      } else {
                        print("Date is not selected");
                      }
                    },
                  ),
                  SizedBox(
                    height: 15,
                  ),
                  TextFormField(
                    controller: startTime,
                    validator: (val) {
                      return val!.isEmpty ? "Provide start time" : null;
                    },
                    decoration: InputDecoration(
                      prefixIcon: Padding(
                        padding: EdgeInsets.only(left: 1),
                        child: Icon(Icons.punch_clock_outlined),
                      ),
                      labelText: "Enter Start Time",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    readOnly: true,
                    onTap: () async {
                      TimeOfDay? pickedTime = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.now(),
                      );
                      if (pickedTime != null) {
                        String formattedTime = pickedTime.format(context);
                        formattedTime1 = formatDuration(pickedTime.hour) +
                            ":" +
                            formatDuration(pickedTime.minute) +
                            ":00";

                        date1 = DateTime.parse(
                            formattedDate1 + " " + formattedTime1);

                        date2 = DateTime.parse(
                            formattedDate2 + " " + formattedTime2);

                        timeInSecond = date2!.difference(date1!).inSeconds;

                        int temptime = timeInSecond;
                        int h = (temptime / 3600).toInt();
                        temptime = temptime % 3600;
                        int m = (temptime / 60).toInt();
                        temptime = temptime % 60;
                        totalTimeInSecond = formatDuration(h) +
                            ":" +
                            formatDuration(m) +
                            ":" +
                            formatDuration(temptime);

                        setState(() {
                          startTime.text = formattedTime;
                          totalTime.text = totalTimeInSecond;
                        });
                      } else {
                        print("Time is not selected");
                      }
                    },
                  ),
                  SizedBox(
                    height: 15,
                  ),
                  TextFormField(
                    controller: endTime,
                    validator: (val) {
                      return val!.isEmpty ? "Provide end time" : null;
                    },
                    decoration: InputDecoration(
                      prefixIcon: Padding(
                        padding: EdgeInsets.only(left: 1),
                        child: Icon(Icons.punch_clock_outlined),
                      ),
                      labelText: "Enter End Time",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    readOnly: true,
                    onTap: () async {
                      TimeOfDay? pickedTime = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.now(),
                      );
                      if (pickedTime != null) {
                        String formattedTime = pickedTime.format(context);
                        formattedTime2 = formatDuration(pickedTime.hour) +
                            ":" +
                            formatDuration(pickedTime.minute) +
                            ":00";
                        date1 = DateTime.parse(
                            formattedDate1 + " " + formattedTime1);

                        date2 = DateTime.parse(
                            formattedDate2 + " " + formattedTime2);

                        timeInSecond = date2!.difference(date1!).inSeconds;

                        int temptime = timeInSecond;
                        int h = (temptime / 3600).toInt();
                        temptime = temptime % 3600;
                        int m = (temptime / 60).toInt();
                        temptime = temptime % 60;
                        totalTimeInSecond = formatDuration(h) +
                            ":" +
                            formatDuration(m) +
                            ":" +
                            formatDuration(temptime);

                        setState(() {
                          endTime.text = formattedTime;
                          totalTime.text = totalTimeInSecond;
                        });
                      } else {
                        print("Time is not selected");
                      }
                    },
                  ),
                  SizedBox(
                    height: 15,
                  ),
                  TextFormField(
                    keyboardType: TextInputType.number,
                    controller: totalTime,
                    validator: (val) {
                      return val!.isEmpty ? "Provide total time" : null;
                    },
                    decoration: InputDecoration(
                      prefixIcon: Padding(
                        padding: EdgeInsets.only(left: 1),
                        child: Icon(Icons.punch_clock_outlined),
                      ),
                      labelText: "Total Time",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 15,
                  ),
                  TextFormField(
                    keyboardType: TextInputType.number,
                    controller: totalMarks,
                    validator: (val) {
                      return val!.isEmpty ? "Provide mark" : null;
                    },
                    decoration: InputDecoration(
                      prefixIcon: Padding(
                        padding: EdgeInsets.only(left: 1),
                        child: Icon(Icons.numbers),
                      ),
                      labelText: "Total Marks",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 15,
                  ),
                  TextFormField(
                    keyboardType: TextInputType.number,
                    controller: marks_per_question,
                    validator: (val) {
                      return val!.isEmpty ? "Provide per question mark" : null;
                    },
                    decoration: InputDecoration(
                      prefixIcon: Padding(
                        padding: EdgeInsets.only(left: 1),
                        child: Icon(Icons.numbers),
                      ),
                      labelText: "Marks Per Questions",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 15,
                  ),
                  GestureDetector(
                    onTap: () {
                      examValid();
                    },
                    child: Container(
                      alignment: Alignment.center,
                      width: MediaQuery.of(context).size.width,
                      padding: EdgeInsets.symmetric(vertical: 15),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                          gradient: LinearGradient(colors: [
                            const Color(0xff007EF4),
                            const Color(0xff2A75BC),
                          ])),
                      child: Text(
                        "Create Exam",
                        style: TextStyle(
                          fontSize: 17,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 15,
                  ),
                ],
              ),
            ),
          )),
    );
  }
}
