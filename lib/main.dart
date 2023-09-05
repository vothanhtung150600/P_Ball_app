import 'dart:ui';

import 'package:fballapp/provider/auth_provider.dart';
import 'package:fballapp/provider_manager.dart';
import 'package:fballapp/screens/Infomation_screen.dart';
import 'package:fballapp/screens/home_screen.dart';
import 'package:fballapp/screens/message_screen.dart';
import 'package:fballapp/screens/notifi_screen.dart';
import 'package:fballapp/screens/team_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

import 'login/login_screen.dart';

void main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  await Firebase.initializeApp();
  WidgetsFlutterBinding.ensureInitialized();
  await Permission.notification.isDenied.then((value) {
    if (value) {
      Permission.notification.request();
    }
  });
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  runApp(
      ChangeNotifierProvider(
          create: (BuildContext context) => AuthProvider(),
          child: MyApp()
      ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: providers,
      child: Consumer<AuthProvider>(
          builder: (context, providervalue, child) {
            return MaterialApp(
              debugShowCheckedModeBanner: false,
              home: providervalue.isSignedIn ? MyHomePage() : LoginScreen(),
            );
          },
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with SingleTickerProviderStateMixin{
  late TabController _tabController;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Phủi Mini",style: TextStyle(color: Colors.green,fontWeight: FontWeight.w500),),
        actions: [
          Container(
            margin: EdgeInsets.only(right: 20),
            child: GestureDetector(
              onTap: () {},
              child: Icon(Icons.search),
            ),
          ),
          Container(
            margin: EdgeInsets.only(right: 20),
            child: GestureDetector(
              onTap: () {},
              child: Icon(Icons.person_add_alt_1),
            ),
          ),
        ],
        bottom: TabBar(
          indicatorColor: Colors.green,
          labelColor: Colors.green,
          unselectedLabelColor: Colors.black,
          labelStyle: TextStyle(fontSize: 10.0),
          tabs: <Widget>[
            Tab(
              icon: Icon(
                Icons.home,
                size: 24.0,
              ),
            ),
            Tab(
              icon: Icon(
                Icons.message,
                size: 24.0,
              ),
            ),
            Tab(
              icon: Icon(
                Icons.supervisor_account,
                size: 24.0,
              ),
            ),
            Tab(
              icon: Icon(
                Icons.notifications_active,
                size: 24.0,
              ),
            ),
            Tab(
              icon: Icon(
                Icons.dehaze,
                size: 24.0,
              ),
            ),
          ],
          controller: _tabController,
        ),
      ),
      body: TabBarView(
        physics: NeverScrollableScrollPhysics(),
        children: [
          HomeScreen(),
          MessageScreen(),
          TeamScreen(),
          NotifiScreen(),
          Infomation(),
        ],
        controller: _tabController,
      ),
    );
  }
}


