import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stories/bloc/stories_pager_bloc.dart';
import 'package:stories/utils/progress_bar.dart';

class StoryProgressIndicator extends AnimatedWidget {
  StoryProgressIndicator({
    @required this.controller,
    @required this.itemCount,
    @required this.selectedItem,
    color,
  })  : color = color ?? Color.fromRGBO(190, 190, 190, 1.0),
        background = Color.fromRGBO(90, 90, 90, 0.4),
        super(listenable: controller);

  /// The PageController that this StoryProgressIndicator is representing.
  final PageController controller;

  /// The number of items managed by the PageController
  final int itemCount;

  final Color color;

  final int selectedItem;

  final Color background;

  // The base size of the dots
  static const double _kDotSize = 2.0;

  Widget _buildInternalProgressIndicator(
      {double screenWidth, double progress: 0, selected: false}) {
    return Padding(
      padding: EdgeInsets.only(
          top: 8,
          right: _dotPaddingSize(screenWidth),
          left: _dotPaddingSize(screenWidth)),
      child: SizedBox(
          width: selected
              ? _progressIndicatorSize(screenWidth)
              : _dotSize(screenWidth),
          height: 4,
          child: ProgressBar(
            backgroundColor: background,
            foregroundColor: color,
            value: progress ?? 0,
            strokeWidth: _kDotSize,
            animationDuration: selected ? null : 50,
          )),
    );
  }

  Widget _buildProgressIndicator(
          double screenWidth, int index, StoriesPagerBloc storiesPagerBlock) =>
      (selectedItem == index)
          ? StreamBuilder<double>(
              initialData: 0.0,
              stream: storiesPagerBlock.progress,
              builder: (context, snapshot) {
                var progress = snapshot.data ?? 0;
                print("From StreamBuilder $snapshot");
                return _buildInternalProgressIndicator(
                    screenWidth: screenWidth,
                    progress: progress,
                    selected: true);
              })
          : _buildInternalProgressIndicator(
              screenWidth: screenWidth, progress: index < selectedItem ? 1 : 0);

  double _progressIndicatorSize(double screenWidth) => screenWidth / 3;

  double _dotSize(double screenWidth) =>
      dotsSize(screenWidth) * 0.9 / itemCount;

  double _dotPaddingSize(double screenWidth) =>
      dotsSize(screenWidth) * 0.1 / (itemCount * 2);

  double dotsSize(double screenWidth) => (2 * screenWidth / 3);

  Widget build(BuildContext context) {
    var screenWidth = MediaQuery.of(context).size.width;
    var storiesPagerBlock = Provider.of<StoriesPagerBloc>(context);
    return Padding(
        padding: const EdgeInsets.only(left: 4.0),
        child: SizedBox(
            width: screenWidth,
            child: Row(
                children: List<Widget>.generate(
                    itemCount,
                    (index) => _buildProgressIndicator(
                        screenWidth, index, storiesPagerBlock)))));
  }
}
