import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:test_app/pages/editProfile.dart';

import '../util/loadingPage.dart';
import '../util/url.dart';
import 'package:http/http.dart' as http;

class EditProfile1 extends StatefulWidget {
  const EditProfile1({Key? key}) : super(key: key);

  @override
  State<EditProfile1> createState() => _EditProfile1State();
}

class _EditProfile1State extends State<EditProfile1> {
  // !INIT state
  @override
  void initState() {
    getData();
    super.initState();
  }

  //**From Key to validate the update form fields
  final formkey = GlobalKey<FormState>(); //for email, name,dept,batch

  //**This variables are used to create the department dropdown
  List<String> departmentlist = [];
  String? departmentname;
  List<String> dept_id_list = [];
  String DeptId = "";

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
  String batch_id = "";

//**this controlers are used to take value from text filed to update profile
  TextEditingController newName = new TextEditingController();
  TextEditingController newEmail = new TextEditingController();
  TextEditingController newDept = new TextEditingController();
  TextEditingController newBatch = new TextEditingController();
  TextEditingController newPassword = new TextEditingController();
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
      batch_id = sp.getString('batch_id') ?? "";
    });
    getDepartment();
    newEmail.text = email;
    newName.text = name;
    departmentname = dept;
    batchname = batch;
    BatchId = batch_id;
    DeptId = dept_id;
    print(DeptId);
    // print(BatchId);
  }

  //**this function is used to validate the edit form
  update() {
    if (formkey.currentState!.validate()) {
      // Navigator.pop(context);
      profileUpdate();
    }
  }

//** this function is used  for get department from DB
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
      dept_id_list.clear();
      for (var x in jsondata['data']) {
        setState(() {
          departmentlist.add(x['dept_name']);
          dept_id_list.add(x['dept_id']);
        });
      }
      DeptId = getDeptId();
      print(departmentlist);
      print(DeptId);
      print(BatchId);
      await getBatch();
      print(batchlist);
      print(batch_id_list);
    }
  }

//**this function is used to get Dept Id
  getDeptId() {
    for (int i = 0; i < departmentlist.length; i++) {
      if (departmentname == departmentlist[i]) {
        return dept_id_list[i];
      }
    }
  }

//**this function is used to get Batch Id
  void getBatchId() {
    for (int i = 0; i < batchlist.length; i++) {
      if (batchname == batchlist[i]) {
        BatchId = batch_id_list[i];
        print(BatchId);

        break;
      }
    }
    setState(() {});
  }

// **this function is used for get batch coresponding department from DB
  Future getBatch() async {
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
        batch_id_list.clear();
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

//**this funtion is use to update profile
  Future profileUpdate() async {
    Map data = {
      'roll': roll,
      'name': newName.text,
      'email': newEmail.text,
      'dept': DeptId.toString(),
      'batch': BatchId.toString(),
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
          MyUrl.suburl + "updateprofile.php",
        ),
        body: data,
      );
      var jsondata = jsonDecode(response.body);
      if (jsondata['status'] == "true") {
        sp = await SharedPreferences.getInstance();
        sp.setString('name', newName.text);
        sp.setString('email', newEmail.text);
        sp.setString('dept', departmentname!);
        sp.setString('batch', batchname!);
        name = sp.getString('name') ?? "";
        email = sp.getString('email') ?? "";
        dept = sp.getString('dept') ?? "";
        batch = sp.getString('batch') ?? "";

        Navigator.pop(context);
        Navigator.pop(context);
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: ((context) => EditProfile())));

        Fluttertoast.showToast(
          msg: jsondata['msg'],
          backgroundColor: Color.fromARGB(255, 67, 141, 253),
          textColor: Colors.white,
        );
      } else {
        Navigator.pop(context);
        Fluttertoast.showToast(
          msg: jsondata['msg'],
          backgroundColor: Color.fromARGB(255, 67, 141, 253),
          textColor: Colors.white,
        );
      }
    } catch (e) {
      Fluttertoast.showToast(
        msg: e.toString(),
        backgroundColor: Color.fromARGB(255, 67, 141, 253),
        textColor: Colors.white,
      );
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Update Profile"),
        leading: InkWell(
          onTap: () {
            Navigator.pop(context);
          },
          child: Icon(Icons.arrow_back_ios_outlined),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              height: 25,
            ),
            Container(
              margin: EdgeInsets.all(15),
              child: Form(
                key: formkey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: newName,
                      validator: (val) {
                        return val!.isEmpty || val.length < 2
                            ? "Enter valid Name"
                            : null;
                      },
                      decoration: InputDecoration(
                        hintText: name,
                        hintStyle: TextStyle(
                          fontFamily: 'Ubuntu',
                        ),
                        prefixIcon: Padding(
                          padding: EdgeInsets.only(
                              left: 1), // add padding to adjust icon
                          child: Icon(Icons.person),
                        ),
                        labelText: "Enter Your Name",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      autofocus: true,
                      toolbarOptions: ToolbarOptions(
                        copy: true,
                        paste: true,
                        cut: true,
                        selectAll: true,
                      ),
                    ),
                    SizedBox(
                      height: 30,
                    ),
                    TextFormField(
                      // autovalidateMode: ,
                      controller: newEmail,
                      validator: (val) {
                        return RegExp(
                                    r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                                .hasMatch(val!)
                            ? null
                            : "Please Provide Valid Email";
                      },
                      decoration: InputDecoration(
                        hintText: email,
                        hintStyle: TextStyle(
                          fontFamily: 'Ubuntu',
                        ),
                        prefixIcon: Padding(
                          padding: EdgeInsets.only(
                              left: 1), // add padding to adjust icon
                          child: Icon(Icons.email),
                        ),
                        labelText: "Enter Your Email",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      autofocus: true,
                    ),
                    SizedBox(
                      height: 30,
                    ),
                    DropdownButtonFormField(
                      value: departmentname,
                      isExpanded: true,
                      hint: Text(
                        "select department",
                      ),
                      decoration: InputDecoration(
                        prefixIcon: Padding(
                          padding: EdgeInsets.only(
                              left: 1), // add padding to adjust icon
                          child: Icon(Icons.book),
                        ),
                        labelText: "Select Your Department",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
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
                          DeptId = getDeptId().toString();
                          print(DeptId);
                          getBatch();
                        });
                      },
                    ),
                    SizedBox(
                      height: 30,
                    ),
                    DropdownButtonFormField(
                      value: batchlist.contains(batchname) ? batchname : null,
                      isExpanded: true,
                      hint: Text(
                        "select batch",
                      ),
                      decoration: InputDecoration(
                        prefixIcon: Padding(
                          padding: EdgeInsets.only(
                              left: 1), // add padding to adjust icon
                          child: Icon(Icons.book),
                        ),
                        labelText: "Select Your Batch",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
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
                        });
                      },
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          style: TextButton.styleFrom(
                            primary: Colors.white,
                            backgroundColor: Colors.red,
                            elevation: 3,
                            shadowColor: Colors.red,
                            minimumSize: Size(67, 20),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                          ),
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: Text(
                            "Discard",
                            style: TextStyle(
                              color: Color.fromARGB(255, 255, 255, 255),
                              fontFamily: 'Ubuntu',
                              fontSize: 16,
                            ),
                          ),
                        ),
                        SizedBox(
                          width: 25,
                        ),
                        TextButton(
                          style: TextButton.styleFrom(
                            primary: Colors.white,
                            backgroundColor: Color.fromARGB(255, 16, 186, 0),
                            elevation: 3,
                            shadowColor: Color.fromARGB(211, 0, 149, 255),
                            minimumSize: Size(67, 20),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                          ),
                          onPressed: () {
                            update();
                          },
                          child: Text(
                            "Save",
                            style: TextStyle(
                              color: Color.fromARGB(255, 255, 255, 255),
                              fontFamily: 'Ubuntu',
                              fontSize: 16,
                              // fontWeight: FontWeight.w600
                            ),
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
