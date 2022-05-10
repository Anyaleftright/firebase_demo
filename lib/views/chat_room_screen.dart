import 'dart:developer';
import 'dart:io';

// import 'package:better_player/better_player.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:emoji_picker/emoji_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_notify_demo/config/setting.dart';
import 'package:firebase_notify_demo/main.dart';
import 'package:firebase_notify_demo/models/chat_room_model.dart';
import 'package:firebase_notify_demo/models/message_model.dart';
import 'package:firebase_notify_demo/models/user_model.dart';
import 'package:firebase_notify_demo/widgets/widget.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_player/video_player.dart';

class ChatRoomScreen extends StatefulWidget {
  final UserModel userModel;
  final User firebaseUser;
  final UserModel targetUser;
  final ChatRoomModel chatRoom;

  const ChatRoomScreen(
      {Key? key,
      required this.userModel,
      required this.firebaseUser,
      required this.targetUser,
      required this.chatRoom})
      : super(key: key);

  @override
  _ChatRoomScreenState createState() => _ChatRoomScreenState();
}

class _ChatRoomScreenState extends State<ChatRoomScreen> {
  File? image;
  File? video;

  TextEditingController messageController = TextEditingController();
  VideoPlayerController? _videoPlayerController;

  bool isShowEmoji = false;
  final FocusNode _keyboard = FocusNode();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // isShowEmoji = false;
    _keyboard.addListener(() {
      if (_keyboard.hasFocus) {
        setState(() {
          isShowEmoji = false;
        });
      }
    });
  }

  void selectImage(ImageSource source) async {
    XFile? pickedFile = await ImagePicker().pickImage(source: source);
    if (pickedFile != null) {
      editImage(pickedFile);
    }
  }

  void editImage(XFile file) async {
    File? editedImage = await ImageCropper.cropImage(sourcePath: file.path);
    if (editedImage != null) {
      setState(() {
        image = editedImage;
      });
    }
  }

  void uploadImage() async {
    if (image != null) {
      ///Lấy tên file
      String? fileName = image?.path.split('/').last;

      UploadTask uploadTask = FirebaseStorage.instance
          .ref("imageMessage")
          .child(widget.chatRoom.roomId.toString() + '/$fileName')
          .putFile(image!);
      TaskSnapshot snapshot = await uploadTask;
      String? imageUrl = await snapshot.ref.getDownloadURL();

      MessageModel messageModel = MessageModel(
        messageId: uuid.v1(),
        sender: widget.userModel.uid,
        createdOn: DateTime.now(),
        text: imageUrl,
        seen: false,
        type: 'image',
      );

      FirebaseFirestore.instance
          .collection('chatRooms')
          .doc(widget.chatRoom.roomId)
          .collection('messages')
          .doc(messageModel.messageId)
          .set(messageModel.toMap());

      widget.chatRoom.lastMessage =
          widget.userModel.name.toString() + ' has sent an image.';
      FirebaseFirestore.instance
          .collection('chatRooms')
          .doc(widget.chatRoom.roomId)
          .set(widget.chatRoom.toMap());
      log('Image uploaded');
      // image!.delete();
      setState(() {
        image = null;
      });
    }
  }

  void selectVideo(ImageSource source) async {
    final pickedFile = await ImagePicker().pickVideo(source: source);
    video = File(pickedFile!.path);

    // print(pickedFile.path.toString());

    _videoPlayerController = VideoPlayerController.file(video!)
      ..initialize().then((value) {
        setState(() {});
        _videoPlayerController!.play();
      });
  }

  void uploadVideo() async {
    if (video != null) {
      ///Lấy tên file
      String? fileName = video?.path.split('/').last;

      UploadTask uploadTask = FirebaseStorage.instance
          .ref("videoMessage")
          .child(widget.chatRoom.roomId.toString() + '/$fileName')
          .putFile(video!);
      TaskSnapshot snapshot = await uploadTask;
      String? videoUrl = await snapshot.ref.getDownloadURL();

      // print(videoUrl);
      // print(fileName);

      MessageModel messageModel = MessageModel(
        messageId: uuid.v1(),
        sender: widget.userModel.uid,
        createdOn: DateTime.now(),
        text: videoUrl,
        seen: false,
        type: 'video',
      );

      FirebaseFirestore.instance
          .collection('chatRooms')
          .doc(widget.chatRoom.roomId)
          .collection('messages')
          .doc(messageModel.messageId)
          .set(messageModel.toMap());

      widget.chatRoom.lastMessage =
          widget.userModel.name.toString() + ' has sent a video.';
      FirebaseFirestore.instance
          .collection('chatRooms')
          .doc(widget.chatRoom.roomId)
          .set(widget.chatRoom.toMap());
      log('video uploaded');
      // image!.delete();
      setState(() {
        video = null;
      });
    }
  }

  void sendMessage() async {
    String msg = messageController.text.trim();
    messageController.clear();

    if (msg != '') {
      MessageModel messageModel = MessageModel(
        messageId: uuid.v1(),
        sender: widget.userModel.uid,
        createdOn: DateTime.now(),
        text: msg,
        seen: false,
        type: 'text',
      );
      FirebaseFirestore.instance
          .collection('chatRooms')
          .doc(widget.chatRoom.roomId)
          .collection('messages')
          .doc(messageModel.messageId)
          .set(messageModel.toMap());

      widget.chatRoom.lastMessage = msg;
      FirebaseFirestore.instance
          .collection('chatRooms')
          .doc(widget.chatRoom.roomId)
          .set(widget.chatRoom.toMap());

      log('Message sent');
    }
  }

  @override
  Widget build(BuildContext context) {
    MediaQueryData queryData = MediaQuery.of(context);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Setting.themeColor,
        title: Row(
          children: [
            CircleAvatar(
              backgroundImage:
                  NetworkImage(widget.targetUser.avatar.toString()),
            ),
            const SizedBox(width: 6),
            Text(widget.targetUser.name.toString(), style: simpleTextStyle()),
          ],
        ),
      ),
      body: WillPopScope(
        child: SafeArea(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Column(
              children: [
                Expanded(
                  child: StreamBuilder(
                    stream: FirebaseFirestore.instance
                        .collection('chatRooms')
                        .doc(widget.chatRoom.roomId)
                        .collection('messages')
                        .orderBy('createdOn', descending: true)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.active) {
                        if (snapshot.hasData) {
                          QuerySnapshot dataSnapshot =
                              snapshot.data as QuerySnapshot;
                          return ListView.builder(
                            physics: const BouncingScrollPhysics(),
                            reverse: true,
                            itemCount: dataSnapshot.docs.length,
                            itemBuilder: (context, index) {
                              MessageModel current = MessageModel.fromMap(
                                  dataSnapshot.docs[index].data()
                                      as Map<String, dynamic>);
                              return Row(
                                mainAxisAlignment:
                                    current.sender == widget.userModel.uid
                                        ? MainAxisAlignment.end
                                        : MainAxisAlignment.start,
                                children: [
                                  if (current.type.toString() == 'image')
                                    Container(
                                        constraints: BoxConstraints(
                                          maxHeight:
                                              queryData.size.height * 0.5,
                                          maxWidth: queryData.size.width * 0.7,
                                        ),
                                        margin: const EdgeInsets.symmetric(
                                            vertical: 6),
                                        child: GestureDetector(
                                          onTap: () =>
                                              Navigator.of(context).push(
                                            MaterialPageRoute(
                                              builder: (context) => ExtendImage(
                                                imageUrl:
                                                    current.text.toString(),
                                              ),
                                            ),
                                          ),
                                          onLongPress: () {
                                            // print('on long press');
                                            showModalBottomSheet(
                                                context: context,
                                                builder: (_) {
                                                  return Container(
                                                    padding: const EdgeInsets
                                                            .symmetric(
                                                        horizontal: 40,
                                                        vertical: 30),
                                                    child: Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceBetween,
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .center,
                                                      children: [
                                                        DetailsMessage(
                                                            icon: const Icon(
                                                                Icons.save),
                                                            title: 'Save',
                                                            onPress: () {}),
                                                        DetailsMessage(
                                                            icon: const Icon(
                                                                Icons.info),
                                                            title: 'Info',
                                                            onPress: () {}),
                                                        DetailsMessage(
                                                            icon: const Icon(
                                                                Icons.delete),
                                                            title: 'Delete',
                                                            onPress: () {}),
                                                      ],
                                                    ),
                                                  );
                                                });
                                          },
                                          child: ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(24),
                                            child: current.text!.isNotEmpty
                                                ? Image.network(
                                                    current.text.toString())
                                                : const isLoading(),
                                          ),
                                        ))
                                  else if (current.type.toString() == 'video')
                                    Container(
                                        /*constraints: BoxConstraints(
                                          maxHeight: queryData.size.height * 0.2,
                                          maxWidth: queryData.size.width * 0.7,
                                        ),
                                        margin: const EdgeInsets.symmetric(vertical: 6),
                                        child: GestureDetector(
                                          */ /*onTap: () => Navigator.of(context).push(
                                            MaterialPageRoute(
                                              builder: (context) => ExtendImage(
                                                imageUrl: current.text.toString(),
                                              ),
                                            ),
                                          ),*/ /*
                                          onTap: () {},
                                          child: ClipRRect(
                                            borderRadius: BorderRadius.circular(24),
                                            child: BetterPlayer.network(
                                              current.text.toString(),
                                              betterPlayerConfiguration: const BetterPlayerConfiguration(
                                                aspectRatio: 16/9,
                                              ),
                                            )
                                          ),
                                        )*/
                                        )
                                  else
                                    Container(
                                      constraints: BoxConstraints(
                                          maxWidth:
                                              queryData.size.width * 0.75),
                                      margin: const EdgeInsets.symmetric(
                                          vertical: 6),
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 10, horizontal: 15),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(30),
                                        color: current.sender ==
                                                widget.userModel.uid
                                            ? Setting.themeColor
                                            : Colors.grey.withOpacity(0.5),
                                      ),
                                      child: Text(current.text.toString(),
                                          style: simpleTextStyle()),
                                    ),
                                ],
                              );
                            },
                          );
                        } else if (snapshot.hasError) {
                          return const Center(child: Text('Lost connection.'));
                        } else {
                          return const Center(child: Text("Let's Talking"));
                        }
                      } else {
                        return const isLoading();
                      }
                    },
                  ),
                ),
                Container(
                  child: image == null
                      ? null
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Stack(
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    selectImage(ImageSource.gallery);
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.only(
                                        bottom: 12, left: 12),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(24),
                                      child: Image.file(
                                        image!,
                                        width: 150,
                                        height: 150,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                ),
                                Positioned(
                                  right: 0,
                                  top: 0,
                                  child: IconButton(
                                    onPressed: () {
                                      setState(() {
                                        image = null;
                                      });
                                    },
                                    icon: Container(
                                      decoration: BoxDecoration(
                                        color: Colors.grey,
                                        borderRadius: BorderRadius.circular(90),
                                      ),
                                      child: const Icon(
                                        Icons.close_rounded,
                                        size: 24,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                ),
                Column(
                  children: [
                    if (video != null)
                      _videoPlayerController!.value.isInitialized
                          ? AspectRatio(
                              aspectRatio:
                                  _videoPlayerController!.value.aspectRatio,
                              child: VideoPlayer(_videoPlayerController!))
                          : Container(),
                  ],
                ),
                Container(
                  height: queryData.size.height * 0.1,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    children: [
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        child: IconButton(
                          onPressed: () {
                            selectImage(ImageSource.gallery);
                          },
                          icon: const Icon(Icons.photo,
                              size: 32, color: Colors.grey),
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        child: IconButton(
                          onPressed: () {
                            selectVideo(ImageSource.gallery);
                          },
                          icon: const Icon(Icons.video_library,
                              size: 32, color: Colors.grey),
                        ),
                      ),
                      Flexible(
                        child: TextField(
                          focusNode: _keyboard,
                          controller: messageController,
                          style: simpleTextStyle(),
                          maxLines: null,
                          decoration: textFieldMessage(
                            () {
                              setState(() {
                                /// when keyboard is opened, click emoji btn can dispose the keyboard
                                isShowEmoji = !isShowEmoji;
                                _keyboard.unfocus();
                                _keyboard.canRequestFocus = false;
                              });
                            },
                          ),
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.only(left: 8),
                        child: IconButton(
                          onPressed: () {
                            sendMessage();
                            uploadImage();
                            uploadVideo();
                          },
                          icon: Icon(Icons.send,
                              size: 30,
                              color: messageController.text.isEmpty
                                  ? Colors.grey
                                  : Setting.themeColor),
                        ),
                      )
                    ],
                  ),
                ),
                isShowEmoji == true
                    ? EmojiPicker(
                        rows: 3,
                        columns: 7,
                        bgColor: Colors.black,
                        indicatorColor: Setting.themeColor,
                        onEmojiSelected: (emoji, category) {
                          messageController.text =
                              messageController.text + emoji.emoji;
                        },
                      )
                    : Container(height: 1),
              ],
            ),
          ),
        ),
        onWillPop: () {
          if (isShowEmoji == true) {
            setState(() {
              isShowEmoji = false;
            });
          } else {
            Navigator.pop(context);
          }
          return Future.value(false);
        },
      ),
    );
  }
}

class ExtendImage extends StatelessWidget {
  final String imageUrl;

  const ExtendImage({Key? key, required this.imageUrl}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;

    return Scaffold(
      body: Container(
        height: size.height,
        width: size.width,
        color: Colors.black,
        child: InteractiveViewer(
          child: Image.network(imageUrl),
        ),
      ),
    );
  }
}

class DetailsMessage extends StatelessWidget {
  final Icon icon;
  final String title;
  final VoidCallback onPress;

  const DetailsMessage(
      {Key? key,
      required this.icon,
      required this.title,
      required this.onPress})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPress,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          icon,
          Text(title),
        ],
      ),
    );
  }
}
