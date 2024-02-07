import 'dart:io';

import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:mobile_downloaderx/common/styles.dart';
import 'package:video_player/video_player.dart';

class MyVideoPlayer extends StatefulWidget {
  String? videoPath;
  MyVideoPlayer({this.videoPath, super.key});

  @override
  State<MyVideoPlayer> createState() => _MyVideoPlayerState();
}

class _MyVideoPlayerState extends State<MyVideoPlayer> {
  VideoPlayerController? videoPlayerController;
  ChewieController? chewieController;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    initaliseVidePlayer();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 1.0,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(
            Icons.arrow_back,
            color: Colors.white,
          ),
        ),
      ),
      body: Container(
        child: Center(
          child: chewieController != null &&
                  chewieController!.videoPlayerController.value.isInitialized
              ? Chewie(
                  controller: chewieController!,
                )
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    CircularProgressIndicator(),
                    SizedBox(height: 20),
                    Text("Loading"),
                  ],
                ),
        ),
      ),
    );
  }

  initaliseVidePlayer() async {
    videoPlayerController = VideoPlayerController.file(File(widget.videoPath!));
    await Future.wait([videoPlayerController!.initialize()]);
    chewieController = ChewieController(
        videoPlayerController: videoPlayerController!,
        autoPlay: true,
        looping: true,
        showOptions: false,
        showControls: true,
        cupertinoProgressColors:
            ChewieProgressColors(playedColor: DownloaderColor.buttonColor));
    setState(() {});
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    disposeVideoPlayer();
  }

  void disposeVideoPlayer() async {
    await videoPlayerController!.dispose();
    chewieController!.dispose();
  }
}
