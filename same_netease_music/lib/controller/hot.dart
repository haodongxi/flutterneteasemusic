import 'dart:collection';

import 'package:flutter/material.dart';
import 'dart:ui';
import '../Tool/contextTool.dart';
import 'more.dart';
import 'package:lpinyin/lpinyin.dart';
import 'package:dio/dio.dart';
import '../model/ArtistInfo.dart';
import 'package:extended_image/extended_image.dart';
import 'package:cached_network_image/cached_network_image.dart';

class HotPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return HotPageState();
  }
}

class HotPageState extends State<HotPage> with AutomaticKeepAliveClientMixin {
  List<ArtistInfo> _artList = List();
  List<String> _titleList = List();
  Map<String, List> _kindOfArtsMap = Map();

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    for (int i = 0; i < 28; i++) {
      String tempStr = null;
      if (i == 0) {
        tempStr = "热门";
      } else if (i == 27) {
        tempStr = "#";
      } else {
        tempStr = String.fromCharCode('A'.codeUnitAt(0) + (i - 1));
      }
      _titleList.add(tempStr);
      List tempList = List();
      _kindOfArtsMap[tempStr] = tempList;
    }

    _getArtsFromNet();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Container(
        child: ListView.separated(
      itemBuilder: (BuildContext context, int index) {
        ArtistInfo item = _artList[index];
        return item.isTitle == false
            ? Container()
            : Container(
                height: 20,
                color: Colors.grey,
                alignment: Alignment.topLeft,
                child: Container(
                  margin: EdgeInsets.only(left: 20),
                  width: 150,
                  child: Text(
                    item.name,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                    ),
                  ),
                ));
      },
      separatorBuilder: (BuildContext context, int index) {
        ArtistInfo item = _artList[index];
        return item.isTitle == true
            ? Container()
            : Container(
                height: 80,
                child: GestureDetector(
                  onTap: () {
                    print(item.id);
                    Navigator.pushNamed(context, "/ListDetailPage",
                        arguments: {'id': item.id, "singer": true});
                  },
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Container(
                        margin: EdgeInsets.only(left: 5),
                        width: 75,
                        height: 75,
                        child: CachedNetworkImage(
                          imageUrl: item.picUrl,
                          width: 75,
                          height: 75,
                          fit: BoxFit.fill,
                        ),
//                        decoration: BoxDecoration(
//                          image:
//                              DecorationImage(image: NetworkImage(item.picUrl)),
//                        ),
                      ),
                      Container(
                        margin: EdgeInsets.only(left: 10),
                        width: 150,
                        child: Text(
                          item.name,
                        ),
                      )
                    ],
                  ),
                ),
              );
      },
      itemCount: _artList.length,
    ));
  }

//  http://120.79.162.149:3000/top/artists?limit=100

  _getArtsFromNet() async {
    Response response;
    Dio dio = Dio();
    response = await dio.get("http://120.79.162.149:3000/top/artists",
        queryParameters: {"limit": 100});
    var jsonStr = response.data;
    if (jsonStr['code'] == 200) {
      List artists = jsonStr['artists'];
      List<ArtistInfo> tempList = List();
      for (Map dict in artists) {
        ArtistInfo info = ArtistInfo.fromJson(dict);
        if (info != null) {
          if (info.name != null) {
            String tempStr = PinyinHelper.getShortPinyin(info.name[0]);
            if (tempStr != '#') {
              _kindOfArtsMap[tempStr.toUpperCase()].add(info);
            } else {
              _kindOfArtsMap['#'].add(info);
            }
            tempList.add(info);
          }
        }
      }

      if (tempList.length > 10) {
        for (int i = 0; i < 10; i++) {
          _kindOfArtsMap["热门"].add(tempList[i]);
        }
      }

      for (int i = 0; i < _titleList.length; i++) {
        String kindStr = _titleList[i];
        List subList = _kindOfArtsMap[kindStr];

        ArtistInfo titleInfo = ArtistInfo();
        titleInfo.name = kindStr;
        titleInfo.isTitle = true;
        _artList.add(titleInfo);
        for (int j = 0; j < subList.length; j++) {
          ArtistInfo realInfo = subList[j];
          realInfo.isTitle = false;
          _artList.add(realInfo);
        }
      }

      setState(() {
        _artList = _artList;
      });
    }
  }
}
