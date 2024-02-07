import 'dart:convert';
import 'dart:developer';

import 'dart:io';
import 'dart:isolate';
import 'dart:ui';
import 'package:android_path_provider/android_path_provider.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:mobile_downloaderx/common/data.dart';

import 'package:mobile_downloaderx/common/styles.dart';
import 'package:mobile_downloaderx/models/video_download_model.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:clipboard/clipboard.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  TextEditingController _textEditingController = TextEditingController();
  VideoDownload? videoDownload;
  late List<ItemHolder> _items;
  late bool _showContent;
  late bool _permissionReady;
  late bool _saveInPublicStorage;
  String _localPath = "";
  List<TaskInfo>? _tasks;
  final ReceivePort _port = ReceivePort();

  @override
  void initState() {
    super.initState();
    initalFunction();
  }

  initalFunction() {
    _bindBackgroundIsolate();
    FlutterDownloader.registerCallback(downloadCallback, step: 1);
    _showContent = false;
    _permissionReady = false;
    _saveInPublicStorage = false;

    _prepare();
  }

  void _bindBackgroundIsolate() {
    final isSuccess = IsolateNameServer.registerPortWithName(
      _port.sendPort,
      'downloader_send_port',
    );
    if (!isSuccess) {
      _unbindBackgroundIsolate();
      _bindBackgroundIsolate();
      return;
    }
    _port.listen((dynamic data) {
      final taskId = (data as List<dynamic>)[0] as String;
      final status = DownloadTaskStatus(data[1] as int);
      final progress = data[2] as int;

      print(
        'Callback on UI isolate: '
        'task ($taskId) is in status ($status) and process ($progress)',
      );
      if (status.value == 3) {
        Navigator.pop(context);
        _textEditingController.text = "";
        _localPath = "";
        if (mounted) {
          setState(() {});
        }

        // Fluttertoast.showToast(
        //     msg: "Downloaded Completed", toastLength: Toast.LENGTH_SHORT);
      }
    });
  }

  void _unbindBackgroundIsolate() {
    IsolateNameServer.removePortNameMapping('downloader_send_port');
  }

  @pragma('vm:entry-point')
  static void downloadCallback(
    String id,
    DownloadTaskStatus status,
    int progress,
  ) {
    print(
      'Callback on background isolate: '
      'task ($id) is in status ($status) and process ($progress)',
    );

    IsolateNameServer.lookupPortByName('downloader_send_port')
        ?.send([id, status.value, progress]);
  }

  Future callDownload() async {
    showLoader("Loading...");
    try {
      final queryParameters = {
        "url": _textEditingController.text,
        "key":
            "1a5268f3b39058e0cf9258c13f4db4853af2d7bb684d4f56f2b9ba3aadc29433"
      };
      final uri = Uri.https(
          'www.videodownloaderx.com', '/wp-json/aio-dl/api/', queryParameters);
      final response = await http.get(uri, headers: {
        HttpHeaders.contentTypeHeader: 'application/json',
      });

      videoDownload = VideoDownload.fromJson(jsonDecode(response.body));
      if (!mounted) return;
      setState(() {});
      Navigator.of(context).pop();
      //show bottom sheet
      if (videoDownload != null &&
          videoDownload!.medias != null &&
          videoDownload!.medias!.isNotEmpty) {
        showCustomBottomSheet();
      }
    } catch (e) {
      if (!mounted) return;
      Navigator.of(context).pop();
    }
  }

  Future<bool> _checkPermission() async {
    if (Platform.isIOS) {
      return true;
    }

    if (Platform.isAndroid) {
      final status = await Permission.storage.request();

      if (status == PermissionStatus.granted) {
        return true;
      }
    }

    throw StateError('unknown platform');
  }

  Future<void> _prepare() async {
    final tasks = await FlutterDownloader.loadTasks();

    if (tasks == null) {
      print('No tasks were retrieved from the database.');
      return;
    }
    var count = 0;
    _tasks = [];
    _items = [];

    _tasks!.addAll(
      DownloadItems.videos
          .map((video) => TaskInfo(name: video.name, link: video.url)),
    );

    _items.add(ItemHolder(name: 'Videos'));
    for (var i = count; i < _tasks!.length; i++) {
      _items.add(ItemHolder(name: _tasks![i].name, task: _tasks![i]));
      count++;
    }
    for (final task in tasks) {
      for (final info in _tasks!) {
        if (info.link == task.url) {
          info
            ..taskId = task.taskId
            ..status = task.status
            ..progress = task.progress;
        }
      }
    }
    _permissionReady = await _checkPermission();
    // if (_permissionReady) {
    //   await _prepareSaveDir("");
    // }
  }

  Future<void> _prepareSaveDir(String videoType) async {
    try {
      Directory? directory = await getExternalStorageDirectory();

      List<String> paths = directory!.path.split("/");

      for (int x = 1; x < paths.length; x++) {
        String folder = paths[x];
        if (folder != "Android") {
          _localPath += "/$folder";
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

      _localPath = (videoType.isNotEmpty)
          ? "$path/VideoDownloader/$videoType"
          : "$path/VideoDownloader/";

      final savedDir = Directory(_localPath);
      if (!savedDir.existsSync()) {
        await savedDir.create();
      }
    } catch (e) {
      log(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(
        top: 50,
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Align(
                alignment: Alignment.topCenter,
                child: Image.asset(
                  "assets/icons/logo.png",
                  scale: 2.0,
                )),
            const SizedBox(
              height: 40,
            ),
            const Padding(
              padding: EdgeInsets.only(left: 20),
              child: Text(
                "Free Video Downloader",
                style: TextStyle(
                    fontSize: 30,
                    color: DownloaderColor.headingColor,
                    fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(
              height: 30,
            ),
            const Padding(
              padding: EdgeInsets.only(left: 20),
              child: Text(
                "Fast and free all in one video\ndownloader",
                style: TextStyle(
                    fontSize: 25,
                    color: DownloaderColor.headingColor,
                    fontWeight: FontWeight.w400),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: TextField(
                controller: _textEditingController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Paste a video URL',
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Expanded(
                    flex: 2,
                    child: InkWell(
                      onTap: () {
                        if (_textEditingController.text.isNotEmpty) {
                          callDownload();
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 20),
                        alignment: Alignment.center,
                        decoration: const BoxDecoration(
                            color: DownloaderColor.buttonColor,
                            borderRadius:
                                BorderRadius.all(Radius.circular(8.0)),
                            shape: BoxShape.rectangle),
                        child: const Text(
                          "Download",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(
                    width: 20,
                  ),
                  Expanded(
                    flex: 3,
                    child: InkWell(
                      onTap: () {
                        if (_textEditingController.text.isEmpty) {
                          FlutterClipboard.paste().then((value) {
                            if (value.isNotEmpty) {
                              _textEditingController =
                                  TextEditingController(text: value);
                              if (mounted) {
                                setState(() {});
                              }
                            }
                          });
                        } else {
                          _textEditingController.text = "";
                         
                          setState(() {});
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 20),
                        alignment: Alignment.center,
                        decoration:  BoxDecoration(
                          shape: BoxShape.rectangle,

                          border: Border.all(color: Color(0xffC4C6C5) ),
                          borderRadius: const BorderRadius.all(Radius.circular(8.0)),
                        ),
                        child: Text(
                          (_textEditingController.text.isEmpty)
                              ? "Paste from clipboard"
                              : "Clear clipboard",
                          style: TextStyle(color: Colors.black),
                        ),
                      ),
                    ),
                  ),
                  /* Need to show download UI*/
                ],
              ),
            ),
           
           
          ],
        ),
      ),
    );
  }

  showLoader(String message) async {
    await showDialog(
        // The user CANNOT close this dialog  by pressing outsite it
        barrierDismissible: false,
        context: context,
        builder: (_) {
          return Dialog(
            // The background color
            backgroundColor: Colors.white,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // The loading indicator
                  const CircularProgressIndicator(color: DownloaderColor.buttonColor,),
                  const SizedBox(
                    height: 15,
                  ),
                  // Some text
                  Text("$message"),
                ],
              ),
            ),
          );
        });
  }

  downloadDetailUI() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(videoDownload!.title!),
        ),
        // const SizedBox(height: 10,),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Image.network(
            videoDownload!.thumbnail!,
            scale: 2.0,
          ),
        ),
        const SizedBox(
          height: 20,
        ),
        Wrap(
          direction: Axis.horizontal,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            for (var i in videoDownload!.medias!)
              InkWell(
                onTap: () async {
                  await _prepareSaveDir(getVideoType(i.url!));
                  // requestDownload(
                  //     _items[1].task!, i.url!, videoDownload!.title!.trim());
                },
                child: Container(
                    height: 100,
                    width: 150,
                    margin:
                        const EdgeInsets.only(left: 10, right: 10, bottom: 10),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 20),
                    alignment: Alignment.center,
                    decoration: const BoxDecoration(
                      shape: BoxShape.rectangle,
                      color: Color(0xff297373),
                      borderRadius: BorderRadius.all(Radius.circular(8.0)),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          i.quality!,
                          style: const TextStyle(
                              color: Colors.white, fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(
                          height: 5.0,
                        ),
                        Text(i.format!,
                            style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600)),
                        const SizedBox(
                          height: 5.0,
                        ),
                        Text(i.formattedSize!,
                            style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600)),
                      ],
                    )),
              ),
          ],
        )
      ],
    );
  }

  Future<void> requestDownload(
      TaskInfo task, String url, String filename, String format) async {
    showLoader("Downloading...");
    // Fluttertoast.showToast(msg: "Downloaded Started",toastLength: Toast.LENGTH_SHORT);
    task.taskId = await FlutterDownloader.enqueue(
            url: url,
            headers: {'auth': 'test_for_sql_encoding'},
            savedDir: _localPath,
            saveInPublicStorage: false,
            fileName: (filename.length < 5)
                ? "${filename.substring(0, 4).trim()}.$format"
                : "${filename.substring(0, 10).trim()}.$format")
        .then((value) {});
  }

  int index = 0;

  showCustomBottomSheet() {
    index = 0;
    return showModalBottomSheet(
      context: context,
      isScrollControlled: false,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
            topLeft: Radius.circular(15.0), topRight: Radius.circular(15.0)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Container(
               height: 350,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(10.0),
                    topRight: Radius.circular(10.0)),
              ),
              child: Column(
                children: [
                  const SizedBox(
                    height: 10,
                  ),
                  const Divider(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        height: 80,
                        width: 100,
                        margin: const EdgeInsets.only(left: 10.0),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10.0),
                            image: DecorationImage(
                                image: NetworkImage(videoDownload!.thumbnail!),
                                fit: BoxFit.cover)),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(right: 20),
                            child: Text(
                        videoDownload!.title!,
                        softWrap: true,
                        overflow: TextOverflow.fade,
                        maxLines: 3,
                      ),
                          ))
                    ],
                  ),
                  const Divider(),
                  Expanded(
                    flex: 2,
                    child: SingleChildScrollView(
                      padding: EdgeInsets.zero,
                      child: ListView.builder(
                          shrinkWrap: true,
                          padding: EdgeInsets.zero,
                          itemCount: videoDownload!.medias!.length,
                          physics: NeverScrollableScrollPhysics(),
                          itemBuilder: (context, localindex) {
                            return (videoDownload!
                                      .medias![localindex].format! == 'mp4')?Padding(
                              padding: const EdgeInsets.only(
                                  left: 20, right: 20, bottom: 0.0),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(videoDownload!
                                      .medias![localindex].format!),
                                  Row(
                                    children: [
                                      Text(
                                          "Size ${videoDownload!.medias![localindex].formattedSize!}"),
                                      Radio(
                                          value: localindex,
                                          groupValue: index,
                                          fillColor:
                                              MaterialStateColor.resolveWith(
                                                  (states) => DownloaderColor
                                                      .buttonColor),
                                          onChanged: (value) {
                                            setState(() {
                                              index = value!;
                                            });
                                          })
                                    ],
                                  )
                                ],
                              ),
                            ):const SizedBox();
                          }),
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            GestureDetector(
                              onTap: () {
                                Navigator.pop(context);
                              },
                              child: Container(
                                height: 60,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 50, vertical: 20),
                                alignment: Alignment.center,
                                decoration:  BoxDecoration(
                                  shape: BoxShape.rectangle,
                                  
                                  border: Border.all(color: Color(0xffC4C6C5)),
                                  borderRadius:
                                      const BorderRadius.all(Radius.circular(10.0)),
                                ),
                                child: const Text(
                                  "Cancel",
                                  style: TextStyle(color: Colors.black),
                                ),
                              ),
                            ),
                            GestureDetector(
                              onTap: () async {
                                Navigator.pop(context);
                                // await _prepareSaveDir(getVideoType(
                                //     videoDownload!.medias![index].url!));
                                String hostName =
                                    Uri.parse(_textEditingController.text).host;
                                String folderName =
                                    hostName.split(".").length > 2
                                        ? Uri.parse(_textEditingController.text)
                                            .host
                                            .split(".")[1]
                                        : Uri.parse(_textEditingController.text)
                                            .host
                                            .split(".")
                                            .first;
                                log(folderName);
                                await _prepareSaveDir(folderName);
                                requestDownload(
                                    _items[1].task!,
                                    videoDownload!.medias![index].url!,
                                    videoDownload!.title!.trim(),
                                    videoDownload!.medias![index].format!);
                              },
                              child: Container(
                                height: 60,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 40, vertical: 20),
                                alignment: Alignment.center,
                                decoration: const BoxDecoration(
                                    color: DownloaderColor.buttonColor,
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(10.0)),
                                    shape: BoxShape.rectangle),
                                child: const Text(
                                  "Download",
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                ],
              ),
            );
          },
        );
      },
    );
  }
}

String getVideoType(String url) {
  if (url.contains("instagram")) {
    return "Instagram";
  } else if (url.contains("youtube")) {
    return "Youtube";
  } else {
    return "Others";
  }
}

class ItemHolder {
  ItemHolder({this.name, this.task});

  final String? name;
  final TaskInfo? task;
}

class TaskInfo {
  TaskInfo({this.name, this.link});

  final String? name;
  final String? link;

  String? taskId;
  int? progress = 0;
  DownloadTaskStatus? status = DownloadTaskStatus.undefined;
}
