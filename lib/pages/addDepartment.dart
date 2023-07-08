import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:test_app/model/department_model.dart';
import 'package:test_app/pages/addBatch.dart';
import 'package:test_app/util/loadingPage.dart';
import 'package:http/http.dart' as http;

import '../util/url.dart ';

class AddDepartment extends StatefulWidget {
  const AddDepartment({super.key});

  @override
  State<AddDepartment> createState() => _AddDepartmentState();
}

class _AddDepartmentState extends State<AddDepartment> {
  //**This variables are used to create the department dropdown
  List<Department> departmentlist = [];

//**TextEditingController is used to get the text from form feild
  TextEditingController deptNameTextEditingController =
      new TextEditingController();

//**From Key to validate the department name
  final formkey = GlobalKey<FormState>();

// **Function to get department
  Future getDepartment() async {
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
          MyUrl.suburl + "getdept.php",
        ),
      );
      var jsondata = jsonDecode(response.body);
      if (jsondata['status'] == "true") {
        Navigator.pop(context);
        departmentlist.clear();
        for (var x in jsondata['data']) {
          setState(
            () {
              Department department = Department(
                x['dept_name'],
                int.parse(x['dept_id']),
              );
              departmentlist.add(department);
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

//** Function to add department
  Future addDepartment() async {
    Map data = {
      'dept_name': deptNameTextEditingController.text.toString(),
    };
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return LoadingPage("Please wait...");
        });
    try {
      var response = await http.post(
          Uri.http(
            MyUrl.hosturl,
            MyUrl.suburl + "add_department.php",
          ),
          body: data);
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

//**This function is used to remove dept from DB table
  Future removeDept(int id, int index) async {
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
          MyUrl.suburl + "remove_dept.php",
        ),
        body: data,
      );
      var jsondata = jsonDecode(response.body);
      if (jsondata['status'] == "true") {
        departmentlist.removeAt(index);
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

//**This function is used for validation check of department name
  departmentValidator() {
    if (formkey.currentState!.validate()) {
      addDepartment().whenComplete(() {
        getDepartment();
        deptNameTextEditingController.clear();
      });
    }
  }

// **DialogBox to insert department name
  departmentDialog() {
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Row(
              children: [
                Icon(
                  Icons.school,
                  color: Color.fromARGB(255, 66, 129, 238),
                  size: 30,
                ),
                SizedBox(
                  width: 7,
                ),
                Text(
                  "Add Department",
                  style: TextStyle(
                    color: Color.fromARGB(255, 66, 129, 238),
                    fontSize: 22,
                    fontFamily: 'Ubuntu',
                  ),
                ),
              ],
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            content: Form(
              key: formkey,
              child: TextFormField(
                validator: (val) {
                  return val!.isEmpty || val.length < 2
                      ? "Enter department name"
                      : null;
                },
                controller: deptNameTextEditingController,
                textAlign: TextAlign.start,
                decoration: InputDecoration(
                  prefixIcon: Padding(
                    padding: EdgeInsets.only(left: 1),
                    child: Icon(Icons.school),
                  ),
                  labelText: "enter department",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                toolbarOptions: ToolbarOptions(
                  copy: true,
                  paste: true,
                  cut: true,
                  selectAll: true,
                ),
              ),
            ),
            actions: [
              TextButton(
                style: TextButton.styleFrom(
                  primary: Colors.white,
                  backgroundColor: Color.fromARGB(255, 255, 80, 80),
                  elevation: 1,
                  shadowColor: Color.fromARGB(255, 253, 59, 59),
                  minimumSize: Size(70, 30),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: () {
                  setState(() {
                    deptNameTextEditingController.clear();
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
                  setState(() {
                    departmentValidator();
                  });
                },
                child: Text(
                  "Add",
                  style: TextStyle(
                    color: Color.fromARGB(255, 255, 255, 255),
                    fontFamily: 'Ubuntu',
                    fontSize: 16,
                    // fontWeight: FontWeight.w600
                  ),
                ),
              ),
            ],
          );
        });
  }

//**this dialog box is used to take confirmation for deleting dept
  deptRemove(int id, int index) => showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          title: Text(
            "Remove Department",
            style: TextStyle(
              color: Color.fromARGB(255, 254, 11, 11),
              fontSize: 22,
            ),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          content: Text("Do you want to remove department ?"),
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
                removeDept(id, index);
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

// !!INIT STATE
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      getDepartment();
    });
  }

  @override
  Widget build(BuildContext context) {
    // **Media Quary variable
    var _mediaquary = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: Text("Add Department"),
        leading: InkWell(
          onTap: () {
            Navigator.pop(context);
          },
          child: Icon(Icons.arrow_back_ios_outlined),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          // getDepartment();
        },
        child: ListView.builder(
          itemCount: departmentlist.length,
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
                  leading: SvgPicture.asset(
                    "assets/images/office-block-svgrepo-com.svg",
                    height: 28,
                  ),
                  contentPadding:
                      EdgeInsets.only(left: 25, right: 10, top: 5, bottom: 5),
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        departmentlist[index].name,
                        style: TextStyle(
                          color: Color.fromARGB(255, 0, 0, 0),
                        ),
                      ),
                      Spacer(),
                      TextButton.icon(
                        style: TextButton.styleFrom(
                          primary: Color.fromARGB(255, 25, 44, 253),
                          minimumSize: Size(25, 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          elevation: 1,
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  AddBatch(departmentlist[index].dept_id),
                            ),
                          );
                        },
                        label: Text(
                          "Batch",
                          style: TextStyle(
                            color: Color.fromARGB(255, 213, 215, 218),
                          ),
                        ),
                        icon: Icon(
                          Icons.add_rounded,
                          color: Color.fromARGB(255, 213, 215, 218),
                        ),
                      ),
                      SizedBox(
                        width: 8,
                      ),
                      GestureDetector(
                        onTap: () {
                          deptRemove(departmentlist[index].dept_id, index);
                        },
                        child: Icon(
                          Icons.delete,
                          color: Color.fromARGB(255, 252, 100, 89),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: "Add Department",
        onPressed: () {
          departmentDialog();
        },
        child: Icon(
          Icons.add_rounded,
          size: 28,
        ),
      ),
    );
  }
}
