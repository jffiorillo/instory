import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:stories/bloc/stories_pager_bloc.dart';
import 'package:stories/models.dart';
import 'package:video_player/video_player.dart';

class VideoStory extends StatefulWidget {
  final int index;
  final int selectedItem;
  final Items story;

  VideoStory({
    Key key,
    @required this.selectedItem,
    @required this.story,
    @required this.index,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() =>
      _VideoStory(selectedItem: selectedItem, story: story, index: index);
}

class _VideoStory extends State<VideoStory> {
  final int index;
  final int selectedItem;
  final Items story;
  StreamSubscription _play;

  _VideoStory({
    Key key,
    @required this.selectedItem,
    @required this.story,
    @required this.index,
  });

//  @override
//  void initState() {
////    _listener = () {
////      if (this.mounted) {
////        var update = (_controller.value.position.inMilliseconds /
////            _controller.value.duration.inMilliseconds *
////            100)
////            .roundToDouble() /
////            100;
//////        print("updateProgress video $update ${_controller.value.position.inMilliseconds} dur ${_controller.value.duration.inMilliseconds}");
////        _storiesPagerBloc.updateProgress = update;
////        if (hasFinishVideo()) {
////          _storiesPagerBloc.onFinished();
////          _controller.removeListener(_listener);
////        }
////      }
////    };
//    super.initState();
////    _controller = VideoPlayerController.network(this.story.videoVersions[1].url)
////      ..addListener(_listener)
////      ..initialize().then((_) {
////        if (_storiesPagerBloc.isPlaying) {
////          _playVideo();
////        }
////      })
//        ;
//  }

  bool hasFinishVideo(VideoPlayerController _controller) =>
      _controller.value.initialized &&
      _controller.value.duration.inMilliseconds > 100 &&
      _controller.value.position.compareTo(_controller.value.duration) != -1;

  @override
  void dispose() {
    super.dispose();
    _play.cancel();
  }

  void _playVideo(VideoPlayerController _controller) {
    if (_controller.value.initialized) {
      setState(() {
        _controller.play();
      });
    }
  }

  void _pauseVideo(VideoPlayerController _controller) {
    print("Pause");
    if (_controller.value.initialized) {
      setState(() {
        _controller.pause();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    StoriesPagerBloc storiesPagerBloc = Provider.of<StoriesPagerBloc>(context);
    return Hero(
        tag: index == selectedItem ? this.story.id : "",
        child: ChangeNotifierProvider(
          builder: (context) =>
              VideoPlayerController.network(this.story.videoVersions[1].url),
          child: Consumer<VideoPlayerController>(builder:
              (BuildContext context, VideoPlayerController controller, _) {
            print("${controller.value.initialized}");
            if (hasFinishVideo(controller)) {
              storiesPagerBloc.onFinished();
            }
            _play = storiesPagerBloc.isPlayingStream.listen((play) =>
                play ? _playVideo(controller) : _pauseVideo(controller));
            return Stack(
                fit: StackFit.expand,
                children: controller.value.initialized
                    ? [
                        AspectRatio(
                          aspectRatio: controller.value.aspectRatio,
                          child: VideoPlayer(controller),
                        ),
                      ]
                    : [
                        FadeInImage(
                            fit: BoxFit.cover,
                            fadeInDuration: Duration(milliseconds: 100),
                            placeholder: NetworkImage(
                                story.imageVersions2.candidates[5].url),
                            image: NetworkImage(
                                story.imageVersions2.candidates[2].url)),
                        Center(child: CircularProgressIndicator())
                      ]);
          }),
        ));
  }
}
