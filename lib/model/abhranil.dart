// import 'dart:convert';
// import 'package:assets_audio_player/assets_audio_player.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/rendering.dart';
// import 'package:flutter/src/foundation/key.dart';
// import 'package:flutter/src/widgets/framework.dart';
// import 'package:fluttertoast/fluttertoast.dart';
// import 'package:mock_test/dialog/loadingdialog.dart';
// import 'package:mock_test/utils/appcolors.dart';
// import 'package:mock_test/utils/question.dart';
// import 'package:mock_test/utils/urls.dart';
// import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:http/http.dart' as http;

// class TestPage extends StatefulWidget {
//   List<Question> questionlist;
//   String chapterid;
//   TestPage(this.questionlist, this.chapterid);
//   @override
//   State<TestPage> createState() => _TestPageState(questionlist, chapterid);
// }

// class _TestPageState extends State<TestPage> {
//   List<Question> questionlist;
//   final itemscroll = ItemScrollController();
//   String chapterid;
//   _TestPageState(this.questionlist, this.chapterid);

//   int quesnum = 0, score = 0, skipped = 0, wrong = 0;
//   //bool isclicked = false;
//   List<bool> isclicked = [];
//   List<Map> btncolors = [];
//   List<Color> questioncolor = [];
//   Color tapcolor = Color.fromARGB(255, 244, 210, 219);
//   AssetsAudioPlayer player = AssetsAudioPlayer();
//   @override
//   void initState() {
//     super.initState();
//     if (questionlist.length > 0) {
//       for (int i = 1; i <= questionlist.length; i++) {
//         isclicked.add(false);
//         btncolors.add(<String, Color>{
//           "1": Colors.white,
//           "2": Colors.white,
//           "3": Colors.white,
//           "4": Colors.white,
//         });
//         questioncolor.add(Colors.white);
//       }
//       questioncolor[0] = tapcolor;
//     }
//   }

//   Future scrollToItem() async {
//     itemscroll.scrollTo(
//       index: quesnum,
//       alignment: 0.5,
//       duration: Duration(
//         milliseconds: 500,
//       ),
//     );
//   }

//   goBack() {
//     return showDialog(
//         context: context,
//         barrierDismissible: false,
//         builder: (context) {
//           return AlertDialog(
//             title: Text(
//               "Go Back",
//               style: TextStyle(color: AppColor.maincolor),
//             ),
//             content: Text(
//                 "If you go back, your data will be lost. Do you really want to go back?"),
//             actions: [
//               TextButton(
//                   onPressed: () {
//                     Navigator.pop(context);
//                   },
//                   child: Text(
//                     "No",
//                     style: TextStyle(fontSize: 18),
//                   )),
//               TextButton(
//                   onPressed: () {
//                     Navigator.pop(context);
//                     Navigator.pop(context);
//                   },
//                   child: Text(
//                     "Yes",
//                     style: TextStyle(fontSize: 18),
//                   )),
//             ],
//           );
//         });
//   }

//   chooseAnswer(String key, String correctans) {
//     if (key == correctans) {
//       btncolors[quesnum][key] = Colors.green;
//       score += 1;
//       player.open(Audio("assets/audio/right.mp3"));
//     } else {
//       btncolors[quesnum][correctans] = Colors.green;
//       btncolors[quesnum][key] = Colors.redAccent;
//       player.open(Audio("assets/audio/wrong.mp3"));
//     }
//     isclicked[quesnum] = true;
//     questioncolor[quesnum] = Colors.green;
//     setState(() {});
//   }

//   nextBtnPressed() {
//     if (quesnum == questionlist.length - 1) {
//       return showDialog(
//           context: context,
//           barrierDismissible: false,
//           builder: (context) {
//             return AlertDialog(
//               title: Text(
//                 "Submit",
//                 style: TextStyle(color: AppColor.maincolor),
//               ),
//               content: Text("Do you want to submit the test?"),
//               actions: [
//                 TextButton(
//                     onPressed: () {
//                       Navigator.pop(context);
//                     },
//                     child: Text(
//                       "No",
//                       style: TextStyle(fontSize: 18),
//                     )),
//                 TextButton(
//                     onPressed: () {
//                       Navigator.pop(context);
//                       submitTest();
//                     },
//                     child: Text(
//                       "Yes",
//                       style: TextStyle(fontSize: 18),
//                     )),
//               ],
//             );
//           });
//     } else {
//       quesnum += 1;
//       scrollToItem();
//     }
//     if (isclicked[quesnum] != true) {
//       questioncolor[quesnum] = tapcolor;
//       if (isclicked[quesnum - 1] != true)
//         questioncolor[quesnum - 1] = Colors.white;
//     } else {
//       if (isclicked[quesnum - 1] != true)
//         questioncolor[quesnum - 1] = Colors.white;
//     }
//     setState(() {});
//   }

//   void prevBtnPressed() {
//     quesnum -= 1;
//     scrollToItem();
//     if (isclicked[quesnum] != true) {
//       questioncolor[quesnum] = tapcolor;
//       if (isclicked[quesnum + 1] != true)
//         questioncolor[quesnum + 1] = Colors.white;
//     } else {
//       if (isclicked[quesnum + 1] != true)
//         questioncolor[quesnum + 1] = Colors.white;
//     }
//     setState(() {});
//   }

//   Future submitTest() async {
//     SharedPreferences sp = await SharedPreferences.getInstance();
//     String userid = sp.getString('userid') ?? "";
//     int x = 0;
//     for (int i = 0; i < isclicked.length; i++) {
//       if (isclicked[i] == true)
//         x++;
//       else {
//         skipped++;
//       }
//     }
//     wrong = x - score;
//     Map data = {
//       'ur_no': userid,
//       'chap_id': chapterid,
//       'total_question': questionlist.length.toString(),
//       'correct': score.toString(),
//       'wrong': wrong.toString(),
//       'skip': skipped.toString(),
//     };
//     print("User Id " + userid);
//     print("Chapter Id " + chapterid);
//     print("Total qus " + questionlist.length.toString());
//     print("Score " + score.toString());
//     print("Wrong " + wrong.toString());
//     print("Skipped " + skipped.toString());

//     showDialog(
//         context: context,
//         barrierDismissible: false,
//         builder: (BuildContext context) {
//           return LoadingDialog();
//         });
//     try {
//       var response = await http.post(
//           Uri.http(MyUrls.apihost, MyUrls.apiurl + "result_add.php"),
//           body: data);
//       var jsondata = jsonDecode(response.body);
//       if (jsondata['status'] == "true") {
//         Navigator.pop(context);
//         Fluttertoast.showToast(
//           msg: jsondata['msg'],
//           fontSize: 15,
//           backgroundColor: AppColor.maincolor,
//           textColor: Colors.white,
//         );
//         Navigator.pop(context);
//       } else {
//         Navigator.pop(context);
//         Fluttertoast.showToast(
//           msg: jsondata['msg'],
//           fontSize: 15,
//           backgroundColor: AppColor.maincolor,
//           textColor: Colors.white,
//         );
//       }
//     } catch (e) {
//       Navigator.pop(context);
//       Fluttertoast.showToast(
//         msg: e.toString(),
//         fontSize: 15,
//         backgroundColor: AppColor.maincolor,
//         textColor: Colors.white,
//       );
//     }
//     setState(() {});
//   }

//   setLayout() {
//     if (questionlist.length == 0) {
//       return Container(
//         alignment: Alignment.center,
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Opacity(
//               opacity: 0.5,
//               child: Image.asset(
//                 "assets/images/exam.png",
//                 height: 70,
//                 width: 70,
//               ),
//             ),
//             SizedBox(
//               height: 10,
//             ),
//             Text(
//               "No Question Found!!",
//               style: TextStyle(
//                 fontSize: 18,
//                 color: Colors.grey,
//               ),
//             ),
//           ],
//         ),
//       );
//     } else {
//       return WillPopScope(
//         onWillPop: () => goBack(),
//         child: Container(
//           child: SingleChildScrollView(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Container(
//                   alignment: Alignment.topLeft,
//                   padding: EdgeInsets.all(10),
//                   margin: EdgeInsets.only(
//                     top: 50,
//                     left: 5,
//                     right: 5,
//                   ),
//                   decoration: BoxDecoration(
//                     color: Color.fromARGB(255, 211, 210, 210),
//                     borderRadius: BorderRadius.circular(7),
//                   ),
//                   child: Text(
//                     (quesnum + 1).toString() +
//                         ". " +
//                         questionlist[quesnum].questionname,
//                     style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
//                   ),
//                 ),
//                 Container(
//                   margin: EdgeInsets.only(
//                     top: 30,
//                   ),
//                   alignment: Alignment.center,
//                   child: Column(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceAround,
//                         children: [
//                           Container(
//                             padding: EdgeInsets.all(10),
//                             decoration: BoxDecoration(
//                               color: Colors.green,
//                               borderRadius: BorderRadius.circular(20),
//                             ),
//                             child: Text(
//                               "Q: " +
//                                   (quesnum + 1).toString() +
//                                   "/" +
//                                   questionlist.length.toString(),
//                               style: TextStyle(
//                                 color: Colors.white,
//                               ),
//                             ),
//                           ),
//                           Container(
//                             padding: EdgeInsets.all(10),
//                             decoration: BoxDecoration(
//                               color: Color.fromARGB(255, 18, 133, 165),
//                               borderRadius: BorderRadius.circular(20),
//                             ),
//                             child: Text(
//                               "Score: " + score.toString(),
//                               style: TextStyle(
//                                 color: Colors.white,
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                       SizedBox(
//                         height: 10,
//                       ),
//                       optionButton("1", questionlist[quesnum].option1,
//                           questionlist[quesnum].correctanswer),
//                       SizedBox(
//                         height: 10,
//                       ),
//                       optionButton("2", questionlist[quesnum].option2,
//                           questionlist[quesnum].correctanswer),
//                       SizedBox(
//                         height: 10,
//                       ),
//                       optionButton("3", questionlist[quesnum].option3,
//                           questionlist[quesnum].correctanswer),
//                       SizedBox(
//                         height: 10,
//                       ),
//                       optionButton("4", questionlist[quesnum].option4,
//                           questionlist[quesnum].correctanswer),
//                     ],
//                   ),
//                 ),
//                 SizedBox(
//                   height: 50,
//                 ),
//                 Container(
//                   child: Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceAround,
//                     children: [
//                       SizedBox(
//                         width: 120,
//                         height: 50,
//                         child: Visibility(
//                           visible: quesnum == 0 ? false : true,
//                           child: ElevatedButton(
//                             onPressed: () => prevBtnPressed(),
//                             style: ElevatedButton.styleFrom(
//                               primary: Color.fromARGB(255, 235, 115, 55),
//                             ),
//                             child: Text(
//                               "<< Prev",
//                               style: TextStyle(
//                                 fontSize: 20,
//                               ),
//                             ),
//                           ),
//                         ),
//                       ),
//                       SizedBox(
//                         width: 120,
//                         height: 50,
//                         child: ElevatedButton(
//                           onPressed: () => nextBtnPressed(),
//                           child: Text(
//                             quesnum == questionlist.length - 1
//                                 ? "Submit"
//                                 : "Next >>",
//                             style: TextStyle(
//                               fontSize: 20,
//                             ),
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//                 Container(
//                   height: 40,
//                   margin: EdgeInsets.all(30),
//                   alignment: Alignment.center,
//                   child: ScrollablePositionedList.builder(
//                     scrollDirection: Axis.horizontal,
//                     itemScrollController: itemscroll,
//                     shrinkWrap: true,
//                     itemCount: questionlist.length,
//                     itemBuilder: (BuildContext context, int index) {
//                       return InkWell(
//                         onTap: () {
//                           quesnum = index;
//                           if (isclicked[index] != true) {
//                             questioncolor[index] = tapcolor;
//                             for (int i = 0; i < questioncolor.length; i++) {
//                               if (i != index && isclicked[i] != true)
//                                 questioncolor[i] = Colors.white;
//                             }
//                           } else {
//                             for (int i = 0; i < questioncolor.length; i++) {
//                               if (isclicked[i] != true)
//                                 questioncolor[i] = Colors.white;
//                             }
//                           }

//                           setState(() {});
//                         },
//                         child: customQuestionBtn(index),
//                       );
//                     },
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Material(
//       child: Scaffold(
//         body: setLayout(),
//       ),
//     );
//   }

//   Widget optionButton(String key, String btnval, String correctans) {
//     return InkWell(
//       onTap: isclicked[quesnum] ? null : () => chooseAnswer(key, correctans),
//       child: Container(
//         constraints: BoxConstraints(
//           minHeight: 60,
//         ),
//         decoration: BoxDecoration(
//           border: Border.all(color: Colors.purple),
//           color: btncolors[quesnum][key],
//           borderRadius: BorderRadius.circular(10),
//         ),
//         //height: 60,
//         width: 300,
//         padding: EdgeInsets.all(5),
//         child: Center(
//           child: Text(
//             btnval,
//             style: TextStyle(
//               fontSize: 20,
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget customQuestionBtn(int index) {
//     return Container(
//       height: 40,
//       width: 40,
//       margin: EdgeInsets.only(right: 5),
//       decoration: BoxDecoration(
//         color: questioncolor[index],
//         border: Border.all(
//           color: Colors.purple,
//         ),
//         borderRadius: BorderRadius.circular(
//           5,
//         ),
//       ),
//       child: Center(
//         child: Text(
//           (index + 1).toString(),
//         ),
//       ),
//     );
//   }
// }
