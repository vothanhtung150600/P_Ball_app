import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import '../../../../dialog/showdialog.dart';
import '../../../../main.dart';
import '../../../../provider/auth_provider.dart';
import 'create_group.dart';


class AddMembersInGroup extends StatefulWidget {
  const AddMembersInGroup({Key? key}) : super(key: key);

  @override
  State<AddMembersInGroup> createState() => _AddMembersInGroupState();
}

class _AddMembersInGroupState extends State<AddMembersInGroup> {
  final TextEditingController _search = TextEditingController();
  final TextEditingController _groupName = TextEditingController();
  FirebaseFirestore _firestore = FirebaseFirestore.instance;
  FirebaseAuth _auth = FirebaseAuth.instance;
  List<Map<String, dynamic>> membersList = [];
  bool isLoading = false;
  Map<String, dynamic>? userMap;

  @override
  void initState() {
    super.initState();
    getCurrentUserDetails();
  }

  void getCurrentUserDetails() async {
    await _firestore
        .collection('users')
        .doc(_auth.currentUser!.uid)
        .get()
        .then((map) {
      setState(() {
        membersList.add({
          "name": map['name'],
          "uid": map['uid'],
          "phoneNumber": map['phoneNumber'],
          "profilePic": map['profilePic'],
          "isAdmin": true,
        });
      });
    });
  }

  void onSearch() async {
    setState(() {
      isLoading = true;
    });

    await _firestore
        .collection('users')
        .where("name", isEqualTo: _search.text)
        .get()
        .then((value) {
      setState(() {
        userMap = value.docs[0].data();
        isLoading = false;
      });
      print(userMap);
    });
  }

  void onResultTap() {
    bool isAlreadyExist = false;

    for (int i = 0; i < membersList.length; i++) {
      if (membersList[i]['uid'] == userMap!['uid']) {
        isAlreadyExist = true;
      }
    }

    if (!isAlreadyExist) {
      setState(() {
        membersList.add({
          "name": userMap!['name'],
          "phoneNumber":  userMap!['phoneNumber'],
          "profilePic":  userMap!['profilePic'],
          "uid": userMap!['uid'],
          "isAdmin": false,
        });

        userMap = null;
      });
    }
    _search.text = '';
  }


  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    final ap = Provider.of<AuthProvider>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green.withOpacity(0.5),
        title: Text("Tạo Nhóm"),
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(height: 20,),
            Container(
              height: size.height / 14,
              width: size.width,
              alignment: Alignment.center,
              child: Container(
                height: size.height / 14,
                width: size.width / 1.15,
                child: TextField(
                  onChanged: (value) => {setState(() {})},
                  controller: _search,
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
              ),
            ),
            isLoading
                ? Container(
                    height: size.height / 12,
                    width: size.height / 12,
                    alignment: Alignment.center,
                    child: CircularProgressIndicator(),
                  )
                : ElevatedButton(
                    style: ButtonStyle(backgroundColor: MaterialStatePropertyAll(Colors.grey)),
                    onPressed: onSearch,
                    child: Text("Tìm",style: TextStyle(color: Colors.white),),
                  ),
            userMap != null
                ?
            Container(
              margin: EdgeInsets.all(10),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.green.withOpacity(0.1)
              ),
              child: ListTile(
                leading: Hero(
                  tag: Text(userMap!['name']),
                  child: CircleAvatar(
                    backgroundImage: NetworkImage(
                        userMap!['profilePic'].toString(),
                    ),
                  ),
                ),
                trailing: GestureDetector(
                  onTap: onResultTap,
                  child: Container(
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.blue
                    ),
                    child: Text('Thêm',style: TextStyle(color: Colors.white),),
                  ),
                ),
                title: Text(userMap!['name'].toString(),style: TextStyle(fontWeight: FontWeight.w600),),
                subtitle: Text(userMap!['phoneNumber'].toString(),),
              ),
            )
                : SizedBox(),
            Container(
              alignment: Alignment.topLeft,
              margin: EdgeInsets.only(top: 20,left: 20),
              child: Text('Thành viên',style: TextStyle(fontSize: 18,fontWeight: FontWeight.w600),),
            ),
            Flexible(
              child: ListView.builder(
                itemCount: membersList.length,
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemBuilder: (context, index) {
                  bool isadmin = false;
                  if(index == 0){
                    isadmin = true;
                  }
                  return
                    Container(
                      margin: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: Colors.green.withOpacity(0.1)
                      ),
                      child: ListTile(
                        leading: Hero(
                          tag: Text(membersList[index]['name']),
                          child: CircleAvatar(
                            backgroundImage: NetworkImage(
                              membersList[index]['profilePic'].toString(),
                            ),
                          ),
                        ),

                        trailing: isadmin ? Text('Admin') :  GestureDetector(
                          onTap: (){
                            if (membersList[index]['uid'] != ap.userModel.phoneNumber) {
                              setState(() {
                                membersList.removeAt(index);
                              });
                            }
                          },
                          child: Container(
                            padding: EdgeInsets.all(10),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: Colors.red
                            ),
                            child: Text('Xóa',style: TextStyle(color: Colors.white),),
                          ),
                        ),
                        title: Text(membersList[index]['name'].toString(),style: TextStyle(fontWeight: FontWeight.w600),),
                        subtitle: Text(membersList[index]['phoneNumber'].toString().replaceAll("+84", "0"),),
                      ),
                    );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: membersList.length > 1
          ? FloatingActionButton(
              backgroundColor: Colors.green.withOpacity(0.8),
              child: Icon(Icons.check,color: Colors.black,),
              onPressed: () => showModalBottomSheet<void>(
                useSafeArea: true,
                isScrollControlled: true,
                context: context,
                builder: (BuildContext context) {


                  return StatefulBuilder(
                    builder: (context, setState) {
                      return Container(
                        margin: EdgeInsets.only(bottom: 20,left: 10,right: 10),
                        padding: EdgeInsets.zero,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Padding(
                          padding: EdgeInsets.only(
                              bottom: MediaQuery.of(context).viewInsets.bottom),
                          child: Column(
                            children: [
                              Expanded(
                                flex: 1,
                                child: Container(
                                  margin: EdgeInsets.only(left: 10,right: 30),
                                  child: Row(
                                    children: [
                                      GestureDetector(
                                        onTap: () {
                                          Navigator.pop(context);
                                        },
                                        child: Icon(Icons.close,color: Colors.black,),
                                      ),
                                      SizedBox(width: 50,),
                                      Container(
                                        width: 200,
                                        child: Text(
                                          'Nhập tên nhóm',
                                          maxLines: 2,
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                              overflow: TextOverflow.ellipsis,
                                              fontSize: 25,
                                              fontWeight: FontWeight.w600
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              Container(height: 1,width: double.infinity,decoration: BoxDecoration(border: Border.all(color: Colors.black),color: Colors.white.withOpacity(0.5)),),
                              Expanded(
                                  flex: 4,
                                  child: Container(
                                    margin: EdgeInsets.only(top: 20),
                                    child: Column(
                                      children: [
                                        Text('Nhập tên nhóm',style: TextStyle(fontSize: 18),),
                                        SizedBox(height: 30,),
                                        Container(
                                          margin: EdgeInsets.only(left: 10,right: 10),
                                          child: TextFormField(
                                            obscureText:  false,
                                            textInputAction: TextInputAction.done,
                                            maxLines: 1,
                                            textAlignVertical: TextAlignVertical.top,
                                            minLines: 1,
                                            style: TextStyle(color: Colors.black),
                                            controller: _groupName,
                                            decoration: InputDecoration(
                                              border: OutlineInputBorder(),
                                              labelStyle: TextStyle(color: Colors.grey),
                                              enabledBorder:  OutlineInputBorder(
                                                borderSide:  BorderSide(color: Colors.black, width: 0.0),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                              ),
                              Container(height: 1,width: double.infinity,color: Colors.white.withOpacity(0.5),),

                              Expanded(
                                  flex: 1,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                    children: [
                                      Expanded(
                                          flex: 1,
                                          child: Container(
                                            child: GestureDetector(
                                              child: Container(
                                                margin: EdgeInsets.all(5),
                                                decoration: BoxDecoration(
                                                    color: Colors.green.withOpacity(0.8),
                                                    borderRadius: BorderRadius.circular(10)
                                                ),
                                                child: Center(
                                                  child: Text('Tạo nhóm',
                                                      style: TextStyle(
                                                          fontSize: 18,
                                                          color: Colors.white,
                                                          letterSpacing: 0.05,
                                                          fontWeight: FontWeight.w700
                                                      )),
                                                ),
                                              ),
                                              onTap: createGroup,
                                            ),
                                          )
                                      ),
                                    ],
                                  )
                              )
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            )
          : SizedBox(),
    );
  }
  void createGroup() async {
    final ap = Provider.of<AuthProvider>(context, listen: false);

    setState(() {
      isLoading = true;
    });

    String groupId = Uuid().v1();

    await _firestore.collection('groups').doc(groupId).set({
      "members": membersList,
      "id": groupId,
    });

    for (int i = 0; i < membersList.length; i++) {
      String uid = membersList[i]['uid'];

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
}
