import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_notify_demo/config/setting.dart';
import 'package:firebase_notify_demo/models/ui_helper.dart';
import 'package:firebase_notify_demo/models/user_model.dart';
import 'package:firebase_notify_demo/views/signin.dart';
import 'package:firebase_notify_demo/widgets/widget.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';

class CompleteProfile extends StatefulWidget {
  final UserModel userModel;
  final User firebaseUser;

  const CompleteProfile({Key? key, required this.userModel, required this.firebaseUser}) : super(key: key);

  @override
  _CompleteProfileState createState() => _CompleteProfileState();
}

class _CompleteProfileState extends State<CompleteProfile> {

  File? image;
  TextEditingController nameController = TextEditingController();

  void selectImage(ImageSource source) async {
    XFile? pickedFile =  await ImagePicker().pickImage(source: source);

    if(pickedFile != null){
      cropImage(pickedFile);
    }
  }

  void cropImage(XFile file) async {
    File? croppedImage = await ImageCropper.cropImage(
      sourcePath: file.path,
      aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
      compressQuality: 20,
    );

    if(croppedImage != null){
      setState(() {
        image = croppedImage;
      });
    }
  }

  void showImageOptions() {
    showDialog(context: context, builder: (context) {
      return AlertDialog(
        title: const Text('Upload profile picture'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('Camera'),
              leading: const Icon(Icons.camera, size: 40,),
              onTap: () {
                Navigator.pop(context);
                selectImage(ImageSource.camera);
              },
            ),
            ListTile(
              title: const Text('Gallery'),
              leading: const Icon(Icons.image, size: 40,),
              onTap: () {
                Navigator.pop(context);
                selectImage(ImageSource.gallery);
              },
            ),
          ],
        ),
      );
    });
  }

  void checkValues() {
    String name = nameController.text.trim();
    if(name == '' || image == null) {
      showDialog(context: context, builder: (context) {
        return const AlertDialog(
          title: Text('Error'),
          content: Text('Input your name.'),
        );
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Uploading data..."),));
      uploadData();
    }
  }

  void uploadData() async {
    UploadTask uploadTask = FirebaseStorage.instance.ref("profilepictures")
        .child(widget.userModel.uid.toString()).putFile(image!);

    TaskSnapshot snapshot = await uploadTask;

    String? imageUrl = await snapshot.ref.getDownloadURL();
    String? name = nameController.text.trim();

    widget.userModel.name = name;
    widget.userModel.avatar = imageUrl;

    UIHelper.showLoadingDialog(context, 'Saving');

    await FirebaseFirestore.instance
        .collection("users").doc(widget.userModel.uid)
        .set(widget.userModel.toMap()).then((value) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Data has been uploaded."),));
      showDialog(context: context, builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.black,
          titleTextStyle: simpleTextStyle(),
          contentTextStyle: simpleTextStyle(),
          title: const Text('Notice'),
          content: const Text('Data has been uploaded.'),
          actions: [
            TextButton(
                onPressed: () => Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) => const SignIn()), (route) => false),
                child: const Text('Go to login'),
            ),
          ],
        );
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBarMain(context),
      body: SafeArea(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 30),
          child: ListView(
            children: [
              GestureDetector(
                onTap: () {
                  showImageOptions();
                },
                child: CircleAvatar(
                  radius: 60,
                  backgroundColor: Setting.themeColor,
                  child: image!=null ? null : const Icon(Icons.person, size: 60),
                  backgroundImage: image!=null ? FileImage(image!) : null,
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: nameController,
                decoration: textFieldInputDecoration('Full name'),
                style: simpleTextStyle(),
              ),
              const SizedBox(height: 20),
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                ),
                child: ElevatedButton(
                  onPressed: () {
                    checkValues();
                  },
                  child: const Text('Submit'),
                  style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(Setting.themeColor),
                      padding: MaterialStateProperty.all<EdgeInsets>(const EdgeInsets.all(12)),
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(RoundedRectangleBorder(borderRadius: BorderRadius.circular(18.0)))
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
