import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fballapp/post/comments.dart';
import 'package:fballapp/provider/auth_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../chat/models/chat_room_model.dart';
import '../chat/screens/chat_room.dart';
import '../model/user_model.dart';

class PostCard extends StatefulWidget {
  PostCard(this.post,this.userMap);
  final Map<String, dynamic> userMap;
  final post;
  @override
  _PostCardState createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  late bool _isLiked;
  bool _isyou = false;
  bool _isLoading = false;
  ChatRoomModel? chatRoom = ChatRoomModel();

  @override
  void initState() {
    super.initState();
    final user = Provider.of<AuthProvider>(context, listen: false);

    if (widget.post.data()['likedBy'].contains(user.userModel.uid))
      _isLiked = true;
    else
      _isLiked = false;
    if(widget.post.data()['name'] == user.userModel.name)
      setState(() {
        _isyou = true;
      });
  }


  Future<ChatRoomModel?> getChatRoomModel(UserModel targetUser) async {
    final ap = Provider.of<AuthProvider>(context, listen: false);

    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection("chatRooms")
        .where("participants.${ap.userModel.uid}", isEqualTo: true)
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
          ap.userModel.uid.toString(): true,
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
    final ap = Provider.of<AuthProvider>(context, listen: false);
    User? currentUser = FirebaseAuth.instance.currentUser;

    return Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatRooms(
          firebaseUser: currentUser,
          targetUser: searchedUser,
          userModel: ap.userModel,
          chatRoom: chatRoomModel,
        ),
      ),
    );
  }

  void _setLike() async {
    final user = Provider.of<AuthProvider>(context, listen: false);
    if (_isLiked)
      await FirebaseFirestore.instance
          .collection('posts')
          .doc(widget.post.id)
          .update({
        'likedBy': FieldValue.arrayUnion([user.userModel.uid])
      });
    else
      await FirebaseFirestore.instance
          .collection('posts')
          .doc(widget.post.id)
          .update({
        'likedBy': FieldValue.arrayRemove([user.userModel.uid])
      });
  }

  @override
  Widget build(BuildContext context) {
    final ap = Provider.of<AuthProvider>(context, listen: false);
    final date = widget.post.data()['createdAt'].toDate();
    final dateformat = DateFormat.yMd().add_jm().format(date);
    UserModel searchedUser = UserModel.frommain(widget.userMap);

    return _isLoading
        ? Center(child: CircularProgressIndicator())
        : Card(
            color: Colors.white,
            child: Column(
              children: [
                ListTile(
                  leading: CircleAvatar(
                    backgroundImage: NetworkImage(
                      widget.post.data()['profilePic'],
                    ),
                    radius: 20,
                  ),
                  title: Text(widget.post.data()['name'],style: TextStyle(fontWeight: FontWeight.w600),),
                  subtitle: Text(dateformat),
                  onTap: () => {
                    // Navigator.of(context).pushNamed('/other_profile',
                    //     arguments: [
                    //       widget.post.data()['userId'],
                    //       'patients'
                    //     ])
                  },
                ),
              // if (widget.post.data()['title'] != '')
              //   Text(
              //     widget.post.data()['title'],
              //     style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
              //   ),
              Row(
                children: [
                  Container(
                    width: 350,
                    margin: EdgeInsets.only(left: 10,bottom: 20),
                    child: Text(
                      widget.post.data()['main_text'],
                      style: TextStyle(fontSize: 17,overflow: TextOverflow.clip),
                    ),
                  ),
                ],
              ),
              Container(
                height: 40,
                margin: EdgeInsets.only(left: 10,right: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    widget.post.data()['likedBy'].length >= 1 ?
                      Row(
                      children: [
                        Icon(Icons.thumb_up_alt,color: _isLiked ? Colors.green : Colors.black,),
                        SizedBox(width: 5,),
                        Text(widget.post.data()['likedBy'].length.toString()),
                      ],
                    ): Row(
                      children: [
                        SizedBox(width: 5,),
                        Text(''),
                      ],
                    ),
                    widget.post.data()['comment_count'] >= 1?
                      GestureDetector(
                        onTap: () {
                          Navigator.push(context, MaterialPageRoute(builder: (context) => CommentPage(widget.post.id),));
                        },
                        child: Row(
                          children: [
                            Text(widget.post.data()['comment_count'].toString()),
                            SizedBox(width: 5,),
                            Text('bình luận')
                          ],
                        ),
                      ): Row(
                      children: [
                        SizedBox(width: 5,),
                        Text('')
                      ],
                    )
                  ],
                ),
              ),
                Container(height: 1,width: double.infinity,color: Colors.black,),
                _isyou ?
                Container(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Expanded(
                        flex: 1,
                        child: Container(
                          height: 40,
                          decoration: BoxDecoration(
                              border: Border(
                                  right: BorderSide(
                                    width: 1,
                                    color: Colors.black,
                                  )
                              )
                          ),
                          child: GestureDetector(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.thumb_up_alt,color:_isLiked ? Colors.green : Colors.black,),
                                SizedBox(width: 7,),
                                Text('Thích',
                                    style: TextStyle(
                                      color:_isLiked ? Colors.green : Colors.black,
                                    )),
                              ],
                            ),
                            onTap: () {
                              setState(() {
                                _isLiked = !_isLiked;
                              });
                              _setLike();
                            },
                          ),
                        ),
                      ),
                      //if (onPressCancel != null)
                      //Container(height: SizeConfig.textMultiplier * 5,width:SizeConfig.heightMultiplier*0.1,color: AppColors.colorMain4,),
                      Expanded(
                        flex: 1,
                        child: Container(
                          child: GestureDetector(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.comment,color: Colors.black,),
                                SizedBox(width: 7,),
                                Text('Bình luận',
                                    style: TextStyle(
                                      color: Colors.black,
                                    )),
                              ],
                            ),
                            onTap: () {
                              Navigator.push(context, MaterialPageRoute(builder: (context) => CommentPage(widget.post.id),));
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                )
                    :
                Container(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                        Expanded(
                          flex: 1,
                          child: Container(
                            height: 40,
                            decoration: BoxDecoration(
                                border: Border(
                                    right: BorderSide(
                                      width: 1,
                                      color: Colors.black,
                                    )
                                )
                            ),
                            child: GestureDetector(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.thumb_up_alt,color:_isLiked ? Colors.green : Colors.black,),
                                  SizedBox(width: 7,),
                                  Text('Thích',
                                      style: TextStyle(
                                          color:_isLiked ? Colors.green : Colors.black,
                                      )),
                                ],
                              ),
                              onTap: () {
                                setState(() {
                                  _isLiked = !_isLiked;
                                });
                                _setLike();
                              },
                            ),
                          ),
                        ),
                      //if (onPressCancel != null)
                      //Container(height: SizeConfig.textMultiplier * 5,width:SizeConfig.heightMultiplier*0.1,color: AppColors.colorMain4,),
                        Expanded(
                          flex: 1,
                          child: Container(
                            height: 40,
                            decoration: BoxDecoration(
                                border: Border(
                                    right: BorderSide(
                                      width: 1,
                                      color: Colors.black,
                                    )
                                )
                            ),
                            child: GestureDetector(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.comment,color: Colors.black,),
                                  SizedBox(width: 7,),
                                  Text('Bình luận',
                                      style: TextStyle(
                                          color: Colors.black,
                                      )),
                                ],
                              ),
                              onTap: () {
                                Navigator.push(context, MaterialPageRoute(builder: (context) => CommentPage(widget.post.id),));
                                },
                            ),
                          ),
                        ),
                      Expanded(
                        flex: 1,
                        child: GestureDetector(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.send,color: Colors.black,),
                              SizedBox(width: 7,),
                              Text('Nhắn tin',
                                  style: TextStyle(
                                    color: Colors.black,
                                  )),
                            ],
                          ),
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
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          )
    );
  }
}
