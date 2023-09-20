import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fballapp/post/comments.dart';
import 'package:fballapp/provider/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../chat/screens/chat_room.dart';

class PostCard extends StatefulWidget {
  PostCard(this.post);

  final post;
  @override
  _PostCardState createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  late bool _isLiked;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final user = Provider.of<AuthProvider>(context, listen: false);
    if (widget.post.data()['likedBy'].contains(user.userModel.uid))
      _isLiked = true;
    else
      _isLiked = false;
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
    return _isLoading
        ? Center(child: CircularProgressIndicator())
        : Card(
            color: Colors.white,
            child: Column(
              children: [
                ListTile(
                  leading: CircleAvatar(
                    backgroundImage: NetworkImage(
                      widget.post.data()['photo'],
                    ),
                    radius: 20,
                  ),
                  title: Text(widget.post.data()['username'],style: TextStyle(fontWeight: FontWeight.w600),),
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
                    ],
                  ),
                ),
            ],
          )
    );
  }
}
