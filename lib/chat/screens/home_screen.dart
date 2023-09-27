
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fballapp/chat/screens/chat_room.dart';
import 'package:fballapp/chat/screens/search_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../model/user_model.dart';
import '../../provider/auth_provider.dart';
import '../../utils/loading_widget.dart';
import '../models/chat_room_model.dart';
import '../models/firebase_helper.dart';
import 'group_chats/group_chat_room.dart';

class HomeScreenss extends StatefulWidget {

  const HomeScreenss(
      {Key? key})
      : super(key: key);

  @override
  State<HomeScreenss> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreenss> with SingleTickerProviderStateMixin{
  User? currentUser = FirebaseAuth.instance.currentUser;
  late TabController _tabController;
  int selectedIndex = 0;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool isLoading = true;

  List groupList = [];

  void getAvailableGroups() async {
    final ap = Provider.of<AuthProvider>(context, listen: false);

    String uid = _auth.currentUser!.uid;

    await _firestore
        .collection('users')
        .doc(ap.uid)
        .collection('groups')
        .get()
        .then((value) {
      setState(() {
        groupList = value.docs;
        isLoading = false;
      });
    });
  }
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getAvailableGroups();
    _tabController = TabController(
      initialIndex: selectedIndex,
      length: 2,
      vsync: this,
    );

  }
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    final ap = Provider.of<AuthProvider>(context, listen: false);

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text('Tin nhắn',style: TextStyle(fontWeight: FontWeight.w500),),
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              TabBar(
                indicatorColor: Colors.green,
                labelColor: Colors.green,
                unselectedLabelColor: Colors.black,
                labelStyle: TextStyle(fontSize: 18.0),
                tabs: <Tab>[
                  Tab(text: "Cá nhân",),
                  Tab(text: "Nhóm",),
                ],
                controller: _tabController,
                onTap: (int index) {
                  setState(() {
                    selectedIndex = index;
                    _tabController.animateTo(index);
                  });
                },
              ),
              IndexedStack(
                children: <Widget>[
                  Visibility(
                    child: Container(
                      margin: EdgeInsets.only(top: 10),
                      child: _buildpersonal(),
                    ),
                    maintainState: true,
                    visible: selectedIndex == 0,
                  ),
                  Visibility(

                    child: Container(
                      margin: EdgeInsets.only(top: 10),
                      child: _buildgroup()
                    ),
                    maintainState: true,
                    visible: selectedIndex == 1,
                  ),
                ],
                index: selectedIndex,
              ),
            ],
          ),
        ),
      ),
    );
  }
  Widget _buildpersonal() {
    final ap = Provider.of<AuthProvider>(context, listen: false);
    return StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection("chatRooms")
            .where("participants.${ap.userModel.uid}",
            isEqualTo: true)
            .snapshots(),
        builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return  Center(child: LoadingWidgetGreen());
          } else {
            if (snapshot.hasData) {
              QuerySnapshot querySnapshot = snapshot.data as QuerySnapshot;
              return ListView.builder(
                physics: NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                addAutomaticKeepAlives: true,
                itemCount: querySnapshot.docs.length,
                itemBuilder: (BuildContext context, int index) {
                  ChatRoomModel chatRoomModel = ChatRoomModel.fromMap(querySnapshot.docs[index].data() as Map<String, dynamic>,);
                  Map<String?, dynamic>? participants = chatRoomModel.participants;
                  List<String?> participantsKeys = participants!.keys
                      .where((element) => element != ap.userModel.uid)
                      .toList();
                  return FutureBuilder(
                    future: FirebaseHelper.getUserModelById(participantsKeys[0]),
                    builder: (context, data) {
                      if (data.connectionState == ConnectionState.waiting) {
                        return Center(
                          child: Container(),
                        );
                      } else {
                        print(data);
                        if (data.hasData) {
                          UserModel targetUser = data.data as UserModel;
                          // arrange the latest messages on top
                          return Container(
                            margin: EdgeInsets.only(bottom: 20,left: 10,right: 10),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: Colors.green.withOpacity(0.1)
                            ),
                            child: InkWell(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ChatRooms(
                                      chatRoom: chatRoomModel,
                                      userModel: ap.userModel,
                                      firebaseUser: currentUser,
                                      targetUser: targetUser,
                                    ),
                                  ),
                                );
                              },
                              child: ListTile(
                                leading: Stack(
                                  children: [
                                    CircleAvatar(
                                      maxRadius: 30,
                                      backgroundImage: NetworkImage(targetUser.profilePic!),
                                    ),
                                    if(targetUser.status == "Online")
                                    Container(
                                      height: 60,width: 60,
                                        alignment: Alignment.bottomRight,
                                        child: Icon(Icons.circle,color: Colors.green,size: 17,))
                                  ],
                                ),
                                title: Text(targetUser.name!,style: TextStyle(fontWeight: FontWeight.w500,fontSize: 18),),
                                subtitle: Text(chatRoomModel.lastMessage!),
                                trailing: Icon(Icons.navigate_next,size: 30,),
                              ),
                            ),
                          );
                        } else if (data.hasError) {
                            return Text(
                              "aaaaaaaaaaaa",
                            );
                        } else {
                          return const Center(
                            child: Text(
                              "aaaaaaaaaaaa",
                            ),
                          );
                        }
                      }
                    },
                  );
                },
              );
            } else if (snapshot.hasError) {
              return Center(child: Text(snapshot.error.toString()));
            } else {
              return const Center(
                  child: Text("No chats yet. Start chatting with someone"));
            }
          }
        });
  }
  Widget _buildgroup() {
    final Size size = MediaQuery.of(context).size;
    final ap = Provider.of<AuthProvider>(context, listen: false);
    return isLoading ?
    Container(
      height: size.height,
      width: size.width,
      alignment: Alignment.center,
      child: CircularProgressIndicator(),
    ) :
    ListView.builder(
      shrinkWrap: true,
      addAutomaticKeepAlives: true,
      itemCount: groupList.length,
      itemBuilder: (context, index) {
        return Container(
          margin: EdgeInsets.only(bottom: 20,left: 10,right: 10),
          padding: EdgeInsets.only(top: 5,bottom: 5),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Colors.green.withOpacity(0.1)
          ),
          child: ListTile(
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => GroupChatRoom(
                  groupName: groupList[index]['name'],
                  groupChatId: groupList[index]['id'],
                ),
              ),
            ),
            leading: CircleAvatar(
              backgroundColor: Colors.cyan,
              maxRadius: 30,
              child: Icon(Icons.group),
            ),
            title: Text(groupList[index]['name'],style: TextStyle(fontWeight: FontWeight.w500,fontSize: 18),),
            trailing: Icon(Icons.navigate_next,size: 30,),
          ),
        );
      },
    );
  }

}
