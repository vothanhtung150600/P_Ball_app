import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fballapp/chat/screens/chat_room.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../../model/user_model.dart';
import '../models/chat_room_model.dart';

var uuid = const Uuid();

class SearchScreens extends StatefulWidget {
  final UserModel? userModel;
  final User? firebaseUser;
  const SearchScreens(
      {Key? key, required this.userModel, required this.firebaseUser})
      : super(key: key);

  @override
  State<SearchScreens> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreens> {
  final TextEditingController _searchController = TextEditingController();
  ChatRoomModel? chatRoom = ChatRoomModel();

  Future<ChatRoomModel?> getChatRoomModel(UserModel targetUser) async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection("chatRooms")
        .where("participants.${widget.userModel?.uid}", isEqualTo: true)
        .where("participants.${targetUser.uid}", isEqualTo: true)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      log("ChatRoomModel found");
      var data = querySnapshot.docs[0].data();
      chatRoom = ChatRoomModel.fromMap(data as Map<String, dynamic>);
    } else {
      ChatRoomModel newChatRoom = ChatRoomModel(
        chatRoomId: uuid.v1(),
        lastMessage: "",
        participants: {
          widget.userModel?.uid.toString(): true,
          targetUser.uid: true,
        },
      );

      await FirebaseFirestore.instance
          .collection("chatRooms")
          .doc(newChatRoom.chatRoomId)
          .set(
            newChatRoom.toMap(),
          )
          .whenComplete(
            () => log("New chat room created"),
          );
      chatRoom = newChatRoom;
    }
    return chatRoom;
  }

  Future<dynamic> toChatRoom(BuildContext context, UserModel searchedUser,
      ChatRoomModel chatRoomModel) {
    return Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => ChatRooms(
          firebaseUser: widget.firebaseUser,
          targetUser: searchedUser,
          userModel: widget.userModel!,
          chatRoom: chatRoomModel,
        ),
      ),
    );
  }

  @override
  void initState() {
    _searchController.text = "";
    super.initState();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green.withOpacity(0.5),
        title: const Text('Tìm bạn'),
      ),
      body: SafeArea(
        child: Container(
          margin: const EdgeInsets.only(left: 10,right: 10,top: 10),
          child: Column(
            children: [
              TextFormField(
                onChanged: (value) => {setState(() {})},
                controller: _searchController,
                decoration: InputDecoration(
                  contentPadding: EdgeInsets.only(left: 20,right: 10),
                  hintText: "Nhập tên bạn muốn tìm",
                  hintStyle: TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 15,
                    color: Colors.black.withOpacity(0.2),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: const BorderSide(color: Colors.black),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: const BorderSide(color: Colors.black),
                  ),
                ),
              ),
              const SizedBox(height: 30),
              StreamBuilder(
                // dummy data
                initialData:
                    FirebaseFirestore.instance.collection('users').get(),
                stream: FirebaseFirestore.instance
                    .collection("users")
                    .where("name", isEqualTo: _searchController.text)
                    .where("name", isNotEqualTo: widget.userModel?.name)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator();
                  } else {
                    if (snapshot.hasData) {
                      QuerySnapshot querySnapshot =
                          snapshot.data as QuerySnapshot;

                      if (querySnapshot.docs.isEmpty) {
                        return const Text("Không tìm thấy");
                      } else {
                        return Expanded(
                          child: ListView.builder(
                            itemCount: querySnapshot.docs.length,
                            itemBuilder: (context, index) {
                              Map<String, dynamic> userMap =
                                  querySnapshot.docs[index].data()
                                      as Map<String, dynamic>;
                              UserModel searchedUser =
                                  UserModel.fromMap(userMap);
                              return Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  color: Colors.green.withOpacity(0.1)
                                ),
                                child: ListTile(
                                  onTap: () async {
                                    chatRoom =
                                    await getChatRoomModel(searchedUser);

                                    if (chatRoom != null) {
                                      // ignore: use_build_context_synchronously
                                      toChatRoom(
                                        context,
                                        searchedUser,
                                        chatRoom!,
                                      );
                                    }
                                  },
                                  leading: Hero(
                                    tag: searchedUser.name.toString(),
                                    child: CircleAvatar(
                                      backgroundImage: NetworkImage(
                                        searchedUser.profilePic.toString(),
                                      ),
                                    ),
                                  ),
                                  trailing: const Icon(Icons.arrow_right),
                                  title: Text(searchedUser.name.toString()),
                                  subtitle: Text(
                                    searchedUser.phoneNumber.toString(),
                                  ),
                                ),
                              );
                            },
                          ),
                        );
                      }
                    } else if (snapshot.hasError) {
                      return Text(snapshot.error.toString());
                    } else {
                      return const Text("No Data");
                    }
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
