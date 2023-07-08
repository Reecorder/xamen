import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:test_app/model/batch_model.dart';
import '../util/loadingPage.dart';
import '../util/url.dart ';

class AddBatch extends StatefulWidget {
  int dept_id = 0;
  AddBatch(this.dept_id);

  @override
  State<AddBatch> createState() => _AddBatchState(dept_id);
}

class _AddBatchState extends State<AddBatch> {
  int dept_id = 0;
  _AddBatchState(this.dept_id);

//**This variables are used to create the batch dropdown
  List<Batch> batchlist = [];

//**TextEditingController is used to get the text from form feild
  TextEditingController batchNameTextEditingController =
      new TextEditingController();

//**From Key to validate the department name
  final formkey = GlobalKey<FormState>();

// **this function is used for get batch coresponding department from DB
  Future getBatch() async {
    Map data = {
      'deptid': dept_id.toString(),
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
            Batch batch = Batch(
              int.parse(x['batch_id']),
              x['batch_name'],
            );
            batchlist.add(batch);
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

//** Function to add Batch
  Future addBatch() async {
    Map data = {
      'batch_name': batchNameTextEditingController.text.toString(),
      'deptid': dept_id.toString(),
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
            MyUrl.suburl + "add_batch.php",
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

//**This function is used for validation check of Batch name
  batchValidator() {
    if (formkey.currentState!.validate()) {
      addBatch().whenComplete(() {
        getBatch();
        batchNameTextEditingController.clear();
      });
    }
  }

// **DialogBox to insert department name
  batchDialog() {
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
                  "Add Batch",
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
                      ? "Enter batch name"
                      : null;
                },
                controller: batchNameTextEditingController,
                textAlign: TextAlign.start,
                decoration: InputDecoration(
                  prefixIcon: Padding(
                    padding: EdgeInsets.only(left: 1),
                    child: Icon(Icons.school),
                  ),
                  labelText: "enter batch",
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
                    batchNameTextEditingController.clear();
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
                    batchValidator();
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

//**This function is used to remove batch from DB table
  Future removeBatch(int id, int index) async {
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
          MyUrl.suburl + "remove_batch.php",
        ),
        body: data,
      );
      var jsondata = jsonDecode(response.body);
      if (jsondata['status'] == "true") {
        batchlist.removeAt(index);
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
  batchRemove(int id, int index) => showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          title: Text(
            "Remove Batch",
            style: TextStyle(
              color: Color.fromARGB(255, 254, 11, 11),
              fontSize: 22,
            ),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          content: Text("Do you want to remove batch ?"),
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
                removeBatch(id, index);
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
      getBatch();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Add Batch"),
        leading: InkWell(
          onTap: () {
            Navigator.pop(context);
          },
          child: Icon(Icons.arrow_back_ios_outlined),
        ),
      ),
      body: ListView.builder(
        itemCount: batchlist.length,
        itemBuilder: (BuildContext context, int index) {
          return Padding(
            padding:
                const EdgeInsets.only(top: 5, left: 6, right: 6, bottom: 0),
            child: Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
              elevation: 3,
              color: Color.fromARGB(255, 89, 217, 228),
              child: ListTile(
                // style: ,
                leading: SvgPicture.asset(
                  "assets/images/office-block-svgrepo-com (1).svg",
                  height: 28,
                ),
                contentPadding:
                    EdgeInsets.only(left: 15, right: 15, top: 5, bottom: 5),
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      batchlist[index].name,
                      style: TextStyle(
                        color: Color.fromARGB(255, 0, 0, 0),
                      ),
                    ),
                  ],
                ),
                trailing: GestureDetector(
                  onTap: () {
                    batchRemove(batchlist[index].id, index);
                  },
                  child: Icon(
                    Icons.delete,
                    color: Colors.red,
                  ),
                ),
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: "Add Batch",
        onPressed: () {
          batchDialog();
        },
        child: Icon(
          Icons.add_rounded,
          size: 30,
        ),
      ),
    );
  }
}
