import 'dart:ui';

import 'package:country_picker/country_picker.dart';
import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import '../dialog/showdialog.dart';
import '../provider/auth_provider.dart';
import '../widgets/custom_button.dart';

class RegisterPhone extends StatefulWidget {
  String email;
  RegisterPhone({super.key,required this.email});

  @override
  State<RegisterPhone> createState() => _RegisterPhoneState();
}

class _RegisterPhoneState extends State<RegisterPhone> {
  TextEditingController phoneController = TextEditingController();
  TextEditingController passwordTextController = TextEditingController();
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
              title: Text('Đăng ký OTP',style: TextStyle(color: Colors.white),),
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
                  children: [
                    Container(
                      margin: EdgeInsets.only(left: 10,right: 10,top: 20),
                      child: TextFormField(
                        keyboardType: TextInputType.number,
                        cursorColor: Colors.white,
                        controller: phoneController,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                        onChanged: (value) {
                          setState(() {
                            phoneController.text = value;
                          });
                        },
                        decoration: InputDecoration(
                          hintText: "Vui lòng nhập số điện thoại",
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
                      margin: EdgeInsets.only(left: 50,right: 50,top: 30),
                      width: double.infinity,
                      height: 50,
                      child: CustomButton(
                          text: "Đăng nhập", onPressed: () {
                            if(phoneController.text.length > 9 && phoneController.text.length < 12)
                              sendPhoneNumber();
                          }
                          ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        )
      ],
    );
  }

  void sendPhoneNumber() {
    final ap = Provider.of<AuthProvider>(context, listen: false);
    String phoneNumber = phoneController.text.trim();
    ap.checkExistingUser().then(
          (value) async {
        if (value == true) {
          // user exists in our app
          ap.getDataFromFirestore().then(
                (value) => faillogin(context, 'Số điện thoại đã có người sử dụng!',onPressOK: (){})
          ).onError((error, stackTrace) => faillogin(context, 'Số điện thoại đã có người sử dụng!',onPressOK: (){}));
        } else {
          ap.signInWithPhone(context, "+${selectedCountry.phoneCode}$phoneNumber",widget.email);
        }
      },
    ).onError((error, stackTrace) {
      faillogin(context, 'Số điện thoại đã có người sử dụng!',onPressOK: (){});
    } );
  }
}
