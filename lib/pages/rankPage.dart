import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import '../model/rank_model.dart';
import '../util/loadingPage.dart';
import '../util/url.dart';

class MyRank extends StatefulWidget {
  int examId;
  MyRank(this.examId);
  @override
  State<MyRank> createState() => _MyRankState(this.examId);
}

class _MyRankState extends State<MyRank> {
  int examId;
  _MyRankState(this.examId);

  //**Exam list to show all Exams
  List<Rank> ranklist = [];

  //**This function is used to get the  all exam details
  Future rankList(int examid) async {
    Map data = {
      'exam_id': examid.toString(),
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
          MyUrl.suburl + "getrank.php",
        ),
        body: data,
      );
      var jsondata = jsonDecode(response.body);
      if (jsondata['status'] == "true") {
        Navigator.pop(context);
        ranklist.clear();
        for (var x in jsondata['data']) {
          setState(
            () {
              Rank rank = Rank(
                x['name'],
                int.parse(x['correct_ans']),
                int.parse(x['marks_per_qns']),
                int.parse(x['rank']),
              );
              ranklist.add(rank);
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

  // ! Init state
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) {
        rankList(examId);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Rank",
        ),
        leading: InkWell(
          onTap: () {
            Navigator.pop(context);
          },
          child: Icon(Icons.arrow_back_ios_outlined),
        ),
      ),
      body: ListView.builder(
          itemCount: ranklist.length,
          itemBuilder: (BuildContext context, int index) {
            return Padding(
              padding: const EdgeInsets.only(
                top: 10,
                left: 10,
                right: 10,
              ),
              child: ListTile(
                title: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: Color.fromARGB(255, 124, 6, 73),
                      child: Text(
                        ranklist[index].name[0],
                        style: TextStyle(
                          color: Colors.white,
                          fontFamily: "Ubuntu",
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 15,
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          ranklist[index].name,
                        ),
                        Text(
                          "Score: " +
                              (ranklist[index].score *
                                      ranklist[index].mark_per_qns)
                                  .toString(),
                          style: TextStyle(
                            fontFamily: "Ubuntu",
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    Spacer(),
                    Text(
                      "Rank : " + ranklist[index].rank.toString(),
                      style: TextStyle(
                        fontFamily: "Ubuntu",
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Image.asset(
                      "assets/images/icons8-trophy-unscreen.gif",
                      height: 27,
                    ),
                  ],
                ),
                contentPadding: EdgeInsets.all(8),
                tileColor: Color.fromARGB(213, 171, 255, 255),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
            );
          }),
    );
  }
}
