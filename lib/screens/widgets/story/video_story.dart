import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:stories/bloc/block_provider.dart';
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
  VideoPlayerController _controller;
  bool hasFinished = false;
  StoriesPagerBloc _storiesPagerBloc;

  VoidCallback listener;

  _VideoStory({
    Key key,
    @required this.selectedItem,
    @required this.story,
    @required this.index,
  });

  @override
  void initState() {
    listener = () {
      setState(() {
        var update = _controller.value.position.inMilliseconds /
            _controller.value.duration.inMilliseconds;
        print("pos ${_controller.value.position.inMilliseconds} dur "
            "${_controller.value.duration.inMilliseconds} update $update");
        _storiesPagerBloc.updateProgress(update);
        if (!hasFinished && hasFinishVideo()) {
          hasFinished = true;
          _storiesPagerBloc.onFinished();
        }
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

  bool hasFinishVideo() =>
      _controller.value.duration.inMilliseconds > 100 &&
      _controller.value.position.compareTo(_controller.value.duration) != -1;

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
    _storiesPagerBloc = BlocProvider.of<StoriesPagerBloc>(context);
    _storiesPagerBloc.play.listen((_) => _playVideo());
    _storiesPagerBloc.pause.listen((_) => _pauseVideo());
    return Hero(
        tag: index == selectedItem ? this.story.id : "",
        child: Stack(
            fit: StackFit.expand,
            children: _controller.value.initialized
                ? [
                    AspectRatio(
                      aspectRatio: _controller.value.aspectRatio,
                      child: VideoPlayer(_controller),
                    ),
//                    Text(
//                      "${(_controller.value.position.inMilliseconds) / _controller.value.duration.inMilliseconds} "
//                      "${_controller.value.position.compareTo(_controller.value.duration)}"
//                      " ${hasFinishVideo()}",
//                      style: TextStyle(color: Colors.redAccent, fontSize: 30.0),
//                    ),
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
                  ]));
  }
}
