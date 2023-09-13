import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fballapp/dialog/showdialog.dart';
import 'package:flutter/material.dart';

class AddMembersINGroup extends StatefulWidget {
  final String groupChatId, name;
  final List membersList;
  const AddMembersINGroup(
      {required this.name,
      required this.membersList,
      required this.groupChatId,
      Key? key})
      : super(key: key);

  @override
  _AddMembersINGroupState createState() => _AddMembersINGroupState();
}

class _AddMembersINGroupState extends State<AddMembersINGroup> {
  final TextEditingController _search = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  Map<String, dynamic>? userMap;
  bool isLoading = false;
  List membersList = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    membersList = widget.membersList;
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

  void onAddMembers() async {
    bool isAlreadyExist = false;

    for (int i = 0; i < membersList.length; i++) {
      if (membersList[i]['uid'] == userMap!['uid']) {
        isAlreadyExist = true;
      }
    }

    if (!isAlreadyExist) {
      setState(() async{
        membersList.add(userMap);
        await _firestore.collection('groups').doc(widget.groupChatId).update({
          "members": membersList,
        });

        await _firestore
            .collection('users')
            .doc(userMap!['uid'])
            .collection('groups')
            .doc(widget.groupChatId)
            .set({"name": widget.name, "id": widget.groupChatId});

        userMap = null;

        Navigator.pop(context);
      });
    }else{
      faillogin(context, 'Tồn tại người này rồi!',onPressOK: () {});
    }

  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green.withOpacity(0.5),
        title: Text("Thêm thành viên"),
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: 20,
            ),
            Container(
              height: size.height / 14,
              width: size.width,
              alignment: Alignment.center,
              child: Container(
                height: size.height / 14,
                width: size.width / 1.15,
                child: TextField(
                  controller: _search,
                  decoration: InputDecoration(
                    hintText: "Nhập tên bạn tìm",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(
              height: size.height / 50,
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
                ? Container(
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
                      title: Text(userMap!['name']),
                      subtitle: Text(userMap!['phoneNumber']),
                      trailing: IconButton(icon: Icon(Icons.add),onPressed: onAddMembers),
                    ),
                )
                : SizedBox(),
          ],
        ),
      ),
    );
  }
}
