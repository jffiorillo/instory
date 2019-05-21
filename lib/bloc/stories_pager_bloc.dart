import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

const _kDuration = const Duration(milliseconds: 300);
const _kCurve = Curves.ease;

class StoriesPagerBloc with ChangeNotifier {
  final int itemCount;
  int selectedItem;
  bool _isPlaying = true;
  final StreamController<bool> _play = StreamController.broadcast();
  final StreamController<double> _progress = StreamController.broadcast();
  final PageController _controller;

  StoriesPagerBloc(this.itemCount, this.selectedItem)
      : _controller = PageController(
            initialPage: selectedItem, keepPage: true, viewportFraction: 1);

  Stream<bool> get isPlayingStream => _play.stream;

  PageController get controller => _controller;

  set play(bool value) {
    _isPlaying = true;
    _play.add(true);
    notifyListeners();
  }

  Stream<double> get progress => _progress.stream;

  set updateProgress(double update) {
    _progress.add(update);
    notifyListeners();
  }

  void onFinished() {
    onNextClicked();
  }

  void onNextClicked() {
    if (_currentPage < itemCount) {
      _controller.nextPage(duration: _kDuration, curve: _kCurve);
    }
  }

  void onPreviousClicked() {
    if (_currentPage > 0) {
      _controller.previousPage(duration: _kDuration, curve: _kCurve);
    }
  }

  int get _currentPage => this._controller.page.round();

  bool get isPlaying => _isPlaying;

  bool get isPause => !_isPlaying;

  @override
  void dispose() {
    super.dispose();
    _play.close();
    _progress.close();
    _controller.dispose();
  }
}
