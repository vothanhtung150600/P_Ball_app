import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../provider/auth_provider.dart';

class CreatePost extends StatefulWidget {
  @override
  _CreatePostState createState() => _CreatePostState();
}

class _CreatePostState extends State<CreatePost> {
  final _body = new TextEditingController();
  var _post = '';
  var _isLoading = false;

  Future _confirmDialog(BuildContext context) async {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: Text('Xác nhận'),
        content: Text('Bạn chắc chắn với nội dung này rồi chứ?'),
        actions: [
          GestureDetector(
            onTap: () {
              Navigator.of(ctx).pop(false);
            },
            child: Container(
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(10)
                ),
                child: Text('No',style: TextStyle(color: Colors.white,fontWeight: FontWeight.w600),)),
          ),
          SizedBox(width: 20,),
          GestureDetector(
            onTap: () {
              Navigator.of(ctx).pop(true);
            },
            child: Container(
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.circular(10)
                ),
                child: Text('Yes',style: TextStyle(color: Colors.white,fontWeight: FontWeight.w600),)),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text('Tạo bài viết'),
        actions: [
          GestureDetector(
              onTap: _post.trim().isEmpty ? () {
                  FocusScope.of(context).unfocus();
                  showDialog(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: Text('Haizz'),
                      content: Text(
                          'Xin lỗi!, Hãy viết gì đó đừng để trống mà đăng nhé'),
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
                } : () async {
                      FocusScope.of(context).unfocus();
                      final bool confirm = await _confirmDialog(context);
                      if (confirm) {
                        setState(() {
                          _isLoading = true;
                        });
                        final user = Provider.of<AuthProvider>(context, listen: false);
                        await FirebaseFirestore.instance
                            .collection('posts')
                            .add({
                          "name": user.userModel.name,
                          "uid": user.userModel.uid,
                          "profilePic": user.userModel.profilePic,
                          "createdAt": Timestamp.now(),
                          'main_text': _body.text,
                          'likedBy': FieldValue.arrayUnion([]),
                          'comment_count': 0,
                          'status': user.userModel.status
                        });
                        setState(() {
                          _isLoading = false;
                        });
                        Navigator.of(context).pop();
                      }
                    },
              child: Container(
                margin: EdgeInsets.only(right: 20),
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.green,
                ),
                child: Text('Đăng',style: TextStyle(color: Colors.white),),
              )
          )
        ],
      ),
      body: Container(
        margin: EdgeInsets.all(15.0),
        decoration: BoxDecoration(),
        child: Column(
          children: [
            Container(
              margin: EdgeInsets.only(right: 5),
              child: TextField(
                onChanged: (value) {
                  setState(() {
                    _post = value;
                  });
                },
                controller: _body,
                maxLines: 10,
                minLines: 1,
                style: TextStyle(fontSize: 16,fontWeight: FontWeight.w300),
                decoration: InputDecoration.collapsed(
                  hintText: 'Hãy viết 1 bài để dễ dàng tìm đối thủ nào :>',
                ),
              ),
            ),
            Expanded(child: Container()),
          ],
        ),
      ),
    );
  }
}
