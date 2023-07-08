import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:test_app/pages/homePage.dart';
import 'package:test_app/pages/updateProfile.dart';

import '../util/loadingPage.dart';
import '../util/url.dart ';
import 'package:http/http.dart' as http;
import 'package:crypto/crypto.dart';

class EditProfile extends StatefulWidget {
  const EditProfile({Key? key}) : super(key: key);

  @override
  State<EditProfile> createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  //**From Key to validate the update form fields
  final formkey = GlobalKey<FormState>(); //for email, name,dept,batch
  final newpasswordkey = GlobalKey<FormState>(); //for password
  final oldpasswordkey = GlobalKey<FormState>(); //for password

//**This variables are used to create the department dropdown
  List<String> departmentlist = [];
  String? departmentname;
  List<String> dept_id_list = [];
  String DeptId = "";
  bool incorrectpassvisible = false;

//**This variables are used to create the batch dropdown
  List<String> batchlist = [];
  String? batchname;
  List<String> batch_id_list = [];
  late String BatchId;

//**this variables are used for store SsharedPreference Data
  late SharedPreferences sp;
  String name = "";
  String email = "";
  String roll = "";
  String image = "";
  String dept = "";
  String batch = "";
  String dept_id = "";
  String pass = "";

//**this controlers are used to take value from text filed to update profile
  TextEditingController newName = new TextEditingController();
  TextEditingController newEmail = new TextEditingController();
  TextEditingController newDept = new TextEditingController();
  TextEditingController newBatch = new TextEditingController();
  TextEditingController newPassword = new TextEditingController();
  TextEditingController oldPassword = new TextEditingController();
  TextEditingController confirmPassword = new TextEditingController();

//**This is a SharedPreference function to get the data
  Future getData() async {
    sp = await SharedPreferences.getInstance();

    setState(() {
      name = sp.getString('name') ?? "";
      roll = sp.getString('roll') ?? "";
      email = sp.getString('email') ?? "";
      image = sp.getString('image') ?? "";
      dept = sp.getString('dept') ?? "";
      dept_id = sp.getString('dept_id') ?? "";
      batch = sp.getString('batch') ?? "";
      pass = sp.getString('pass') ?? "";
      print(pass);
    });

    // print(generateMd5(oldPassword.text));
  }

//**this function is used to load the image in the side bar from sharedprefernce
  setImage() {
    if (image != "") {
      return CircleAvatar(
        backgroundImage: NetworkImage(
          MyUrl.imageurl + image,
          scale: 50,
        ),
      );
    } else {
      return CircleAvatar(
        backgroundColor: Colors.white,
        child: CircularProgressIndicator(color: Colors.blue),
      );
    }
  }

//**this function is used for checking new password validation and update password
  validateNewPassword() {
    if (newpasswordkey.currentState!.validate()) {
      Navigator.pop(context);
      updatePassword();
    }
  }

//**Function to covert text to MD5 to match old password */
  String generateMd5(String input) {
    return md5.convert(utf8.encode(input)).toString();
  }

//**this function is used for checking new password validation and update password
  validateOldPassword() {
    if (oldpasswordkey.currentState!.validate()) {
      if (pass.toString() == generateMd5(oldPassword.text)) {
        setState(() {
          incorrectpassvisible = false;
        });
        Navigator.pop(context);
        newPassDialog();
      } else if (pass != generateMd5(oldPassword.text)) {
        setState(() {
          incorrectpassvisible = true;
        });
      }
    }
  }

//**this funtion is used for sending new password in DB using updatepassword.php API
  Future updatePassword() async {
    Map data = {
      'roll': roll,
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
      // sp = await SharedPreferences.getInstance();
      setState(() {
        sp.setString('pass', generateMd5(confirmPassword.text));
        confirmPassword.clear();
      });
      // pass = sp.getString('pass') ?? "";
      Navigator.pop(context);
      Navigator.pop(context);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (contex) => HomePage(),
        ),
      );
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
              key: newpasswordkey,
              child: Container(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: newPassword,
                      obscureText: true,
                      validator: (val) {
                        return val!.isEmpty || val.length < 3
                            ? "Pasword must be minimum 4 digit"
                            : null;
                      },
                      decoration: InputDecoration(
                        // hintText: 'Enter New Password',
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
                        // hintText: 'Confirm Password',
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
                style: TextButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.red,
                  elevation: 3,
                  shadowColor: Colors.red,
                  minimumSize: Size(67, 20),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: () {
                  incorrectpassvisible = false;
                  Navigator.pop(contex);
                },
                child: Text(
                  "Cancel",
                  style: TextStyle(
                    color: Color.fromARGB(255, 255, 255, 255),
                    fontFamily: 'Ubuntu',
                    fontSize: 15,
                  ),
                ),
              ),
              TextButton(
                style: TextButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Color.fromARGB(255, 1, 113, 179),
                  elevation: 3,
                  shadowColor: Color.fromARGB(211, 0, 149, 255),
                  minimumSize: Size(67, 20),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: () {
                  validateNewPassword();
                  newPassword.clear();
                  // confirmPassword.clear();
                },
                child: Text(
                  "Submit",
                  style: TextStyle(
                    color: Color.fromARGB(255, 255, 255, 255),
                    fontFamily: 'Ubuntu',
                    fontSize: 15,
                  ),
                ),
              ),
            ],
          ));

//**Alert box for entering old password to go to new password alert dialog
  oldPassDialog() {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return StatefulBuilder(builder: (context, setInternalState) {
            return AlertDialog(
              title: Text(
                "Enter old password",
                style: TextStyle(fontSize: 17),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              content: Form(
                key: oldpasswordkey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: oldPassword,
                      obscureText: true,
                      validator: (val) {
                        return val!.isEmpty || val.length < 3
                            ? "Pasword must be minimum 4 digit"
                            : null;
                      },
                      decoration: InputDecoration(
                        hintText: 'Enter old password',
                        prefixIcon: Padding(
                          padding: EdgeInsets.only(
                              left: 1), // add padding to adjust icon
                          child: Icon(Icons.lock_outline),
                        ),
                        labelText: "Old password",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      autofocus: true,
                      toolbarOptions: ToolbarOptions(
                          copy: true, paste: true, cut: true, selectAll: true),
                    ),
                    Visibility(
                      visible: incorrectpassvisible,
                      child: Container(
                        alignment: Alignment.centerLeft,
                        padding: EdgeInsets.only(left: 15),
                        child: Text(
                          "Incorrect Password",
                          style: TextStyle(color: Colors.redAccent),
                        ),
                      ),
                    )
                  ],
                ),
              ),
              actions: [
                TextButton(
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Colors.red,
                    elevation: 3,
                    shadowColor: Colors.red,
                    minimumSize: Size(67, 20),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: () {
                    setState(() {
                      oldPassword.clear();
                      incorrectpassvisible = false;
                    });
                    Navigator.pop(context);
                  },
                  child: Text(
                    "Cancel",
                    style: TextStyle(
                      color: Color.fromARGB(255, 255, 255, 255),
                      fontFamily: 'Ubuntu',
                      fontSize: 15,
                    ),
                  ),
                ),
                TextButton(
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Color.fromARGB(255, 1, 113, 179),
                    elevation: 3,
                    shadowColor: Color.fromARGB(211, 0, 149, 255),
                    minimumSize: Size(67, 20),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: () {
                    setInternalState(() {
                      validateOldPassword();
                    });
                  },
                  child: Text(
                    "Submit",
                    style: TextStyle(
                      color: Color.fromARGB(255, 255, 255, 255),
                      fontFamily: 'Ubuntu',
                      fontSize: 15,
                    ),
                  ),
                ),
              ],
            );
          });
        });
  }

  @override
  void initState() {
    super.initState();
    getData();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: ((context) => HomePage()),
          ),
        );
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            "Edit Profile",
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          leading: GestureDetector(
              onTap: () {
                Navigator.pushReplacement(context,
                    MaterialPageRoute(builder: ((context) => HomePage())));
              },
              child: Icon(Icons.home)),
        ),
        body: Container(
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 50,
                  ),
                  Container(
                    height: 200,
                    width: 200,
                    decoration: BoxDecoration(
                      color: Color.fromARGB(0, 0, 0, 0),
                      borderRadius: BorderRadius.all(
                        Radius.circular(100),
                      ),
                    ),
                    child: setImage(),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Container(
                    height: 50,
                    width: MediaQuery.of(context).size.width,
                    margin: EdgeInsets.only(right: 17, left: 17),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.lightBlue),
                      borderRadius: BorderRadius.all(
                        Radius.circular(8),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 10,
                        ),
                        Text(
                          "Name :  ",
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 17,
                          ),
                        ),
                        Text(
                          name,
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 17,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Container(
                    height: 50,
                    width: MediaQuery.of(context).size.width,
                    margin: EdgeInsets.only(right: 17, left: 17),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.lightBlue),
                      borderRadius: BorderRadius.all(
                        Radius.circular(8),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 10,
                        ),
                        Text(
                          "Roll :  ",
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 17,
                          ),
                        ),
                        Text(
                          roll,
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 17,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Container(
                    height: 50,
                    width: MediaQuery.of(context).size.width,
                    margin: EdgeInsets.only(right: 17, left: 17),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.lightBlue),
                      borderRadius: BorderRadius.all(
                        Radius.circular(8),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 10,
                        ),
                        Text(
                          "Department :  ",
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 17,
                          ),
                        ),
                        Text(
                          dept,
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 17,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Container(
                    height: 50,
                    width: MediaQuery.of(context).size.width,
                    margin: EdgeInsets.only(right: 17, left: 17),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.lightBlue),
                      borderRadius: BorderRadius.all(
                        Radius.circular(8),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 10,
                        ),
                        Text(
                          "Batch :  ",
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 17,
                          ),
                        ),
                        Text(
                          batch,
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 17,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Container(
                    height: 50,
                    width: MediaQuery.of(context).size.width,
                    margin: EdgeInsets.only(right: 17, left: 17),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.lightBlue),
                      borderRadius: BorderRadius.all(
                        Radius.circular(8),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 10,
                        ),
                        Text(
                          "Email :  ",
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 17,
                          ),
                        ),
                        Text(
                          email,
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 17,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  InkWell(
                    onTap: () {
                      showModalBottomSheet(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.vertical(
                              top: Radius.circular(20),
                            ),
                          ),
                          context: context,
                          builder: (BuildContext context) {
                            return Container(
                              height: 200,
                              decoration: BoxDecoration(
                                  color: Color.fromARGB(255, 255, 255, 255),
                                  borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(20),
                                    topRight: Radius.circular(20),
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Color.fromARGB(255, 54, 127, 244),
                                      blurRadius: 5, // soften the shadow
                                      spreadRadius: 0, //extend the shadow
                                      offset: Offset(
                                        0, // Move to right 10  horizontally
                                        -3.0, // Move to
                                      ),
                                    )
                                  ]),
                              child: Column(
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceAround,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.all(15),
                                        child: Text(
                                          "Edit Profile",
                                          style: TextStyle(
                                            color: Colors.black,
                                            fontWeight: FontWeight.bold,
                                            fontFamily: 'Ubuntu',
                                            fontSize: 17,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(
                                    height: 25,
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      Column(
                                        children: [
                                          GestureDetector(
                                            onTap: () {
                                              Navigator.pop(context);
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      EditProfile1(),
                                                ),
                                              );
                                            },
                                            child: CircleAvatar(
                                              radius: 30,
                                              backgroundColor: Color.fromARGB(
                                                  238, 120, 184, 233),
                                              child: Icon(
                                                size: 21,
                                                Icons.edit,
                                                color: Color.fromARGB(
                                                    255, 1, 5, 16),
                                              ),
                                            ),
                                          ),
                                          SizedBox(
                                            height: 10,
                                          ),
                                          Text(
                                            "Edit Profile",
                                            style: TextStyle(
                                              color: Color.fromARGB(
                                                  163, 0, 112, 209),
                                              fontWeight: FontWeight.w600,
                                              fontFamily: 'Ubuntu',
                                            ),
                                          )
                                        ],
                                      ),
                                      Column(
                                        children: [
                                          GestureDetector(
                                            onTap: () {
                                              Navigator.pop(context);
                                              oldPassDialog();
                                            },
                                            child: CircleAvatar(
                                              radius: 30,
                                              backgroundColor: Color.fromARGB(
                                                  238, 120, 184, 233),
                                              child: Icon(
                                                size: 21,
                                                Icons.lock,
                                                color: Color.fromARGB(
                                                    255, 1, 5, 16),
                                              ),
                                            ),
                                          ),
                                          SizedBox(
                                            height: 10,
                                          ),
                                          Text(
                                            "Change Password",
                                            style: TextStyle(
                                              color: Color.fromARGB(
                                                  163, 0, 112, 209),
                                              fontWeight: FontWeight.w600,
                                              fontFamily: 'Ubuntu',
                                            ),
                                          )
                                        ],
                                      ),
                                    ],
                                  )
                                ],
                              ),
                            );
                          });
                    },
                    child: Container(
                      height: 50,
                      width: 120,
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        borderRadius: BorderRadius.all(
                          Radius.circular(8),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Edit",
                            style: TextStyle(
                              color: Color.fromARGB(255, 255, 255, 255),
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          Icon(
                            Icons.edit,
                            size: 23,
                            color: Colors.white,
                          ),
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
