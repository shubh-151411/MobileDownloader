import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_share/flutter_share.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:mobile_downloaderx/ui/views/myvideo_player.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:video_player/video_player.dart';

class CategoryWiseDownload extends StatefulWidget {
  List? file = [];
  String? title = "";
  CategoryWiseDownload({this.file, this.title, super.key});

  @override
  State<CategoryWiseDownload> createState() => _CategoryWiseDownloadState();
}

class _CategoryWiseDownloadState extends State<CategoryWiseDownload> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.black,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: Text(
          widget.title!,
          style: const TextStyle(color: Colors.black),
        ),
      ),
      body: SizedBox(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        child: ListView.separated(
          itemCount: widget.file!.length,
          shrinkWrap: true,
          itemBuilder: (context, index) {
            return FileView(
              file: "${widget.file![index].path}",
              callBack: (value) {
                if (value) {
                  widget.file!.removeAt(index);
                  setState(() {});
                }
              },
            );
          },
          separatorBuilder: (BuildContext context, int index) {
            return Padding(
              padding: const EdgeInsets.all(10.0),
              child: const Divider(
                thickness: 2.0,
              ),
            );
          },
        ),
      ),
    );
  }
}

class FileView extends StatefulWidget {
  String? file = "";
  final Function(bool)? callBack;
  FileView({this.file, this.callBack});

  @override
  State<FileView> createState() => _FileViewState();
}

class _FileViewState extends State<FileView> {
  late VideoPlayerController _controller;
  late Future<void> _initializeVideoPlayerFuture;
  int size = 0;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _controller = VideoPlayerController.file(
      File(widget.file!),
    );
    _initializeVideoPlayerFuture =
        _controller.initialize().catchError((error) {});

    initalFunction();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    disposeVideo();
    // _controller.dispose();
  }

  disposeVideo() async {
    await _controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      child: Row(
        children: [
          Container(
            margin:
                const EdgeInsets.only(left: 10, bottom: 10, right: 10, top: 10),
            height: 100,
            width: 100,
            decoration:
                BoxDecoration(borderRadius: BorderRadius.circular(10.0)),
            child: FutureBuilder(
              future: _initializeVideoPlayerFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  // If the VideoPlayerController has finished initialization, use
                  // the data it provides to limit the aspect ratio of the video.
                  return AspectRatio(
                    aspectRatio: _controller.value.aspectRatio,
                    // Use the VideoPlayer widget to display the video.
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => MyVideoPlayer(
                              videoPath: widget.file,
                            ),
                          ),
                        );
                      },
                      child: Stack(
                        children: [
                          ClipRRect(
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(10.0)),
                              child: VideoPlayer(_controller)),
                        ],
                      ),
                    ),
                  );
                } else {
                  // If the VideoPlayerController is still initializing, show a
                  // loading spinner.
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }
              },
            ),
          ),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.file!.split("/").last),
                const SizedBox(
                  height: 10,
                ),
                SizedBox(
                  // width: MediaQuery.of(context).size.width,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Text("${bytesToMegabytes(size)}mb"),
                          IconButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => MyVideoPlayer(
                                      videoPath: widget.file,
                                    ),
                                  ),
                                );
                              },
                              icon: const Icon(Icons.play_circle_outline_sharp))
                        ],
                      ),
                      PopupMenuButton<String>(
                        itemBuilder: (BuildContext context) =>
                            <PopupMenuEntry<String>>[
                          const PopupMenuItem<String>(
                            value: 'Share',
                            child: Text('Share'),
                          ),
                          const PopupMenuItem<String>(
                            value: 'Delete',
                            child: Text('Delete'),
                          ),
                        ],
                        onSelected: (String value) async {
                          if (value.contains("Share")) {
                            await FlutterShare.shareFile(
                              title: widget.file!.split("/").last,
                              text: widget.file!.split("/").last,
                              filePath: widget.file!,
                            );
                          } else {
                            log(widget.file!);
                            deleteFile(widget.file!);
                          }
                          // Do something when a menu item is selected
                        },
                      )
                    ],
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  void initalFunction() async {
    size = await File(widget.file!).length();
    setState(() {});
  }

  String bytesToMegabytes(int bytes) {
    return (bytes / (1024 * 1024)).toStringAsFixed(2);
  }

  void deleteFile(String filePath) async {
    try {
      final file = File(filePath);
      var status1 = await Permission.manageExternalStorage.request();
      if (status1 == PermissionStatus.granted) {
        if (await file.exists()) {
          await file.delete();
          widget.callBack!(true);
        }
      } else {
        Fluttertoast.showToast(msg: "Permission Required");
      }
    } catch (e) {
      widget.callBack!(false);
    }
  }
}
