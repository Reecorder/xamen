import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:test_app/model/result_model.dart';
import 'package:test_app/pages/MarkSheet.dart';
import 'package:test_app/pages/Result.dart';
import 'package:test_app/pages/examForRankPage.dart';

import 'package:test_app/pages/sideDrawer.dart';
import 'package:test_app/pages/test.dart';

class HomePage extends StatefulWidget {
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // **SharedPreferences to get data
  late SharedPreferences sp;
  String name = "";
  String email = "";
  String image = "";

// !Init state
  @override
  void initState() {
    super.initState();
    getData();
  }

// **Function is used to get data from sharedprefernce
  Future getData() async {
    sp = await SharedPreferences.getInstance();

    setState(() {
      name = sp.getString('name') ?? "";
      email = sp.getString('email') ?? "";
      image = sp.getString('image') ?? "";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: SideNavber(),
      appBar: AppBar(
        elevation: 2,
        title: Text(
          "Student Dashboard",
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontFamily: 'Roboto',
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
          color: Colors.lightBlue,
        ),
        child: Column(
          children: [
            SizedBox(
              height: 20,
            ),
            Text(
              "Welcome Back..",
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontFamily: 'Ubuntu',
                fontWeight: FontWeight.bold,
              ),
            ),
            AnimatedTextKit(
              animatedTexts: [
                TypewriterAnimatedText(
                  name,
                  textStyle: const TextStyle(
                    fontSize: 20,
                    color: Colors.white,
                    fontFamily: "Roboto",
                    fontWeight: FontWeight.bold,
                  ),
                  speed: const Duration(milliseconds: 300),
                  curve: Curves.linear,
                ),
              ],
              totalRepeatCount: 5,
              pause: const Duration(milliseconds: 100),
            ),
            SizedBox(
              height: 80,
            ),
            Expanded(
              child: Container(
                height: MediaQuery.of(context).size.height,
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Color.fromARGB(55, 0, 0, 0),
                        blurRadius: 2,
                        spreadRadius: 2,
                        offset: Offset(0, -1),
                      )
                    ]),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // SvgPicture.asset(
                    //   "assets/images/undraw_futuristic_interface_re_0cm6.svg",
                    //   height: MediaQuery.of(context).size.height * 0.3,
                    // ),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => TestPage(),
                              ),
                            );
                          },
                          child: Container(
                            height: MediaQuery.of(context).size.height * 0.15,
                            width: MediaQuery.of(context).size.width * 0.45,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: Color.fromARGB(128, 248, 89, 89),
                              border: Border.all(
                                color: Color.fromARGB(35, 156, 11, 11),
                              ),
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: [
                                BoxShadow(
                                  color: Color.fromARGB(255, 255, 96, 96),
                                  blurRadius: 8,
                                  spreadRadius: 1,
                                  offset: Offset(
                                    -1,
                                    3,
                                  ),
                                ),
                              ],
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SvgPicture.asset(
                                  "assets/images/undraw_notebook_re_id0r (1).svg",
                                  height:
                                      MediaQuery.of(context).size.height * 0.09,
                                ),
                                SizedBox(
                                  height: 5,
                                ),
                                Text(
                                  "Tests",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontFamily: 'OpenSans-SemiBold',
                                    color: Colors.white,
                                    fontSize: 20,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ResultPage(),
                              ),
                            );
                          },
                          child: Container(
                            height: MediaQuery.of(context).size.height * 0.15,
                            width: MediaQuery.of(context).size.width * 0.45,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: Color.fromARGB(255, 55, 156, 215),
                              border: Border.all(
                                color: Color.fromARGB(34, 11, 74, 156),
                              ),
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: [
                                BoxShadow(
                                  color: Color.fromARGB(167, 4, 105, 164),
                                  blurRadius: 8,
                                  spreadRadius: 1,
                                  offset: Offset(
                                    -1,
                                    3,
                                  ),
                                ),
                              ],
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SvgPicture.asset(
                                  "assets/images/undraw_analysis_re_w2vd (1).svg",
                                  height:
                                      MediaQuery.of(context).size.height * 0.09,
                                ),
                                SizedBox(
                                  height: 5,
                                ),
                                Text(
                                  "Result",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontFamily: 'OpenSans-SemiBold',
                                    color: Colors.white,
                                    fontSize: 20,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 30,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => RankforExam(),
                                ));
                          },
                          child: Container(
                            height: MediaQuery.of(context).size.height * 0.15,
                            width: MediaQuery.of(context).size.width * 0.46,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: Color.fromARGB(255, 53, 129, 7),
                              border: Border.all(
                                color: Color.fromARGB(35, 156, 11, 11),
                              ),
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: [
                                BoxShadow(
                                  color: Color.fromARGB(150, 6, 157, 29),
                                  blurRadius: 8,
                                  spreadRadius: 1,
                                  offset: Offset(
                                    -1,
                                    3,
                                  ),
                                ),
                              ],
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SvgPicture.asset(
                                  "assets/images/undraw_blog_post_re_fy5x.svg",
                                  height:
                                      MediaQuery.of(context).size.height * 0.09,
                                ),
                                SizedBox(
                                  height: 5,
                                ),
                                Text(
                                  "Rank",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontFamily: 'OpenSans-SemiBold',
                                    color: Colors.white,
                                    fontSize: 20,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => MarkSheet(),
                                ));
                          },
                          child: Container(
                            height: MediaQuery.of(context).size.height * 0.15,
                            width: MediaQuery.of(context).size.width * 0.45,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: Color.fromARGB(219, 231, 165, 23),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: Color.fromARGB(34, 156, 144, 11),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Color.fromARGB(219, 231, 165, 23),
                                  blurRadius: 8,
                                  spreadRadius: 1,
                                  offset: Offset(
                                    -1,
                                    3,
                                  ),
                                ),
                              ],
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SvgPicture.asset(
                                  "assets/images/undraw_certificate_re_yadi (2).svg",
                                  height:
                                      MediaQuery.of(context).size.height * 0.08,
                                ),
                                SizedBox(
                                  height: 5,
                                ),
                                Text(
                                  "Mark Sheet",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontFamily: 'OpenSans-SemiBold',
                                    color: Colors.white,
                                    fontSize: 20,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
