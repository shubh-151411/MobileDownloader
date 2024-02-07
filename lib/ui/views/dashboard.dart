import 'package:flutter/material.dart';
import 'package:mobile_downloaderx/common/styles.dart';
import 'package:mobile_downloaderx/routes/router_constant.dart';
import 'package:mobile_downloaderx/ui/views/home.dart';
import 'package:mobile_downloaderx/ui/views/mydownload.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  int _selectedIndex = 0;

  @override
  String get route => DownloaderRoute.dashBoardScreen;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: (_selectedIndex == 0)
          ? Home()
          : MyDownload(),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.open_in_new_rounded),
            label: 'My Download',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: DownloaderColor.buttonColor,
        onTap: (int index) {
          setState(
            () {
              _selectedIndex = index;
            },
          );
        },
      ),
    );
  }
}
