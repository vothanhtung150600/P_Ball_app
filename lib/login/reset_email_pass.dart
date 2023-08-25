import 'dart:ui';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../dialog/showdialog.dart';
import '../utils/color_utils.dart';
import '../widgets/custom_button.dart';

class ResetEmail extends StatefulWidget {
  const ResetEmail({Key? key}) : super(key: key);

  @override
  _ResetEmailState createState() => _ResetEmailState();
}

class _ResetEmailState extends State<ResetEmail> {
  TextEditingController emailTextController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            image: DecorationImage(
                image: AssetImage('assets/image/background.png'),
                fit: BoxFit.cover),
          ),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
            child: Container(
              color: Colors.black.withOpacity(0.5),
            ),
          ),
        ),
        GestureDetector(
          onTap: () {
            FocusManager.instance.primaryFocus?.unfocus();
          },
          child: Scaffold(
            backgroundColor: Colors.transparent,
            extendBodyBehindAppBar: true,
            appBar: AppBar(
              centerTitle: true,
              title: Text('Quên mật khẩu',style: TextStyle(color: Colors.white),),
              leading: IconButton(
                onPressed: (){
                  Navigator.pop(context);
                },
                icon: Icon(Icons.arrow_back,color: Colors.white,),
              ),
              backgroundColor: Colors.transparent,
            ),
            body: SafeArea(
              child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Container(
                        margin: EdgeInsets.only(left: 10,right: 10,top: 20),
                        child: TextFormField(
                          cursorColor: Colors.white,
                          controller: emailTextController,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                          onChanged: (value) {
                            setState(() {
                              emailTextController.text = value;
                            });
                          },
                          decoration: InputDecoration(
                            hintText: "Vui lòng nhập Email",
                            hintStyle: TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 15,
                              color: Colors.white,
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(color: Colors.white70),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(color: Colors.white70),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      Container(
                        margin: EdgeInsets.only(left: 50,right: 50,top: 30),
                        width: double.infinity,
                        height: 50,
                        child: CustomButton(text: "Reset password", onPressed:() {
                          FirebaseAuth.instance
                              .sendPasswordResetEmail(email: emailTextController.text)
                              .then((value) => resetpass(context,'Vui lòng check email của bạn để thay đổi mật khẩu',onPressOK: (){Navigator.pop(context);})
                          ).onError((error, stackTrace) => faillogin(context, 'Email này chưa được đăng ký',onPressOK: () {}));
                        }),
                      )
                    ],
                  )),
            ),
          ),
        )
      ],
    );
  }
}
