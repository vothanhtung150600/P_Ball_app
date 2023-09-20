import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fballapp/provider/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class CommentPage extends StatefulWidget {
  String id;
  CommentPage(this.id);

  @override
  _CommentPageState createState() => _CommentPageState();
}

class _CommentPageState extends State<CommentPage> {
  final _controller = new TextEditingController();
  var _enteredComment = '';
  var post;
  var _isLoading = false;
  var _isinit = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_isinit) {
      post = widget.id;
    }
    _isinit = false;
  }
  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        title: Text('Bình luận'),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection('posts')
                    .doc(post)
                    .collection('comments')
                    .orderBy(
                      'createdAt',
                    )
                    .snapshots(),
                builder: (ctx, AsyncSnapshot<QuerySnapshot> commentSnapshot) {
                  if (commentSnapshot.connectionState ==
                      ConnectionState.waiting) {
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                  final commentDocs = commentSnapshot.data!.docs;
                  if (commentDocs.isEmpty)
                    return Center(child: Text('Chưa có bình luận'));
                  else
                    return ListView.builder(
                      itemBuilder: (context, index) {
                        final comment = commentDocs[index];
                        final date = comment['createdAt'].toDate();
                        final dateformat =
                            DateFormat().add_jm().format(date);
                        return Container(
                          margin: EdgeInsets.only(right: 10,bottom: 10),
                          child: Container(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ListTile(
                                  leading: CircleAvatar(
                                    backgroundImage: NetworkImage(
                                      comment['photo'],
                                    ),
                                    radius: 20,
                                  ),
                                  title: Row(
                                    children: [
                                      Text(comment['username'],style: TextStyle(fontWeight: FontWeight.w600),),
                                      Container(
                                        width: 10,
                                      ),
                                    ],
                                  ),
                                  subtitle: Padding(
                                    padding:
                                        const EdgeInsets.fromLTRB(0, 5, 0, 0),
                                    child: Text(dateformat),
                                  ),
                                ),
                                Container(
                                  padding: EdgeInsets.all(10),
                                  margin: EdgeInsets.only(left: 70),
                                  decoration: BoxDecoration(
                                    color: Colors.green.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(10)
                                  ),
                                  child: Container(
                                    child: Text(
                                      comment['text'],
                                      style: TextStyle(fontSize: 15),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                      itemCount: commentDocs.length,
                    );
                }),
          ),
          Container(
            margin: EdgeInsets.only(top: 8,right: 10),
            padding: EdgeInsets.all(8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Expanded(
                  child: TextField(
                    keyboardType: TextInputType.multiline,
                    maxLines: null,
                    controller: _controller,
                    textCapitalization: TextCapitalization.sentences,
                    autocorrect: true,
                    enableSuggestions: true,
                    decoration: InputDecoration(
                      hintStyle: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 15,
                        color: Colors.black.withOpacity(0.4),
                      ),
                      hintText: 'Bình luận',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      enabledBorder: const OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                        borderSide: BorderSide(
                          color: Colors.black,
                          width: 2,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(
                          color: Colors.black,
                          width: 2,
                        ),
                      ),
                    ),                    onChanged: (value) {
                      _enteredComment = value;
                    },
                  ),
                ),
                SizedBox(width: 10,),
                _isLoading ? Center(
                        child: CircularProgressIndicator(),
                      )
                    : GestureDetector(
                        child: Icon(Icons.send,color: Colors.black,),
                        onTap: _controller.text.length != 0
                            ? () {
                                FocusScope.of(context).unfocus();
                                showDialog(
                                  context: context,
                                  builder: (ctx) => AlertDialog(
                                    title: Text('Haizz'),
                                    content: Text(
                                        'Xin lỗi!, Bạn đừng để trống comment khi gửi nhé!'),
                                    actions: [
                                      GestureDetector(
                                        onTap: () {
                                          Navigator.of(ctx).pop();
                                        },
                                        child: Container(
                                            padding: EdgeInsets.all(10),
                                            decoration: BoxDecoration(
                                                color: Colors.green,
                                                borderRadius: BorderRadius.circular(10)
                                            ),
                                            child: Text('Ok',style: TextStyle(color: Colors.white,fontWeight: FontWeight.w600),)),
                                      ),
                                    ],
                                  ),
                                );
                              }
                            : () async {
                                FocusScope.of(context).unfocus();
                                setState(() {
                                  _isLoading = true;
                                });
                                final user =
                                Provider.of<AuthProvider>(context, listen: false);
                                await FirebaseFirestore.instance
                                    .collection('posts')
                                    .doc(post)
                                    .collection('comments')
                                    .add({
                                  'text': _enteredComment.trim(),
                                  'createdAt': Timestamp.now(),
                                  'userId': user.userModel.uid,
                                  'username': user.userModel.name,
                                  'photo': user.userModel.profilePic,
                                });
                                await FirebaseFirestore.instance
                                    .collection('posts')
                                    .doc(post)
                                    .update({
                                  'comment_count': FieldValue.increment(1)
                                });
                                _controller.clear();
                                setState(() {
                                  _isLoading = false;
                                });
                              }),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
