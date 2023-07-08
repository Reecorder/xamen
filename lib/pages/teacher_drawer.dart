import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:test_app/pages/login.dart';

class AdminDrawer extends StatefulWidget {
  const AdminDrawer({Key? key}) : super(key: key);

  @override
  State<AdminDrawer> createState() => _AdminDrawerState();
}

class _AdminDrawerState extends State<AdminDrawer> {
//**this variables are used for store SsharedPreference Data
  late SharedPreferences sp;
  String tname = "";
  String temail = "";

//**This is a SharedPreference function to get the data
  Future getData() async {
    sp = await SharedPreferences.getInstance();
    tname = sp.getString('tname') ?? "";

    temail = sp.getString('temail') ?? "";

    setState(() {});
  }

//**Logout Function
  logOut() {
    sp.clear();
    Navigator.pop(context);
    Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => LogIn()),
        (Route<dynamic> route) => false);
  }

//**this dialog box is used to take confirmation for logout
  logOutDailog() => showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          title: Text(
            " Logout",
            style: TextStyle(
              color: Color.fromARGB(255, 254, 11, 11),
              fontSize: 22,
            ),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          content: Text("Do you want to Logout ?"),
          actions: [
            TextButton(
              style: TextButton.styleFrom(
                primary: Colors.white,
                backgroundColor: Colors.red,
                elevation: 3,
                shadowColor: Colors.red,
                minimumSize: Size(70, 30),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30)),
              ),
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text(
                "Cancel",
                style: TextStyle(
                  color: Color.fromARGB(255, 255, 255, 255),
                  fontFamily: 'Ubuntu',
                  fontSize: 16,
                ),
              ),
            ),
            SizedBox(
              width: 0,
            ),
            TextButton(
              style: TextButton.styleFrom(
                primary: Colors.white,
                backgroundColor: Colors.blue,
                elevation: 3,
                shadowColor: Colors.blue,
                minimumSize: Size(70, 30),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30)),
              ),
              onPressed: () {
                // Navigator.pop(context);
                logOut();
              },
              child: Text(
                "Ok",
                style: TextStyle(
                  color: Color.fromARGB(255, 255, 255, 255),
                  fontFamily: 'Ubuntu',
                  fontSize: 16,
                  // fontWeight: FontWeight.w600
                ),
              ),
            ),
          ],
        ),
      );
  @override
  void initState() {
    super.initState();
    setState(() {
      getData();
      // print(image);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
        child: ListView(padding: EdgeInsets.zero, children: [
      UserAccountsDrawerHeader(
        accountName: Text(tname),
        accountEmail: Text(temail),
        currentAccountPicture: CircleAvatar(
          backgroundImage: AssetImage("assets/images/default-images.png"),
        ),
      ),
      ListTile(
        leading: Icon(
          Icons.home,
          color: Colors.blue,
        ),
        title: Text(
          "Home",
          // style: TextStyle(color: Colors.blue),
        ),
        onTap: () {
          Navigator.pop(context);
        },
      ),
      ListTile(
        leading: Icon(
          Icons.share,
          color: Colors.blue,
        ),
        title: Text("Share"),
        onTap: () {
          final UrlPriview = 'Hello ';
          Share.share('This is a Exam App \n\n $UrlPriview');
        },
      ),
      Divider(
        endIndent: 30,
        thickness: 1.5,
      ),
      ListTile(
        // enableFeedback: ,
        leading: Icon(
          Icons.exit_to_app_outlined,
          color: Colors.red,
        ),
        title: Text(
          "LogOut",
          style: TextStyle(color: Colors.red, fontWeight: FontWeight.w700),
        ),
        onTap: () => logOutDailog(),
      ),
    ]));
  }
}
