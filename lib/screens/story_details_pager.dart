import 'package:flutter/material.dart';
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

class _StoryDetails extends State<StoryDetails> {
  int selectedItem;
  final List<Items> items;
  PageController _pageController;

  static const _kDuration = const Duration(milliseconds: 300);

  static const _kCurve = Curves.ease;

  _StoryDetails(this.selectedItem, this.items);

  @override
  void initState() {
    super.initState();
    _pageController = PageController(
        initialPage: selectedItem, keepPage: true, viewportFraction: 1);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SafeArea(
            child: Stack(children: [
      PageView.builder(
        itemBuilder: _pageBuilder,
        physics: BouncingScrollPhysics(),
        pageSnapping: true,
        onPageChanged: _onPageChange,
        controller: _pageController,
        itemCount: items.length,
      ),
      Positioned(
        top: 0.0,
        left: 0.0,
        child: StoryProgressIndicator(
          controller: _pageController,
          itemCount: items.length,
          onPageSelected: (int page) {
            _pageController.animateToPage(
              page,
              duration: _kDuration,
              curve: _kCurve,
            );
          },
          selectedItem: this.selectedItem,
        ),
      ),
    ])));
  }

  Widget _pageBuilder(BuildContext context, int index) {
    Items story = items[index];
    return Story(story, index, selectedItem);
  }

  void _onPageChange(int value) {
    setState(() {
      selectedItem = value;
    });
  }
}
