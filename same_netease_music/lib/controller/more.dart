import 'package:flutter/material.dart';
import 'dart:ui';
import "../model/SongInfo.dart";
import '../Tool/DBTool.dart';
import 'dart:convert' as convert;

class MorePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return MorePageState();
  }
}

class MorePageState extends State<MorePage> {
  List<Tab> _tabList;
  TabController _tabC;
  List<SongInfo> _currentPlayList = List();
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _tabList = <Tab>[
      Tab(
        text: "最近播放",
      ),
      Tab(
        text: "我的收藏",
      ),
    ];
    _tabC = TabController(length: 2, vsync: ScrollableState());

    _getCurrentPlayList();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      body: Container(
          width: double.infinity,
          height: double.infinity,
          color: Colors.white,
          alignment: Alignment.topLeft,
          child: Column(
            children: <Widget>[
              Container(
                width: double.infinity,
                height: MediaQueryData.fromWindow(window).padding.top + 50,
                color: Colors.red,
                child: Stack(
                  children: <Widget>[
                    Container(
                      margin: EdgeInsets.only(
                          top: MediaQueryData.fromWindow(window).padding.top),
                      width: MediaQueryData.fromWindow(window).size.width,
                      height: 44,
                      alignment: Alignment.center,
                      child: Container(
                        width: 250,
                        height: 44,
                        child: TabBar(
                          tabs: _tabList,
                          indicatorSize: TabBarIndicatorSize.tab,
                          indicatorColor: Colors.white,
                          controller: _tabC,
                        ),
                      ),
                    ),
                    Positioned(
                      top: MediaQueryData.fromWindow(window).padding.top,
                      left: 0,
                      child: IconButton(
                          icon: Icon(Icons.arrow_back_ios),
                          iconSize: 24,
                          padding: EdgeInsets.only(bottom: 10),
                          color: Colors.white,
                          onPressed: () {
                            Navigator.of(context).pop();
                          }),
                    )
                  ],
                ),
              ),
              Expanded(
                  child: TabBarView(
                controller: _tabC,
                children: <Widget>[
                  Container(
                    child: Column(
                      children: <Widget>[
                        Container(
                          height: 44,
                          width: double.infinity,
                          child: Row(
                            children: <Widget>[
                              IconButton(
                                  icon: Icon(
                                    Icons.play_circle_filled,
                                    color: Colors.grey,
                                  ),
                                  onPressed: null),
                              Text(
                                "播放全部",
                                style: TextStyle(fontSize: 15),
                              ),
                              Text(
                                "(共${_currentPlayList.length}首)",
                                style:
                                    TextStyle(fontSize: 13, color: Colors.grey),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          height: 0.2,
                          width: double.infinity,
                          child: Container(
                            color: Colors.grey,
                          ),
                        ),
                        Expanded(
                          child: Container(
                            alignment: Alignment.topLeft,
                            child: ListView.builder(
                                padding: EdgeInsets.only(top: 0),
                                itemCount: _currentPlayList.length,
                                itemBuilder: (BuildContext context, int index) {
                                  return GestureDetector(
                                    onTap: () {
                                      Navigator.of(context).pushNamed('/play',
                                          arguments: {
                                            "song": _currentPlayList[index]
                                          });
                                    },
                                    child: Container(
                                      width: MediaQueryData.fromWindow(window)
                                          .size
                                          .width,
                                      height: 60,
                                      decoration: BoxDecoration(
                                          border: Border(
                                              bottom: BorderSide(
                                                  width: 0.2,
                                                  color: Colors.grey))),
                                      child: Row(
                                        children: <Widget>[
                                          Container(
                                            width: 20,
                                            margin: EdgeInsets.only(left: 20),
                                            child: Text('${index + 1}'),
                                          ),
                                          Container(
                                            height: 60,
                                            width: MediaQueryData.fromWindow(
                                                        window)
                                                    .size
                                                    .width -
                                                100,
                                            margin: EdgeInsets.only(left: 10),
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: <Widget>[
                                                Container(
                                                  margin:
                                                      EdgeInsets.only(top: 7),
                                                  height: 25,
                                                  child: Text(
                                                    _currentPlayList[index]
                                                        .name,
                                                    style: TextStyle(
                                                      fontSize: 16,
                                                    ),
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                ),
                                                Container(
                                                  height: 25,
                                                  child: Text(
                                                    _currentPlayList[index]
                                                        .artNames,
                                                    style: TextStyle(
                                                        fontSize: 13,
                                                        color: Colors.grey),
                                                  ),
                                                )
                                              ],
                                            ),
                                          )
                                        ],
                                      ),
                                    ),
                                  );
                                }),
                          ),
                        )
                      ],
                    ),
                  ),
                  Container()
                ],
              ))
            ],
          )),
    );
  }

  _getCurrentPlayList() {
    DBTool dbTool = DBTool();
    dbTool.OpenPlayListDB().then((database) {
      if (database != null) {
        dbTool.getAllPlayList().then((value) {
          if (value != null) {
            _currentPlayList.clear();
            List tempList = value;
            for (Map tempInfo in tempList) {
              String jsonStr = tempInfo['Info'];
              var tempJson = convert.jsonDecode(jsonStr);
              SongInfo songInfo =
                  (tempJson is Map) ? SongInfo.fromJson(tempJson) : null;
              if (songInfo != null) {
                _currentPlayList.add(songInfo);
              }
            }
            setState(() {});
          }
        });
      }
    });
  }
}
