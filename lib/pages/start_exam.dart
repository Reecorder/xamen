import 'dart:async';
import 'dart:convert';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:test_app/model/question_model.dart';
import 'package:http/http.dart' as http;
import 'package:test_app/pages/test.dart';
import 'package:test_app/util/loadingPage.dart';

import '../util/url.dart ';

class StartExam extends StatefulWidget {
//! StatefulWidget constructor
  List questionlist = [];
  String examname = "";
  int examId;
  int examTime;
  StartExam(this.questionlist, this.examname, this.examId, this.examTime);

  @override
  State<StartExam> createState() => _StartExamState(
      this.questionlist, this.examname, this.examId, this.examTime);
}

class _StartExamState extends State<StartExam> {
  //! StatefulWidget constructor
  List questionlist = [];
  String examname = "";
  int examId;
  int examTime;

  _StartExamState(this.questionlist, this.examname, this.examId, this.examTime);

// ** Veriable for set answer option value
  List<String> selectedRadio = [];

//**Variable to color the question list numbers & right ans,Wrong ans,review
  List<Map> btncolors = [];
  List<Color> questioncolor = [];
  Color defaultcolor = Color.fromARGB(255, 255, 255, 255);
  Color tapcolor = Color.fromARGB(255, 236, 112, 99);
  Color selectcolor = Color.fromARGB(255, 39, 183, 78);
  Color reviewcolor = Color.fromARGB(255, 118, 39, 183);

// **Variable for review qns
  String review = "Mark";

// **Variables for animated Container
  bool _heightAnimation = false;

//**Variable for increment and decrement questions number
  int qns_number = 0;

//**Variable for list view scroll action */
  // final itemScroll = ScrollController();

// **Variable for calculating crrocet_ans,skip_qns,wrong_ans
  int score = 0;
  int skip_qns = 0;
  int wrong_ans = 0;
  int review_count = 0;
  bool review_click = false;

// **Variable for timer
  late int totalTime;
  Timer? timer;

// **Hour,minute,second
  int h = 0;
  int m = 0;
  int second = 0;
  String timeCounter = "";

//**SharederPreference variables to store the user_id
  late SharedPreferences sp;
  String user_id = "";

//**SharedPreferrence Function to get the user_id
  Future getUserId() async {
    sp = await SharedPreferences.getInstance();
    user_id = sp.getString('user_id') ?? "";
    setState(() {});
  }

//**Widget for questions button(list view builder question number row)*/
  Widget qns_button(int qns_number) {
    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: 5,
      ),
      alignment: Alignment.center,
      // height: 40,
      // width: 40,
      decoration: BoxDecoration(
        color: questioncolor[qns_number],
        borderRadius: BorderRadius.circular(5),
        border: Border.all(
          color: Color.fromARGB(255, 45, 104, 206),
          width: 2,
        ),
      ),
      child: Text(
        (qns_number + 1).toString(),
        style: TextStyle(
          fontFamily: 'Ubuntu',
        ),
      ),
    );
  }

//**Function to go back to previous page */
  goBackDialog() {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          title: Text(
            "Go Back",
            style: TextStyle(color: Colors.red),
          ),
          content: Text(
            "If you go back, your data will be lost. Do you really want to go back?",
            style: TextStyle(
              fontFamily: 'Ubuntu',
              fontSize: 17,
            ),
          ),
          actions: [
            TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text(
                  "No",
                  style: TextStyle(fontSize: 18),
                )),
            TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pop(context);
                },
                child: Text(
                  "Yes",
                  style: TextStyle(fontSize: 18),
                )),
          ],
        );
      },
    );
  }

//**Function to go back to previous page */
  submitDialog() {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          title: Text(
            "Submit",
            style: TextStyle(color: Colors.red),
          ),
          content: Text(
            "Do you want to submit?",
            style: TextStyle(
              fontFamily: 'Ubuntu',
              fontSize: 17,
            ),
          ),
          actions: [
            TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text(
                  "No",
                  style: TextStyle(fontSize: 18),
                )),
            TextButton(
                onPressed: () {
                  submitTest().whenComplete(() {
                    Navigator.pop(context);
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => TestPage()),
                    );
                  });
                },
                child: Text(
                  "Yes",
                  style: TextStyle(fontSize: 18),
                )),
          ],
        );
      },
    );
  }

//**Function is used to control WillpopScope when warning dialog is shown */
  Future<bool> warning() async {
    return false;
  }

//**Function to show exam submit warning dialog */
  warningDialog() {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return WillPopScope(
          onWillPop: () => warning(),
          child: AlertDialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            title: Text(
              "Submit",
              style: TextStyle(color: Colors.red),
            ),
            content: Text(
              "Your time is over. Your exam will be automatically submitted..",
              style: TextStyle(
                fontFamily: 'Ubuntu',
                fontSize: 17,
              ),
            ),
            actions: [
              TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => TestPage()),
                    );
                  },
                  child: Text(
                    "Ok",
                    style: TextStyle(fontSize: 18),
                  )),
            ],
          ),
        );
      },
    );
  }

//**Function for scroll the question numbers */
  // Future scrollToitem() async {
  //   itemScroll.scrollTo(
  //     index: qns_number,
  //     duration: Duration(milliseconds: 500),
  //     alignment: 0.5,
  //   );
  // }

// **Function for submitting result
  Future submitTest() async {
    Map data = {
      'userid': user_id,
      'examid': examId.toString(),
      'correct': score.toString(),
      'wrong': wrong_ans.toString(),
      'skip': skip_qns.toString(),
    };

    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return LoadingPage("Submitting...");
        });
    try {
      var response = await http.post(
        Uri.http(
          MyUrl.hosturl,
          MyUrl.suburl + "submit_result.php",
        ),
        body: data,
      );
      var jsondata = jsonDecode(response.body);
      if (jsondata['status'] == "true") {
        Navigator.pop(context);
        Fluttertoast.showToast(
          msg: jsondata['msg'],
          fontSize: 15,
          backgroundColor: Color.fromARGB(255, 53, 159, 246),
          textColor: Colors.white,
        );
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

// **Function for calculating score,worngR_ans,skip_qns
  calculateResult() {
    skip_qns = 0;
    score = 0;
    wrong_ans = 0;
    for (int i = 0; i < questionlist.length; i++) {
      if (selectedRadio[i] == "") {
        skip_qns++;
      } else if (questionlist[i].correct_ans.toString() == selectedRadio[i]) {
        score++;
      } else {
        wrong_ans++;
      }
    }
  }

// **Funtion to show total Time in format
  String formatDuration(int t) {
    if (t < 10) {
      return "0$t";
    } else {
      return t.toString();
    }
  }

// **Function to calculate total time
  calculateTime(int t) {
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
  }

// **Funtion to start the timer
  void startTime() {
    timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        if (totalTime > 0) {
          totalTime--;
          calculateTime(totalTime);
        } else {
          timer.cancel();
          calculateResult();
          submitTest().whenComplete(() {
            warningDialog();
          });
        }
      });
    });
  }

//! Init state
  @override
  void initState() {
    super.initState();
    getUserId();
    questioncolor.add(tapcolor);
    selectedRadio.add("");
    for (int i = 1; i < questionlist.length; i++) {
      questioncolor.add(defaultcolor);

      selectedRadio.add("");
    }
    totalTime = examTime;
    startTime();
    calculateTime(totalTime);
  }

// !Dispose
  @override
  void dispose() {
    super.dispose();
    timer?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () => goBackDialog(),
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            examname,
            style: TextStyle(
              fontFamily: 'Ubuntu',
              fontWeight: FontWeight.bold,
            ),
          ),
          leading: InkWell(
            onTap: () {
              goBackDialog();
            },
            child: Icon(Icons.arrow_back_ios_outlined),
          ),
        ),
        body: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              SizedBox(
                height: 10,
              ),
              Align(
                alignment: Alignment.topLeft,
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Container(
                      height: 40,
                      width: MediaQuery.of(context).size.width * 0.25,
                      alignment: Alignment.center,
                      margin: EdgeInsets.symmetric(horizontal: 10),
                      decoration: BoxDecoration(
                        color: Color.fromARGB(255, 100, 234, 219),
                        borderRadius: BorderRadius.circular(50),
                      ),
                      child: Text(
                        timeCounter,
                        style: TextStyle(
                          fontFamily: 'Ubuntu',
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.65,
                      child: LinearProgressIndicator(
                        color: Color.fromARGB(255, 77, 191, 239),
                        minHeight: 10,
                        backgroundColor: Colors.grey,
                        value: totalTime / examTime,
                      ),
                    )
                  ],
                ),
              ),
              Container(
                child: IntrinsicHeight(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(
                        child: Container(
                          // height: ,
                          margin:
                              EdgeInsets.symmetric(horizontal: 5, vertical: 10),
                          padding: EdgeInsets.symmetric(
                              horizontal: 15, vertical: 20),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: Color.fromARGB(190, 255, 193, 7),
                          ),
                          child: Text(
                            "Q" + (qns_number + 1).toString() + ".",
                            style: TextStyle(
                              fontSize: 17,
                              fontFamily: "Ubuntu",
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.symmetric(vertical: 10),
                        padding:
                            EdgeInsets.symmetric(horizontal: 15, vertical: 20),
                        width: MediaQuery.of(context).size.width * .78,
                        alignment: Alignment.topLeft,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: Color.fromARGB(190, 255, 193, 7),
                        ),
                        child: Text(
                          questionlist[qns_number].qns,
                          style: TextStyle(
                            fontSize: 17,
                            fontFamily: "Ubuntu",
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                  ),
                  child: RadioListTile(
                    tileColor: Color(0xFFFFF1C6),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    title: Text(questionlist[qns_number].opt1),
                    value: '1',
                    groupValue: selectedRadio[qns_number],
                    onChanged: (value) {
                      setState(() {
                        selectedRadio[qns_number] = value.toString();
                        if (questioncolor[qns_number] != reviewcolor) {
                          questioncolor[qns_number] = selectcolor;
                        }
                      });
                    },
                  )),
              SizedBox(
                height: 7,
              ),
              Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                  ),
                  child: RadioListTile(
                    tileColor: Color(0xFFFFF1C6),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    title: Text(questionlist[qns_number].opt2),
                    value: '2',
                    groupValue: selectedRadio[qns_number],
                    onChanged: (value) {
                      setState(() {
                        selectedRadio[qns_number] = value.toString();
                        if (questioncolor[qns_number] != reviewcolor) {
                          questioncolor[qns_number] = selectcolor;
                        }
                        // print(selectedRadio);
                      });
                    },
                  )),
              SizedBox(
                height: 7,
              ),
              Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                  ),
                  child: RadioListTile(
                    tileColor: Color(0xFFFFF1C6),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    title: Text(questionlist[qns_number].opt3),
                    value: '3',
                    groupValue: selectedRadio[qns_number],
                    onChanged: (value) {
                      setState(() {
                        selectedRadio[qns_number] = value.toString();
                        if (questioncolor[qns_number] != reviewcolor) {
                          questioncolor[qns_number] = selectcolor;
                        }
                        // print(selectedRadio);
                      });
                    },
                  )),
              SizedBox(
                height: 7,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                ),
                child: RadioListTile(
                  tileColor: Color(0xFFFFF1C6),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  title: Text(questionlist[qns_number].opt4),
                  value: '4',
                  groupValue: selectedRadio[qns_number],
                  onChanged: (value) {
                    setState(() {
                      selectedRadio[qns_number] = value.toString();
                      if (questioncolor[qns_number] != reviewcolor) {
                        questioncolor[qns_number] = selectcolor;
                      }

                      // print(selectedRadio);
                    });
                  },
                ),
              ),
              SizedBox(
                height: 20,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Visibility(
                    visible: qns_number == 0 ? false : true,
                    maintainSemantics: true,
                    maintainSize: true,
                    maintainAnimation: true,
                    maintainState: true,
                    child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.redAccent,
                          minimumSize: Size(10, 45),
                          foregroundColor: Color.fromARGB(255, 255, 255, 255),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          elevation: 1,
                          shadowColor: Color.fromARGB(255, 0, 0, 0),
                        ),
                        onPressed: () {
                          setState(() {
                            if (qns_number == 0) {
                              qns_number = questionlist.length - 1;
                            } else {
                              qns_number--;
                              if (questioncolor[qns_number] == reviewcolor) {
                                review = "Marked";
                              } else {
                                review = "Mark";
                              }
                              for (int i = 0; i < questionlist.length; i++) {
                                if (selectedRadio[i] == "" &&
                                    questioncolor[i] != reviewcolor) {
                                  questioncolor[i] = defaultcolor;
                                }
                              }
                              if (selectedRadio[qns_number] == "" &&
                                  questioncolor[qns_number] != reviewcolor) {
                                questioncolor[qns_number] = tapcolor;
                              }
                            }
                            // scrollToitem();
                          });
                        },
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.arrow_back_ios_rounded,
                              size: 17,
                            ),
                            SizedBox(
                              width: 10,
                            ),
                            Text(
                              "Prev",
                              style: TextStyle(fontSize: 17),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        if (questioncolor[qns_number] == reviewcolor) {
                          review = "Mark";
                          if (selectedRadio[qns_number] == "") {
                            questioncolor[qns_number] = tapcolor;
                            review = "Mark";
                          } else {
                            questioncolor[qns_number] = selectcolor;
                            review = "Mark";
                          }
                        } else {
                          questioncolor[qns_number] = reviewcolor;
                          review = "Marked";
                        }
                      });
                    },
                    child: Text(review),
                    style: TextButton.styleFrom(
                      backgroundColor: Color.fromARGB(221, 148, 36, 208),
                      minimumSize: Size(30, 30),
                      foregroundColor: Color.fromARGB(255, 255, 255, 255),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(50),
                      ),
                      elevation: 1,
                      shadowColor: Color.fromARGB(255, 0, 0, 0),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(10),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color.fromARGB(255, 36, 208, 125),
                        minimumSize: Size(10, 45),
                        foregroundColor: Color.fromARGB(255, 255, 255, 255),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        elevation: 1,
                        shadowColor: Color.fromARGB(255, 0, 0, 0),
                      ),
                      onPressed: () {
                        setState(() {
                          if (qns_number == questionlist.length - 1) {
                            calculateResult();
                            submitDialog();
                          } else {
                            qns_number++;
                            // calculateTime();
                            if (questioncolor[qns_number] == reviewcolor) {
                              review = "Marked";
                            } else {
                              review = "Mark";
                            }
                            for (int i = 0; i < questionlist.length; i++) {
                              if (selectedRadio[i] == "" &&
                                  questioncolor[i] != reviewcolor) {
                                questioncolor[i] = defaultcolor;
                              }
                            }
                            if (selectedRadio[qns_number] == "" &&
                                questioncolor[qns_number] != reviewcolor) {
                              questioncolor[qns_number] = tapcolor;
                            }
                          }

                          // scrollToitem();
                        });
                      },
                      child: Row(
                        children: [
                          Text(
                            qns_number == questionlist.length - 1
                                ? "Submit"
                                : "Next",
                            style: TextStyle(
                              fontFamily: "Ubuntu",
                              fontSize: 17,
                            ),
                          ),
                          Icon(
                            Icons.arrow_forward_ios_rounded,
                            size: 17,
                          ),
                        ],
                      ),
                    ),
                  )
                ],
              ),
              AnimatedContainer(
                height: _heightAnimation ? 285 : 52,
                width: double.infinity,
                margin: EdgeInsets.symmetric(horizontal: 5, vertical: 10),
                padding: _heightAnimation ? EdgeInsets.only(bottom: 2) : null,
                duration: Duration(milliseconds: 250),
                curve: Curves.easeIn,
                decoration: BoxDecoration(
                  color: Color.fromARGB(84, 197, 197, 197),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _heightAnimation
                        ? Color.fromARGB(98, 0, 0, 0)
                        : Color.fromARGB(50, 0, 0, 0),
                  ),
                ),
                child: Column(
                  mainAxisAlignment: _heightAnimation
                      ? MainAxisAlignment.start
                      : MainAxisAlignment.start,
                  children: [
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _heightAnimation = !_heightAnimation;
                        });
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: _heightAnimation
                            ? CrossAxisAlignment.center
                            : CrossAxisAlignment.center,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                            ),
                            child: Text(
                              "Question numbers ",
                              style: TextStyle(
                                color: Colors.blueAccent,
                                fontFamily: "Roboto",
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          IconButton(
                            onPressed: () {
                              setState(() {
                                _heightAnimation = !_heightAnimation;
                              });
                            },
                            icon: _heightAnimation
                                ? Icon(
                                    Icons.keyboard_arrow_up_rounded,
                                    color: Color.fromARGB(255, 0, 0, 0),
                                  )
                                : Icon(
                                    Icons.keyboard_arrow_down_rounded,
                                    color: Color.fromARGB(255, 0, 0, 0),
                                  ),
                          ),
                        ],
                      ),
                    ),
                    Visibility(
                      visible: _heightAnimation ? true : false,
                      child: Expanded(
                        child: Container(
                          // height: MediaQuery.of(context).size.height,
                          width: MediaQuery.of(context).size.width,
                          // margin: EdgeInsets.symmetric(horizontal: 10),
                          padding:
                              EdgeInsets.only(right: 10, left: 10, bottom: 5),
                          color: Color.fromARGB(0, 68, 137, 255),
                          child: GridView.builder(
                            // controller: itemScroll,
                            //  itemScrollController: itemScroll,
                            shrinkWrap: true,
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 7,
                              mainAxisSpacing: 10,
                              childAspectRatio: 1.2,
                            ),

                            scrollDirection: Axis.vertical,
                            itemCount: questionlist.length,
                            itemBuilder: (BuildContext context, int index) {
                              return InkWell(
                                borderRadius: BorderRadius.circular(10),
                                child: qns_button(index),
                                onTap: () {
                                  setState(() {
                                    qns_number = index;
                                    if (questioncolor[qns_number] ==
                                        reviewcolor) {
                                      review = "Marked";
                                    } else {
                                      review = "Mark";
                                    }
                                    for (int i = 0;
                                        i < questionlist.length;
                                        i++) {
                                      if (selectedRadio[i] == "" &&
                                          questioncolor[i] != reviewcolor) {
                                        questioncolor[i] = defaultcolor;
                                      }
                                    }
                                    if (selectedRadio[qns_number] == "" &&
                                        questioncolor[qns_number] !=
                                            reviewcolor) {
                                      questioncolor[qns_number] = tapcolor;
                                    }
                                  });
                                },
                              );
                            },
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
