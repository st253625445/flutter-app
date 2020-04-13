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
  bool showToTopBtn = false; //是否显示“返回到顶部”按钮
  List _items = []; //保存数据

  @override
  void initState() {
    super.initState();
    // 初始化数据
    _retrieveIcons();
    //监听滚动事件，打印滚动位置
    _controller.addListener(() {
      // print(_controller.offset); //打印滚动位置
      if (_controller.offset < 200 && showToTopBtn) {
        setState(() {
          showToTopBtn = false;
        });
      } else if (_controller.offset >= 200 && showToTopBtn == false) {
        setState(() {
          showToTopBtn = true;
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

  @override
  Widget build(BuildContext context) {
    return new Stack(children: [
      GridView.builder(
        padding: EdgeInsets.all(10),
        controller: _controller,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2, //每行2列
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: 3),
        itemCount: _items.length,
        itemBuilder: (context, index) {
          //如果显示到最后一个并且Icon总数小于200时继续获取数据
          if (index == _items.length - 1 && _items.length < 200) {
            _retrieveIcons();
          }
          return new TbktItem(item: _items[index]);
        },
      ),
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
    ]);
  }

  //模拟异步获取数据
  void _retrieveIcons() {
    Future.delayed(Duration(milliseconds: 200)).then((e) {
      setState(() {
        _items.addAll([
          _Item('圣诞节爱好巴巴爸爸是躲不好改吧在咋说的哈事'),
          _Item('22222'),
          _Item('22222'),
        ]);
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
