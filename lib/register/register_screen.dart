import 'dart:ui';

import 'package:country_picker/country_picker.dart';
import 'package:fballapp/dialog/showdialog.dart';
import 'package:fballapp/register/register_phone_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import '../provider/auth_provider.dart';
import '../screens/home_screen.dart';
import 'user_information_screen.dart';
import '../widgets/custom_button.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  TextEditingController passwordTextController = TextEditingController();
  TextEditingController passwordcheckTextController = TextEditingController();
  TextEditingController emailTextController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  Country selectedCountry = Country(
    phoneCode: "84",
    countryCode: "VN",
    e164Sc: 0,
    geographic: true,
    level: 1,
    name: "Vietnam",
    example: "Vietnam",
    displayName: "Vietnam",
    displayNameNoCountryCode: "VN",
    e164Key: "",
  );
  bool checkphone = false;
  bool checkpassword = false;
  bool checckconformpass = false;
  bool isshowpass = true;
  @override
  Widget build(BuildContext context) {
    phoneController.selection = TextSelection.fromPosition(
      TextPosition(
        offset: phoneController.text.length,
      ),
    );
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
              title: Text('Đăng ký',style: TextStyle(color: Colors.white),),
              leading: IconButton(
                onPressed: (){
                  Navigator.pop(context);
                },
                icon: Icon(Icons.arrow_back,color: Colors.white,),
              ),
              backgroundColor: Colors.transparent,
            ),
            body: SafeArea(
              child: Container(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        margin: EdgeInsets.only(left: 10,right: 10),
                        child: TextFormField(
                          cursorColor: Colors.white,
                          keyboardType: TextInputType.emailAddress,
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
                            hintText: "Vui lòng nhập Email || abc@gmail.com",
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
                      checkpassword ? Container(
                        margin: EdgeInsets.only(left: 15,top: 10),
                        alignment: Alignment.topLeft,
                          child: Text('Mật khẩu phải trên 6 kí tự',style: TextStyle(color: Colors.red),)
                      ): Container(),
                      const SizedBox(height: 20),
                      Container(
                        margin: EdgeInsets.only(left: 10,right: 10),
                        child: TextFormField(
                          obscureText: isshowpass,
                          cursorColor: Colors.white,
                          controller: passwordcheckTextController,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                          onChanged: (value) {
                            setState(() {
                              passwordcheckTextController.text = value;
                            });
                          },
                          decoration: InputDecoration(
                            hintText: "Xác thực lại mật khẩu",
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
                            suffixIcon:
                            passwordcheckTextController.text.length != 0 ?
                            passwordcheckTextController.text == passwordTextController.text ?
                            Container(
                              height: 30,
                              width: 30,
                              margin: const EdgeInsets.all(10.0),
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.green,
                              ),
                              child: const Icon(
                                Icons.done,
                                color: Colors.white,
                                size: 20,
                              ),
                            ) : null : null,
                          ),
                        ),
                      ),
                      checckconformpass ? Container(
                          margin: EdgeInsets.only(left: 15,top: 10),
                          alignment: Alignment.topLeft,
                          child: Text('Mật khẩu không trùng khớp',style: TextStyle(color: Colors.red),)
                      ): Container(),
                      const SizedBox(height: 10),
                      Container(
                        margin: EdgeInsets.only(left: 50,right: 50,top: 30),
                        width: double.infinity,
                        height: 50,
                        child: CustomButton(
                            text: "Đăng Ký", onPressed: () {
                              if(passwordTextController.text.length < 5)
                                setState(() {
                                  checkpassword = true;
                                });
                              if(phoneController.text.length < 9 || phoneController.text.length > 11)
                                setState(() {
                                  checkphone = true;
                                });
                              if(passwordcheckTextController.text != passwordTextController.text)
                                setState(() {
                                  checckconformpass = true;
                                });
                          if(emailTextController.text.length != 0 &&
                              passwordcheckTextController.text == passwordTextController.text &&
                              passwordTextController.text.length > 5){
                            FirebaseAuth.instance
                                .createUserWithEmailAndPassword(
                                email: emailTextController.text.trim(),
                                password: passwordTextController.text.trim())
                                .then((value) {
                                    Navigator.push(context, MaterialPageRoute(builder: (context) => RegisterPhone(email: emailTextController.text),));
                                }).onError((error, stackTrace) {
                              faillogin(context, 'Email đã có người sử dụng!',onPressOK: (){});
                              print("Error ${error.toString()}");
                            });
                          }
                        }),
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
