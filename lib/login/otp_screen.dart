import 'dart:async';
import 'dart:ui';

import 'package:fballapp/register/user_information_screen.dart';
import 'package:flutter/material.dart';
import 'package:otp_timer_button/otp_timer_button.dart';

import 'package:pinput/pinput.dart';
import 'package:provider/provider.dart';

import '../provider/auth_provider.dart';
import '../utils/utils.dart';
import '../widgets/custom_button.dart';
import '../screens/home_screen.dart';

class OtpScreen extends StatefulWidget {
  String email;
  String phone;
  final String verificationId;
  OtpScreen({super.key, required this.verificationId,required this.email,required this.phone});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  String? otpCode;
  OtpTimerButtonController controller = OtpTimerButtonController();

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context, listen: true);
    _requestOtp() {
      controller.loading();
      Future.delayed(Duration(seconds: 2), () {
        controller.startTimer();
        auth.signInWithPhone(context, widget.phone, widget.email);
      });
    }
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
        Scaffold(
          backgroundColor: Colors.transparent,
          extendBodyBehindAppBar: true,
          appBar: AppBar(
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
                    width: 200,
                    height: 200,
                    padding: const EdgeInsets.all(20.0),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                    ),
                    child: Image.asset(
                      "assets/image/logo_splash.png",
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    "Xác thực",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    "Xin vui lòng nhập mã OTP",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  Container(
                    height: 60,
                    width: double.infinity,
                    margin: EdgeInsets.only(left: 10,right: 10),
                    child: Pinput(
                      length: 6,
                      showCursor: true,
                      defaultPinTheme: PinTheme(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: Colors.white,
                          ),
                        ),
                        textStyle: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      onCompleted: (value) {
                        setState(() {
                          otpCode = value;
                        });
                      },
                    ),
                  ),
                  const SizedBox(height: 25),
                  Container(
                    margin: EdgeInsets.only(left: 50,right: 50),
                    width: double.infinity,
                    height: 50,
                    child: CustomButton(
                      text: "Xác thực",
                      onPressed: () {
                        if (otpCode != null) {
                          verifyOtp(context, otpCode!);
                        } else {
                          showSnackBar(context, "Enter 6-Digit code");
                        }
                      },
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    "Bạn chưa nhận được code?",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 15),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      OtpTimerButton(
                        backgroundColor: Colors.green,
                        controller: controller,
                        onPressed: () => _requestOtp(),
                        text: Text('Gửi lại',style: TextStyle(color: Colors.white),),
                        duration: 60,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        )
      ],
    );
  }

  // verify otp
  void verifyOtp(BuildContext context, String userOtp) {
    final ap = Provider.of<AuthProvider>(context, listen: false);
    ap.verifyOtp(
      context: context,
      verificationId: widget.verificationId,
      userOtp: userOtp,
      onSuccess: () {
        ap.checkExistingUser().then(
          (value) async {
            if (value == true) {
              // user exists in our app
              ap.getDataFromFirestore().then(
                    (value) => ap.saveUserDataToSP().then(
                          (value) => ap.setSignIn().then(
                                (value) => Navigator.pushAndRemoveUntil(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const HomeScreen(),
                                    ),
                                    (route) => false),
                              ),
                        ),
                  );
            } else {
              // new user
              Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                      builder: (context) => UserInfromationScreen(email: widget.email,)),
                  (route) => false);
            }
          },
        );
      },
    );
  }
}
