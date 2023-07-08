import 'dart:convert';
import 'dart:ui';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/services.dart';
import 'package:flutter/services.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:test_app/pages/forgetPassword.dart';
import 'package:test_app/pages/homePage.dart';
import 'package:test_app/pages/signup.dart';
import 'package:test_app/pages/super_adminPage.dart';
import 'package:test_app/util/loadingPage.dart';
import '../util/url.dart ';
import 'package:http/http.dart' as http;

import 'teacherHomePage.dart';

class LogIn extends StatefulWidget {
  const LogIn({Key? key}) : super(key: key);

  @override
  State<LogIn> createState() => _LogInState();
}

class _LogInState extends State<LogIn> {
  // final _scaffoldKey = GlobalKey<ScaffoldMessengerState>();
  late SharedPreferences sp;
  int tid = 0;
  String tname = "";
  String tdept = "";
  String tdeptname = "";
//**From Key to validate the student login form fields
  final formkey = GlobalKey<FormState>();
  final formkey1 = GlobalKey<FormState>();

//**TextEditingController is used to get the text from form feild
  TextEditingController emailTextEditingController =
      new TextEditingController();
  TextEditingController passWordTextEditingController =
      new TextEditingController();
  TextEditingController adminEmailTextEditingController =
      new TextEditingController();
  TextEditingController adminPassWordTextEditingController =
      new TextEditingController();

  //**This variables are used to change the login screen between Teacher and Student
  bool userClicked = true;
  bool adminClicked = false;
  bool _isObscure = true;

//**This function is used to login to home page from student login
  login() {
    if (userClicked == true) {
      if (formkey.currentState!.validate()) {
        getLoginStatus();
      }
    }
  }

//**This function is used to login to home page from admin login
  adminLogin() {
    if (adminClicked == true) {
      if (formkey1.currentState!.validate()) {
        getAdminLoginStatus();
      }
    }
  }

//**This function is used to go to SignUp Page
  register() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => SignUp(),
      ),
    );
  }

// **!Function to check internet connectivity
  checkNetworkSnackBar() async {
    final connection = Connectivity().checkConnectivity();
    final connectionState = connection != ConnectionState.none;
    final msg = connectionState
        ? "You have ${connectionState.toString()} connection"
        : "You have no internet";
    final color = connectionState ? Colors.green : Colors.red;
    final snackBar = SnackBar(
      content: Text(msg),
      backgroundColor: color,
      duration: Duration(seconds: 2),
    );
    await ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

//**This function is used to get the Data from DataBase for Student Login
  Future getLoginStatus() async {
    Map data = {
      'email': emailTextEditingController.text.toString(),
      'pass': passWordTextEditingController.text.toString(),
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
            MyUrl.suburl + "student_login.php",
          ),
          body: data);
      var jsondata = jsonDecode(response.body);
      if (jsondata['status'] == "true") {
        sp = await SharedPreferences.getInstance();
        sp.setString('user_id', jsondata['user_id'].toString());
        sp.setString('name', jsondata['sname'].toString());
        sp.setString('email', jsondata['email'].toString());
        sp.setString('roll', jsondata['roll'].toString());
        sp.setString('image', jsondata['image'].toString());
        sp.setString('dept', jsondata['dept'].toString());
        sp.setString('batch', jsondata['batch'].toString());
        sp.setString('dept_id', jsondata['dept_id'].toString());
        sp.setString('batch_id', jsondata['batch_id'].toString());
        sp.setString('pass', jsondata['pass'].toString());
        print(jsondata['batch_id'].toString());

        Navigator.pop(context);

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => HomePage(),
          ),
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

//**This function is used to get the Data from DataBase for Admin Login
  Future getAdminLoginStatus() async {
    Map data = {
      'email': adminEmailTextEditingController.text.toString(),
      'pass': adminPassWordTextEditingController.text.toString(),
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
            MyUrl.suburl + "admin_login.php",
          ),
          body: data);
      var jsondata = jsonDecode(response.body);
      if (jsondata['status'] == "true") {
        sp = await SharedPreferences.getInstance();
        tid = int.parse(jsondata['tid']);
        tname = jsondata['tname'].toString();
        tdept = jsondata['tdept'].toString();
        tdeptname = jsondata['dept_name'].toString();
        sp.setString('tname', jsondata['tname'].toString());
        sp.setString('tid', jsondata['tid'].toString());
        sp.setString('temail', jsondata['temail'].toString());
        sp.setString('tdept', jsondata['tdept'].toString());
        sp.setString('tdeptname', jsondata['dept_name'].toString());

        Navigator.pop(context);

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => AdminPage(tid, tname, tdept, tdeptname),
          ),
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

//***This function shows the Student Login Page
  Widget setStudentLayout() {
    return Form(
      key: formkey,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
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
                  padding:
                      EdgeInsets.only(left: 1), // add padding to adjust icon
                  child: Icon(Icons.person),
                ),
                labelText: "username/email",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              toolbarOptions: ToolbarOptions(
                  copy: true, paste: true, cut: true, selectAll: true),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 30,
            ),
            child: TextFormField(
              validator: (val) {
                return val!.length > 3
                    ? null
                    : "Please Provide 3 digit Password";
              },
              controller: passWordTextEditingController,
              obscureText: _isObscure,
              enableSuggestions: false,
              autocorrect: false,
              textAlign: TextAlign.start,
              decoration: InputDecoration(
                prefixIcon: Padding(
                  padding:
                      EdgeInsets.only(left: 1), // add padding to adjust icon
                  child: Icon(Icons.lock),
                ),
                suffixIcon: IconButton(
                  icon: Icon(
                      _isObscure ? Icons.visibility_off : Icons.visibility),
                  onPressed: () {
                    setState(() {
                      _isObscure = !_isObscure;
                    });
                  },
                  color: Colors.grey,
                ),
                labelText: "password",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              toolbarOptions: ToolbarOptions(
                  copy: true, paste: true, cut: true, selectAll: true),
            ),
          ),
          SizedBox(
            height: 8,
          ),
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ForgetPassword(),
                ),
              );
              emailTextEditingController.clear();
              passWordTextEditingController.clear();
            },
            child: Container(
              alignment: Alignment.centerRight,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 30, vertical: 8),
                child: Text(
                  "Forget Password?",
                  style: TextStyle(
                    color: Color.fromARGB(255, 0, 114, 167),
                    decoration: TextDecoration.underline,
                    fontSize: 15,
                  ),
                ),
              ),
            ),
          ),
          SizedBox(
            height: 8,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
            child: GestureDetector(
              onTap: () {
                login();
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
                  "Login",
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
                "Don't have a account?",
                style: TextStyle(
                  fontSize: 15,
                  color: Color.fromARGB(255, 11, 9, 9),
                ),
              ),
              GestureDetector(
                onTap: () {
                  register();
                },
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 5, vertical: 8),
                  child: Text(
                    "Register Now",
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
    );
  }

//**This function shows the Admin Login Page
  Widget setAdminLayout() {
    return Form(
      key: formkey1,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
            child: TextFormField(
              validator: (val) {
                return RegExp(
                            r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                        .hasMatch(val!)
                    ? null
                    : "Please Provide Valid Email";
              },
              controller: adminEmailTextEditingController,
              textAlign: TextAlign.start,
              decoration: InputDecoration(
                prefixIcon: Padding(
                  padding:
                      EdgeInsets.only(left: 1), // add padding to adjust icon
                  child: Icon(Icons.person),
                ),
                labelText: "username/email",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              toolbarOptions: ToolbarOptions(
                  copy: true, paste: true, cut: true, selectAll: true),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 30,
            ),
            child: TextFormField(
              validator: (val) {
                return val!.length > 3
                    ? null
                    : "Please Provide 3 digit Password";
              },
              controller: adminPassWordTextEditingController,
              obscureText: _isObscure,
              enableSuggestions: false,
              autocorrect: false,
              textAlign: TextAlign.start,
              decoration: InputDecoration(
                prefixIcon: Padding(
                  padding:
                      EdgeInsets.only(left: 1), // add padding to adjust icon
                  child: Icon(Icons.lock),
                ),
                suffixIcon: IconButton(
                  icon: Icon(
                      _isObscure ? Icons.visibility_off : Icons.visibility),
                  onPressed: () {
                    setState(() {
                      _isObscure = !_isObscure;
                    });
                  },
                  color: Colors.grey,
                ),
                labelText: "password",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              toolbarOptions: ToolbarOptions(
                  copy: true, paste: true, cut: true, selectAll: true),
            ),
          ),
          SizedBox(
            height: 8,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
            child: GestureDetector(
              onTap: () {
                adminLogin();
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
                  "Login",
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
        ],
      ),
    );
  }

// // !Init state
//   @override
//   void initState() {
//     super.initState();
//     WidgetsBinding.instance.addPostFrameCallback((_) => _scaffoldKey
//         .currentState
//         ?.showSnackBar(SnackBar(content: checkNetworkSnackBar())));
//   }

  // @override
  // void dispose() {
  //   SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
  //     statusBarColor: Colors.transparent,
  //   ));
  //   super.dispose();
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
        child: SingleChildScrollView(
          child: Container(
            height: MediaQuery.of(context).size.height,
            color: Colors.lightBlue,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Align(
                  alignment: Alignment.topRight,
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (BuildContext context) => SuperAdmin(),
                        ),
                      );
                    },
                    child: Container(
                        height: 35,
                        width: 35,
                        margin: EdgeInsets.only(
                          top: 30,
                          right: 30,
                        ),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: Color.fromARGB(255, 230, 230, 230),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Icon(
                          Icons.person,
                          color: Color.fromARGB(255, 6, 126, 225),
                        )),
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
                Expanded(
                  child: Container(
                    //  height: MediaQuery.of(context).size.height,
                    width: MediaQuery.of(context).size.width,
                    decoration: BoxDecoration(
                      color: Color.fromARGB(255, 255, 252, 252),
                      borderRadius: BorderRadius.only(
                        topRight: Radius.circular(20),
                        topLeft: Radius.circular(20),
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Padding(
                          padding: EdgeInsets.only(top: 10),
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: 20, vertical: 10),
                            child: Row(
                              children: [
                                Expanded(
                                  child: InkWell(
                                    onTap: () {
                                      userClicked = true;
                                      adminClicked = false;
                                      adminEmailTextEditingController.clear();
                                      adminPassWordTextEditingController
                                          .clear();
                                      setState(() {});
                                    },
                                    child: Container(
                                      alignment: Alignment.center,
                                      width: MediaQuery.of(context).size.width,
                                      height: 40,
                                      decoration: BoxDecoration(
                                        color: userClicked
                                            ? Color.fromARGB(255, 251, 15, 117)
                                            : Color.fromARGB(255, 70, 123, 146),
                                        border: Border.all(
                                          color: userClicked == true
                                              ? Color.fromARGB(
                                                  255, 251, 15, 117)
                                              : Color.fromARGB(
                                                  255, 70, 123, 146),
                                          width: 2,
                                        ),
                                        borderRadius: BorderRadius.circular(30),
                                      ),
                                      child: Text(
                                        "Student",
                                        style: TextStyle(
                                          color: userClicked
                                              ? Color.fromARGB(
                                                  255, 255, 255, 255)
                                              : Color.fromARGB(
                                                  255, 255, 255, 255),
                                          fontFamily: 'Roboto',
                                          fontSize: 20,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: 30,
                                ),
                                Expanded(
                                  child: InkWell(
                                    onTap: () {
                                      setState(() {
                                        userClicked = false;
                                        adminClicked = true;
                                        emailTextEditingController.clear();
                                        passWordTextEditingController.clear();
                                      });
                                    },
                                    child: Container(
                                      alignment: Alignment.center,
                                      width: MediaQuery.of(context).size.width,
                                      height: 40,
                                      decoration: BoxDecoration(
                                        color: adminClicked
                                            ? Color.fromARGB(255, 251, 15, 117)
                                            : Color.fromARGB(255, 70, 123, 146),
                                        border: Border.all(
                                          color: adminClicked == true
                                              ? Color.fromARGB(
                                                  255, 251, 15, 117)
                                              : Color.fromARGB(
                                                  255, 70, 123, 146),
                                          width: 2,
                                        ),
                                        borderRadius: BorderRadius.circular(30),
                                      ),
                                      child: Text(
                                        "Teacher",
                                        style: TextStyle(
                                          color: adminClicked
                                              ? Color.fromARGB(
                                                  255, 255, 255, 255)
                                              : Color.fromARGB(
                                                  255, 255, 255, 255),
                                          fontFamily: 'Roboto',
                                          fontSize: 20,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 30,
                        ),
                        userClicked ? setStudentLayout() : setAdminLayout(),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
