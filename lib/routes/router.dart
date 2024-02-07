import 'package:flutter/material.dart';
import 'package:mobile_downloaderx/routes/router_constant.dart';
import 'package:mobile_downloaderx/ui/views/dashboard.dart';
import 'package:mobile_downloaderx/ui/views/splashscreen.dart';

Route<dynamic> generateRoute(RouteSettings settings)  {
  switch (settings.name) {
    case DownloaderRoute.splashScreen:
      return MaterialPageRoute(builder: (context) => const SplashScreen());

    case DownloaderRoute.dashBoardScreen:
    return MaterialPageRoute(builder: (context) => const Dashboard());
      
      
    default:
    return MaterialPageRoute(builder: (context) => const SplashScreen());
  }
}