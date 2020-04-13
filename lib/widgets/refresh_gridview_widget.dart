import 'package:flutter/material.dart';

class PullToRefreshWidget extends StatefulWidget {
  @override
  State<PullToRefreshWidget> createState() => PullToRefreshState();
}

class PullToRefreshState extends State<PullToRefreshWidget> {
  ScrollController _scrollController = new ScrollController();

  @override
  Widget build(BuildContext context) {
    return new RefreshWidget(
      scrollController: _scrollController,
    );
  }
}

class RefreshWidget extends StatefulWidget {
  RefreshWidget({this.scrollController});

  final ScrollController scrollController;

  @override
  State<RefreshWidget> createState() => RefreshState();
}

class RefreshState extends State<RefreshWidget> {
  bool isRefreshing = false;
  bool isLoadingMore = false;
  var mDataList;
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      new GlobalKey<RefreshIndicatorState>();

  void bindItemData(List<ItemInfo> itemDatas) {
    setState(() {
      mDataList.addAll(itemDatas);
      isLoadingMore = false;
      isRefreshing = false;
    });
  }

  void _updateScrollPosition() {
    bool isBottom = widget.scrollController.position.pixels ==
        widget.scrollController.position.maxScrollExtent;
    if (!isLoadingMore && isBottom && !isRefreshing) {
      setState(() {
        isRefreshing = false;
        isLoadingMore = true;
        _loadMore();
      });
    }
  }

  Future<Null> _loadMore() async {
    //模拟耗时3秒
    await new Future.delayed(new Duration(seconds: 5));
    bindItemData(generateData());
    return null;
  }

  @override
  void initState() {
    super.initState();
    widget.scrollController.addListener(_updateScrollPosition);
    mDataList = getDatas();
  }

  @override
  void dispose() {
    widget.scrollController.removeListener(_updateScrollPosition);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return new RefreshIndicator(
        child: _buildListView(), onRefresh: _handlerRefresh);
  }

  Widget _buildListView() {
    return new ListView.builder(
      key: _refreshIndicatorKey,
      controller: widget.scrollController,
      itemBuilder: (context, index) {
        if (index == mDataList.length) {
          return new Container(
            alignment: Alignment.center,
            padding: EdgeInsets.all(5.0),
            child: new SizedBox(
              height: 40.0,
              width: 40.0,
              child: new Opacity(
                opacity: isLoadingMore ? 1.0 : 0.0,
                child: new CircularProgressIndicator(),
              ),
            ),
          );
        }
        return new Column(
          children: <Widget>[
            new Container(
              width: double.infinity,
              height: 38.0,
              alignment: Alignment.centerLeft,
              key: new PageStorageKey<int>(index),
              child: new Text(
                mDataList[index].content,
              ),
            ),
            new Divider(
              height: 2.0,
            )
          ],
        );
      },
      physics: const AlwaysScrollableScrollPhysics(),
      itemCount: mDataList.length + 1,
    );
  }

  Future<Null> _handlerRefresh() async {
    if (!isLoadingMore) {
      setState(() {
        isRefreshing = true;
        isLoadingMore = false;
      });
      //模拟耗时3秒
      await new Future.delayed(new Duration(seconds: 5));
      setState(() {
        mDataList = [];
        isRefreshing = false;
        isLoadingMore = false;
      });
      widget.scrollController.jumpTo(0.0);
    }
    //widget.scrollController.animateTo(0.0, duration: new Duration(milliseconds:100), curve: Curves.linear);
    return null;
  }
}
