import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';

class LoadingPage2 extends StatelessWidget {
  String status = "";
  LoadingPage2(this.status);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Dialog(
        elevation: 0,
        backgroundColor: Colors.transparent,
        child: Center(
          child: Container(
            height: 168,
            width: 200,
            decoration: BoxDecoration(
              color: Color.fromARGB(255, 255, 255, 255),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              children: [
                Image.asset(
                  'assets/images/checkbox.gif',
                  height: 140,
                ),
                SizedBox(
                  height: 5,
                ),
                Text(
                  status,
                  style: TextStyle(
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
