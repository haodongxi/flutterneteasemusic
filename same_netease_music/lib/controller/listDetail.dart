import 'dart:convert';
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:cached_network_image/cached_network_image.dart';
import '../model/PlayListDetailInfo.dart';
import 'package:dio/dio.dart';
import 'play.dart';

class ListDetailPage extends StatefulWidget {
  Map arguments;

  ListDetailPage(this.arguments);

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return ListDetailState();
  }
}

class ListDetailState extends State<ListDetailPage> {
  ScrollController _scrollController;
  double opacity = 0.0;
  PlayListDetailInfo _listInfo;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(() {
      if (_scrollController.offset.toInt() >= 300) {
        setState(() {
          opacity = 1.0;
        });
      } else if (_scrollController.offset.toInt() > 0) {
        setState(() {
          opacity = _scrollController.offset.toInt() / 300;
        });
      } else {
        setState(() {
          opacity = 0;
        });
      }
    });
    int id = widget.arguments['id'];
    bool isSinger = widget.arguments['singer'] == true ? true : false;
    if (isSinger == true) {
      //兼容歌手歌曲详情
      _getSingerListDetailFromNet(id);
    } else {
      _getListDetailFromNet(id);
    }
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      body: Container(
        color: Colors.white,
        width: MediaQueryData.fromWindow(window).size.width,
        height: MediaQueryData.fromWindow(window).size.height,
        child: Stack(
          children: <Widget>[
            Container(
              color: Colors.white,
              width: MediaQueryData.fromWindow(window).size.width,
              height: MediaQueryData.fromWindow(window).size.height,
              child: CustomScrollView(
                controller: _scrollController,
//                physics: ScrollPhysics(),
                slivers: <Widget>[
                  SliverToBoxAdapter(
                    child: Container(
                      width: MediaQueryData.fromWindow(window).size.width,
                      height: 300,
//                      color: Colors.yellow,
                      child: Stack(
                        children: <Widget>[
                          RepaintBoundary(
                            child: _listInfo != null
                                ? CachedNetworkImage(
                                    imageUrl: _listInfo != null
                                        ? _listInfo.coverImgUrl
                                        : "",
                                    width: MediaQueryData.fromWindow(window)
                                        .size
                                        .width,
                                    height: 300,
                                    fit: BoxFit.cover,
                                  )
                                : Container(),
                          ),
                          Positioned(
                            bottom: 0,
                            left: 0,
                            width: MediaQueryData.fromWindow(window).size.width,
                            height: 70,
                            child: Container(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Container(
                                    padding: EdgeInsets.only(left: 20),
                                    child: Text(
                                      _listInfo != null ? _listInfo.name : "",
                                      maxLines: 1,
                                      style: TextStyle(
                                          fontSize: 18, color: Colors.white),
                                    ),
                                  ),
                                  _listInfo == null ||
                                          _listInfo.playCount == null
                                      ? Container()
                                      : Container(
                                          padding: EdgeInsets.only(left: 20),
                                          child: Row(
                                            children: <Widget>[
                                              Container(
                                                width: 26,
                                                height: 26,
                                                child: IconButton(
                                                  icon: Icon(
                                                    Icons.volume_up,
                                                    size: 12,
                                                    color: Colors.white,
                                                  ),
                                                  onPressed: null,
                                                ),
                                              ),
                                              Text(
                                                ((_listInfo != null
                                                                ? _listInfo
                                                                    .playCount
                                                                : 0) ~/
                                                            10000)
                                                        .toString() +
                                                    '万',
                                                maxLines: 1,
                                                style: TextStyle(
                                                    fontSize: 12,
                                                    color: Colors.white),
                                              )
                                            ],
                                          ),
                                        )
                                ],
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Container(
                      width: MediaQueryData.fromWindow(window).size.width,
                      height: 40,
                      color: Colors.white,
                      child: _listInfo == null
                          ? Container()
                          : Row(
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                                Container(
                                  margin: EdgeInsets.only(left: 10),
                                  child: IconButton(
                                      icon: Icon(
                                        Icons.play_circle_filled,
                                        size: 30,
                                      ),
                                      onPressed: null),
                                ),
                                Container(
                                    margin: EdgeInsets.only(left: 10),
                                    width: 200,
                                    child: Text(
                                      '播放全部' + '共${_listInfo.trackCount}首',
                                      maxLines: 1,
                                      style: TextStyle(fontSize: 16),
                                    ))
                              ],
                            ),
                    ),
                  ),
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (BuildContext context, int index) {
                        return Container(
                          height: 70,
//                          color: Colors.green,
                          child: GestureDetector(
                            onTap: () {
                              Navigator.pushNamed(context, "/play",
                                  arguments: {'song': _listInfo.tracks[index]});
                            },
                            child: Container(
                              padding: EdgeInsets.only(left: 20),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: <Widget>[
                                  Text(
                                    '${index + 1}',
                                    style: TextStyle(
                                        fontSize: 18, color: Colors.black),
                                  ),
                                  Container(
                                    width: 250,
                                    padding: EdgeInsets.only(
                                      left: 20,
                                    ),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: <Widget>[
                                        Text(
                                          '${_listInfo.tracks[index].name}',
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                              fontSize: 18,
                                              color: Colors.black),
                                        ),
                                        Text(
                                          '${_listInfo.tracks[index].artNames}',
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                              fontSize: 14, color: Colors.grey),
                                        ),
                                      ],
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                      childCount: _listInfo != null ? _listInfo.trackCount : 0,
                    ),
                  )
                ],
              ),
            ),
            Positioned(
                left: 0,
                top: 0,
                height: MediaQueryData.fromWindow(window).padding.top + 44,
                width: MediaQueryData.fromWindow(window).size.width,
                child: Opacity(
                  opacity: opacity,
                  child: Container(
                    height: MediaQueryData.fromWindow(window).padding.top + 44,
                    width: double.infinity,
                    color: Colors.red,
                    child: Center(
                        child: Container(
                      margin: EdgeInsets.only(
                        top: MediaQueryData.fromWindow(window).padding.top,
                      ),
                      width: 200,
                      child: Text(
                        _listInfo != null ? _listInfo.name : "",
                        maxLines: 1,
                        textAlign: TextAlign.left,
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.white,
                        ),
                      ),
                    )),
                  ),
                )),
            Positioned(
              left: 10,
              top: MediaQueryData.fromWindow(window).padding.top,
              width: 25,
              height: 25,
              child: IconButton(
                  icon: Icon(
                    Icons.arrow_back_ios,
                    color: Colors.blueGrey,
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                  }),
            )
          ],
        ),
      ),
    );
  }

  _getListDetailFromNet(int id) async {
    Response response;
    Dio dio = Dio();
    response = await dio.get("http://120.79.162.149:3000/playlist/detail",
        queryParameters: {'id': id});
    var jsonStr = response.data;
    if (jsonStr['code'] == 200) {
      Map results = jsonStr['result'];
      setState(() {
        _listInfo = PlayListDetailInfo.fromJson(results);
      });
    }
  }

  _getSingerListDetailFromNet(int id) async {
    Response response;
    Dio dio = Dio();
    response = await dio
        .get("http://120.79.162.149:3000/artists", queryParameters: {'id': id});
    var jsonStr = response.data;
    if (jsonStr['code'] == 200) {
      //兼容歌手歌曲详情
      Map results = jsonStr['artist'];
      results['hotSongs'] = jsonStr['hotSongs'];
      setState(() {
        _listInfo = PlayListDetailInfo.fromJson(results);
      });
    }
  }
}
