import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:test_app/pages/homePage.dart';
import 'package:test_app/pages/login.dart';

import '../util/loadingPage.dart';
import '../util/url.dart ';
import 'package:http/http.dart' as http;

class ForgetPassword extends StatefulWidget {
  const ForgetPassword({Key? key}) : super(key: key);

  @override
  State<ForgetPassword> createState() => _ForgetPasswordState();
}

class _ForgetPasswordState extends State<ForgetPassword> {
  //**this key is used for  email validation
  final formkey = GlobalKey<FormState>();

  //**this key is used for new password validation
  final formkey1 = GlobalKey<FormState>();

//**this key is used for OTP
  final OTP = GlobalKey<FormState>();

//**this variable is used to store otp
  late int otpChecker;

  TextEditingController forgetPassWordTextEditingController =
      new TextEditingController();
  TextEditingController newPassword = new TextEditingController();
  TextEditingController confirmPassword = new TextEditingController();
  TextEditingController otp = new TextEditingController();

//**this function is used for checking email validation and opening alert dialogbox  for enter new password
  retrivePassword() {
    if (formkey.currentState!.validate()) {
      getPassword();
    }
  }

//**this function is used for checking new password validation and update password
  validateNewPassword() {
    if (formkey1.currentState!.validate()) {
      updatePassword();
    }
  }

//**this function is udsed for otp valid checking
  otpValid() {
    if (OTP.currentState!.validate()) {
      newPassDialog();
    }
  }

//**this funtion is used for checking roll form DB using forget_password_otp.php API
  Future getPassword() async {
    Map data = {
      'roll': forgetPassWordTextEditingController.text.toString(),
    };
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return LoadingPage("Loading...");
        });
    var response = await http.post(
        Uri.http(
          MyUrl.hosturl,
          MyUrl.suburl + "forgot_passwprd_otp.php",
        ),
        body: data);
    var jsondata = jsonDecode(response.body);
    if (jsondata['status'] == "true") {
      Navigator.pop(context);
      // Navigator.pop(context);
      otpChecker = jsondata['otp'];
      otp.clear();
      otpDialog();
    } else {
      Navigator.pop(context);
      Fluttertoast.showToast(
        msg: jsondata['msg'],
        backgroundColor: Colors.blueAccent,
        textColor: Colors.white,
      );
    }
  }

//**this funtion is used for sending new password in DB using updatepassword.php API
  Future updatePassword() async {
    Map data = {
      'roll': forgetPassWordTextEditingController.text,
      'password': confirmPassword.text,
    };
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return LoadingPage("Loading...");
        });
    var response = await http.post(
        Uri.http(
          MyUrl.hosturl,
          MyUrl.suburl + "updatepassword.php",
        ),
        body: data);
    var jsondata = jsonDecode(response.body);
    if (jsondata['status'] == "true") {
      Navigator.pop(context);
      Navigator.pop(context);
      Navigator.pop(context);
      // Navigator.push(context, MaterialPageRoute(builder: (contex) => LogIn()));
      Fluttertoast.showToast(
        msg: jsondata['msg'],
        backgroundColor: Colors.blueAccent,
        textColor: Colors.white,
      );
    } else {
      Navigator.pop(context);
      Fluttertoast.showToast(
        msg: jsondata['msg'],
        backgroundColor: Colors.blueAccent,
        textColor: Colors.white,
      );
    }
  }

//**otp dialog box for entering otp
  otpDialog() => showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
            title: Text("enter OTP"),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            content: Form(
              key: OTP,
              child: Container(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: otp,
                      validator: (val) {
                        if (val!.isEmpty) {
                          return "Enter OTP";
                        } else if (int.parse(otp.text) != otpChecker) {
                          return "OTP Invalid";
                        }
                      },
                      decoration: InputDecoration(
                        hintText: 'Enter OTP',
                        prefixIcon: Padding(
                          padding: EdgeInsets.only(
                              left: 1), // add padding to adjust icon
                          child: Icon(Icons.numbers),
                        ),
                        labelText: "OTP",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      autofocus: true,
                      toolbarOptions: ToolbarOptions(
                          copy: true, paste: true, cut: true, selectAll: true),
                    )
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  otp.clear();
                  Navigator.pop(context);
                },
                child: Text(
                  "Cancel",
                  style: TextStyle(
                    color: Colors.red,
                  ),
                ),
              ),
              TextButton(
                  onPressed: () {
                    newPassword.clear();
                    confirmPassword.clear();
                    otpValid();
                  },
                  child: Text("Submit"))
            ],
          ));

//**Alert dialog box for entering new password and confirm password
  newPassDialog() => showDialog(
      context: context,
      barrierDismissible: false,
      builder: (contex) => AlertDialog(
            title: Text("Enter New Password"),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            content: Form(
              key: formkey1,
              child: Container(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: newPassword,
                      obscureText: true,
                      validator: (val) {
                        return val!.length > 3
                            ? null
                            : "Please Provide 3 digit Password";
                      },
                      decoration: InputDecoration(
                        hintText: 'Enter New Password',
                        prefixIcon: Padding(
                          padding: EdgeInsets.only(
                              left: 1), // add padding to adjust icon
                          child: Icon(Icons.lock_outline),
                        ),
                        labelText: "New Password",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      autofocus: true,
                      toolbarOptions: ToolbarOptions(
                          copy: true, paste: true, cut: true, selectAll: true),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    TextFormField(
                      controller: confirmPassword,
                      obscureText: true,
                      validator: (val) {
                        return val.toString() == newPassword.text
                            ? null
                            : "Password must be same";
                      },
                      decoration: InputDecoration(
                        hintText: 'Confirm Password',
                        prefixIcon: Padding(
                          padding: EdgeInsets.only(
                              left: 1), // add padding to adjust icon
                          child: Icon(Icons.lock_outline),
                        ),
                        labelText: "Confirm Password",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      autofocus: true,
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                  onPressed: () {
                    Navigator.pop(contex);
                    validateNewPassword();
                  },
                  child: Text("Submit"))
            ],
          ));

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        appBar: AppBar(
          title: Text("Forget Password"),
          leading: InkWell(
            onTap: () {
              Navigator.pop(context);
            },
            child: Icon(Icons.arrow_back_ios_outlined),
          ),
        ),
        body: GestureDetector(
          onTap: (() => FocusManager.instance.primaryFocus?.unfocus()),
          child: Container(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(
              color: Colors.lightBlue,
            ),
            child: Column(
              children: [
                Image.asset(
                  'assets/images/logo-removebg.png',
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Forget Password?",
                      style: TextStyle(
                        color: Color.fromARGB(255, 246, 246, 246),
                        fontSize: 20,
                        fontFamily: 'Roboto',
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    Text(
                      "Don't Worry....",
                      style: TextStyle(
                        color: Color.fromARGB(255, 255, 255, 255),
                        fontSize: 20,
                        fontFamily: 'Roboto',
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: 20,
                ),
                Expanded(
                  child: Form(
                    key: formkey,
                    child: Container(
                      height: MediaQuery.of(context).size.height,
                      width: MediaQuery.of(context).size.width,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(30),
                          topRight: Radius.circular(30),
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: 30,
                            ),
                            child: TextFormField(
                              validator: (val) {
                                return val!.isEmpty
                                    ? "Enter roll number"
                                    : null;
                              },
                              controller: forgetPassWordTextEditingController,
                              textAlign: TextAlign.start,
                              decoration: InputDecoration(
                                prefixIcon: Padding(
                                  padding: EdgeInsets.only(
                                      left: 1), // add padding to adjust icon
                                  child: Icon(Icons.numbers),
                                ),
                                labelText: "enter university roll",
                                hintText: "i.e : 34001220100",
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
                                horizontal: 30, vertical: 10),
                            child: GestureDetector(
                              onTap: () {
                                retrivePassword();
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
                                  "Submit",
                                  style: TextStyle(
                                    fontSize: 17,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
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
    );
  }
}
