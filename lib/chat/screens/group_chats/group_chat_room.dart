import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../provider/auth_provider.dart';
import 'group_info.dart';


class GroupChatRoom extends StatefulWidget {
  final String groupChatId, groupName;

  GroupChatRoom({required this.groupName, required this.groupChatId, Key? key})
      : super(key: key);
  @override
  State<GroupChatRoom> createState() => _GroupChatRoomState();
}

class _GroupChatRoomState extends State<GroupChatRoom> {
  final TextEditingController _message = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  void onSendMessage() async {
    final ap = Provider.of<AuthProvider>(context, listen: false);

    if (_message.text.isNotEmpty) {
      Map<String, dynamic> chatData = {
        "sendBy": ap.userModel.name,
        "message": _message.text,
        "type": "text",
        "time": FieldValue.serverTimestamp(),
      };

      _message.clear();

      await _firestore
          .collection('listfriend')
          .doc(widget.groupChatId)
          .collection('chats')
          .add(chatData);
    }
  }
  var timeFormat = DateFormat("hh:mm");

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    final ap = Provider.of<AuthProvider>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green.withOpacity(0.5),
        title: Text(widget.groupName,style: TextStyle(fontWeight: FontWeight.w600),),
        actions: [
          IconButton(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => GroupInfo(
                    groupName: widget.groupName,
                    groupId: widget.groupChatId,
                  ),
                ),
              ),
              icon: Icon(Icons.more_vert)),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              height: size.height / 1.27,
              width: size.width,
              alignment: Alignment.bottomLeft,
              child: StreamBuilder<QuerySnapshot>(
                stream: _firestore
                    .collection('listfriend')
                    .doc(widget.groupChatId)
                    .collection('chats')
                    .orderBy('time')
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ListView.builder(
                          addAutomaticKeepAlives: true,
                          shrinkWrap: true,
                          itemCount: snapshot.data!.docs.length,
                          itemBuilder: (context, index) {
                            Map<String, dynamic> chatMap =
                            snapshot.data!.docs[index].data()
                            as Map<String, dynamic>;
                            return messageTile(size, chatMap,ap.userModel.name);
                          },
                        ),
                      ],
                    );
                  } else {
                    return Container();
                  }
                },
              ),
            ),
            Container(
              height: size.height / 10,
              width: size.width,
              alignment: Alignment.center,
              child: Container(
                height: size.height / 12,
                width: size.width / 1.1,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      height: size.height / 12,
                      width: size.width / 1.3,
                      child: TextField(
                        controller: _message,
                        decoration: InputDecoration(
                            hintText: "Nhắn tin",
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
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(
                              color: Colors.green,
                              width: 2,
                            ),
                          ),
                        ),
                      ),
                    ),
                    IconButton(
                        icon: Icon(Icons.send), onPressed: onSendMessage),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  Widget messageTile(Size size, Map<String, dynamic> chatMap,String username) {

    return Builder(builder: (_) {
      if (chatMap['type'] == "text") {
        return Container(
          margin: EdgeInsets.only(left: 10,right: 10,top: 5),
          width: size.width,
          alignment: chatMap['sendBy'] == username
              ? Alignment.centerRight
              : Alignment.centerLeft,
          child: Column(
            crossAxisAlignment: chatMap['sendBy'] == username
                ? CrossAxisAlignment.end
                : CrossAxisAlignment.start,
            children: [
              Text(
                chatMap['sendBy'],
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Colors.black,
                ),
              ),
              Container(
                  padding: EdgeInsets.symmetric(vertical: 8, horizontal: 14),
                  margin: EdgeInsets.only(top: 5),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    color: Colors.blue.withOpacity(0.7),
                  ),
                  child:  Text(
                    chatMap['message'],
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                  ),
              )
            ],
          ),
        );
      } else if (chatMap['type'] == "img") {
        return Container(
          width: size.width,
          alignment: chatMap['sendBy'] == username
              ? Alignment.centerRight
              : Alignment.centerLeft,
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 10, horizontal: 14),
            margin: EdgeInsets.symmetric(vertical: 5, horizontal: 8),
            height: size.height / 2,
            child: Image.network(
              chatMap['message'],
            ),
          ),
        );
      } else if (chatMap['type'] == "notify") {
        return Container(
          width: size.width,
          alignment: Alignment.center,
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 8, horizontal: 8),
            margin: EdgeInsets.symmetric(vertical: 5, horizontal: 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5),
              color: Colors.black38,
            ),
            child: Text(
              chatMap['message'],
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        );
      } else {
        return SizedBox();
      }
    });
  }

}
