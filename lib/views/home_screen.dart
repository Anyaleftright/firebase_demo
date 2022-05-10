import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_notify_demo/config/setting.dart';
import 'package:firebase_notify_demo/models/chat_room_model.dart';
import 'package:firebase_notify_demo/models/firebase_helper.dart';
import 'package:firebase_notify_demo/models/ui_helper.dart';
import 'package:firebase_notify_demo/models/user_model.dart';
import 'package:firebase_notify_demo/views/search_screen.dart';
import 'package:firebase_notify_demo/widgets/widget.dart';
import 'package:flutter/material.dart';

import 'chat_room_screen.dart';

class HomeScreen extends StatefulWidget {
  final UserModel userModel;
  final User firebaseUser;

  const HomeScreen({Key? key, required this.userModel, required this.firebaseUser}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBarMain(context),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // UIHelper.showLoadingDialog(context, 'Loading');
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => SearchScreen(userModel: widget.userModel, firebaseUser: widget.firebaseUser)));
        },
        child: const Icon(Icons.search, color: Colors.white),
        backgroundColor: Setting.themeColor,
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,
        backgroundColor: Setting.themeColor,
        color: Colors.white,
        child: SafeArea(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 12),
            child: StreamBuilder(
              stream: FirebaseFirestore.instance.collection('chatRooms')
                  .where('participants.${widget.userModel.uid}', isEqualTo: true).snapshots(),
              builder: (context, snapshot) {
                if(snapshot.connectionState == ConnectionState.active) {
                  if(snapshot.hasData){
                    QuerySnapshot dataSnapshot = snapshot.data as QuerySnapshot;
                    return ListView.builder(
                      itemCount: dataSnapshot.docs.length,
                      itemBuilder: (context, index) {
                        ChatRoomModel chatRoomModel = ChatRoomModel.fromMap(dataSnapshot.docs[index].data() as Map<String, dynamic>);
                        Map<String, dynamic> participants = chatRoomModel.participants!;
                        List<String> participantKeys = participants.keys.toList();
                        participantKeys.remove(widget.userModel.uid);

                        return FutureBuilder(
                          future: FirebaseHelper.getUserModelById(participantKeys[0]),
                          builder: (context, userData) {
                            if(userData.connectionState == ConnectionState.done) {
                              if(userData.data!=null) {
                                UserModel targetUser = userData.data as UserModel;
                                return ListTile(
                                  onTap: () async {
                                    if (chatRoomModel != null) {
                                      Navigator.push(context, MaterialPageRoute(builder: (context) {
                                        return ChatRoomScreen(
                                            userModel: widget.userModel,
                                            firebaseUser:
                                            widget.firebaseUser,
                                            targetUser: targetUser,
                                            chatRoom: chatRoomModel);
                                      })
                                      );
                                    }
                                  },
                                  leading: CircleAvatar(
                                    radius: 32,
                                    backgroundImage: NetworkImage(targetUser.avatar.toString()),
                                  ),
                                  title: Text(
                                    targetUser.name.toString(),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 20,
                                    ),
                                  ),
                                  subtitle: Text(
                                    chatRoomModel.lastMessage.toString(),
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.8),
                                      fontSize: 15,
                                    ),
                                  ),
                                );
                              } else {
                                return Container();
                              }
                            } else {
                              return Container();
                            }
                          },
                        );
                      },
                    );
                  } else if (snapshot.hasError) {
                    return Center(child: Text(snapshot.error.toString()));
                  } else {
                    return const Center(child: Text("Empty."));
                  }
                } else {
                  return const isLoading();
                }
              },
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _refresh() async {
    await Future.delayed(const Duration(milliseconds: 500));
    setState(() {});
  }
}
