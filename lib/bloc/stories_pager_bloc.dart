import 'dart:async';

import 'package:stories/bloc/block_provider.dart';

class StoriesPagerBloc extends BlocBase {
  final StoriesPagerUi ui;
  final int itemCount;

  final StreamController<void> _play = StreamController.broadcast();
  final StreamController<void> _stop = StreamController.broadcast();
  final StreamController<double> _progress = StreamController.broadcast();

  Stream<void> get play => _play.stream;
  Stream<void> get pause => _stop.stream;
  Stream<double> get progress => _progress.stream;

  StoriesPagerBloc(this.ui, this.itemCount);

  void updateProgress(double update){
    _progress.add(update);
  }

  void onPlay(){
    _play.add(null);
  }

  void onPause(){
    _stop.add(null);
  }

  void onFinished() {
    onNextClicked();
  }

  void onNextClicked() {
    if (ui.getCurrentPage() < itemCount) {
      ui.goToNextPage();
    }
  }

  void onPreviousClicked() {
    if (ui.getCurrentPage() > 0) {
      ui.goToPreviousPage();
    }
  }

  @override
  void dispose() {
    _play.close();
    _stop.close();
    _progress.close();
  }
}

abstract class StoriesPagerUi {
  int getCurrentPage();

  void goToNextPage();

  void goToPreviousPage();
}
