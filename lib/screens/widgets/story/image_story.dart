import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:stories/bloc/stories_pager_bloc.dart';
import 'package:stories/models.dart';

class ImageStory extends StatefulWidget {
  final int index;

  final int selectedItem;
  final Items story;
  final int animationDuration = 5;

  ImageStory({
    Key key,
    @required this.selectedItem,
    @required this.story,
    @required this.index,
  }) : super(key: key);

  @override
  _ImageStoryState createState() => _ImageStoryState();
}

class _ImageStoryState extends State<ImageStory>
    with SingleTickerProviderStateMixin {
  AnimationController _controller;
  Animation<double> _animation;
  StoriesPagerBloc _storiesPagerBloc;
  StreamSubscription _play;
  StreamSubscription _pause;

  @override
  Widget build(BuildContext context) {
    _storiesPagerBloc = Provider.of<StoriesPagerBloc>(context);
    if (_storiesPagerBloc.isPlaying) {
      _controller.forward();
    }
    _play = _storiesPagerBloc.isPlayingStream.listen((isPlaying) =>
        isPlaying ? this._controller.forward() : this._controller.stop());
    this._animation
      ..addListener(() {
        if (_controller.isAnimating) {
          _storiesPagerBloc.updateProgress = _animation.value;
        }
      })
      ..addStatusListener((status) {
        print("status listener $status");
        if (status == AnimationStatus.completed && _animation.value == 1.0) {
          _storiesPagerBloc.onFinished();
        }
      });
    return Hero(
      tag: widget.index == widget.selectedItem ? widget.story.id : "",
      child: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          FadeInImage(
              fit: BoxFit.fill,
              fadeInDuration: Duration(milliseconds: 50),
              placeholder:
                  NetworkImage(widget.story.imageVersions2.candidates[5].url),
              image:
                  NetworkImage(widget.story.imageVersions2.candidates[2].url)),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    this._controller = AnimationController(
      duration: Duration(seconds: this.widget.animationDuration),
      vsync: this,
    );
    this._animation = Tween(begin: 0.0, end: 1.0).animate(this._controller);
    this._controller..value = 0;
  }

  @override
  void dispose() {
    super.dispose();
    _pause.cancel();
    _play.cancel();
    this._controller.dispose();
  }
}
