import 'dart:developer';
import 'dart:ui';

import 'package:fballapp/chat/screens/home_screen.dart';
import 'package:fballapp/post/main_page.dart';
import 'package:fballapp/provider/auth_provider.dart';
import 'package:fballapp/provider_manager.dart';
import 'package:fballapp/screens/Infomation_screen.dart';
import 'package:fballapp/screens/notifi_screen.dart';
import 'package:fballapp/screens/team_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_notification_channel/flutter_notification_channel.dart';
import 'package:flutter_notification_channel/notification_importance.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'chat/models/firebase_helper.dart';
import 'chat/screens/group_chats/create_group/add_members.dart';
import 'chat/screens/search_screen.dart';
import 'login/login_screen.dart';
import 'model/user_model.dart';

late Size mq;

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
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]).then((value) {
    _initializeFirebase();
  });
  runApp(
      ChangeNotifierProvider(
          create: (BuildContext context) => AuthProvider(),
          child: MyApp()
      ),
  );
}


_initializeFirebase() async {
  var result = await FlutterNotificationChannel.registerNotificationChannel(
      description: 'For Showing Message Notification',
      id: 'chats',
      importance: NotificationImportance.IMPORTANCE_HIGH,
      name: 'Chats');
  log('\nNotification Channel Result: $result');
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
  User? currentUser = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
  }
  @override
  Widget build(BuildContext context) {
    final ap = Provider.of<AuthProvider>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: Text("Phủi Mini",style: TextStyle(color: Colors.green,fontWeight: FontWeight.w500),),
        actions: [
          Container(
            margin: EdgeInsets.only(right: 20),
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SearchScreens(
                      userModel: ap.userModel,
                      firebaseUser: currentUser,
                    ),
                  ),
                );
              },
              child: Icon(Icons.search),
            ),
          ),
          Container(
            margin: EdgeInsets.only(right: 20),
            child: GestureDetector(
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => AddMembersInGroup(),));
              },
              child: Icon(Icons.group_add_rounded),
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
          HomeScreenss(),
          TeamScreen(),
          NotifiScreen(),
          Infomation(),
        ],
        controller: _tabController,
      ),
    );
  }
}


