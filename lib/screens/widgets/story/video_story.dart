import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
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
  VideoPlayerController _controller;
  VoidCallback listener;

  _VideoStory({
    Key key,
    this.selectedItem,
    this.story,
    this.index,
  });

  @override
  void initState() {
    listener = () {
      setState(() {
        _controller = _controller;
      });
    };
    super.initState();
    _controller = VideoPlayerController.network(this.story.videoVersions[1].url)
      ..addListener(listener)
      ..initialize().then((_) {
        // Ensure the first frame is shown after the video is initialized, even before the play button has been pressed.
        _playVideo();
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _playVideo() {
    if (_controller.value.initialized) {
      setState(() {
        _controller.play();
      });
    }
    print("Duration ${_controller.value.duration}");
  }

  void _pauseVideo() {
    if (_controller.value.initialized) {
      setState(() {
        _controller.pause();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Hero(
        tag: index == selectedItem ? this.story.id : "",
        child: GestureDetector(
            onVerticalDragEnd: (DragEndDetails down) {
              if (down.primaryVelocity > 800) {
                Navigator.pop(context);
              }
            },
            onLongPressEnd: (LongPressEndDetails details) {
              _playVideo();
            },
            onTapDown: (TapDownDetails details) {
              _pauseVideo();
            },
            onTapUp: (TapUpDetails details) {
              _playVideo();
            },
            child: Stack(
                fit: StackFit.expand,
                children: _controller.value.initialized
                    ? [
                        AspectRatio(
                          aspectRatio: _controller.value.aspectRatio,
                          child: VideoPlayer(_controller),
                        )
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
                      ])));
  }
}
