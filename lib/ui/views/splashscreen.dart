import 'package:flutter/material.dart';
import 'package:mobile_downloaderx/routes/router_constant.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  String get route => DownloaderRoute.splashScreen;

  @override
  void initState() {
    super.initState();

    Future.delayed(Duration(seconds: 1), () {
      Navigator.pushNamed(context, DownloaderRoute.dashBoardScreen);
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Text("Splash Screen"),
      ),
    );
  }
}
