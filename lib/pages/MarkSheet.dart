import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:test_app/model/marksheet_model.dart';
import 'package:test_app/pages/MarkSheet.dart';
import 'package:test_app/pages/assignExam.dart';
import 'package:test_app/pages/pdf.dart';
import 'package:test_app/pages/rankPage.dart';
import 'package:test_app/pages/start_exam.dart';
import 'package:test_app/pages/mobile.dart';
import 'package:test_app/util/loadingPage.dart';
import 'package:http/http.dart' as http;

import '../model/exam.dart';
import '../model/question_model.dart';
import '../util/url.dart';

class MarkSheet extends StatefulWidget {
  const MarkSheet({super.key});

  @override
  State<MarkSheet> createState() => _MarkSheetState();
}

class _MarkSheetState extends State<MarkSheet> {
  //**Exam list to show all Exams
  List<MarkSheetModel> marksheetlist = [];

//**SharederPreference variables to store the user_id
  late SharedPreferences sp;
  String user_id = "";

//**SharedPreferrence Function to get the user_id
  Future getUserId() async {
    sp = await SharedPreferences.getInstance();
    user_id = sp.getString('user_id') ?? "";
    setState(() {});
  }

  //**This function is used to get the  all exam details
  Future marksheetList() async {
    Map data = {
      'user_id': user_id,
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
          MyUrl.suburl + "generatepdf.php",
        ),
        body: data,
      );
      var jsondata = jsonDecode(response.body);
      if (jsondata['status'] == "true") {
        Navigator.pop(context);
        marksheetlist.clear();
        for (var x in jsondata['data']) {
          setState(
            () {
              MarkSheetModel marksheet = MarkSheetModel(
                int.parse(x['skiped_qns']),
                int.parse(x['correct_ans']),
                int.parse(x['worng_ans']),
                int.parse(x['full_marks']),
                int.parse(x['marks_per_qns']),
                x['name'],
                x['roll'],
                x['exam_name'],
                x['batch_name'],
                x['start_date'],
                x['end_date'],
                x['start_time'],
                int.parse(x['exam_duration']),
              );
              marksheetlist.add(marksheet);
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

// **PDF generate function

  // Future<void> _createPDF() async {
  //   PdfDocument document = PdfDocument();
  //   final page = document.pages.add();
  //   page.graphics
  //       .drawString("CCLMS", PdfStandardFont(PdfFontFamily.helvetica, 30));

  //   //*Set the page size
  //   document.pageSettings.size = PdfPageSize.a4;

  //   //*Change the page orientation to landscape
  //   document.pageSettings.orientation = PdfPageOrientation.landscape;

  //   PdfGrid grid = PdfGrid();
  //   grid.style = PdfGridStyle(
  //       font: PdfStandardFont(PdfFontFamily.helvetica, 10),
  //       cellPadding: PdfPaddings(left: 3, right: 1, top: 1, bottom: 1));

  //   grid.columns.add(count: 8);
  //   grid.headers.add(1);

  //   PdfGridRow header = grid.headers[0];
  //   header.cells[0].value = 'PC ID';

  //   header.cells[1].value = 'Monitor';
  //   header.cells[2].value = 'Motherboard';
  //   header.cells[3].value = 'CPU';
  //   header.cells[4].value = 'Keyboard';
  //   header.cells[5].value = 'Mouse';
  //   header.cells[6].value = 'Ram';
  //   header.cells[7].value = 'Ups';
  //   for (int i = 0; i < examlist.length; i++) {
  //     PdfGridRow row = grid.rows.add();
  //     row.cells[0].value = examlist[i].name;
  //     row.cells[1].value = examlist[i].startdate;
  //     row.cells[2].value = examlist[i].enddate;
  //     row.cells[3].value = examlist[i].start_time;
  //     row.cells[4].value = examlist[i].end_time;
  //     row.cells[5].value = examlist[i].exam_duration.toString();
  //     row.cells[6].value = examlist[i].mark_per_qns.toString();
  //     row.cells[7].value = examlist[i].full_marks.toString();
  //   }

  //   grid.draw(
  //       page: document.pages.add(), bounds: const Rect.fromLTWH(0, 0, 0, 0));

  //   List<int> bytes = document.saveSync();
  //   document.dispose();

  //   saveAndLaunchFile(bytes, 'PCList.pdf');
  // }

  // ! Init state
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) {
        getUserId().whenComplete(
          () => marksheetList(),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Mark Sheet"),
      ),
      body: ListView.builder(
          itemCount: marksheetlist.length,
          itemBuilder: (BuildContext context, int index) {
            return Padding(
              padding:
                  const EdgeInsets.only(top: 8, bottom: 2, right: 9, left: 9),
              child: ListTile(
                title: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: Colors.purple,
                      child: Text(
                        marksheetlist[index].exam_name[0],
                      ),
                    ),
                    SizedBox(
                      width: 15,
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(marksheetlist[index].exam_name +
                            "   " +
                            marksheetlist[index].startdate),
                        Text(
                          marksheetlist[index].name +
                              "   score: " +
                              (marksheetlist[index].correct_ans *
                                      marksheetlist[index].marks_per_qns)
                                  .toString(),
                          style: TextStyle(
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                    Spacer(),
                    GestureDetector(
                      onTap: () async {
                        final pdf = await PdfApi.generate(marksheetlist, index);
                        PdfApi.openFile(pdf);
                        // print(marksheetlist[index].name);
                      },
                      child: Image.asset(
                        "assets/images/exportpdf-unscreen.gif",
                        height: 29,
                      ),
                    )
                  ],
                ),
                contentPadding:
                    EdgeInsets.only(top: 8, bottom: 8, right: 9, left: 9),
                tileColor: Color.fromARGB(164, 162, 146, 191),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
            );
          }),
    );
  }
}
