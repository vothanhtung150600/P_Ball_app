// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:fballapp/test/Screens/ChatRoom.dart';
// import 'package:fballapp/test/group_chats/group_chat_screen.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
//
// import '../../provider/auth_provider.dart';
// import '../group_chats/group_chat_room.dart';
//
// class HomeScreenChatGroup extends StatefulWidget {
//   @override
//   _HomeScreenChatState createState() => _HomeScreenChatState();
// }
//
// class _HomeScreenChatState extends State<HomeScreenChatGroup> with WidgetsBindingObserver {
//   Map<String, dynamic>? userMap;
//   bool isLoading = false;
//   final TextEditingController _search = TextEditingController();
//   final FirebaseAuth _auth = FirebaseAuth.instance;
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//   List Listfriend = [];
//
//   @override
//   void initState() {
//     super.initState();
//     WidgetsBinding.instance!.addObserver(this);
//     setStatus("Online");
//     getAvailableGroups();
//   }
//
//   void setStatus(String status) async {
//     await _firestore.collection('users').doc(_auth.currentUser!.uid).update({
//       "status": status,
//     });
//   }
//
//   @override
//   void didChangeAppLifecycleState(AppLifecycleState state) {
//     if (state == AppLifecycleState.resumed) {
//       // online
//       setStatus("Online");
//     } else {
//       // offline
//       setStatus("Offline");
//     }
//   }
//
//   void getAvailableGroups() async {
//     final ap = Provider.of<AuthProvider>(context, listen: false);
//
//     String uid = _auth.currentUser!.uid;
//
//     await _firestore
//         .collection('users')
//         .doc(ap.uid)
//         .collection('listfriend')
//         .get()
//         .then((value) {
//       setState(() {
//         Listfriend = value.docs;
//         isLoading = false;
//       });
//     });
//   }
//   String chatRoomId(String user1, String user2) {
//     if (user1[0].toLowerCase().codeUnits[0] >
//         user2.toLowerCase().codeUnits[0]) {
//       return "$user1$user2";
//     } else {
//       return "$user2$user1";
//     }
//   }
//
//   void onSearch() async {
//     FirebaseFirestore _firestore = FirebaseFirestore.instance;
//
//     setState(() {
//       isLoading = true;
//     });
//
//     await _firestore
//         .collection('users')
//         .where("name", isEqualTo: _search.text)
//         .get()
//         .then((value) {
//       setState(() {
//         userMap = value.docs[0].data();
//         isLoading = false;
//       });
//       print(userMap);
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final size = MediaQuery.of(context).size;
//     final ap = Provider.of<AuthProvider>(context, listen: false);
//
//     return Scaffold(
//       body: Column(
//         children: [
//           Row(
//             children: [
//               GestureDetector(
//                 onTap: () {
//                   Navigator.of(context).push(
//                     MaterialPageRoute(
//                       builder: (_) => GroupChatHomeScreen(),
//                     ),
//                   );
//                 },
//                 child: Container(
//                   margin: EdgeInsets.only(top: 20,left: 20),
//                   height: 60,
//                   width: 60,
//                   decoration: BoxDecoration(
//                     color: Colors.greenAccent,
//                     border: Border.all(color: Colors.black),
//                     borderRadius: BorderRadius.circular(10)
//                   ),
//                   child: Icon(Icons.group_add_rounded,color: Colors.black,),
//                 ),
//               ),
//               GestureDetector(
//                 onTap: () {
//                   Navigator.of(context).push(
//                     MaterialPageRoute(
//                       builder: (_) => GroupChatHomeScreen(),
//                     ),
//                   );
//                 },
//                 child: Container(
//                   margin: EdgeInsets.only(top: 20,left: 20),
//                   height: 60,
//                   width: 60,
//                   decoration: BoxDecoration(
//                       color: Colors.greenAccent,
//                       border: Border.all(color: Colors.black),
//                       borderRadius: BorderRadius.circular(10)
//                   ),
//                   child: Icon(Icons.search,color: Colors.black,),
//                 ),
//               )
//             ],
//           ),
//           isLoading ? Center(
//             child: Container(
//               height: size.height / 20,
//               width: size.height / 20,
//               child: CircularProgressIndicator(),
//             ),
//           ) :
//           SingleChildScrollView(
//             child: Column(
//               children: [
//                 // Container(
//                 //   margin: EdgeInsets.only(left: 20,right: 20,top: 20),
//                 //   child: Container(
//                 //     height: size.height / 16,
//                 //     width: double.infinity,
//                 //     child: TextField(
//                 //       controller: _search,
//                 //       decoration: InputDecoration(
//                 //         hintText: "Tìm kiếm bạn bè",
//                 //         hintStyle: TextStyle(
//                 //           fontWeight: FontWeight.w500,
//                 //           fontSize: 15,
//                 //           color: Colors.black.withOpacity(0.4),
//                 //         ),
//                 //         enabledBorder: OutlineInputBorder(
//                 //           borderRadius: BorderRadius.circular(40),
//                 //           borderSide: const BorderSide(color: Colors.black),
//                 //         ),
//                 //         focusedBorder: OutlineInputBorder(
//                 //           borderRadius: BorderRadius.circular(40),
//                 //           borderSide: const BorderSide(color: Colors.black),
//                 //         ),
//                 //       ),
//                 //     ),
//                 //   ),
//                 // ),
//                 // SizedBox(
//                 //   height: size.height / 50,
//                 // ),
//                 // ElevatedButton(
//                 //   onPressed: onSearch,
//                 //   child: Text("Search"),
//                 // ),
//                 // SizedBox(
//                 //   height: size.height / 30,
//                 // ),
//                 // userMap != null
//                 //     ? ListTile(
//                 //   onTap: () {
//                 //     String roomId = chatRoomId(
//                 //         ap.userModel.name,
//                 //         userMap!['name']);
//                 //
//                 //     Navigator.of(context).push(
//                 //       MaterialPageRoute(
//                 //         builder: (_) => ChatRoom(
//                 //           chatRoomId: roomId,
//                 //           userMap: userMap!,
//                 //         ),
//                 //       ),
//                 //     );
//                 //   },
//                 //   leading: Image.network(userMap!['profilePic']),
//                 //   title: Text(
//                 //     userMap!['name'],
//                 //     style: TextStyle(
//                 //       color: Colors.black,
//                 //       fontSize: 17,
//                 //       fontWeight: FontWeight.w500,
//                 //     ),
//                 //   ),
//                 //   trailing: Icon(Icons.chat, color: Colors.black),
//                 // )
//                 //     : Container(),
//
//                 isLoading
//                     ? Container(
//                   height: size.height,
//                   width: size.width,
//                   alignment: Alignment.center,
//                   child: CircularProgressIndicator(),
//                 )
//                     : ListView.builder(
//                   shrinkWrap: true,
//                   addAutomaticKeepAlives: true,
//                   itemCount: Listfriend.length,
//                   itemBuilder: (context, index) {
//                     return ListTile(
//                       onTap: () => Navigator.of(context).push(
//                         MaterialPageRoute(
//                           builder: (_) => GroupChatRoom(
//                             groupName: Listfriend[index]['name'],
//                             groupChatId: Listfriend[index]['id'],
//                           ),
//                         ),
//                       ),
//                       leading: Icon(Icons.person),
//                       title: Text(Listfriend[index]['name']),
//                     );
//                   },
//                 ),
//               ],
//             ),
//           ),
//
//         ],
//       ),
//     );
//   }
// }
