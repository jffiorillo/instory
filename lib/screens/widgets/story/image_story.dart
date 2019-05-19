import 'package:flutter/widgets.dart';
import 'package:stories/bloc/block_provider.dart';
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

  @override
  Widget build(BuildContext context) {
    var storiesPagerBloc = BlocProvider.of<StoriesPagerBloc>(context);
    this._animation
      ..addListener(() => storiesPagerBloc.updateProgress(_animation.value))
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed && _animation.value == 1.0) {
          storiesPagerBloc.onFinished();
        }
      });
    storiesPagerBloc.pause.listen((_) => this._controller.stop());
    storiesPagerBloc.play.listen((_) => this._controller.forward());
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
    this._controller
      ..value = 0
      ..forward();
  }

  @override
  void dispose() {
    super.dispose();
    this._controller.dispose();
  }
}
