import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:test_app/pages/super_admin_homePage.dart';
import 'package:test_app/util/loadingPage.dart';

import 'package:http/http.dart' as http;

import '../util/url.dart ';

class SuperAdmin extends StatefulWidget {
  const SuperAdmin({super.key});

  @override
  State<SuperAdmin> createState() => _SuperAdminState();
}

class _SuperAdminState extends State<SuperAdmin> {
  //**From Key to validate the student login form fields
  final formkey = GlobalKey<FormState>();

// **Shared Preference variable
  late SharedPreferences sp;
  String adminName = "";

//**TextEditingController is used to get the text from form feild
  TextEditingController emailTextEditingController =
      new TextEditingController();
  TextEditingController passWordTextEditingController =
      new TextEditingController();

//**This function is used to login to home page from admin login
  superAdminLogin() {
    if (formkey.currentState!.validate()) {
      getAdminLoginStatus();
    }
  }

//**This function is used to get the Data from DataBase for Admin Login
  Future getAdminLoginStatus() async {
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
            MyUrl.suburl + "super_admin_login.php",
          ),
          body: data);
      var jsondata = jsonDecode(response.body);
      if (jsondata['status'] == "true") {
        sp = await SharedPreferences.getInstance();
        adminName = jsondata['Aname'].toString();
        sp.setString('Aname', jsondata['Aname'].toString());
        sp.setString('Aemail', jsondata['Aemail'].toString());

        Navigator.pop(context);

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => SuperAdminHomePage(adminName),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("ADMIN"),
        leading: InkWell(
          onTap: () {
            Navigator.pop(context);
          },
          child: Icon(Icons.arrow_back_ios_outlined),
        ),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          RichText(
            textAlign: TextAlign.justify,
            text: TextSpan(
              children: [
                WidgetSpan(
                  alignment: PlaceholderAlignment.middle,
                  child: Icon(
                    Icons.person,
                    color: Color.fromARGB(220, 0, 0, 0),
                  ),
                ),
                TextSpan(
                  text: "ADMIN LOGIN",
                  style: TextStyle(
                    color: Color.fromARGB(230, 0, 0, 0),
                    fontFamily: "OpenSans-SemiBold",
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
          ),
          SingleChildScrollView(
            child: Container(
              margin: EdgeInsets.all(15),
              height: MediaQuery.of(context).size.height * 0.4,
              decoration: BoxDecoration(
                color: Color.fromARGB(255, 255, 255, 255),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.blue),
                boxShadow: [
                  BoxShadow(
                    color: Color.fromARGB(80, 33, 149, 243),
                    offset: Offset(0, 0),
                    spreadRadius: 3,
                    blurRadius: 5,
                  ),
                ],
              ),
              child: Form(
                key: formkey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 30, vertical: 20),
                      child: TextFormField(
                        controller: emailTextEditingController,
                        validator: (val) {
                          return RegExp(
                                      r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                                  .hasMatch(val!)
                              ? null
                              : "Please Provide Valid Email";
                        },
                        // controller: adminEmailTextEditingController,
                        textAlign: TextAlign.start,

                        decoration: InputDecoration(
                          prefixIcon: Padding(
                            padding: EdgeInsets.only(
                                left: 1), // add padding to adjust icon
                            child: Icon(Icons.person),
                          ),
                          labelText: "username/email",
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
                      ),
                      child: TextFormField(
                        controller: passWordTextEditingController,
                        validator: (val) {
                          return val!.length > 3
                              ? null
                              : "Please Provide 3 digit Password";
                        },
                        // controller: adminPassWordTextEditingController,
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
                          labelText: "password",
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
                          superAdminLogin();
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
              ),
            ),
          ),
        ],
      ),
    );
  }
}
