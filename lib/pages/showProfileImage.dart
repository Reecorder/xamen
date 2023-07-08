import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';

import '../util/url.dart ';

class ShowProfileImage extends StatelessWidget {
  late String Profileimage = "";
  ShowProfileImage(this.Profileimage);

//**this function is used to show the image in the full view
  setImage() {
    if (Profileimage != "") {
      return Container(
          decoration: BoxDecoration(
        image: DecorationImage(
          image: (NetworkImage(MyUrl.imageurl + Profileimage)),
          fit: BoxFit.fitWidth,
        ),
      ));
    } else {
      return Container(
        color: Colors.white,
        child: CircularProgressIndicator(color: Colors.blue),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black,
      child: Center(
        child: Container(
          child: Column(
            children: [
              SizedBox(
                height: 30,
              ),
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  alignment: Alignment.topLeft,
                  padding: EdgeInsets.only(left: 10),
                  child: SafeArea(
                    child: Icon(
                      Icons.arrow_back,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              Container(
                height: 500,
                margin: EdgeInsets.only(top: 90),
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                  color: Color.fromARGB(255, 0, 0, 0),
                ),
                child: setImage(),
              )
            ],
          ),
        ),
      ),
    );
  }
}
