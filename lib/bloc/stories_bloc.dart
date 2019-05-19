import 'dart:async';

import 'package:stories/bloc/block_provider.dart';
import 'package:stories/models.dart';
import 'package:stories/screens/widgets/stories_tray.dart';
import 'package:stories/utils/cache.dart';

class StoriesBloc extends BlocBase {
  List<Items> _todaysStories = [];
  StreamController<List<Tray>> _storiesTrayStream =
      new StreamController<List<Tray>>();
  StreamController<int> _selectedStory = new StreamController<int>();
  StreamController<ApiResponse> _profileResponse =
      new StreamController<ApiResponse>();
  StreamController<String> _selectedTray = new StreamController<String>();
  StreamController<String> _loadingHighLight = new StreamController<String>();

  StreamController<List<Items>> _storiesStream =
      new StreamController<List<Items>>();

  Stream<List<Tray>> get storiesArchive => _storiesTrayStream.stream;

  Stream<List<Items>> get stories => _storiesStream.stream;

  Stream<String> get selectedTray => _selectedTray.stream;

  Stream<int> get selectedStory => _selectedStory.stream;

  Stream<ApiResponse> get apiResponse => _profileResponse.stream;

  Stream<String> get loadingHighLight => _loadingHighLight.stream;

  List<Items> get todaysStories => _todaysStories;

  StoriesBloc(ApiResponse profile, HighLightsResponse response) {
    List<Tray> items = [];
    items.add(new Tray(
        title: "Today",
        id: "__TODAY__",
        coverMedia: new CoverMedia(
            croppedImageVersion:
                new CroppedImageVersion(url: profile.user.profilePicUrl))));
    items.addAll(response.tray);
    _selectedTray.sink.add("__TODAY__");
    _loadingHighLight.sink.add("_NONE_");
    _profileResponse.sink.add(profile);
    _storiesTrayStream.sink.add(items);
    _addStories(profile.items);

    //storing for tray clicks
    _todaysStories.addAll(profile.items);
  }

  @override
  void dispose() {
    _storiesTrayStream.close();
    _storiesStream.close();
    _selectedTray.close();
    _loadingHighLight.close();
    _selectedStory.close();
    _profileResponse.close();
  }

  void _selectTray(String index) {
    this._selectedTray.sink.add(index);
  }

  Future selectTrayView(String trayIndex, TrayItemView view) async {
    if (trayIndex == "__TODAY__") {
      _addStories(todaysStories);
      _selectTray(trayIndex);
    } else {
      view.setLoadingState(true);
      var highlight = await Cache.getCacheHighLight();
      _addStories(highlight.highLight.items);
      _selectTray(trayIndex);
      view.setLoadingState(false);
    }
  }

  void selectStory(int index) {
    this._selectedStory.sink.add(index);
  }

  void _addStories(List<Items> items) {
    _storiesStream.sink.add(items);
  }

  void setHighLightLoading(String id) {
    _loadingHighLight.sink.add(id);
  }
}
