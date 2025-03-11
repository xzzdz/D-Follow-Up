import 'package:flutter/material.dart';
import 'package:hotel_web/splash_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'screens/home.dart';
import 'screens/login.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // สำหรับ async ใน main()

  // ตรวจสอบสถานะการล็อกอิน
  SharedPreferences prefs = await SharedPreferences.getInstance();
  bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;

  runApp(MyApp(isLoggedIn: isLoggedIn));
}

class MyApp extends StatelessWidget {
  final bool isLoggedIn; // รับสถานะการล็อกอินจาก main()
  const MyApp({super.key, required this.isLoggedIn});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'D Follow Up',
      theme: ThemeData(
        primarySwatch: Colors.grey,
        scrollbarTheme: ScrollbarThemeData(
          thumbColor: MaterialStateProperty.all(Colors.grey[200]),
        ),
      ),
      // ตรวจสอบสถานะ: ถ้าล็อกอินแล้วไป Homepage ถ้ายังให้ไป Login
      home: isLoggedIn ? const HomepageWeb() : const SplashScreen(),
    );
  }
}
