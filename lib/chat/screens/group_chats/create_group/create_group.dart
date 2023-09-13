import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fballapp/main.dart';
import 'package:fballapp/utils/loading_widget.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import '../../../../provider/auth_provider.dart';
import '../../../screens/home_screen.dart';

class CreateGroup extends StatefulWidget {
  final List<Map<String, dynamic>> membersList;

  const CreateGroup({required this.membersList, Key? key}) : super(key: key);

  @override
  State<CreateGroup> createState() => _CreateGroupState();
}

class _CreateGroupState extends State<CreateGroup> {
  final TextEditingController _groupName = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool isLoading = false;

  void createGroup() async {
    final ap = Provider.of<AuthProvider>(context, listen: false);

    setState(() {
      isLoading = true;
    });

    String groupId = Uuid().v1();

    await _firestore.collection('groups').doc(groupId).set({
      "members": widget.membersList,
      "id": groupId,
    });

    for (int i = 0; i < widget.membersList.length; i++) {
      String uid = widget.membersList[i]['uid'];

      await _firestore
          .collection('users')
          .doc(uid)
          .collection('groups')
          .doc(groupId)
          .set({
        "name": _groupName.text,
        "id": groupId,
      });
    }

    await _firestore.collection('groups').doc(groupId).collection('chats').add({
      "message": "${ap.userModel.name} Created This Group.",
      "type": "notify",
    });

    Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => MyHomePage()), (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green.withOpacity(0.5),
        title: Text("Tên Nhóm"),
      ),
      body: isLoading
          ? Container(
              height: size.height,
              width: size.width,
              alignment: Alignment.center,
              child: LoadingWidgetGreen(),
            )
          : Column(
              children: [
                Container(
                  margin: EdgeInsets.only(top: 20),
                  height: size.height / 14,
                  width: size.width,
                  alignment: Alignment.center,
                  child: Container(
                    height: size.height / 14,
                    width: size.width / 1.15,
                    child: TextField(
                      controller: _groupName,
                      decoration: InputDecoration(
                        hintText: "Nhập tên nhóm",
                        hintStyle: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 15,
                          color: Colors.black.withOpacity(0.2),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(color: Colors.black),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(color: Colors.black),
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: size.height / 50,
                ),
                ElevatedButton(
                  style: ButtonStyle(backgroundColor: MaterialStatePropertyAll(Colors.grey)),
                  onPressed: createGroup,
                  child: Text("Tạo nhóm",style: TextStyle(color: Colors.white),),
                ),
              ],
            ),
    );
  }
}


//