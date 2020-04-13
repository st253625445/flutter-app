import 'package:flutter/material.dart';

class TbktItem extends StatelessWidget {
  const TbktItem({Key key, @required this.item}) : super(key: key);

  final item;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        item.onTap();
      },
      child: new DecoratedBox(
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(4.0), //3像素圆角
              boxShadow: [
                //阴影
                BoxShadow(
                    color: Colors.black26,
                    offset: Offset(1.0, 2.0),
                    blurRadius: 4.0)
              ]),
          child: Padding(
              padding: EdgeInsets.all(10.0),
              child: new Stack(children: [
                Positioned(
                  top: 0,
                  left: 0,
                  right: 100,
                  child: Text(
                    item.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        color: Colors.black, fontSize: 11, height: 1.2),
                  ),
                ),
                Positioned(
                  top: 33,
                  left: 0,
                  right: 100,
                  child: Text(
                    item.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        color: Colors.black, fontSize: 8, height: 1.2),
                  ),
                ),
                Positioned(
                  top: 0,
                  right: 0,
                  child: Container(
                    width: 90,
                    height: 55,
                    color: Colors.grey,
                  ),
                ),
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Row(
                    children: <Widget>[
                      TbktItemTag(
                        tag: '初高中同步课堂',
                      ),
                      TbktItemTag(
                        tag: '24分钟',
                      ),
                    ],
                  ),
                ),
              ]))),
    );
  }
}

// 标签widget
class TbktItemTag extends StatelessWidget {
  const TbktItemTag({Key key, @required this.tag}) : super(key: key);

  final String tag;
  @override
  Widget build(BuildContext context) {
    return Container(
        margin: EdgeInsets.only(right: 10),
        child: DecoratedBox(
            decoration: BoxDecoration(
                color: Colors.grey[350],
                borderRadius: BorderRadius.circular(1.5)),
            child: Container(
                padding: EdgeInsets.all(3),
                child: Text(
                  this.tag,
                  style:
                      TextStyle(color: Colors.black, fontSize: 8, height: 1.2),
                ))));
  }
}
