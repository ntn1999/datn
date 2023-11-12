
import 'package:flutter/material.dart';
import 'package:iot_demo/presentation/login/login_screen.dart';
import 'configs/colors.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Demo project',
      theme: ThemeData(
        primaryColor: kPrimaryColor,
        scaffoldBackgroundColor: Colors.white,
      ),
      home: const LoginScreen(),
      // navigatorKey: AppNavigator.navigatorKey,
      // onGenerateRoute: AppNavigator.onGenerateRoute,
    );
  }
}
