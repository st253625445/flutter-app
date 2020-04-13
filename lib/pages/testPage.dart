import 'package:flutter/material.dart';
import '../widgets/gridview_widget.dart';
import '../widgets/listItem/tbkt_list_item.dart';

class TestPage extends StatefulWidget {
  @override
  State<TestPage> createState() => TestPageState();
}

class TestPageState extends State<TestPage> {
  @override
  Widget build(BuildContext context) {
    return Material(
        color: Color(0xffffffff),
        child: new Row(children: <Widget>[
          new Container(
            width: 50,
            color: Color(0xffa3a5a7),
            child: new Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Icon(Icons.airport_shuttle),
                Icon(Icons.beach_access),
                Icon(Icons.cake),
                Icon(Icons.free_breakfast)
              ],
            ),
          ),
          new Expanded(
              child: Container(
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
                  child: new GridviewRefresh(
                    onRetrieveData: (int page, List items, bool refresh) async {
                      var data =
                          await Future.delayed(Duration(milliseconds: 200))
                              .then((e) {
                        return [
                          _Item('圣诞节爱好巴巴爸爸是躲不好改吧在咋说的哈事'),
                          _Item('22222'),
                          _Item('22222'),
                          _Item('22222'),
                          _Item('22222'),
                          _Item('22222'),
                          _Item('22222'),
                          _Item('22222'),
                          _Item('22222'),
                        ];
                      });
                      //把请求到的新数据添加到items中
                      items.addAll(data);
                      // 如果接口返回的数量等于'page_size'，则认为还有数据，反之则认为最后一页
                      return items.length > 20;
                    },
                    itemBuilder: (List list, int index, BuildContext ctx) {
                      // 项目信息列表项
                      return new TbktItem(item: list[index]);
                    },
                  ),
                )
              ],
            ),
          ))
        ]));
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
