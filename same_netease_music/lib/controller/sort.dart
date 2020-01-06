import 'package:flutter/material.dart';
import 'dart:ui';
import '../model/PlayListDetailInfo.dart';
import 'package:dio/dio.dart';
import 'listDetail.dart';

class SortPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return SortPageState();
  }
}

class SortPageState extends State<SortPage> {
  List _sortList = List();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _getSortFromNet(0);
    _getSortFromNet(1);
    _getSortFromNet(2);
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Container(
      color: Colors.white,
      child: ListView.builder(
          padding: EdgeInsets.only(left: 10),
          itemCount: _sortList.length,
          itemBuilder: (BuildContext context, int index) {
            return _itemGet(context, _sortList[index]);
          }),
    );
  }

  _getSortFromNet(int index) async {
    Response response;
    Dio dio = Dio();
    response = await dio.get("http://120.79.162.149:3000/top/list",
        queryParameters: {"idx": index});
    var jsonStr = response.data;
    List<PlayListDetailInfo> list = List();
    if (jsonStr['code'] == 200) {
      Map results = jsonStr['playlist'];
      PlayListDetailInfo info =
          PlayListDetailInfo.fromJson(jsonStr['playlist']);
      if (info != null) {
        setState(() {
          _sortList.add(info);
        });
      }
    }
  }
}

Widget _itemGet(BuildContext context, PlayListDetailInfo detail) {
  return GestureDetector(
    onTap: () {
      Navigator.pushNamed(context, "/ListDetailPage",
          arguments: {'id': detail.id});
    },
    child: Container(
      width: MediaQueryData.fromWindow(window).size.width,
      height: 110,
      decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: Colors.grey, width: 0.1))),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                  image: DecorationImage(
                      image: NetworkImage(detail.coverImgUrl)))),
          detail.trackCount < 3
              ? Container()
              : Container(
                  margin: EdgeInsets.only(left: 10),
                  width: 200,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        "1   " +
                            detail.tracks[0].name +
                            '-' +
                            detail.tracks[0].artNames,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 13),
                      ),
                      Container(
                        height: 10,
                      ),
                      Text(
                        "2   " +
                            detail.tracks[1].name +
                            '-' +
                            detail.tracks[1].artNames,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 13),
                      ),
                      Container(
                        height: 10,
                      ),
                      Text(
                        "3   " +
                            detail.tracks[2].name +
                            '-' +
                            detail.tracks[2].artNames,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 13),
                      ),
                    ],
                  ),
                )
        ],
      ),
    ),
  );
}
