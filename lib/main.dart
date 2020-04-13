import 'package:flutter/material.dart';
import './pages/tbkt_page.dart';
import './pages/testPage.dart';

void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
        title: 'Flutter Demo',
        initialRoute: '/text',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        //注册路由表
        routes: {
          "/": (context) => MyHomePage(), //注册首页路由
          "/text": (context) => TestPage(),
        });
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({Key key}) : super(key: key);

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
          new Expanded(child: TbktPage())
        ]));
  }
}
