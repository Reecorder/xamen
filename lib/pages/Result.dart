import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../model/indivisual_result_model.dart';
import '../util/loadingPage.dart';
import '../util/url.dart';

class ResultPage extends StatefulWidget {
  const ResultPage({super.key});

  @override
  State<ResultPage> createState() => _ResultPageState();
}

class _ResultPageState extends State<ResultPage> {
//** List for  indivisual result modal */
  List<IndivisualResult> indivisualResultlist = [];

//**SharederPreference variables to store the user_id
  late SharedPreferences sp;
  String user_id = "";

//**SharedPreferrence Function to get the user_id
  Future getUserId() async {
    sp = await SharedPreferences.getInstance();
    user_id = sp.getString('user_id') ?? "";
    setState(() {});
  }

// **Function for geting indivisual result
  Future getResult() async {
    Map data = {
      'user_id': user_id,
    };

    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return LoadingPage("Getting result...");
        });
    try {
      var response = await http.post(
        Uri.http(
          MyUrl.hosturl,
          MyUrl.suburl + "get_published_result.php",
        ),
        body: data,
      );
      var jsondata = jsonDecode(response.body);
      if (jsondata['status'] == "true") {
        Navigator.pop(context);
        indivisualResultlist.clear();
        for (var x in jsondata['data']) {
          setState(() {
            IndivisualResult ind_result = IndivisualResult(
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
            );
            indivisualResultlist.add(ind_result);
          });
        }
      } else {
        Navigator.pop(context);
        Fluttertoast.showToast(
          msg: jsondata['msg'],
          fontSize: 15,
          backgroundColor: Colors.blueAccent,
          textColor: Colors.white,
        );
      }
    } catch (e) {
      Navigator.pop(context);
      Fluttertoast.showToast(
        msg: e.toString(),
        fontSize: 15,
        backgroundColor: Colors.blueAccent,
        textColor: Colors.white,
      );
    }
    setState(() {});
  }

// //**this function is used to show the layout  when resultlist is empty
//   Widget layout() {
//     return Container(
//       width: 300,
//       height: 200,
//       decoration: BoxDecoration(
//         image: DecorationImage(
//           image: AssetImage(
//             "assets/images/result-removebg-preview.png",
//           ),
//           opacity: 0.6,
//         ),
//       ),
//       child: Align(
//         alignment: Alignment.bottomCenter,
//         child: Text(
//           "No result to Publish",
//           style: TextStyle(
//             color: Colors.grey,
//             fontFamily: "Ubuntu",
//             fontSize: 15,
//           ),
//         ),
//       ),
//     );
//   }

// !! Init state
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) {
        getUserId().whenComplete(
          () => getResult(),
        );
        // print(resultlist);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Result",
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: InkWell(
          onTap: () {
            Navigator.pop(context);
          },
          child: Icon(Icons.arrow_back_ios_outlined),
        ),
      ),
      body: ListView.builder(
          itemCount: indivisualResultlist.length,
          itemBuilder: (BuildContext context, int index) {
            return Container(
              height: 140,
              width: 180,
              alignment: Alignment.centerLeft,
              margin: EdgeInsets.only(
                top: 10,
                left: 12,
                right: 12,
                bottom: 5,
              ),
              padding:
                  EdgeInsets.only(left: 10, right: 15, top: 10, bottom: 10),
              decoration: BoxDecoration(
                  color: Color.fromARGB(147, 255, 255, 255),
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Color.fromARGB(156, 56, 122, 253),
                      blurRadius: 1,
                      spreadRadius: 2.5,
                    ),
                  ]),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SvgPicture.asset(
                        "assets/images/trophy-svgrepo-com (1).svg",
                        height: 27,
                      ),
                      Text(
                        "Exam Date : " + indivisualResultlist[index].startdate,
                        style: TextStyle(
                          color: Color.fromARGB(255, 4, 113, 255),
                          fontFamily: "OpenSans-SemiBold",
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    "Exam Name : " + indivisualResultlist[index].exam_name,
                    style: TextStyle(
                      color: Color.fromARGB(230, 18, 90, 132),
                      fontFamily: "OpenSans-SemiBold",
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    "Mark Obtained : " +
                        (indivisualResultlist[index].correct_ans *
                                indivisualResultlist[index].marks_per_qns)
                            .toString(),
                    style: TextStyle(
                      color: Color.fromARGB(230, 18, 90, 132),
                      fontFamily: "OpenSans-SemiBold",
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      RichText(
                        text: TextSpan(
                          style: TextStyle(
                              color: Colors.green,
                              fontFamily: "OpenSans-SemiBold",
                              fontWeight: FontWeight.bold,
                              fontSize: 16),
                          children: [
                            WidgetSpan(
                              alignment: PlaceholderAlignment.middle,
                              child: Icon(
                                Icons.check,
                                color: Colors.green,
                              ),
                            ),
                            TextSpan(
                              text: "Correct : " +
                                  indivisualResultlist[index]
                                      .correct_ans
                                      .toString(),
                            ),
                          ],
                        ),
                      ),
                      RichText(
                        text: TextSpan(
                          children: [
                            WidgetSpan(
                              alignment: PlaceholderAlignment.middle,
                              child: Icon(
                                Icons.close,
                                color: Color.fromARGB(220, 253, 0, 0),
                              ),
                            ),
                            TextSpan(
                              text: "Wrong : " +
                                  indivisualResultlist[index]
                                      .wrong_ans
                                      .toString(),
                              style: TextStyle(
                                color: Color.fromARGB(209, 252, 0, 0),
                                fontFamily: "OpenSans-SemiBold",
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                      RichText(
                        text: TextSpan(
                          children: [
                            WidgetSpan(
                              alignment: PlaceholderAlignment.middle,
                              child: Icon(
                                Icons.skip_next,
                                color: Color.fromARGB(220, 253, 0, 0),
                              ),
                            ),
                            TextSpan(
                              text: "Skipped  : " +
                                  indivisualResultlist[index]
                                      .skiped_qns
                                      .toString(),
                              style: TextStyle(
                                color: Color.fromARGB(230, 192, 25, 25),
                                fontFamily: "OpenSans-SemiBold",
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          }),
    );
  }
}
