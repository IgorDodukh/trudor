import 'package:another_flutter_splash_screen/another_flutter_splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:spoto/presentation/views/main/home/home_view.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FlutterSplashScreen(
      useImmersiveMode: true,
      duration: const Duration(milliseconds: 2000),
      nextScreen: const HomeView(),
      backgroundColor: Colors.black87,
      splashScreenBody: Center(
        child: Lottie.asset(
          "assets/icons/bar-loader.json",
          repeat: true,
        ),
      ),
    );
  }
}
