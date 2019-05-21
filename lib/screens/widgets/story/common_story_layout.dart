import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:stories/bloc/stories_pager_bloc.dart';
import 'package:stories/models.dart';
import 'package:stories/screens/widgets/story/image_story.dart';
import 'package:stories/screens/widgets/story/video_story.dart';
import 'package:stories/utils/colors.dart';

class Story extends StatefulWidget {
  final Items story;
  final int selectedItem;
  final int index;

  Story({
    Key key,
    @required this.story,
    @required this.index,
    @required this.selectedItem,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() =>
      _Story(this.story, this.index, this.selectedItem);
}

class _Story extends State<Story> {
  final Items story;
  final int selectedItem;
  final int index;
  double progress = -1;
  bool showDownloadProgress = false;

  _Story(this.story, this.index, this.selectedItem);

  static const platform = const MethodChannel('stories');

  final GlobalKey<ScaffoldState> _scaffoldkey = new GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    var storiesPagerBloc = Provider.of<StoriesPagerBloc>(context);
    double screenWidth = MediaQuery.of(context).size.width;
    return SafeArea(
      bottom: true,
      top: false,
      child: Scaffold(
        key: _scaffoldkey,
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        floatingActionButton: FloatingActionButton(
            heroTag: "_MAIN_FAB_",
            tooltip: "Download",
            onPressed: () {
              download(context);
            },
            backgroundColor: Colors.grey[100],
            child: showDownloadProgress
                ? CircularProgressIndicator(
                    value: progress,
                    valueColor: AlwaysStoppedAnimation<Color>(instaRed))
                : Icon(
                    Icons.file_download,
                    color: Colors.grey[800],
                  )),
        body: GestureDetector(
            onVerticalDragEnd: (DragEndDetails down) {
              if (down.primaryVelocity > 800) {
                Navigator.pop(context);
              }
            },
            onLongPressEnd: (LongPressEndDetails details) {
              storiesPagerBloc.play = true;
            },
            onTapDown: (TapDownDetails details) {
              storiesPagerBloc.play = false;
            },
            onTapUp: (TapUpDetails details) {
              if (details.globalPosition.dx < screenWidth / 6) {
                storiesPagerBloc.onPreviousClicked();
              } else {
                storiesPagerBloc.onNextClicked();
              }
            },
            child: _getStoryItem()),
      ),
    );
  }

  Widget _getStoryItem() {
    bool noVideos = story.videoVersions.isEmpty;
    return noVideos
        ? new ImageStory(
            selectedItem: selectedItem,
            story: story,
            index: index,
          )
        : new VideoStory(
            selectedItem: selectedItem,
            story: story,
            index: index,
          );
  }

  void download(BuildContext context) async {
    if (Platform.isIOS) {
      initDownloadIOS();
    }
    PermissionStatus permission = await PermissionHandler()
        .checkPermissionStatus(PermissionGroup.storage);

    if (permission == PermissionStatus.granted) {
      initDownload();
    } else {
      Map<PermissionGroup, PermissionStatus> storageRequest =
          await PermissionHandler()
              .requestPermissions([PermissionGroup.storage]);
      if (storageRequest[PermissionGroup.storage] == PermissionStatus.granted) {
        initDownload();
      }
    }
  }

  initDownloadIOS() async {
    String url = "";
    bool noVideos = story.videoVersions.isEmpty;
    String filename = "";
    if (noVideos) {
      url = story.imageVersions2.candidates.first.url;
      filename = "${story.id}.jpg";
    } else {
      url = story.videoVersions.first.url;
      filename = "${story.id}.mp4";
    }
    try {
      var storage = await getApplicationDocumentsDirectory();

      await new Directory("${storage.path}/stories").create(recursive: true);
      setState(() {
        showDownloadProgress = true;
      });
      await Dio().download(url, "${storage.path}/stories/$filename",
          // Listen the download progress.
          onReceiveProgress: (received, total) {
        print((received / total * 100) / 100);
        setState(() {
          progress = (received / total * 100) / 100;
        });
      });
      setState(() {
        showDownloadProgress = false;
        progress = 0.1;
      });
      final snackBar = SnackBar(
        content: Text('File Downloaded successfully'),
        backgroundColor: Colors.greenAccent[700],
      );
      _scaffoldkey.currentState.showSnackBar(snackBar);
    } catch (e) {
      print(e);
      final snackBar = SnackBar(
        content: Text('Error downloading story'),
        backgroundColor: Colors.redAccent[700],
      );
      _scaffoldkey.currentState.showSnackBar(snackBar);
    }
  }

  initDownload() async {
    String url = "";
    bool noVideos = story.videoVersions.isEmpty;
    String filename = "";
    if (noVideos) {
      url = story.imageVersions2.candidates.first.url;
      filename = "${story.id}.jpg";
    } else {
      url = story.videoVersions.first.url;
      filename = "${story.id}.mp4";
    }
    print("Url $url");
    try {
      var storage = await getExternalStorageDirectory();

      await new Directory("${storage.path}/Download").create(recursive: true);
      setState(() {
        showDownloadProgress = true;
      });
      await Dio().download(url, "${storage.path}/Download/$filename",
          // Listen the download progress.
          onReceiveProgress: (received, total) {
        print((received / total * 100) / 100);
        setState(() {
          progress = (received / total * 100) / 100;
        });
      });
      setState(() {
        showDownloadProgress = false;
        progress = 0.1;
      });
      final snackBar = SnackBar(
        content: Text('File Downloaded successfully'),
        backgroundColor: Colors.greenAccent[700],
      );
      _scaffoldkey.currentState.showSnackBar(snackBar);
      platform.invokeMethod("Scan", filename);
    } catch (e) {
      print(e);
      final snackBar = SnackBar(
        content: Text('Error downloading story'),
        backgroundColor: Colors.redAccent[700],
      );
      _scaffoldkey.currentState.showSnackBar(snackBar);
    }
  }
}
