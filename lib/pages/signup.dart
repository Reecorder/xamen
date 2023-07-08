import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:test_app/pages/login.dart';

import '../util/loadingPage.dart';
import '../util/url.dart ';
import 'package:http/http.dart' as http;

import 'homePage.dart';

class SignUp extends StatefulWidget {
  const SignUp({Key? key}) : super(key: key);

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  //!!getdepartment function is called inside INIT state
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      getDepartment();
    });
  }

  //**From Key to validate the form fields
  final formkey = GlobalKey<FormState>();

//**This variables are used to create the department dropdown
  List<String> departmentlist = [];
  String? departmentname;
  bool isdeptvisible = false;
  List<String> dept_id_list = [];
  late String DeptId;

//**This variables are used to create the batch dropdown
  List<String> batchlist = [];
  String? batchname;
  bool isbatchvisible = false;
  List<String> batch_id_list = [];
  late String BatchId;

//**TextEditingController is used to get the text from form feild
  TextEditingController userNameTextEditingController =
      new TextEditingController();
  TextEditingController emailTextEditingController =
      new TextEditingController();
  TextEditingController passWordTextEditingController =
      new TextEditingController();
  TextEditingController re_passWordTextEditingController =
      new TextEditingController();
  TextEditingController rollTextEdittingController =
      new TextEditingController();

//**This function is used to check validation then redirect to login page
  signup() {
    if (formkey.currentState!.validate() &&
        departmentname != null &&
        batchname != null) {
      getSignupStatus();
    }
    if (departmentname == null) isdeptvisible = true;
    setState(() {});
    if (batchname == null) isbatchvisible = true;
    setState(() {});
  }

//**This function is used to go to Login Page
  loginpage() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => LogIn(),
      ),
    );
  }

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

// **this function is used for get batch coresponding department from DB
  Future getBatch() async {
    getDeptId();
    Map data = {
      'deptid': DeptId,
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

//**this function is used for signUp (Incomplete)
  Future getSignupStatus() async {
    Map data = {
      'name': userNameTextEditingController.text.toString(),
      'roll': rollTextEdittingController.text.toString(),
      'email': emailTextEditingController.text.toString(),
      'pass': passWordTextEditingController.text.toString(),
      'dept_id': DeptId,
      'batch_id': BatchId,
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
            MyUrl.suburl + "student_signup.php",
          ),
          body: data);
      var jsondata = jsonDecode(response.body);
      if (jsondata['status'] == "true") {
        Navigator.pop(context);
        loginpage();
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

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: WillPopScope(
        onWillPop: () => loginpage(),
        child: Scaffold(
          body: Material(
            child: Container(
              color: Colors.lightBlue,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: 20,
                    ),
                    GestureDetector(
                      onTap: () => Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => LogIn(),
                        ),
                      ),
                      child: Container(
                        alignment: Alignment.topLeft,
                        padding: EdgeInsets.only(left: 10),
                        child: SafeArea(
                          child: Icon(
                            Icons.arrow_back_ios_outlined,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    Image.asset(
                      'assets/images/logo-removebg.png',
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Hey",
                          style: TextStyle(
                            fontFamily: 'Ubuntu-Regular',
                            fontWeight: FontWeight.w100,
                            fontSize: 28,
                            color: Color.fromARGB(255, 246, 251, 255),
                          ),
                        ),
                        SizedBox(
                          width: 8,
                        ),
                        Text(
                          "Welcome",
                          style: TextStyle(
                            fontFamily: 'Roboto',
                            fontWeight: FontWeight.bold,
                            fontSize: 29,
                            color: Color.fromARGB(255, 255, 255, 255),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Align(
                      alignment: MediaQuery.of(context).viewInsets.bottom != 0
                          ? Alignment.center
                          : Alignment.bottomCenter,
                      child: Form(
                        key: formkey,
                        child: Container(
                          height: MediaQuery.of(context).size.height,
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
                                  "Sigh Up Here",
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
                                    horizontal: 30, vertical: 8),
                                child: TextFormField(
                                  validator: (val) {
                                    return val!.isEmpty
                                        ? "Enter roll number"
                                        : null;
                                  },
                                  controller: rollTextEdittingController,
                                  textAlign: TextAlign.start,
                                  decoration: InputDecoration(
                                    prefixIcon: Padding(
                                      padding: EdgeInsets.only(left: 1),
                                      child: Icon(Icons.numbers),
                                    ),
                                    labelText: "enter university roll",
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
                                    horizontal: 30, vertical: 2),
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
                                        Icons.book,
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
                                              getBatch();
                                              //getBatch();
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
                                  vertical: 2,
                                ),
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
                                        Icons.book,
                                        color: Colors.grey,
                                      ),
                                      SizedBox(
                                        width: 10,
                                      ),
                                      Expanded(
                                        child: DropdownButton(
                                          value: batchlist.contains(batchname)
                                              ? batchname
                                              : null,
                                          isExpanded: true,
                                          underline: SizedBox(),
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
                                              isbatchvisible = false;
                                              getBatchId();
                                            });
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              Visibility(
                                visible: isbatchvisible ? true : false,
                                child: Container(
                                  alignment: Alignment.centerLeft,
                                  margin: EdgeInsets.only(
                                    left: 40,
                                    bottom: 10,
                                  ),
                                  child: Text(
                                    "Select Batch",
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
                                  vertical: 7,
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
                                          left:
                                              1), // add padding to adjust icon
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
                                          left:
                                              1), // add padding to adjust icon
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
                                    signup();
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
                                      "Sign Up",
                                      style: TextStyle(
                                        fontSize: 17,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: 15,
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    "Already have an account?",
                                    style: TextStyle(
                                      fontSize: 15,
                                      color: Color.fromARGB(255, 11, 9, 9),
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      loginpage();
                                    },
                                    child: Container(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 5, vertical: 8),
                                      child: Text(
                                        "Login Now",
                                        style: TextStyle(
                                          color: Color.fromARGB(255, 0, 0, 0),
                                          fontSize: 16,
                                          decoration: TextDecoration.underline,
                                        ),
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
