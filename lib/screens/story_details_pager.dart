import 'package:flutter/material.dart';
import 'package:stories/models.dart';
import 'package:stories/screens/widgets/story/common_story_layout.dart';

class StoryDetails extends StatefulWidget {
  final int selectedItem;
  final List<Items> trays;

  StoryDetails(this.selectedItem, this.trays);

  @override
  State<StatefulWidget> createState() {
    return new _StoryDetails(selectedItem, trays);
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
    _pageController = new PageController(
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
      body:
//        Row(
//        children: <Widget>[
//          Container(
//            padding: EdgeInsets.all(100),
//              child: SizedBox(
//            height: 6,
////                child: ListView.separated(
////                    scrollDirection: Axis.horizontal,
////                    physics: const NeverScrollableScrollPhysics(),
////                    separatorBuilder: (context, index) => Divider(
////                      indent: 1,
////                      color: Colors.black,
////                    ),
////                    itemCount: items.length,
////                    itemBuilder: (BuildContext context, int index) {
////                      return LinearProgressIndicator(
////                        value: index < selectedItem
////                            ? 1
////                            : index == selectedItem ? 0.5 : 0,
////                      );
////                    }),
//            child: DotsIndicator(
//              controller: _pageController,
//              itemCount: items.length,
//              onPageSelected: (int page) {
//                _pageController.animateToPage(
//                  page,
//                  duration: _kDuration,
//                  curve: _kCurve,
//                );
//              },
//            ),
//          )),
          PageView.builder(
        itemBuilder: _pageBuilder,
        physics: BouncingScrollPhysics(),
        pageSnapping: true,
        onPageChanged: _onPageChange,
        controller: _pageController,
        itemCount: items.length,
      )
//        ],
//      )
      ,
    );
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
