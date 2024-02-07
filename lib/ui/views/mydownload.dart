import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:mobile_downloaderx/ui/views/categorywise_download.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class MyDownload extends StatefulWidget {
  const MyDownload({super.key});

  @override
  State<MyDownload> createState() => _MyDownloadState();
}

class _MyDownloadState extends State<MyDownload> {
  String directory = "";
  List file = [];

  String _localPath = "";
  List<String> imagePath = [
    "assets/icons/instagram.png",
    "assets/icons/youtube.png",
    "assets/icons/viewmore.png"
  ];
  List<String> folderName = [
    'Instagram',
    'Youtube',
  ];
  List<Directory> _directory = [];

  @override
  void initState() {
    super.initState();
    _listofFiles();
  }

  void _listofFiles() async {
    try {
      Directory? directory = await getExternalStorageDirectory();
      List<String> paths = directory!.path.split("/");
      for (int x = 1; x < paths.length; x++) {
        String folder = paths[x];
        if (folder != "Android") {
          _localPath += "/" + folder;
        } else {
          break;
        }
      }
      String path = "";
      Directory(_localPath).listSync().forEach((element) {
        if (element.path.contains("Movies") ||
            element.path.contains("movies") ||
            element.path.contains("video") ||
            element.path.contains("Videos")) {
          log(element.path);
          path = element.path;
        }
      });

      file = Directory("${path}/VideoDownloader/").listSync();
      file.forEach((value) {
        _directory.add(value);
      });
      // print(file);
      setState(() {});
    } on Exception catch (e) {
      log(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return (_directory.isNotEmpty)
        ? Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 50),
                child: Align(
                    alignment: Alignment.topCenter,
                    child: Image.asset(
                      "assets/icons/logo.png",
                      scale: 2.0,
                    )),
              ),
              const Padding(
                padding: EdgeInsets.only(top: 10),
                child: Text(
                  "Category Download",
                  style: TextStyle(fontWeight: FontWeight.w500, fontSize: 18),
                ),
              ),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.only(top: 0),
                  child: Container(
                    padding: const EdgeInsets.all(12.0),
                    child: GridView.builder(
                      shrinkWrap: true,
                      itemCount: _directory.length,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 4.0,
                              mainAxisSpacing: 4.0),
                      itemBuilder: (BuildContext context, int index) {
                        return GestureDetector(
                          onTap: () {
                            // print(  _directory[index].listSync());
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => CategoryWiseDownload(
                                          file: _directory[index].listSync(),
                                          title: capitalize(_directory[index]
                                              .path
                                              .split("/")
                                              .last),
                                        ))).then((value) {
                              _listofFiles();
                              setState(() {});
                            });
                          },
                          child: Card(
                            shape: RoundedRectangleBorder(
                              side: BorderSide(
                                  color: Colors.grey.withOpacity(0.5)),
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.white,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.grey.withOpacity(0.1),
                                        spreadRadius: 5,
                                        blurRadius: 7,
                                        offset: Offset(0, 3),
                                      ),
                                    ],
                                  ),
                                  child: Card(
                                    elevation: 0,
                                    color: Colors.transparent,
                                    child: Center(
                                      child: Image.asset(getImage(
                                          _directory[index]
                                              .path
                                              .split("/")
                                              .last)),
                                    ),
                                  ),
                                ),
                                // Image.asset(getImage(
                                //     _directory[index].path.split("/").last)),
                                const SizedBox(
                                  height: 10,
                                ),
                                Text(capitalize(
                                    _directory[index].path.split("/").last)),
                                const SizedBox(
                                  height: 10,
                                ),
                                Text(
                                    "Total Downloads ${_directory[index].listSync().length}")
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ],
          )
        : Padding(
            padding: const EdgeInsets.only(top: 50),
            child: Align(
                alignment: Alignment.topCenter,
                child: Image.asset(
                  "assets/icons/logo.png",
                  scale: 2.0,
                )),
          );
  }

  String getImage(String name) {
    switch (name) {
      case "instagram":
        return "assets/icons/instagram.png";

      case "youtube":
        return "assets/icons/youtube.png";
      default:
        return "assets/icons/viewmore.png";
    }
  }

  String capitalize(String str) {
    return str.isNotEmpty ? "${str[0].toUpperCase()}${str.substring(1)}" : str;
  }
}
