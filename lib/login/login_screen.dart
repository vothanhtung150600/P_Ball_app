import 'dart:ui';

import 'package:country_picker/country_picker.dart';
import 'package:fballapp/login/login_phone_screen.dart';
import 'package:fballapp/login/reset_email_pass.dart';
import 'package:fballapp/register/register_phone_screen.dart';
import 'package:fballapp/screens/home_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';

import 'package:provider/provider.dart';

import '../dialog/showdialog.dart';
import '../provider/auth_provider.dart';
import '../register/register_screen.dart';
import '../router/router.dart';
import '../register/user_information_screen.dart';
import '../widgets/custom_button.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  TextEditingController emailTextController = TextEditingController();
  TextEditingController passwordTextController = TextEditingController();

  bool isshowpass = true;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    FlutterNativeSplash.remove();
  }
  @override
  Widget build(BuildContext context) {
    final ap = Provider.of<AuthProvider>(context, listen: false);
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
            body: SafeArea(
              child:  Container(
                margin: EdgeInsets.only(top: 40),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        margin: EdgeInsets.only(bottom: 30),
                        alignment: Alignment.topCenter,
                        child: Image.asset('assets/image/logo_splash.png',height: 150,),
                      ),
                      Text(
                        "Đăng nhập",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 25,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 30),
                      Container(
                        margin: EdgeInsets.only(left: 10,right: 10),
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
                      const SizedBox(height: 20),
                      Container(
                        margin: EdgeInsets.only(left: 10,right: 10),
                        child: TextFormField(
                          obscureText: isshowpass,
                          cursorColor: Colors.white,
                          controller: passwordTextController,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                          onChanged: (value) {
                            setState(() {
                              passwordTextController.text = value;
                            });
                          },
                          decoration: InputDecoration(
                            suffixIcon: GestureDetector(
                              onTap: (){
                                setState(() {
                                  isshowpass = !isshowpass;
                                });
                              },
                              child: Container(
                                child: Icon(Icons.remove_red_eye_outlined,color: Colors.white,),
                              ),
                            ),
                            hintText: "Mật khẩu",
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
                      const SizedBox(height: 20),
                      Container(
                        height: 50,
                        margin: EdgeInsets.only(left: 50,right: 50,top: 30),
                        width: double.infinity,
                        child: CustomButton(
                            text: "Đăng nhập", onPressed: () {
                          FocusManager.instance.primaryFocus?.unfocus();
                          FirebaseAuth.instance.signInWithEmailAndPassword(
                              email: emailTextController.text,
                              password: passwordTextController.text).then((value) {
                            ap.checkExistingUser().then(
                                  (value) async {
                                if (value == true) {
                                  // user exists in our app
                                  ap.getDataFromFirestore().then(
                                        (value) => ap.saveUserDataToSP().then(
                                          (value) => ap.setSignIn().then(
                                              (value) => Navigator.of(context).push(MaterialPageRoute(builder: (context) => HomeScreen(),))
                                      ),
                                    ),
                                  ).onError((error, stackTrace) => Navigator.push(context, MaterialPageRoute(builder: (context) => RegisterPhone(email: emailTextController.text),)));
                                } else {
                                  // new user
                                  Navigator.of(context).push(MaterialPageRoute(builder: (context) => UserInfromationScreen(email: emailTextController.text),));
                                }
                              },
                            );
                          }).onError((error, stackTrace) {
                            faillogin(
                                context,
                                'Sai thông tin đăng nhập hoặc mật khẩu',
                                onPressOK: (){}
                            );
                            print("Error ${error.toString()}");
                          });
                        }
                        ),
                      ),
                      const SizedBox(height: 30),
                      Container(
                        margin: EdgeInsets.only(left: 20,right: 20),
                        width: double.infinity,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            GestureDetector(
                                onTap: () {
                                  Navigator.of(context).push(MaterialPageRoute(builder: (context) => RegisterScreen(),));
                                },
                                child: Text('Đăng ký',style: TextStyle(color: Colors.white,fontWeight: FontWeight.w500))
                            ),
                            GestureDetector(
                                onTap: () {
                                  Navigator.of(context).push(MaterialPageRoute(builder: (context) => ResetEmail(),));
                                },
                                child: Text('Quên mật khẩu',style: TextStyle(color: Colors.white,fontWeight: FontWeight.w500))
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        )
      ],
    );
  }
}
