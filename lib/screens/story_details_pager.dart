import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stories/bloc/stories_pager_bloc.dart';
import 'package:stories/models.dart';
import 'package:stories/screens/widgets/story/common_story_layout.dart';
import 'package:stories/screens/widgets/story_progress_indicator.dart';

class StoryDetails extends StatelessWidget {
  final int selectedItem;
  final List<Items> items;

  StoryDetails(this.selectedItem, this.items);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SafeArea(
            child: ChangeNotifierProvider(
      builder: (context) => StoriesPagerBloc(items.length, selectedItem),
      child: Consumer<StoriesPagerBloc>(
        builder: (BuildContext context, StoriesPagerBloc storiesPagerBloc, _) =>
            Stack(children: [
              PageView.builder(
                itemBuilder: (context, index) => Story(
                      story: items[index],
                      index: index,
                      selectedItem: storiesPagerBloc.selectedItem,
                    ),
                physics: BouncingScrollPhysics(),
                pageSnapping: true,
                onPageChanged: (value) => storiesPagerBloc.selectedItem = value,
                controller: storiesPagerBloc.controller,
                itemCount: items.length,
              ),
              Positioned(
                top: 0.0,
                left: 0.0,
                child: StoryProgressIndicator(
                  controller: storiesPagerBloc.controller,
                  itemCount: items.length,
                  selectedItem: storiesPagerBloc.selectedItem,
                ),
              ),
            ]),
      ),
    )));
  }
}
