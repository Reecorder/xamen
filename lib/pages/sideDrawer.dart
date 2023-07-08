import 'dart:convert';
// import 'dart:ffi';
//import 'dart:html';
import 'dart:io';
import 'dart:typed_data';
// import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:test_app/pages/login.dart';
import 'package:test_app/pages/profie.dart';
import 'package:test_app/pages/showProfileImage.dart';
import 'package:test_app/util/url.dart';
import 'package:http/http.dart' as http;

import '../util/loadingPage.dart';
import 'editProfile.dart';

class SideNavber extends StatefulWidget {
  const SideNavber({Key? key}) : super(key: key);

  @override
  State<SideNavber> createState() => _SideNavberState();
}

class _SideNavberState extends State<SideNavber> {
//**this variables are used for store SsharedPreference Data
  late SharedPreferences sp;
  String name = "";
  String email = "";
  String roll = "";
  String image = "";
  String dept = "";
  String batch = "";

//**this variable is storing image from camera/gallery
  var imagefile;

//**this function is used to get the image from camera/gallery
  Future getImage({required ImageSource source}) async {
    Navigator.pop(context);
    final file;

    file = await ImagePicker().pickImage(
        source: source, maxHeight: 1000, maxWidth: 1000, imageQuality: 100);

    if (file != null) {
      File? imgfile = File(file.path);
      imgfile = await _cropImage(imageFile: imgfile);
      if (imgfile != null) {
        Uint8List imagebyte = await imgfile.readAsBytes();
        imagefile = base64Encode(imagebyte);

        setState(() {
          uploadeImage(imagefile);
        });
      } else {
        return;
      }
    } else {
      return;
    }
  }

//**This is used for crop the image file */
  Future<File?> _cropImage({required File imageFile}) async {
    CroppedFile? croppedImage = await ImageCropper()
        .cropImage(sourcePath: imageFile.path, cropStyle: CropStyle.circle);
    if (croppedImage == null) return null;
    return File(croppedImage.path);
  }

// **get crop image
  Future cropImage({required File imgFile}) async {
    CroppedFile? croppedImage =
        await ImageCropper().cropImage(sourcePath: imgFile.path);
  }

//**this function is used to upload the image
  Future uploadeImage(String imgurl) async {
    Map data = {
      'roll': roll,
      'image': imgurl,
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
            MyUrl.suburl + "change_image.php",
          ),
          body: data);
      var jsondata = jsonDecode(response.body);
      if (jsondata['status'] == "true") {
        sp = await SharedPreferences.getInstance();
        Navigator.pop(context);
        setState(() {
          sp.remove('image');
          sp.setString('image', jsondata['image']);
          image = jsondata['image'];
        });

        Fluttertoast.showToast(
          msg: jsondata['msg'],
          backgroundColor: Color.fromARGB(255, 21, 111, 180),
          textColor: Colors.white,
        );
      } else {
        Navigator.pop(context);
        Fluttertoast.showToast(
          msg: jsondata['msg'],
          backgroundColor: Color.fromARGB(255, 21, 111, 180),
          textColor: Colors.white,
        );
      }
    } catch (e) {
      Navigator.pop(context);
      Fluttertoast.showToast(
        msg: e.toString(),
        backgroundColor: Color.fromARGB(255, 21, 111, 180),
        textColor: Colors.white,
      );
    }
  }

// ** Delete current image and set default image
  Future deleteImage() async {
    Map data = {
      'roll': roll,
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
            MyUrl.suburl + "deleteprofileimage.php",
          ),
          body: data);
      var jsondata = jsonDecode(response.body);
      if (jsondata['status'] == "true") {
        sp = await SharedPreferences.getInstance();
        Navigator.pop(context);
        Navigator.pop(context);
        setState(() {
          sp.remove('image');
          sp.setString('image', jsondata['image']);
          image = jsondata['image'];
        });

        Fluttertoast.showToast(
          msg: jsondata['msg'],
          backgroundColor: Color.fromARGB(255, 21, 111, 180),
          textColor: Colors.white,
        );
      } else {
        Navigator.pop(context);
        Fluttertoast.showToast(
          msg: jsondata['msg'],
          backgroundColor: Color.fromARGB(255, 21, 111, 180),
          textColor: Colors.white,
        );
      }
    } catch (e) {
      Navigator.pop(context);
      Fluttertoast.showToast(
        msg: e.toString(),
        backgroundColor: Color.fromARGB(255, 21, 111, 180),
        textColor: Colors.white,
      );
    }
  }

//**This is a SharedPreference function to get the data
  Future getData() async {
    sp = await SharedPreferences.getInstance();
    name = sp.getString('name') ?? "";
    roll = sp.getString('roll') ?? "";
    email = sp.getString('email') ?? "";
    image = sp.getString('image') ?? "";
    dept = sp.getString('dept') ?? "";
    batch = sp.getString('batch') ?? "";
    setState(() {});
  }

//**this function is used to load the image in the side bar from sharedprefernce
  setImage() {
    if (image != "") {
      return CircleAvatar(
        backgroundImage: NetworkImage(
          MyUrl.imageurl + image,
        ),
      );
    } else {
      return CircleAvatar(
        backgroundColor: Colors.white,
        child: CircularProgressIndicator(color: Colors.blue),
      );
    }
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

// !Init state
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
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          Stack(
            children: [
              UserAccountsDrawerHeader(
                accountName: Text(
                  name,
                  style: TextStyle(
                    color: Color.fromARGB(242, 255, 255, 255),
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    fontFamily: "Roboto",
                  ),
                ),
                accountEmail: Text(
                  email,
                  style: TextStyle(
                    color: Color.fromARGB(242, 255, 255, 255),
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    fontFamily: "Ubuntu",
                  ),
                ),
                currentAccountPicture: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ShowProfileImage(image),
                      ),
                    );
                  },
                  child: setImage(),
                ),
              ),
              Positioned(
                bottom: 75,
                left: 60,
                child: InkWell(
                  onTap: (() {
                    showModalBottomSheet(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(20),
                          ),
                        ),
                        context: context,
                        builder: (BuildContext context) {
                          return Container(
                            height: 200,
                            decoration: BoxDecoration(
                              color: Color.fromARGB(255, 255, 255, 255),
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(20),
                                topRight: Radius.circular(20),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Color.fromARGB(255, 54, 127, 244),
                                  blurRadius: 5, // soften the shadow
                                  spreadRadius: 0, //extend the shadow
                                  offset: Offset(
                                    0, // Move  horizontally
                                    -3.0, // Move vertically
                                  ),
                                )
                              ],
                            ),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.all(15),
                                      child: Text(
                                        "Uploade Profile Image",
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontWeight: FontWeight.bold,
                                          fontFamily: 'Ubuntu',
                                          fontSize: 17,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(
                                  height: 25,
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    Column(
                                      children: [
                                        GestureDetector(
                                          onTap: () {
                                            getImage(
                                                source: ImageSource.camera);
                                          },
                                          child: CircleAvatar(
                                            radius: 30,
                                            backgroundColor: Color.fromARGB(
                                                238, 120, 184, 233),
                                            child: Icon(
                                              size: 25,
                                              Icons.camera_alt,
                                              color: Color.fromARGB(
                                                  255, 0, 68, 255),
                                            ),
                                          ),
                                        ),
                                        SizedBox(
                                          height: 10,
                                        ),
                                        Text(
                                          "Camera",
                                          style: TextStyle(
                                            color: Color.fromARGB(
                                                163, 0, 112, 209),
                                            fontWeight: FontWeight.w600,
                                            fontFamily: 'Ubuntu',
                                          ),
                                        )
                                      ],
                                    ),
                                    Column(
                                      children: [
                                        GestureDetector(
                                          onTap: (() => getImage(
                                              source: ImageSource.gallery)),
                                          child: CircleAvatar(
                                            radius: 30,
                                            backgroundColor: Color.fromARGB(
                                                238, 120, 184, 233),
                                            child: Icon(
                                              size: 25,
                                              Icons.image,
                                              color: Color.fromARGB(
                                                  255, 0, 164, 52),
                                            ),
                                          ),
                                        ),
                                        SizedBox(
                                          height: 10,
                                        ),
                                        Text(
                                          "Gallery",
                                          style: TextStyle(
                                            color: Color.fromARGB(
                                                163, 0, 112, 209),
                                            fontWeight: FontWeight.w600,
                                            fontFamily: 'Ubuntu',
                                          ),
                                        )
                                      ],
                                    ),
                                    Column(
                                      children: [
                                        GestureDetector(
                                          onTap: () {
                                            deleteImage();
                                          },
                                          child: CircleAvatar(
                                            radius: 30,
                                            backgroundColor: Color.fromARGB(
                                                238, 120, 184, 233),
                                            child: Icon(
                                              size: 25,
                                              Icons.delete,
                                              color: Color.fromARGB(
                                                  205, 255, 1, 1),
                                            ),
                                          ),
                                        ),
                                        SizedBox(
                                          height: 10,
                                        ),
                                        Text(
                                          "Delete",
                                          style: TextStyle(
                                            color: Color.fromARGB(
                                                163, 0, 112, 209),
                                            fontWeight: FontWeight.w600,
                                            fontFamily: 'Ubuntu',
                                          ),
                                        )
                                      ],
                                    ),
                                  ],
                                )
                              ],
                            ),
                          );
                        });
                  }),
                  child: CircleAvatar(
                    radius: 13,
                    backgroundColor: Color.fromARGB(240, 255, 255, 255),
                    child: Icon(
                      size: 21,
                      Icons.camera_alt,
                      color: Color.fromARGB(255, 103, 148, 253),
                    ),
                  ),
                ),
              )
            ],
          ),
          // decoration: BoxDecoration(
          //     image: DecorationImage(
          //         image: AssetImage(
          //   ('assets/images/study.png'),
          // ))),
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
              Icons.person,
              color: Colors.blue,
            ),
            title: Text("Profile"),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: ((context) =>
                      ProfilePage(name, roll, email, image, dept, batch)),
                ),
              );
            },
          ),
          ListTile(
            leading: Icon(
              Icons.edit,
              color: Colors.blue,
            ),
            title: Text("Edit Profile"),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: ((context) => EditProfile()),
                ),
              );
            },
          ),
          Divider(
            endIndent: 30,
            thickness: 1.5,
          ),
          ListTile(
            leading: Icon(
              Icons.settings,
              color: Colors.blue,
            ),
            title: Text("Settings"),
            // onTap: ()=>,
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
        ],
      ),
    );
  }
}
