
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fballapp/main.dart';
import 'package:fballapp/utils/loading_widget.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../dialog/showdialog.dart';
import '../../../provider/auth_provider.dart';
import '../../screens/home_screen.dart';
import 'add_members.dart';

class GroupInfo extends StatefulWidget {
  final String groupId, groupName;
  const GroupInfo({required this.groupId, required this.groupName, Key? key})
      : super(key: key);

  @override
  State<GroupInfo> createState() => _GroupInfoState();
}

class _GroupInfoState extends State<GroupInfo> {
  List membersList = [];
  bool isLoading = true;

  FirebaseFirestore _firestore = FirebaseFirestore.instance;
  FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();

    getGroupDetails();
  }

  Future getGroupDetails() async {
    await _firestore
        .collection('groups')
        .doc(widget.groupId)
        .get()
        .then((chatMap) {
      membersList = chatMap['members'];
      print(membersList);
      isLoading = false;
      setState(() {});
    });
  }

  bool checkAdmin() {
    final ap = Provider.of<AuthProvider>(context, listen: false);
    bool isAdmin = false;

    membersList.forEach((element) {
      if (element['uid'] == ap.userModel.phoneNumber) {
        isAdmin = element['isAdmin'];
      }
    });
    return isAdmin;
  }

  Future removeMembers(int index) async {
    String uid = membersList[index]['uid'];

    setState(() {
      isLoading = true;
      membersList.removeAt(index);
    });

    await _firestore.collection('groups').doc(widget.groupId).update({
      "members": membersList,
    }).then((value) async {
      await _firestore
          .collection('users')
          .doc(uid)
          .collection('groups')
          .doc(widget.groupId)
          .delete();

      setState(() {
        isLoading = false;
      });
    });
  }

  void showDialogBox(int index) {
    final ap = Provider.of<AuthProvider>(context, listen: false);
    if (checkAdmin()) {
      if (ap.userModel.phoneNumber != membersList[index]['uid']) {
        showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                content: ListTile(
                  onTap: () => removeMembers(index),
                  title: Text("Remove This Member"),
                ),
              );
            });
      }
    }
  }

  Future onLeaveGroup() async {
    if (!checkAdmin()) {
      setState(() {
        isLoading = true;
      });
      for (int i = 0; i < membersList.length; i++) {
        if (membersList[i]['uid'] == _auth.currentUser!.uid) {
          membersList.removeAt(i);
        }
      }

      await _firestore.collection('groups').doc(widget.groupId).update({
        "members": membersList,
      });

      await _firestore
          .collection('users')
          .doc(_auth.currentUser!.uid)
          .collection('groups')
          .doc(widget.groupId)
          .delete();

      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => MyHomePage()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green.withOpacity(0.5),
        title: Text('Thành viên nhóm'),
        actions: [
          checkAdmin() ?
          IconButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => AddMembersINGroup(
                      groupChatId: widget.groupId,
                      name: widget.groupName,
                      membersList: membersList,
                    ),
                  ),
                );
              },
              icon: Icon(Icons.add,)
          ) : Container()
        ],
      ),
      body: isLoading
          ? Container(
              height: size.height,
              width: size.width,
              alignment: Alignment.center,
              child: LoadingWidgetGreen(),
            )
          : Stack(
            children: [
              SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      height: size.height / 8,
                      width: size.width / 1.1,
                      child: Row(
                        children: [
                          Container(
                            height: size.height / 11,
                            width: size.height / 11,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.grey,
                            ),
                            child: Icon(
                              Icons.group,
                              color: Colors.white,
                              size: size.width / 10,
                            ),
                          ),
                          SizedBox(
                            width: size.width / 20,
                          ),
                          Expanded(
                            child: Container(
                              child: Text(
                                widget.groupName,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: size.width / 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: size.width / 1.1,
                      child: Text(
                        "${membersList.length} Thành viên",
                        style: TextStyle(
                          fontSize: size.width / 20,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    SizedBox(
                      height: size.height / 20,
                    ),
                    Flexible(
                      child: ListView.builder(
                        itemCount: membersList.length,
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemBuilder: (context, index) {
                          return ListTile(
                            leading: Hero(
                              tag: Text(membersList[index]['name']),
                              child: CircleAvatar(
                                backgroundImage: NetworkImage(
                                  membersList[index]['profilePic'].toString(),
                                ),
                              ),
                            ),
                            title: Text(
                              membersList[index]['name'],
                              style: TextStyle(
                                fontSize: size.width / 22,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            subtitle: Text(membersList[index]['phoneNumber'].toString().replaceAll("+84", "0"),),
                            trailing: membersList[index]['isAdmin'] ? Text("Admin") : IconButton(
                                onPressed: (){
                                    removetv(
                                      context,
                                      'Bạn có muốn xóa thành viên này ra khỏi nhóm không?',
                                      onPressOK: () {removeMembers(index);},
                                      onPressCancel: (){}
                                    );
                              }, icon: Icon(Icons.close)),
                          );
                        },
                      ),
                    ),

                  ],
                ),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  margin: EdgeInsets.only(bottom: 30,left: 10),
                  child: ListTile(
                    onTap: onLeaveGroup,
                    leading: Icon(
                      Icons.logout,
                      color: Colors.redAccent,
                    ),
                    title: Text(
                      "Thoát khỏi nhóm",
                      style: TextStyle(
                        fontSize: size.width / 22,
                        fontWeight: FontWeight.w500,
                        color: Colors.redAccent,
                      ),
                    ),
                  ),
                ),
              ),
            ],
      ),
    );
  }
}
