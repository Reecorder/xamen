import 'dart:convert';
import 'dart:io';
// import 'dart:js';

import 'package:intl/intl.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:universal_html/js.dart';
import 'dart:typed_data';
import 'package:flutter/services.dart';

class PdfApi {
  // **Variable for timer
  static late int totalTime;

// **Hour,minute,second
  static int h = 0;
  static int m = 0;
  static int second = 0;
  static String timeCounter = "";

  // **Funtion to show total Time in format
  static String formatDuration(int t) {
    if (t < 10) {
      return "0$t";
    } else {
      return t.toString();
    }
  }

// **Function to calculate total time
  static String calculateTime(int t) {
    second = t;
    h = (second ~/ 3600);
    second = second % 3600;
    m = (second ~/ 60);
    second = second % 60;
    timeCounter = formatDuration(h) +
        ":" +
        formatDuration(m) +
        ":" +
        formatDuration(second);

    return timeCounter;
  }

  static Future<File> generate(List txt, int index) async {
    final pdf = Document();

    final ByteData bytes = await rootBundle.load('assets/images/cclms.png');
    final Uint8List byteList = bytes.buffer.asUint8List();

    pdf.addPage(
      MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (context) => <Widget>[
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.only(
                  bottom: 3 * PdfPageFormat.mm,
                ),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: PdfColors.blue,
                      width: 2,
                    ),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
                      "CCLMS",
                      style: TextStyle(
                        fontSize: 40,
                        color: PdfColors.blue,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Spacer(),
                    Image(
                      alignment: Alignment.topRight,
                      MemoryImage(
                        byteList,
                      ),
                      fit: BoxFit.fitHeight,
                      height: 70,
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 1 * PdfPageFormat.cm,
              ),
              Container(
                padding: EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: PdfColors.grey100,
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Name : ",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          txt[index].name,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 0.5 * PdfPageFormat.cm,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Roll : ",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          txt[index].roll,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 0.5 * PdfPageFormat.cm,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Exam Name : ",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          txt[index].exam_name,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 0.5 * PdfPageFormat.cm,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Total Mark : ",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          txt[index].full_marks.toString(),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 0.5 * PdfPageFormat.cm,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Obtain mark : ",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          (txt[index].correct_ans * txt[index].marks_per_qns)
                              .toString(),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 0.5 * PdfPageFormat.cm,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Exam Duration : ",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          calculateTime(txt[index].exam_duration),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 0.5 * PdfPageFormat.cm,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Start Date : ",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          DateFormat("dd-MM-yyyy")
                              .format(DateTime.parse(txt[index].startdate)),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 0.5 * PdfPageFormat.cm,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Start Time : ",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          DateFormat('hh:mm a').format(DateTime.parse(
                              "0000-00-00 " + txt[index].starttime)),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
              SizedBox(height: 2 * PdfPageFormat.cm),
              Container(
                  height: 50,
                  width: PdfPageFormat.inch * 10,
                  alignment: Alignment.center,
                  padding: EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: PdfColors.grey100,
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Text(
                    "Thank You",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ))
            ],
          )
        ],
      ),
    );
    return saveDocument(name: "example.pdf", pdf: pdf);
  }

  static Future<File> saveDocument(
      {required String name, required Document pdf}) async {
    final bytes = await pdf.save();
    final dir = await getApplicationDocumentsDirectory();
    final file = (File('${dir.path}/$name'));

    await file.writeAsBytes(bytes);
    return file;
  }

  static Future openFile(File file) async {
    final url = file.path;
    await OpenFile.open(url);
  }
}
