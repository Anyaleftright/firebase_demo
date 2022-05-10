import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_notify_demo/config/setting.dart';
import 'package:firebase_notify_demo/main.dart';
import 'package:firebase_notify_demo/models/chat_room_model.dart';
import 'package:firebase_notify_demo/models/user_model.dart';
import 'package:firebase_notify_demo/views/chat_room_screen.dart';
import 'package:firebase_notify_demo/widgets/widget.dart';
import 'package:flutter/material.dart';

class SearchScreen extends StatefulWidget {
  final UserModel userModel;
  final User firebaseUser;

  const SearchScreen({Key? key, required this.userModel, required this.firebaseUser}) : super(key: key);

  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {

  TextEditingController searchController = TextEditingController();

  Future<ChatRoomModel?> getChatRoomModel(UserModel targetUser) async {
    ChatRoomModel? chatRoom;

    QuerySnapshot snapshot = await FirebaseFirestore.instance.collection('chatRooms')
        .where('participants.${widget.userModel.uid}', isEqualTo: true)
        .where('participants.${targetUser.uid}', isEqualTo: true)
        .get();

    if(snapshot.docs.isNotEmpty) {
      var docData = snapshot.docs[0].data();
      ChatRoomModel existingChatRoom = ChatRoomModel.fromMap(docData as Map<String, dynamic>);

      chatRoom = existingChatRoom;

      log('Chatroom already created.');
    } else {
      ChatRoomModel newChatRoom = ChatRoomModel(
          roomId: uuid.v1(),
          lastMessage: "",
          participants: {
            widget.userModel.uid.toString(): true,
            targetUser.uid.toString(): true,
          }
      );
      await FirebaseFirestore.instance.collection('chatRooms').doc(newChatRoom.roomId).set(newChatRoom.toMap());
      chatRoom = newChatRoom;

      log('New chat room has been created.');

    }
    return chatRoom;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBarMain(context),
      body: SafeArea(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
          child: Column(
            children: [
              TextField(
                controller: searchController,
                decoration: textFieldInputDecoration('Email address'),
                style: simpleTextStyle(),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    setState(() {});
                  },
                  child: const Text('Search'),
                  style: ElevatedButton.styleFrom(
                    elevation: 0,
                    primary: Setting.themeColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              StreamBuilder(
                stream: FirebaseFirestore.instance.collection('users').
                where('email', isGreaterThanOrEqualTo: searchController.text).
                where('email', isNotEqualTo: widget.userModel.email).
                snapshots(),
                builder: (context, snapshot) {
                  if(snapshot.connectionState == ConnectionState.active){
                    if(snapshot.hasData){
                      QuerySnapshot dataSnapshot = snapshot.data as QuerySnapshot;

                      if(dataSnapshot.docs.isNotEmpty){
                        Map<String, dynamic> userMap = dataSnapshot.docs[0].data() as Map<String, dynamic>;

                        UserModel searchedUser = UserModel.fromMap(userMap);

                        return Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(15),
                            border: Border.all(
                              color: Setting.themeColor,
                              width: 2,
                            ),
                          ),
                          child: ListTile(
                            onTap: () async {
                              ChatRoomModel? chatRoomModel = await getChatRoomModel(searchedUser);

                              if (chatRoomModel != null) {
                                Navigator.pop(context);
                                Navigator.push(context, MaterialPageRoute(builder: (context) {
                                  return ChatRoomScreen(
                                      userModel: widget.userModel,
                                      firebaseUser:
                                      widget.firebaseUser,
                                      targetUser: searchedUser,
                                      chatRoom: chatRoomModel);
                                })
                                );
                              }
                            },
                            leading: CircleAvatar(backgroundImage: NetworkImage(searchedUser.avatar!)),
                            title: Text(searchedUser.name!),
                            subtitle: Text(searchedUser.email!),
                            trailing: const Icon(Icons.message_outlined, size: 18),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            textColor: Colors.white,
                            iconColor: Colors.white,
                          ),
                        );
                      } else {
                        return Text('No result', style: simpleTextStyle());
                      }

                    } else if(snapshot.hasError) {
                      return Text('Error.', style: simpleTextStyle());
                    } else {
                      return Text('No result', style: simpleTextStyle());
                    }

                  } else {
                    return const CircularProgressIndicator();
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
