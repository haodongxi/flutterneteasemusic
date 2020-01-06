import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:ui';
import '../model/SearchHotInfo.dart';
import '../model/SongInfo.dart';
import '../model/ArtistInfo.dart';
import 'package:dio/dio.dart';

class SearchPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return searchState();
  }
}

class searchState extends State<SearchPage> {
  List<SearchHotInfo> _searchHotList = List();
  List<SongInfo> _searchList;
  List<ArtistInfo> _suggestList;
  bool _isDisplayCloseButton = false;
  OverlayEntry _entry;
  TextEditingController _editingController;
  bool _isClickHotBtn = false;
  @override
  void initState() {
    super.initState();
    _editingController = TextEditingController()
      ..addListener(() {
        if (_editingController.text.length <= 0) {
          _removeEntry();
        } else {
          _isClickHotBtn = false;
          _searchkeyWordsFromNet(_editingController.text, context);
        }
      });
    _getHotFromNet();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: MediaQueryData.fromWindow(window).size.width,
        height: double.infinity,
        alignment: Alignment.topLeft,
        color: Colors.white,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              height: MediaQueryData.fromWindow(window).padding.top + 50,
              color: Colors.red,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: <Widget>[
                  Container(
                    margin: EdgeInsets.only(
                        top: MediaQueryData.fromWindow(window).padding.top),
                    child: IconButton(
                        icon: Icon(Icons.arrow_back_ios),
                        iconSize: 24,
                        color: Colors.white,
                        padding: EdgeInsets.only(bottom: 10),
                        onPressed: () {
                          _removeEntry();
                          Navigator.of(context).pop();
                        }),
                  ),
                  Container(
                    margin: EdgeInsets.only(bottom: 7),
                    height: 40,
                    width:
                        MediaQueryData.fromWindow(window).size.width - 48 * 2,
                    child: CupertinoTextField(
                      controller: _editingController,
                      cursorColor: Colors.white,
                      placeholderStyle: TextStyle(color: Colors.white),
                      style: TextStyle(
                        color: Colors.white,
                      ),
                      placeholder: '搜索歌曲、歌手',
                      // cursorRadius: ,
                      decoration: BoxDecoration(
                          border: Border(
                              bottom:
                                  BorderSide(width: 0.4, color: Colors.white))),
                    ),
                  ),
                  _isDisplayCloseButton == false
                      ? Container()
                      : IconButton(
                          icon: Icon(
                            Icons.close,
                            color: Colors.white,
                          ),
                          onPressed: () {
                            _removeEntry();
                          },
                        )
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.only(left: 20, top: 20, bottom: 10),
              child: Text(
                '热门搜索',
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
            ),
            Container(
                color: Colors.white,
                padding: EdgeInsets.only(left: 20, right: 10),
                width: MediaQueryData.fromWindow(window).size.width,
                child: Wrap(
                    spacing: 5,
                    runSpacing: 5,
                    children: List.generate(_searchHotList.length, (index) {
                      return GestureDetector(
                        onTap: () {
                          _isClickHotBtn = true;
                          _removeEntry();
                          _searchkeyWordsFromNet(
                              _searchHotList[index].first, context);
//                          _suggestkeyWordsFromNet(
//                              _searchHotList[index].first, context);
                        },
                        child: Container(
                          padding: EdgeInsets.all(2.0),
                          decoration: BoxDecoration(
                            border: Border.all(
                              width: 0.5,
                              color: Colors.grey,
                            ),
                            borderRadius: BorderRadius.circular(2.0),
                          ),
                          child: Text(_searchHotList[index].first),
                        ),
                      );
                    }))),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              mainAxisSize: MainAxisSize.max,
              children: <Widget>[
                Container(
                  padding: EdgeInsets.only(
                    left: 20,
                    top: 20,
                  ),
                  child: Text(
                    '搜索历史',
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                ),
                Container(
                    padding: EdgeInsets.only(
                      left: 20,
                      top: 20,
                    ),
                    child:
                        IconButton(icon: Icon(Icons.delete), onPressed: null)),
              ],
            ),
            Expanded(
                child: Container(
              width: MediaQueryData.fromWindow(window).size.width,
              child: ListView.builder(
                itemExtent: 30,
                padding: EdgeInsets.all(0),
                itemCount: _searchHotList.length,
                itemBuilder: (BuildContext context, index) {
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    mainAxisSize: MainAxisSize.max,
                    children: <Widget>[
                      Container(
                        padding: EdgeInsets.only(
                          left: 20,
                        ),
                        child: Text(
                          _searchHotList[index].first,
                          style: TextStyle(fontSize: 14),
                        ),
                      ),
                      Container(
                          padding: EdgeInsets.only(
                            left: 20,
                          ),
                          child: IconButton(
                              icon: Icon(Icons.delete_forever),
                              onPressed: null)),
                    ],
                  );
                },
              ),
            )),
          ],
        ),
      ),
    );
  }

  _getHotFromNet() async {
    Response response;
    Dio dio = Dio();
    response = await dio.get("http://120.79.162.149:3000/search/hot");
    var jsonStr = response.data;
    if (jsonStr['code'] == 200) {
      Map results = jsonStr['result'];
      List hots = results['hots'];
      for (Map dict in hots) {
        SearchHotInfo info = SearchHotInfo.fromJson(dict);
        _searchHotList.add(info);
      }
      setState(() {});
    }
  }

  _searchkeyWordsFromNet(String keywords, BuildContext context) async {
    Response response;
    Dio dio = Dio();
    response = await dio.get("http://120.79.162.149:3000/search",
        queryParameters: {"keywords": keywords, "offset": 0});
    var jsonStr = response.data;
    if (jsonStr['code'] == 200) {
      Map results = jsonStr['result'];
      List hots = results['songs'];
      List<SongInfo> infoList = List();
      for (Map dict in hots) {
        SongInfo info = SongInfo.fromJson(dict);
        infoList.add(info);
      }
      setState(() {
        _searchList = infoList;
        _searchlistWidget(context);
      });
    }
  }

  _suggestkeyWordsFromNet(String keywords, BuildContext context) async {
    Response response;
    Dio dio = Dio();
    response = await dio.get("http://120.79.162.149:3000/search/suggest",
        queryParameters: {"keywords": keywords});
    var jsonStr = response.data;
    if (jsonStr['code'] == 200) {
      Map results = jsonStr['result'];
      List hots = results['artists'];
      List<ArtistInfo> infoList = List();
      for (Map dict in hots) {
        ArtistInfo info = ArtistInfo.fromJson(dict);
        infoList.add(info);
      }
      setState(() {
        _suggestList = infoList;
      });
    }
  }

  _searchlistWidget(BuildContext context) {
    _removeEntry();
    //判断是否需要显示
    if (_editingController.text.length <= 0) {
      if (_isClickHotBtn == false) {
        return;
      } else {
        _isClickHotBtn = false;
      }
    }
    //创建OverlayEntry
    OverlayEntry entry = OverlayEntry(builder: (BuildContext context) {
      return Positioned(
          top: MediaQueryData.fromWindow(window).padding.top + 50,
          left: 0,
          child: Container(
            width: MediaQueryData.fromWindow(window).size.width,
            height: MediaQueryData.fromWindow(window).size.height -
                (MediaQueryData.fromWindow(window).padding.top + 50),
            color: Colors.white,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  margin: EdgeInsets.only(left: 20, top: 10),
                  child: Text(
                    '最佳匹配',
                    style: TextStyle(
                        fontSize: 14,
                        color: Colors.red,
                        decoration: TextDecoration.none,
                        fontWeight: FontWeight.normal),
                  ),
                ),
                _searchList == null
                    ? Container()
                    : Expanded(
                        child: ListView.builder(
                            itemCount: _searchList.length,
                            itemBuilder: (BuildContext context, int index) {
                              SongInfo info = _searchList[index];
                              return GestureDetector(
                                onTap: () {
                                  _removeEntry();
                                  _editingController.text = "";
                                  Navigator.of(context).pushNamed('/play',
                                      arguments: {"song": info});
                                },
                                child: Container(
                                  width: 250,
                                  height: 70,
                                  padding: EdgeInsets.only(
                                    left: 20,
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Text(
                                        '${info.name}',
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                            fontSize: 18,
                                            color: Colors.black,
                                            decoration: TextDecoration.none,
                                            fontWeight: FontWeight.normal),
                                      ),
                                      Text(
                                        '${info.artNames}',
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.grey,
                                            decoration: TextDecoration.none,
                                            fontWeight: FontWeight.normal),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }),
                      )
              ],
            ),
          ));
    });
//往Overlay中插入插入OverlayEntry
    Overlay.of(context).insert(entry);
    _entry = entry;
    setState(() {
      _isDisplayCloseButton = true;
    });
  }

  _removeEntry() {
    if (_entry != null) {
      _entry.remove();
      _entry = null;
    }
    setState(() {
      _isDisplayCloseButton = false;
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    if (_entry != null) {
      _entry.remove();
      _entry = null;
    }
    _editingController.dispose();
    super.dispose();
  }
}
