// import 'dart:html';

import 'dart:convert';
// import 'dart:ffi';
import 'dart:io';
import 'dart:ui';

import 'package:csv/csv.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:test_app/util/loadingPage.dart';

import '../util/url.dart';
import 'package:http/http.dart' as http;

class QuestionUploade extends StatefulWidget {
  const QuestionUploade({Key? key}) : super(key: key);

  @override
  State<QuestionUploade> createState() => _QuestionUploadeState();
}

class _QuestionUploadeState extends State<QuestionUploade> {
  //**This variables are used to create the department dropdown
  List<String> examlist = [];
  String? examname;
  List<String> exam_id_list = [];
  late String ExamId;
  // List x = ['b', 'c', 'a'];
// These are varialbes are used for file upload
  // List<List<dynamic>> fileData = [];
  FilePickerResult? result;
  String filepath = "";
  PlatformFile? pickedfile;

//**This function is used to pick csv file from folder
  filePicker() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['csv'],
      );
      if (result == null) return;

      PlatformFile Pickedfile = result.files.first;
      setState(() {
        filepath = Pickedfile.path!;
      });
      print(filepath);
    } catch (e) {
      print(e);
    }
  }

//this function is used to read csv file date
  // openFile(String filepath) async {
  //   File f = new File(filepath);
  //   print("CSV to List");
  //   final input = f.openRead();
  //   fileData = await input
  //       .transform(utf8.decoder)
  //       .transform(new CsvToListConverter())
  //       .toList();
  //   print(fileData);
  //   setState(() {});
  // }

// **this function is used  for get Exam from DB
  Future getExam() async {
    var dept = await http.get(
      Uri.http(
        MyUrl.hosturl,
        MyUrl.suburl + "getexam.php",
      ),
    );
    var jsondata = jsonDecode(dept.body);
    if (jsondata['status'] == "true") {
      examlist.clear();
      for (var x in jsondata['data']) {
        setState(() {
          examlist.add(x['exam_name']);
          exam_id_list.add(x['id']);
        });
      }
    }
  }

//**this function is used to get Exam Id
  void getExamId() {
    for (int i = 0; i < examlist.length; i++) {
      if (examname == examlist[i]) {
        ExamId = exam_id_list[i];
        break;
      }
    }
    setState(() {});
  }

//** */ this function is used for get batch coresponding departmentId from DB
  Future uploadQns() async {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return LoadingPage("Loading...");
        });

    var request = http.MultipartRequest(
        'POST',
        Uri.parse(
            'http://' + MyUrl.hosturl + '/' + MyUrl.suburl + 'insert_qns.php'));
    request.fields['examId'] = ExamId.toString();
    request.files.add(await http.MultipartFile.fromPath('questions', filepath));
    var response = await request.send();
    var respond = await http.Response.fromStream(response);

    try {
      var jsondata = jsonDecode(respond.body);
      if (jsondata['status'] == "true") {
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
        backgroundColor: Color.fromARGB(255, 21, 111, 180),
        textColor: Colors.white,
      );
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      getExam();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Question Uploade"),
      ),
      body: Center(
          child: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            DropdownButtonFormField(
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.book),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(
                    Radius.circular(15),
                  ),
                ),
              ),
              value: examname,
              isExpanded: true,
              hint: Text(
                "Choose Exam",
              ),
              items: examlist.map((value) {
                return DropdownMenuItem(
                  value: value,
                  child: Text(
                    value,
                  ),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  examname = value.toString();
                  getExamId();
                  print(ExamId);
                });
              },
            ),
            SizedBox(
              height: 20,
            ),
            filepath.isEmpty
                ? ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      primary: Color.fromARGB(105, 236, 213, 213),
                      // minimumSize: Size(190, 150),
                      minimumSize: Size(MediaQuery.of(context).size.width, 60),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: () {
                      setState(() {});
                      filePicker();
                    },
                    child: Text(
                      "Insert File",
                      style: TextStyle(
                        color: Color.fromARGB(168, 0, 0, 0),
                        fontSize: 20,
                      ),
                    ),
                  )
                : Container(
                    height: 60,
                    alignment: Alignment.center,
                    width: MediaQuery.of(context).size.width,
                    decoration: BoxDecoration(
                      color: Color.fromARGB(255, 61, 173, 230),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      "File Inserted",
                      style: TextStyle(
                        color: Color.fromARGB(234, 238, 238, 238),
                        fontSize: 20,
                      ),
                    ),
                  ),
            SizedBox(
              height: 25,
            ),
            SizedBox(
              width: 100,
              child: FloatingActionButton(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                splashColor: Color.fromARGB(255, 3, 214, 165),
                onPressed: () {
                  uploadQns();
                },
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.upload,
                    ),
                    Text(
                      "Upload",
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      )),
    );
  }
}
