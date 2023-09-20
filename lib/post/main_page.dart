import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fballapp/post/create_post.dart';
import 'package:fballapp/provider/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import 'PostCard.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  var _isLoading = true;
  var _isInit = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInit)
      _isLoading = false;
    else
      _isInit = true;
  }

  @override
  Widget build(BuildContext context) {
    final  user = Provider.of<AuthProvider>(context, listen: false);
    return _isLoading
        ? Container()
        : Scaffold(
            body: SingleChildScrollView(
              child: Column(
                children: [
                  AppBar(
                    leading: Container(
                      height: 40,
                      margin: EdgeInsets.only(top: 10,bottom: 10,left: 10),
                      child: CircleAvatar(
                        backgroundImage: NetworkImage(user.userModel.profilePic),
                      ),
                    ),
                    title: Container(
                      height: 40,
                      margin: EdgeInsets.only(top: 10,bottom: 10),
                      child: TextField(
                        onTap: (){
                          Navigator.push(context, MaterialPageRoute(builder: (context) => CreatePost(),));
                        },
                        readOnly: true,
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.only(left: 20),
                          hintText: "Đăng bài cáp kèo nào :>",
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
                    centerTitle: true,
                  ),
                  StreamBuilder(
                      stream: FirebaseFirestore.instance
                          .collection('posts')
                          .orderBy(
                            'createdAt',
                            descending: true,
                          )
                          .snapshots(),
                      builder: (ctx, AsyncSnapshot<QuerySnapshot> postSnapshot) {
                        if (postSnapshot.connectionState == ConnectionState.waiting) {
                          return Center(
                            child: CircularProgressIndicator(),
                          );
                        }
                        final postDocs = postSnapshot.data!.docs;
                        return ListView.builder(
                          addAutomaticKeepAlives: true,
                          physics: NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          itemBuilder: (context, index) {
                            return Container(
                                margin: EdgeInsets.only(left: 10,right: 10,top: 10),
                                child: PostCard(postDocs[index]));
                          },
                          itemCount: postDocs.length,
                        );
                      }),
                  SizedBox(height: 40,)
                ],
              ),
            ),
          );
  }
}
