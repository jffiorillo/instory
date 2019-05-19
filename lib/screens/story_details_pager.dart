import 'package:flutter/material.dart';
import 'package:stories/bloc/block_provider.dart';
import 'package:stories/bloc/stories_pager_bloc.dart';
import 'package:stories/models.dart';
import 'package:stories/screens/widgets/story/common_story_layout.dart';
import 'package:stories/screens/widgets/story_progress_indicator.dart';

class StoryDetails extends StatefulWidget {
  final int selectedItem;
  final List<Items> trays;

  StoryDetails(this.selectedItem, this.trays);

  @override
  State<StatefulWidget> createState() {
    return _StoryDetails(selectedItem, trays);
  }
}

class _StoryDetails extends State<StoryDetails> with StoriesPagerUi {
  int selectedItem;
  final List<Items> items;
  PageController _controller;

  static const _kDuration = const Duration(milliseconds: 300);

  static const _kCurve = Curves.ease;

  _StoryDetails(this.selectedItem, this.items);

  @override
  void initState() {
    super.initState();
    _controller = PageController(
        initialPage: selectedItem, keepPage: true, viewportFraction: 1);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var scaffold = Scaffold(
        body: SafeArea(
            child: Stack(children: [
      PageView.builder(
        itemBuilder: _pageBuilder,
        physics: BouncingScrollPhysics(),
        pageSnapping: true,
        onPageChanged: _onPageChange,
        controller: _controller,
        itemCount: items.length,
      ),
      Positioned(
        top: 0.0,
        left: 0.0,
        child: StoryProgressIndicator(
          controller: _controller,
          itemCount: items.length,
          selectedItem: this.selectedItem,
        ),
      ),
    ])));
    var storiesPagerBloc = StoriesPagerBloc(this, items.length);
    return BlocProvider(
      bloc: storiesPagerBloc,
      child: scaffold,
    );
  }

  Widget _pageBuilder(BuildContext context, int index) {
    Items story = items[index];
    return Story(
      story: story,
      index: index,
      selectedItem: selectedItem,
    );
  }

  void _onPageChange(int value) {
    setState(() {
      selectedItem = value;
    });
  }

  @override
  int getCurrentPage() {
    return _controller.page.round();
  }

  @override
  void goToNextPage() {
    _controller.nextPage(duration: _kDuration, curve: _kCurve);
  }

  @override
  void goToPreviousPage() {
    _controller.previousPage(duration: _kDuration, curve: _kCurve);
  }
}
