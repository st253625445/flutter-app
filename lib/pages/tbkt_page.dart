import 'package:flutter/material.dart';
import '../widgets/listItem/tbkt_list_item.dart';

class TbktPage extends StatelessWidget {
  const TbktPage({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black12,
      child: new Column(
        children: <Widget>[
          new Container(
            width: double.infinity,
            height: 100,
            color: Colors.white,
            padding: EdgeInsets.all(10.0),
            child: new Center(child: new Text('top')),
          ),
          new Expanded(
            child: new TbktGridView(),
          )
        ],
      ),
    );
  }
}

class TbktGridView extends StatefulWidget {
  @override
  _TbktGridViewState createState() => new _TbktGridViewState();
}

class _TbktGridViewState extends State<TbktGridView> {
  ScrollController _controller = new ScrollController();
  List _items = []; //保存数据
  bool showToTopBtn = false; //是否显示“返回到顶部”按钮
  bool isRefreshing = false; // 是否正在刷新
  bool isLoadingMore = false; // 加载更多
  int page = 1; // 请求页面

  @override
  void initState() {
    super.initState();
    // 初始化数据
    _getData();
    //监听滚动事件，打印滚动位置
    _controller.addListener(() {
      // 显示/隐藏返回顶部
      if (_controller.offset < 200 && showToTopBtn) {
        setState(() {
          showToTopBtn = false;
        });
      } else if (_controller.offset >= 200 && showToTopBtn == false) {
        setState(() {
          showToTopBtn = true;
        });
      }
      // 触底加载更多
      bool isBottom =
          _controller.position.pixels == _controller.position.maxScrollExtent;
      if (!isLoadingMore && isBottom && !isRefreshing) {
        setState(() {
          isRefreshing = false;
          isLoadingMore = true;
        });
        page++;
        _loadMore();
      }
    });
  }

  @override
  void dispose() {
    //为了避免内存泄露，需要调用_controller.dispose
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
        onRefresh: _refresh,
        child: new Stack(children: [
          CustomScrollView(controller: _controller, slivers: [
            SliverPadding(
                padding: const EdgeInsets.all(8.0),
                sliver: SliverGrid(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 8.0,
                    mainAxisSpacing: 8.0,
                    childAspectRatio: 3.0,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (BuildContext context, int index) {
                      return new TbktItem(item: _items[index]);
                    },
                    childCount: _items.length,
                  ),
                )),
            SliverList(
              delegate: new SliverChildBuilderDelegate(
                  (BuildContext context, int index) {
                //创建列表项
                return new Container(
                  alignment: Alignment.center,
                  padding: EdgeInsets.all(20.0),
                  child: new SizedBox(
                    height: 20.0,
                    width: 20.0,
                    child: new Opacity(
                      opacity: isLoadingMore ? 1.0 : 0.0,
                      child: new CircularProgressIndicator(
                          backgroundColor: Colors.grey),
                    ),
                  ),
                );
              }, childCount: 1),
            ),
          ]),
          // 返回顶部按钮
          Positioned(
              bottom: 10,
              right: 0,
              child: Offstage(
                offstage: !showToTopBtn,
                child: new FlatButton(
                    color: Colors.blue,
                    highlightColor: Colors.blue[700],
                    colorBrightness: Brightness.dark,
                    splashColor: Colors.grey,
                    child: Icon(Icons.arrow_upward),
                    shape: CircleBorder(),
                    onPressed: () {
                      //返回到顶部时执行动画
                      _controller.animateTo(.0,
                          duration: Duration(milliseconds: 200),
                          curve: Curves.ease);
                    }),
              ))
        ]));
  }

  Future<Null> _refresh() async {
    _items.clear();
    page = 1;
    setState(() {
      isRefreshing = false;
    });
    _getData();
    return;
  }

  Future<Null> _loadMore() async {
    setState(() {
      isLoadingMore = true;
    });
    //模拟耗时2秒
    await new Future.delayed(new Duration(seconds: 2));
    _getData();
  }

  //模拟异步获取数据
  void _getData() {
    Future.delayed(Duration(milliseconds: 200)).then((e) {
      setState(() {
        _items.addAll([
          _Item('圣诞节爱好巴巴爸爸是躲不好改吧在咋说的哈事'),
          _Item('22222'),
          _Item('22222'),
          _Item('22222'),
          _Item('22222'),
          _Item('22222'),
          _Item('22222'),
          _Item('22222'),
          _Item('22222'),
        ]);
        isLoadingMore = false;
        isRefreshing = false;
      });
    });
  }
}

class _Item {
  String title;
  void onTap() {
    print(this.title);
  }

  _Item(this.title);

  _Item.fromJson(Map json) {
    title = json['title'];
  }
}
