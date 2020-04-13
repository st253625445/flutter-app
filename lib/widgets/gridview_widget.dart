import 'package:flutter/material.dart';

typedef RetrieveDataCallback<T> = Future<bool> Function(
    int page, List<T> items, bool refresh);
typedef ItemBuilder<T> = Widget Function(T e, BuildContext ctx);
typedef IndexedItemBuilder<T> = Widget Function(
    List<T> list, int index, BuildContext ctx);

class LoadingState<T> {
  //Save data
  List<T> items = [];
  dynamic error;
  bool loading = false;
  int currentPage = 0;
  bool noMore = false;

  bool get initialized => items.isNotEmpty || noMore;
}

class GridviewRefresh extends StatefulWidget {
  GridviewRefresh({
    Key key,
    @required this.onRetrieveData,
    @required this.itemBuilder,
    this.initFailBuilder,
    this.initLoadingBuilder,
    this.pageSize = 30,
    this.loadMoreErrorViewBuilder,
    this.loadingBuilder,
    this.headerBuilder,
    this.noMoreViewBuilder,
    this.separatorBuilder,
    this.emptyBuilder,
    this.initState,
    this.physics,
  }) : super(key: key);

  @override
  State<GridviewRefresh> createState() => RefreshState();

  final int pageSize;

  final RetrieveDataCallback onRetrieveData;

  final WidgetBuilder initLoadingBuilder;

  final WidgetBuilder loadingBuilder;

  final IndexedItemBuilder itemBuilder;

  final IndexedItemBuilder separatorBuilder;

  final ItemBuilder<List> headerBuilder;

  final ItemBuilder loadMoreErrorViewBuilder;

  final Widget Function(VoidCallback refresh, BuildContext context)
      emptyBuilder;
  final ItemBuilder<List> noMoreViewBuilder;
  final Widget Function(
          VoidCallback refresh, dynamic error, BuildContext context)
      initFailBuilder;
  final LoadingState initState;
  final ScrollPhysics physics;
}

class RefreshState extends State<GridviewRefresh> {
  ScrollController _controller = new ScrollController();
  dynamic error;
  LoadingState state;
  dynamic initError;
  List _items = []; //保存数据
  bool refreshing = false; // 是否正在刷新
  bool isBottom = false; // 是否触底

  @override
  void initState() {
    super.initState();
    state = widget.initState ?? LoadingState();
    if (!state.initialized) {
      refresh(false);
    }
    //监听滚动事件，打印滚动位置
    _controller.addListener(() {
      // 触底加载更多
      isBottom =
          _controller.position.pixels == _controller.position.maxScrollExtent;
      if (!state.loading && isBottom && !refreshing) {
        setState(() {
          loadMore();
        });
      }
    });
  }

  @override
  void dispose() {
    //为了避免内存泄露，需要调用_controller.dispose
    _controller.dispose();
    super.dispose();
  }

  loadMore() async {
    if (state.loading) return;
    state.loading = true;
    try {
      var hasMore = await widget.onRetrieveData(
          state.currentPage + 1, state.items, false);
      if (!hasMore) {
        state.noMore = true;
      }
      error = null;
      ++state.currentPage;
    } catch (e) {
      error = e;
    } finally {
      state.loading = false;
    }
    if (mounted) {
      update();
    }
  }

  void update() {
    setState(() {});
  }

  Future<void> refresh(bool pullDown) async {
    if (state.loading) return;
    state.loading = true;
    state.noMore = false;
    refreshing = true;
    error = null;
    update();
    try {
      var _items = [];
      var hasMore = await widget.onRetrieveData(1, _items, pullDown);
      if (_items.isEmpty ||
          _items.length % widget.pageSize != 0 && hasMore != true) {
        state.noMore = true;
      }
      state.items = _items;
      state.currentPage = 1;
    } catch (e) {
      debugPrint("infiniteListView: $e \n ${e.stackTrace}");
      if (state.currentPage == 0) {
        initError = e;
      }
    } finally {
      state.loading = false;
      refreshing = false;
    }
    if (mounted) {
      update();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (initError != null) {
      if (widget.initFailBuilder != null) {
        return widget.initFailBuilder(() {
          initError = null;
          refresh(false);
        }, initError, context);
      } else {
        return _buildInitFailedView();
      }
    }
    if (state.items.isEmpty) {
      return _buildInitLoadingOrErrorView(context);
    }
    return _build();
  }

  // 失败widget
  Widget _buildInitFailedView() {
    return Material(
      child: InkWell(
        child: Center(
          child: Text("$initError"),
        ),
        onTap: () {
          initError = null;
          refresh(false);
        },
      ),
    );
  }

  // 请求/失败
  Widget _buildInitLoadingOrErrorView(context) {
    if (state.noMore) {
      if (widget.emptyBuilder != null) {
        return widget.emptyBuilder(() => refresh(false), context);
      } else {
        return _buildEmptyView(context);
      }
    } else {
      if (widget.initLoadingBuilder != null) {
        return widget.initLoadingBuilder(context);
      } else {
        return Center(
          child: SizedBox(
            width: 22,
            height: 22,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        );
      }
    }
  }

  // 数组为空
  Widget _buildEmptyView(context) {
    return Material(
      child: InkWell(
        splashColor: Theme.of(context).secondaryHeaderColor,
        onTap: () => refresh(false),
        child: Center(
          child: Text("No data"),
        ),
      ),
    );
  }

  //  加载更多
  Widget _loadingMoreView() {
    if (widget.loadingBuilder != null) {
      return widget.loadingBuilder(context);
    }
    return Container(
      padding: const EdgeInsets.all(16.0),
      alignment: Alignment.center,
      child: SizedBox(
        width: 20.0,
        height: 20.0,
        child: CircularProgressIndicator(strokeWidth: 2.0),
      ),
    );
  }

  // 列表
  Widget _sliverGrid() {
    return SliverGrid(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 8.0,
        mainAxisSpacing: 8.0,
        childAspectRatio: 3.0,
      ),
      delegate: SliverChildBuilderDelegate(
        (BuildContext context, int index) {
          return widget.itemBuilder(_items, index, context);
        },
        childCount: _items.length,
      ),
    );
  }

  // 列表底部
  Widget _buttomWidget() {
    if (error != null) {
      Widget e;
      if (widget.loadMoreErrorViewBuilder != null) {
        e = widget.loadMoreErrorViewBuilder(error, context);
      } else {
        e = Text('Error, Click to retry!');
      }
      return Listener(
        child: Center(child: e),
        onPointerUp: (event) {
          setState(() {
            error = null;
            loadMore();
          });
        },
      );
    } else if (state.noMore || refreshing) {
      if (widget.noMoreViewBuilder != null) {
        return widget.noMoreViewBuilder(state.items, context);
      } else {
        return Container(
          alignment: Alignment.center,
          padding: EdgeInsets.all(16.0),
          child: Text(
            "Total: ${state.items.length}",
            style: TextStyle(color: Colors.grey),
          ),
        );
      }
    } else {
      loadMore();
      return _loadingMoreView();
    }
  }

  Widget _build() {
    return RefreshIndicator(
        onRefresh: () => refresh(true),
        child: CustomScrollView(controller: _controller, slivers: [
          SliverPadding(
              padding: const EdgeInsets.all(8.0), sliver: _sliverGrid()),
          SliverList(
              delegate: new SliverChildBuilderDelegate(
                  (BuildContext context, int index) {
            //创建列表项
            return new Container(
              alignment: Alignment.center,
              padding: EdgeInsets.all(20.0),
              child: Offstage(offstage: !isBottom, child: _buttomWidget()),
            );
          }, childCount: 1))
        ]));
  }
}
