import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:test_app/model/teacher_model.dart';
import 'package:test_app/pages/createTeachers.dart';
import 'package:http/http.dart' as http;

import '../util/loadingPage.dart';
import '../util/url.dart ';

class AllTeacher extends StatefulWidget {
  const AllTeacher({super.key});

  @override
  State<AllTeacher> createState() => _AllTeacherState();
}

class _AllTeacherState extends State<AllTeacher> {
  // !!INIT STATE
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      getTeacher();
    });
  }

  //**This variables are used to create the department dropdown
  List<Teacher> teacherlist = [];

  // **Function to get department
  Future getTeacher() async {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return LoadingPage("Loading...");
        });

    try {
      var response = await http.get(
        Uri.http(
          MyUrl.hosturl,
          MyUrl.suburl + "getTeacher.php",
        ),
      );
      var jsondata = jsonDecode(response.body);
      if (jsondata['status'] == "true") {
        Navigator.pop(context);
        teacherlist.clear();
        for (var x in jsondata['data']) {
          setState(
            () {
              Teacher teacher = Teacher(
                int.parse(x['id']),
                x['name'],
                x['dept_name'],
              );
              teacherlist.add(teacher);
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

//**This function is used to remove teacher from DB table
  Future removeTeacher(int id, int index) async {
    Map data = {
      'id': id.toString(),
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
          MyUrl.suburl + "remove_teacher.php",
        ),
        body: data,
      );
      var jsondata = jsonDecode(response.body);
      if (jsondata['status'] == "true") {
        teacherlist.removeAt(index);
        Navigator.pop(context);
        Fluttertoast.showToast(
          msg: jsondata['msg'],
          backgroundColor: Color.fromARGB(255, 43, 162, 216),
          textColor: Colors.white,
        );
      } else {
        Navigator.pop(context);
        Fluttertoast.showToast(
          msg: jsondata['msg'],
          backgroundColor: Color.fromARGB(255, 43, 162, 216),
          textColor: Colors.white,
        );
      }
    } catch (e) {
      Navigator.pop(context);
      Fluttertoast.showToast(
        msg: e.toString(),
        backgroundColor: Color.fromARGB(255, 43, 162, 216),
        textColor: Colors.white,
      );
    }
    setState(() {});
  }

  //**this dialog box is used to take confirmation for deleting teacher
  teacherRemove(int id, int index) => showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          title: Text(
            "Remove Teacher",
            style: TextStyle(
              color: Color.fromARGB(255, 254, 11, 11),
              fontSize: 22,
            ),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          content: Text("Do you want to remove teacher ?"),
          actions: [
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
                backgroundColor: Colors.red,
                elevation: 3,
                shadowColor: Colors.red,
                minimumSize: Size(70, 30),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30)),
              ),
              onPressed: () {
                Navigator.pop(context);
                removeTeacher(teacherlist[index].id, index);
              },
              child: Text(
                "Ok",
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("All Teacher"),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          getTeacher();
        },
        child: ListView.builder(
          itemCount: teacherlist.length,
          itemBuilder: (BuildContext context, int index) {
            return Padding(
              padding:
                  const EdgeInsets.only(top: 4, left: 6, right: 6, bottom: 0),
              child: Card(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
                elevation: 3,
                color: Color.fromARGB(255, 121, 210, 243),
                child: ListTile(
                  leading: Image.asset(
                    "assets/images/man.png",
                    height: 40,
                  ),
                  trailing: GestureDetector(
                    onTap: () {
                      teacherRemove(teacherlist[index].id, index);
                    },
                    child: Icon(
                      Icons.cancel,
                      color: Colors.red,
                      size: 25,
                    ),
                  ),
                  contentPadding:
                      EdgeInsets.only(left: 15, right: 15, top: 5, bottom: 5),
                  title: Text(
                    teacherlist[index].name,
                    style: TextStyle(
                      color: Color.fromARGB(255, 0, 0, 0),
                    ),
                  ),
                  subtitle: Text(
                    teacherlist[index].dept,
                    style: TextStyle(
                      color: Color.fromARGB(255, 0, 0, 0),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: "Add Teacher",
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddNewTeacher(),
            ),
          );
        },
        child: Icon(
          Icons.add_rounded,
          size: 28,
        ),
      ),
    );
  }
}
