import 'package:fballapp/provider/auth_provider.dart';
import 'package:fballapp/provider_manager.dart';
import 'package:fballapp/screens/home_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:provider/provider.dart';

import 'login/login_screen.dart';

void main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  await Firebase.initializeApp();
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
              home: providervalue.isSignedIn ? HomeScreen() : LoginScreen(),
            );
          },
      ),
    );
  }
}

