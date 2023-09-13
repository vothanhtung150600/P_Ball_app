import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../provider/auth_provider.dart';
import 'create_group.dart';


class AddMembersInGroup extends StatefulWidget {
  const AddMembersInGroup({Key? key}) : super(key: key);

  @override
  State<AddMembersInGroup> createState() => _AddMembersInGroupState();
}

class _AddMembersInGroupState extends State<AddMembersInGroup> {
  final TextEditingController _search = TextEditingController();
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
                trailing: IconButton(icon: Icon(Icons.add),onPressed: onResultTap,),
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
                        trailing: isadmin ? null :  IconButton(icon: Icon(Icons.close),onPressed: () {
                          if (membersList[index]['uid'] != ap.userModel.phoneNumber) {
                            setState(() {
                              membersList.removeAt(index);
                            });
                          }
                        }),
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
              child: Icon(Icons.forward,color: Colors.black,),
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => CreateGroup(
                    membersList: membersList,
                  ),
                ),
              ),
            )
          : SizedBox(),
    );
  }
}
