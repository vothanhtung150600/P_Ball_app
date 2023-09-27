import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

import '../../model/user_model.dart';
import '../models/chat_room_model.dart';
import '../models/message_model.dart';

var uuid = const Uuid();

class ChatRooms extends StatefulWidget {
  final UserModel targetUser;
  final UserModel userModel;
  final ChatRoomModel? chatRoom;
  final User? firebaseUser;

  const ChatRooms(
      {Key? key,
      required this.chatRoom,
      required this.userModel,
      required this.firebaseUser,
      required this.targetUser})
      : super(key: key);

  @override
  State<ChatRooms> createState() => _ChatRoomsState();
}

class _ChatRoomsState extends State<ChatRooms> {
  TextEditingController messageController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    messageController.text = "";
    super.initState();
  }

  @override
  void dispose() {
    messageController.dispose();
    super.dispose();
  }

  void sendMessage() async {
    String? message = messageController.text.trim();
    messageController.clear();

    if (message.isNotEmpty) {
      MessageModel messageModel = MessageModel(
        text: message,
        messageId: uuid.v1(),
        sender: widget.userModel.uid,
        sentTime: DateTime.now(),
        seen: false,
      );

      // await not used, can store message when internet not available
      await FirebaseFirestore.instance
          .collection("chatRooms")
          .doc(widget.chatRoom?.chatRoomId)
          .collection("messages")
          .doc(messageModel.messageId)
          .set(
            messageModel.toMap(),
          )
          .whenComplete(
        () {
          log("Message sent");
        },
      );

      widget.chatRoom?.lastMessage = message;
      await FirebaseFirestore.instance
          .collection("chatRooms")
          .doc(widget.chatRoom?.chatRoomId)
          .set(
            widget.chatRoom!.toMap(),
          );
    }
  }

  var timeFormat = DateFormat("hh:mm");

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Row(
          children: [
            widget.targetUser.profilePic.toString().isNotEmpty
                ? CircleAvatar(
              maxRadius: 20,
                    backgroundImage:
                        NetworkImage(widget.targetUser.profilePic.toString()),
                  )
                : const CircleAvatar(
                    backgroundColor: Colors.grey,
                    child: Icon(Icons.person),
                  ),
            const SizedBox(width: 15),
            Container(
              margin: EdgeInsets.only(left: 5),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(widget.targetUser.name.toString(),style: TextStyle(fontSize: 18),),
                  StreamBuilder<DocumentSnapshot>(
                    stream:
                    _firestore.collection("users").doc(widget.targetUser.uid).snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.data != null) {
                        if(widget.targetUser.status == "Offline"){
                          return Container(
                            child: Row(
                              children: [
                                  Icon(Icons.circle,size: 15,color: Colors.red,),
                                  SizedBox(width: 5,),
                                  Text(
                                    widget.targetUser.status,
                                    style: TextStyle(fontSize: 14,color: Colors.red),
                                  ),
                              ],
                            ),
                          );
                        }
                          return Container(
                          child: Row(
                            children: [
                              Icon(Icons.circle,size: 15,color: Colors.green,),
                              SizedBox(width: 5,),
                              Text(
                                widget.targetUser.status,
                                style: TextStyle(fontSize: 14,color: Colors.green),
                              ),
                            ],
                          ),
                        );
                      } else {
                        return Container();
                      }
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection("chatRooms")
                    .doc(widget.chatRoom?.chatRoomId)
                    .collection("messages")
                    .orderBy("sentTime", descending: true)
                    .snapshots(),
                builder: (BuildContext context, AsyncSnapshot snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  } else {
                    if (snapshot.hasData) {
                      QuerySnapshot querySnapshot =
                          snapshot.data as QuerySnapshot;
                      return ListView.builder(
                        shrinkWrap: true,
                        reverse: true,
                        itemCount: querySnapshot.docs.length,
                        itemBuilder: (BuildContext context, int index) {
                          MessageModel currentMessage = MessageModel.fromMap(
                            querySnapshot.docs[index].data()
                                as Map<String, dynamic>,
                          );
                          return Row(
                            mainAxisAlignment:
                                currentMessage.sender == widget.userModel.uid
                                    ? MainAxisAlignment.end
                                    : MainAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              InkWell(
                                onLongPress: () async {
                                  await FirebaseFirestore.instance
                                      .collection("chatRooms")
                                      .doc(widget.chatRoom?.chatRoomId)
                                      .collection("messages")
                                      .doc(currentMessage.messageId)
                                      .delete();
                                },
                                onDoubleTap: () async {
                                  // edit message
                                  if (messageController.text.isNotEmpty) {
                                    await FirebaseFirestore.instance
                                        .collection("chatRooms")
                                        .doc(widget.chatRoom?.chatRoomId)
                                        .collection("messages")
                                        .doc(currentMessage.messageId)
                                        .update({
                                      "text": messageController.text,
                                    });
                                  }
                                },
                                borderRadius: BorderRadius.circular(20),
                                splashColor: Colors.green,
                                child: Container(
                                  margin: const EdgeInsets.only(left: 10,right: 10,bottom: 10),
                                  child: Column(
                                    crossAxisAlignment: currentMessage.sender ==
                                            widget.userModel.uid
                                        ? CrossAxisAlignment.end
                                        : CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        // alignment: (currentMessage.sender ==
                                        //         widget.userModel.userId)
                                        //     ? Alignment.centerRight
                                        //     : Alignment.centerLeft,
                                        constraints: const BoxConstraints(
                                          maxWidth: 250,
                                        ),
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 10,
                                          horizontal: 10,
                                        ),
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(15),
                                          color: (currentMessage.sender ==
                                                  widget.userModel.uid)
                                              ? Colors.red.withOpacity(0.7)
                                              : Colors.blue.withOpacity(0.7),
                                        ),
                                        child: Text(
                                          currentMessage.text.toString(),
                                          textAlign: currentMessage.sender ==
                                                  widget.userModel.uid
                                              ? TextAlign.end
                                              : TextAlign.start,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ),
                                      Text(
                                        //  + ${DateTime.parse(currentMessage.sentTime.toString()).second} + ${DateTime.parse(currentMessage.sentTime.toString()).millisecond}
                                        timeFormat
                                            .format(currentMessage.sentTime!),
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      );
                    } else if (snapshot.hasError) {
                      return Text(snapshot.error.toString());
                    } else {
                      return const Center(
                        child: Text("No messages"),
                      );
                    }
                  }
                },
              ),
            ),
            Container(
              margin: EdgeInsets.only(left: 10,right: 10),
              height: size.height / 10,
              width: double.infinity,
              child: Container(
                height: size.height / 12,
                width: size.width / 1.1,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      height: size.height / 12,
                      width: size.width / 1.25,
                      child: TextField(
                        controller: messageController,
                        decoration: InputDecoration(
                          hintStyle: TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 15,
                            color: Colors.black.withOpacity(0.4),
                          ),
                          hintText: 'Nhắn tin',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          enabledBorder: const OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(10)),
                            borderSide: BorderSide(
                              color: Colors.green,
                              width: 2,
                            ),
                          ),
                          suffixIcon: IconButton(
                              icon: Icon(Icons.camera_alt_outlined), onPressed: () {},),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(
                              color: Colors.green,
                              width: 2,
                            ),
                          ),
                        ),
                        // styling
                      ),
                    ),
                    IconButton(
                        icon: Icon(Icons.send), onPressed: () => sendMessage()),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
