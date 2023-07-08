import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:test_app/pages/super_admin_homePage.dart';

import '../util/loadingPage.dart';
import '../util/url.dart ';
import 'package:http/http.dart' as http;

class AddNewTeacher extends StatefulWidget {
  const AddNewTeacher({super.key});

  @override
  State<AddNewTeacher> createState() => _AddNewTeacherState();
}

class _AddNewTeacherState extends State<AddNewTeacher> {
//**TextEditingController is used to get the text from form feild
  TextEditingController userNameTextEditingController =
      new TextEditingController();
  TextEditingController emailTextEditingController =
      new TextEditingController();
  TextEditingController passWordTextEditingController =
      new TextEditingController();
  TextEditingController re_passWordTextEditingController =
      new TextEditingController();

  //**From Key to validate the form fields
  final formkey = GlobalKey<FormState>();

//**This variables are used to create the department dropdown
  List<String> departmentlist = [];
  String? departmentname;
  bool isdeptvisible = false;
  List<String> dept_id_list = [];
  String DeptId = "";

  // **this function is used  to get department(dropdown) from DB
  Future getDepartment() async {
    var dept = await http.get(
      Uri.http(
        MyUrl.hosturl,
        MyUrl.suburl + "getdept.php",
      ),
    );
    var jsondata = jsonDecode(dept.body);
    if (jsondata['status'] == "true") {
      departmentlist.clear();
      for (var x in jsondata['data']) {
        setState(() {
          departmentlist.add(x['dept_name']);
          dept_id_list.add(x['dept_id']);
        });
      }
    }
  }

//**this function is used to get Dept Id
  void getDeptId() {
    for (int i = 0; i < departmentlist.length; i++) {
      if (departmentname == departmentlist[i]) {
        DeptId = dept_id_list[i];
        break;
      }
    }
    setState(() {});
  }

//**this function is used for ADD Teacher
  Future addTeacher() async {
    Map data = {
      'name': userNameTextEditingController.text.toString(),
      'email': emailTextEditingController.text.toString(),
      'pass': passWordTextEditingController.text.toString(),
      'dept_id': DeptId,
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
            MyUrl.suburl + "add_new_teacher.php",
          ),
          body: data);
      var jsondata = jsonDecode(response.body);
      if (jsondata['status'] == "true") {
        Navigator.pop(context);
        userNameTextEditingController.clear();
        emailTextEditingController.clear();
        passWordTextEditingController.clear();
        re_passWordTextEditingController.clear();
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

//**This function is used for  validation then redirect to home page
  teacher() {
    if (formkey.currentState!.validate() && departmentname != null) {
      addTeacher();
    }
    if (departmentname == null) isdeptvisible = true;
    setState(() {});
  }

  //!!getdepartment function is called inside INIT state
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      getDepartment();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Add Teacher"),
        leading: InkWell(
          onTap: () {
            Navigator.pop(context);
          },
          child: Icon(Icons.arrow_back_ios_outlined),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: Form(
              key: formkey,
              child: SingleChildScrollView(
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topRight: Radius.circular(20),
                      topLeft: Radius.circular(20),
                    ),
                  ),
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            "Add new Teacher here",
                            style: TextStyle(
                              color: Colors.lightBlue,
                              fontFamily: 'Roboto',
                              fontSize: 20,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 30,
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 30, vertical: 6),
                          child: Container(
                            padding: EdgeInsets.symmetric(
                                vertical: 5, horizontal: 11),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.school,
                                  color: Colors.grey,
                                ),
                                SizedBox(
                                  width: 10,
                                ),
                                Expanded(
                                  child: DropdownButton(
                                    value: departmentname,
                                    isExpanded: true,
                                    underline: SizedBox(),
                                    hint: Text(
                                      "select department",
                                    ),
                                    items: departmentlist.map((value) {
                                      return DropdownMenuItem(
                                        value: value,
                                        child: Text(
                                          value,
                                        ),
                                      );
                                    }).toList(),
                                    onChanged: (value) {
                                      setState(() {
                                        departmentname = value.toString();
                                        isdeptvisible = false;
                                        getDeptId();
                                        print(DeptId);
                                      });
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Visibility(
                          visible: isdeptvisible ? true : false,
                          child: Container(
                            alignment: Alignment.centerLeft,
                            margin: EdgeInsets.only(
                              left: 40,
                              top: 5,
                            ),
                            child: Text(
                              "Select Department",
                              style: TextStyle(
                                color: Color.fromARGB(255, 207, 20, 20),
                                fontSize: 12.5,
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 30,
                          ),
                          child: TextFormField(
                            validator: (val) {
                              return val!.isEmpty || val.length < 2
                                  ? "Enter User Name"
                                  : null;
                            },
                            controller: userNameTextEditingController,
                            textAlign: TextAlign.start,
                            decoration: InputDecoration(
                              prefixIcon: Padding(
                                padding: EdgeInsets.only(left: 1),
                                child: Icon(Icons.person),
                              ),
                              labelText: "enter name",
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            toolbarOptions: ToolbarOptions(
                                copy: true,
                                paste: true,
                                cut: true,
                                selectAll: true),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 30, vertical: 6),
                          child: TextFormField(
                            validator: (val) {
                              return RegExp(
                                          r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                                      .hasMatch(val!)
                                  ? null
                                  : "Please Provide Valid Email";
                            },
                            controller: emailTextEditingController,
                            textAlign: TextAlign.start,
                            decoration: InputDecoration(
                              prefixIcon: Padding(
                                padding: EdgeInsets.only(left: 1),
                                child: Icon(Icons.email),
                              ),
                              labelText: "email",
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            toolbarOptions: ToolbarOptions(
                                copy: true,
                                paste: true,
                                cut: true,
                                selectAll: true),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 30,
                            vertical: 3,
                          ),
                          child: TextFormField(
                            validator: (val) {
                              return val!.length > 5
                                  ? null
                                  : "Please Provide 6 digit Password";
                            },
                            controller: passWordTextEditingController,
                            obscureText: true,
                            enableSuggestions: false,
                            autocorrect: false,
                            textAlign: TextAlign.start,
                            decoration: InputDecoration(
                              prefixIcon: Padding(
                                padding: EdgeInsets.only(
                                    left: 1), // add padding to adjust icon
                                child: Icon(Icons.lock_open_outlined),
                              ),
                              labelText: "password",
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 30,
                            vertical: 3,
                          ),
                          child: TextFormField(
                            validator: (val) {
                              return val.toString() ==
                                      passWordTextEditingController.text
                                  ? null
                                  : "Password must be same";
                            },
                            controller: re_passWordTextEditingController,
                            obscureText: true,
                            enableSuggestions: false,
                            autocorrect: false,
                            textAlign: TextAlign.start,
                            decoration: InputDecoration(
                              prefixIcon: Padding(
                                padding: EdgeInsets.only(
                                    left: 1), // add padding to adjust icon
                                child: Icon(Icons.lock),
                              ),
                              labelText: "re-enter password",
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            toolbarOptions: ToolbarOptions(
                                copy: true,
                                paste: true,
                                cut: true,
                                selectAll: true),
                          ),
                        ),
                        SizedBox(
                          height: 8,
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 30, vertical: 20),
                          child: GestureDetector(
                            onTap: () {
                              teacher();
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
                                "ADD",
                                style: TextStyle(
                                  fontSize: 17,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ]),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
