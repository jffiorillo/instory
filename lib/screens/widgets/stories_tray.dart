import 'package:flutter/material.dart';
import 'package:stories/bloc/block_provider.dart';
import 'package:stories/bloc/stories_bloc.dart';
import 'package:stories/models.dart';

class StoriesArchiveTray extends StatelessWidget {
  final List<Tray> trays;

  StoriesArchiveTray(this.trays);

  @override
  Widget build(BuildContext context) {
    final storiesBloc = BlocProvider.of<StoriesBloc>(context);

    return StreamBuilder<String>(
        initialData: "__TODAY__",
        stream: storiesBloc.selectedTray,
        builder: (context, snapshot) {
          return Container(
            child: ListView.separated(
                scrollDirection: Axis.horizontal,
                physics: ScrollPhysics(parent: BouncingScrollPhysics()),
                separatorBuilder: (context, index) => Divider(
                      indent: 12,
                      color: Colors.black,
                    ),
                itemCount: this.trays.length,
                itemBuilder: (BuildContext context, int index) {
                  return new TrayItem(
                      index, this.trays[index], snapshot.data, storiesBloc);
                }),
          );
        });
  }
}

class TrayItem extends StatefulWidget {
  final int index;
  final Tray tray;
  final String selectedId;
  final StoriesBloc bloc;

  TrayItem(this.index, this.tray, this.selectedId, this.bloc);

  @override
  _TrayItemState createState() => _TrayItemState();
}

abstract class TrayItemView {
  void setLoadingState(bool isLoading);
}

class _TrayItemState extends State<TrayItem> implements TrayItemView {
  bool loading = false;

  @override
  Widget build(BuildContext context) {
    final storiesBloc = BlocProvider.of<StoriesBloc>(context);
    return InkWell(
      onTap: () {
        storiesBloc.selectTrayView(widget.tray.id, this);
      },
      child: Column(children: <Widget>[
        Container(
          width: 64,
          height: 64,
          margin: EdgeInsets.symmetric(horizontal: 15, vertical: 12),
          decoration: BoxDecoration(
              border: Border.all(
                  color: widget.tray.id == widget.selectedId
                      ? Colors.greenAccent[100]
                      : Colors.grey[100],
                  width: widget.tray.id == widget.selectedId ? 4 : 0),
              image: DecorationImage(
                  image: NetworkImage(
                      widget.tray.coverMedia.croppedImageVersion.url)),
              shape: BoxShape.circle),
          child: loading
              ? CircularProgressIndicator(
                  strokeWidth: 4,
                  valueColor:
                      AlwaysStoppedAnimation<Color>(Colors.greenAccent[100]),
                )
              : Container(),
        ),
        Container(
          margin: EdgeInsets.symmetric(horizontal: 2),
          child: Text(widget.tray.title),
        ),
      ]),
    );
  }

  @override
  void setLoadingState(bool isLoading) {
    setState(() {
      loading = isLoading;
    });
  }
}
