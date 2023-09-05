import 'package:fballapp/login/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:provider/provider.dart';

import '../provider/auth_provider.dart';

class Infomation extends StatefulWidget {
  const Infomation({super.key});

  @override
  State<Infomation> createState() => _InfomationState();
}

class _InfomationState extends State<Infomation> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    FlutterNativeSplash.remove();
  }
  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    final ap = Provider.of<AuthProvider>(context, listen: false);
    return SafeArea(
      child: Scaffold(
        body: Column(
          children: [
            Container(
              margin: EdgeInsets.only(top: 20,left: 10,right: 10),
              padding: EdgeInsets.only(left: 10,top: 10,bottom: 10),
              decoration: BoxDecoration(
                color: Colors.black12.withOpacity(0.1),
                borderRadius: BorderRadius.circular(5)
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.white,
                    backgroundImage: NetworkImage(ap.userModel.profilePic),
                    radius: 25,
                  ),
                  SizedBox(width: 20,),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 5,),
                      Text(ap.userModel.name,style: TextStyle()),
                      Text('Xem trang cá nhân',style: TextStyle(color: Colors.green),)
                    ],
                  ),
                ],
              ),
            ),
            Container(
              margin: EdgeInsets.only(top: 20,left: 10,right: 10),
              padding: EdgeInsets.only(left: 10,top: 10,bottom: 10,right: 10),
              decoration: BoxDecoration(
                  color: Colors.black12,
                  borderRadius: BorderRadius.circular(5)
              ),
              child: GestureDetector(
                onTap: () {
                  ap.userSignOut().then(
                        (value) => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const LoginScreen(),
                      ),
                    ),
                  );
                },
                child: Text('Đăng xuất',style: TextStyle(),),
              ),
            )
          ],
        ),
      ),
    );
  }
}
