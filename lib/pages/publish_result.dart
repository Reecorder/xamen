import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import '../model/result_model.dart';
import '../util/loadingPage.dart';
import '../util/url.dart';

class PublishResult extends StatefulWidget {
  int exam_id;
  PublishResult(this.exam_id);
  @override
  State<PublishResult> createState() => _PublishResultState(this.exam_id);
}

class _PublishResultState extends State<PublishResult> {
  int exam_id;
  _PublishResultState(this.exam_id);
//** List for  inactive result modal */
  List<Result> resultlist = [];

//**List to store checkboxlisttile value(default value false)
  List<bool> checkBoxValue = [];

//**List to store student roll when checkbox is true
  List resultvaluelist = [];

//**variable for checkbox list tile
  bool checked = false;

// **Function to get inactivate results
  Future resultCount() async {
    Map data = {
      'exam_id': exam_id.toString(),
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
          MyUrl.suburl + "unpublished_result.php",
        ),
        body: data,
      );
      var jsondata = jsonDecode(response.body);
      if (jsondata['status'] == "true") {
        Navigator.pop(context);
        resultlist.clear();
        for (var x in jsondata['data']) {
          setState(
            () {
              Result result = Result(
                int.parse(x['id']),
                int.parse(x['exam_id']),
                int.parse(x['user_id']),
                int.parse(x['skiped_qns']),
                int.parse(x['correct_ans']),
                int.parse(x['worng_ans']),
                int.parse(x['full_marks']),
                int.parse(x['marks_per_qns']),
                x['name'],
                x['roll'],
                x['exam_name'],
                x['batch_name'],
              );
              resultlist.add(result);
              checkBoxValue.add(false);
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

//**This function is used to Publish student result
  Future publishResult() async {
    // resultvaluelist.isEmpty
    //     ? resultvaluelist.add(null)
    //     : resultvaluelist.remove(null);
    Map data = {
      'user_id': resultvaluelist.toString(),
      'exam_id': exam_id.toString(),
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
          MyUrl.suburl + "publish_result.php",
        ),
        body: data,
      );
      var jsondata = jsonDecode(response.body);
      if (jsondata['status'] == "true") {
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
    setState(() {});
  }

//**This function is used to Delete student result
  //! Future deleteResult(String id, int index) async {
  //   Map data = {
  //     'result_id': id,
  //   };
  //   showDialog(
  //       context: context,
  //       barrierDismissible: false,
  //       builder: (BuildContext context) {
  //         return LoadingPage("Loading...");
  //       });
  //   try {
  //     var response = await http.post(
  //       Uri.http(
  //         MyUrl.hosturl,
  //         MyUrl.suburl + "delete_result.php",
  //       ),
  //       body: data,
  //     );
  //     var jsondata = jsonDecode(response.body);
  //     if (jsondata['status'] == "true") {
  //       resultlist.removeAt(index);
  //       Navigator.pop(context);
  //       Fluttertoast.showToast(
  //         msg: jsondata['msg'],
  //         backgroundColor: Color.fromARGB(255, 43, 162, 216),
  //         textColor: Colors.white,
  //       );
  //     } else {
  //       Navigator.pop(context);
  //       Fluttertoast.showToast(
  //         msg: jsondata['msg'],
  //         backgroundColor: Colors.green,
  //         textColor: Colors.white,
  //       );
  //     }
  //   } catch (e) {
  //     Navigator.pop(context);
  //     Fluttertoast.showToast(
  //       msg: e.toString(),
  //       backgroundColor: Colors.green,
  //       textColor: Colors.white,
  //     );
  //   }
  //   setState(() {});
  // }

//**this dialog box is used to take confirmation for delete  result
  // !deleteResultDailog(String id, int index) => showDialog(
  //       context: context,
  //       barrierDismissible: false,
  //       builder: (context) => AlertDialog(
  //         title: Row(
  //           children: [
  //             Icon(
  //               Icons.delete,
  //               color: Color.fromARGB(219, 254, 23, 11),
  //             ),
  //             SizedBox(
  //               width: 5,
  //             ),
  //             Text(
  //               "Delete result...",
  //               style: TextStyle(
  //                 color: Color.fromARGB(224, 254, 11, 11),
  //                 fontSize: 20,
  //                 // fontFamily: 'OpenSans-Regular',
  //               ),
  //             ),
  //           ],
  //         ),
  //         shape: RoundedRectangleBorder(
  //           borderRadius: BorderRadius.circular(15),
  //         ),
  //         content: Text(
  //           "Do you want to delete result...?",
  //           style: TextStyle(
  //             fontFamily: 'Ubuntu',
  //             fontSize: 17,
  //           ),
  //         ),
  //         actions: [
  //           TextButton(
  //             style: TextButton.styleFrom(
  //               shape: RoundedRectangleBorder(
  //                   borderRadius: BorderRadius.circular(10)),
  //             ),
  //             onPressed: () {
  //               Navigator.pop(context);
  //             },
  //             child: Text(
  //               "Cancel",
  //               style: TextStyle(
  //                 color: Color.fromARGB(245, 255, 0, 0),
  //                 fontFamily: 'Ubuntu',
  //                 fontSize: 17,
  //                 fontWeight: FontWeight.w600,
  //               ),
  //             ),
  //           ),
  //           SizedBox(
  //             width: 0,
  //           ),
  //           TextButton(
  //             style: TextButton.styleFrom(
  //               shape: RoundedRectangleBorder(
  //                   borderRadius: BorderRadius.circular(10)),
  //             ),
  //             onPressed: () {
  //               deleteResult(id, index).whenComplete(() {
  //                 Navigator.pop(context);
  //               });
  //             },
  //             child: Text(
  //               "OK",
  //               style: TextStyle(
  //                 color: Color.fromARGB(245, 12, 255, 142),
  //                 fontFamily: 'Ubuntu',
  //                 fontSize: 17,
  //                 fontWeight: FontWeight.w600,
  //               ),
  //             ),
  //           ),
  //         ],
  //       ),
  //     );

//**this function is used to show the layout  when resultlist is empty
  Widget layout() {
    return Container(
      width: 300,
      height: 200,
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage(
            "assets/images/result-removebg-preview.png",
          ),
          scale: 1.9,
          opacity: 0.6,
        ),
      ),
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Text(
          "No result to Publish",
          style: TextStyle(
            color: Colors.grey,
            fontFamily: "Ubuntu",
            fontSize: 15,
          ),
        ),
      ),
    );
  }

//**This is a custom widget to creat a checkbox
  Widget myCheckBox(int index) {
    return Padding(
      padding: const EdgeInsets.only(top: 5, left: 5, right: 5),
      child: CheckboxListTile(
        activeColor: Color.fromARGB(255, 30, 124, 23),
        tileColor: Color.fromARGB(255, 250, 226, 156),
        side: BorderSide(
          color: Color.fromARGB(255, 0, 0, 0),
          width: 1.5,
        ),
        checkboxShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        value: checkBoxValue[index],
        onChanged: (value) {
          setState(() {
            checkBoxValue[index] = value!;
            // status += '$studentList[index].roll,';
            // print(status);
            if (value == true) {
              resultvaluelist.add(resultlist[index].user_id);
              print(resultvaluelist);
            } else {
              resultvaluelist.remove(resultlist[index].user_id);
              print(resultvaluelist);
              // print(status);
            }
          });
        },
        title: Row(
          children: [
            CircleAvatar(
              child: Text(
                resultlist[index].exam_name[0],
              ),
            ),
            SizedBox(
              width: 12,
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(resultlist[index].name),
                Text(resultlist[index].exam_name),
                Text("Correct answer: " +
                    resultlist[index].correct_ans.toString()),
              ],
            )
          ],
        ),
      ),
    );
  }

  // ! Init state
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) {
        resultCount();
        // print(resultlist);
      },
    );
  }

  Widget build(BuildContext context) {
    return Scaffold(
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
        appBar: AppBar(
          title: Text(
            "Results",
          ),
          leading: InkWell(
            onTap: () {
              Navigator.pop(context);
            },
            child: Icon(Icons.arrow_back_ios_outlined),
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 22),
              child: Checkbox(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                  side: BorderSide(
                    color: Color.fromARGB(255, 255, 255, 255),
                    width: 1.5,
                  ),
                  activeColor: Color.fromARGB(255, 30, 124, 23),
                  value: checked,
                  onChanged: (value) {
                    setState(() {
                      checked = value!;
                      resultvaluelist.clear();
                      if (value) {
                        for (int i = 0; i < checkBoxValue.length; i++) {
                          checkBoxValue[i] = true;
                          resultvaluelist.add(resultlist[i].user_id);
                          print(resultvaluelist);
                          // for (var i in resultvaluelist) {
                          //   if (status.contains(i)) {
                          //     continue;
                          //   } else {
                          //     status += "$i,";
                          //   }
                          //   print(status);
                          // }
                        }
                      } else {
                        for (int i = 0; i < checkBoxValue.length; i++) {
                          checkBoxValue[i] = false;
                          resultvaluelist.remove(resultlist[i].user_id);
                          print(resultvaluelist);
                        }
                      }
                    });
                  }),
            )
          ],
        ),
        body: resultlist.isNotEmpty
            ? ListView.builder(
                itemCount: resultlist.length,
                itemBuilder: (BuildContext context, int index) {
                  return Container(
                    margin: EdgeInsets.symmetric(horizontal: 5, vertical: 5),
                    child: myCheckBox(index),
                  );
                },
              )
            : Center(
                child: layout(),
              ),
        floatingActionButton:
            //   Column(mainAxisAlignment: MainAxisAlignment.end, children: [
            // FloatingActionButton.extended(
            //   backgroundColor: Color.fromARGB(228, 244, 67, 54),
            //   shape:
            //       RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            //   icon: Icon(Icons.delete),
            //   label: Text(
            //     "Delete",
            //     style: TextStyle(
            //       fontFamily: "Ubuntu",
            //       fontSize: 15,
            //       fontWeight: FontWeight.bold,
            //     ),
            //   ),
            //   onPressed: () {
            //     //...
            //   },
            //   heroTag: null,
            // ),
            // SizedBox(
            //   height: 10,
            // ),
            FloatingActionButton.extended(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          icon: Icon(Icons.check),
          label: Text(
            "Publish",
            style: TextStyle(
              fontFamily: "Ubuntu",
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),
          onPressed: () async {
            await publishResult().whenComplete(() {
              print(resultvaluelist);
              setState(() {
                resultlist.clear();
                checkBoxValue.clear();
                checked = false;
                resultCount();
              });
            });
          },
          heroTag: null,
        ));
  }
}
