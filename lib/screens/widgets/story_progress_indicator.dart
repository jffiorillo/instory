import 'dart:math';

import 'package:flutter/material.dart';

class StoryProgressIndicator extends AnimatedWidget {
  StoryProgressIndicator({
    @required this.controller,
    @required this.itemCount,
    this.onPageSelected,
    @required this.selectedItem,
    this.color: Colors.white,
  }) : super(listenable: controller);

  /// The PageController that this StoryProgressIndicator is representing.
  final PageController controller;

  /// The number of items managed by the PageController
  final int itemCount;

  /// Called when a dot is tapped
  final ValueChanged<int> onPageSelected;

  /// The color of the dots.
  ///
  /// Defaults to `Colors.white`.
  final Color color;

  final int selectedItem;

  // The base size of the dots
  static const double _kDotSize = 8.0;

  // The increase in the size of the selected dot
  static const double _kMaxZoom = 2.0;

//  // The distance between the center of each dot
//  static const double _kDotSpacing = 25.0;

  Widget _buildDot(double screenWidth, int index) {
    double selectedness = Curves.easeOut.transform(
      max(
        0.0,
        1.0 - ((controller.page ?? controller.initialPage) - index).abs(),
      ),
    );
    double zoom = 1.0 + (_kMaxZoom - 1.0) * selectedness;
    var dotSize = _dotSize(screenWidth);
    var padding = _dotPaddingSize(screenWidth);
    return Padding(
      padding: EdgeInsets.only(left: padding, right: padding),
      child: new Container(
        width: dotSize,
        child: new Center(
          child: new Material(
            color: color,
            type: MaterialType.circle,
            child: new Container(
              width: _kDotSize * zoom,
              height: _kDotSize * zoom,
              child: new InkWell(
                onTap: () => onPageSelected(index),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProgressIndicator(double screenWidth, int index) {
    return Container(
      child: SizedBox(
        width: _progressIndicatorSize(screenWidth),
        child: LinearProgressIndicator(
          value: index < selectedItem ? 1 : 0,
        ),
      ),
    );
  }

  double _progressIndicatorSize(double screenWidth) => screenWidth / 3;

  double _dotSize(double screenWidth) =>
      dotsSize(screenWidth) * 0.9 / itemCount;

  double _dotPaddingSize(double screenWidth) =>
      dotsSize(screenWidth) * 0.1 / (itemCount * 2);

  double dotsSize(double screenWidth) => (2 * screenWidth / 3);

  Widget build(BuildContext context) {
    var screenWidth = MediaQuery.of(context).size.width;
    print(
        "screenWidth $screenWidth paddingSize ${_dotPaddingSize(screenWidth)} dotSize ${_dotSize(screenWidth)} li");
    print("$screenWidth == "
        "${_dotSize(screenWidth) * itemCount + 2 * itemCount * _dotPaddingSize(screenWidth)}");
    return SizedBox(
        width: screenWidth,
        child: Row(
            children: List<Widget>.generate(
                itemCount,
                (index) => index == selectedItem
                    ? _buildProgressIndicator(screenWidth, index)
                    : _buildDot(screenWidth, index))));
  }
}
