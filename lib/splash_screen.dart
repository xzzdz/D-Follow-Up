import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:flutter/material.dart';

import 'package:hotel_web/screens/login.dart';

import 'constant/color_font.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedSplashScreen(
      splash: Center(
        child:
            // Lottie.asset('assets//animetion/Animation - 1738560577207.json'),
            Image.asset('assets/img/DFU.png'),
      ),
      nextScreen: const Login(),
      duration: 1000,
      backgroundColor: bgcolor,
      splashTransition: SplashTransition.fadeTransition,
      animationDuration: const Duration(seconds: 1),
      splashIconSize: 400,
    );
  }
}
