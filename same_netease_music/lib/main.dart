import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'controller/more.dart';
import 'controller/sort.dart';
import 'controller/hot.dart';
import 'Tool/contextTool.dart';
import 'controller/search.dart';
import 'package:dio/dio.dart';
import 'model/PersonalizedInfo.dart';

//import 'package:cached_network_image/cached_network_image.dart';
//import 'package:extended_image/extended_image.dart';
import 'controller/play.dart';
import 'controller/listDetail.dart';
import 'dart:io';
import 'package:flutter/services.dart';

void main() {
  runApp(MyApp());
  if (Platform.isAndroid) {
    // 以下两行 设置android状态栏为透明的沉浸。写在组件渲染之后，是为了在渲染后进行set赋值，覆盖状态栏，写在渲染之前MaterialApp组件会覆盖掉这个值。
    SystemUiOverlayStyle systemUiOverlayStyle =
        SystemUiOverlayStyle(statusBarColor: Colors.transparent);
    SystemChrome.setSystemUIOverlayStyle(systemUiOverlayStyle);
  }
}

Map<String, WidgetBuilder> routers = {
  '/play': (context, {arguments}) => PlayPage(arguments),
  '/more': (context, {arguments}) => MorePage(),
  '/search': (context, {arguments}) => SearchPage(),
  '/ListDetailPage': (context, {arguments}) => ListDetailPage(arguments),
};

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.red,
      ),
      // 处理Named页面跳转 传递参数
      onGenerateRoute: (RouteSettings settings) {
        // 统一处理
        final String name = settings.name;
        final Function pageContentBuilder = routers[name];
        if (pageContentBuilder != null) {
          final Route route = MaterialPageRoute(
            builder: (context) {
              //将RouteSettings中的arguments参数取出来，通过构造函数传入
              return pageContentBuilder(context, arguments: settings.arguments);
            },
            settings: settings,
          );
          return route;
        } else {
          return MaterialPageRoute(builder: null);
        }
      },
//      routes: {
//        '/more': (_) => MorePage(),
//        '/search': (_) => SearchPage(),
//        '/play':(_)=>PlayPage(),
//      },
      home: MyHomePage(title: '网易云音乐'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage>
    with AutomaticKeepAliveClientMixin {
  List<Tab> _tabList;
  TabController _tabC;

  List _banner = List();
  List<PersonalizedInfo> _recommandList = List();
  SwiperController _swiperController = SwiperController();
  List<PersonalizedInfo> _recommandSongList = List();

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    _tabC = TabController(length: 3, vsync: ScrollableState());
    _tabList = [
      Tab(
        text: "推荐",
      ),
      Tab(
        text: "排行",
      ),
      Tab(
        text: "歌手",
      )
    ];
    this._getBannerFromNet();
    this._getRecommandFromNet();
    this._getRecommandSongFromNet();
  }

//  @override
//  Future<void> initState() async {
//    // TODO: implement initState
//    super.initState();
//
//    _tabC = TabController(length: 3, vsync: ScrollableState());
//    _tabList = [
//      Tab(
//        text: "推荐",
//      ),
//      Tab(
//        text: "排行",
//      ),
//      Tab(
//        text: "歌手",
//      )
//    ];
//    this._getBannerFromNet();
//    this._getRecommandFromNet();
//    this._getRecommandSongFromNet();
//  }

  @override
  void dispose() {
    _tabC.dispose();
    _swiperController.dispose();
    // TODO: implement dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ContextTool.shareValue().context = context;
    return Scaffold(
      appBar: MyAppBar(
        child: Container(
          color: Colors.red,
          child: Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                width: MediaQueryData.fromWindow(window).size.width,
                height: 44,
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    IconButton(
                        icon: Icon(
                          Icons.format_list_bulleted,
                          color: Colors.white,
                          size: 24,
                        ),
                        onPressed: () {
                          Navigator.of(context).pushNamed('/more');
                        }),
                    Text(
                      "网易云音乐",
                      style: TextStyle(fontSize: 20, color: Colors.white),
                    ),
                    IconButton(
                        icon: Icon(
                          Icons.search,
                          color: Colors.white,
                          size: 24,
                        ),
                        onPressed: () {
                          Navigator.of(context).pushNamed('/search');
                        }),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
      body: Column(
        children: <Widget>[
          Container(
            height: 60,
            color: Colors.red,
            child: Container(
                margin: EdgeInsets.only(top: 20, bottom: 8),
                height: 44,
                width: MediaQuery.of(context).size.width,
                color: Colors.red,
                child: TabBar(
                  controller: _tabC,
                  tabs: _tabList,
                  indicatorSize: TabBarIndicatorSize.label,
                  indicatorColor: Colors.white,
                )),
          ),
          Expanded(
              child: TabBarView(controller: _tabC, children: <Widget>[
            Container(
                child: CustomScrollView(
              slivers: <Widget>[
                SliverToBoxAdapter(
                  child: Container(
                    alignment: Alignment(-1.0, -1.0),
                    child: Container(
                      width: MediaQueryData.fromWindow(window).size.width,
                      height: 145,
                      child: Swiper(
                        controller: _swiperController,
                        itemCount: _banner.length,
                        itemBuilder: (BuildContext context, int index) {
                          return Container(
                            child: Image.network(_banner[index]),
//                              child: CachedNetworkImage(
//                            imageUrl: _banner[index],
//                            placeholder: (context, str) {
//                              return Container(
//                                child: Center(
//                                  child: CircularProgressIndicator(),
//                                ),
//                              );
//                            },
//                          )
//                          child:ExtendedImage.network(_banner[index])
                          );
                        },
                        autoplay: false,
                        loop: false,
                        pagination: SwiperPagination(),
                      ),
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Container(
                      height: 50,
                      width: double.infinity,
                      child: Container(
                        margin: EdgeInsets.only(left: 10, top: 10),
                        child: Text(
                          '推荐歌单',
                          style: TextStyle(fontSize: 18),
                        ),
                      )),
                ),
                SliverPadding(
                  padding: EdgeInsets.all(10),
                  sliver: SliverGrid.count(
                    childAspectRatio: 7.5 / 10,
                    crossAxisCount: 3,
                    mainAxisSpacing: 20,
                    crossAxisSpacing: 20,
                    children: _recommandList.map((item) {
                      return GestureDetector(
                        onTap: () {
                          Navigator.pushNamed(context, "/ListDetailPage",
                              arguments: {'id': item.id});
//                          //创建OverlayEntry
//                          OverlayEntry entry =
//                              OverlayEntry(builder: (BuildContext context) {
//                            return Positioned(
//                                bottom: 0,
//                                left: 0,
//                                child: Container(
//                                    width: MediaQueryData.fromWindow(window)
//                                        .size
//                                        .width,
//                                    height: MediaQueryData.fromWindow(window)
//                                                .padding
//                                                .bottom >
//                                            0
//                                        ? 100
//                                        : 70,
//                                    color: Colors.white,
//                                    child: Row(
//                                      crossAxisAlignment: CrossAxisAlignment.center,
//                                      children: <Widget>[
//                                        Container(
//                                          margin:EdgeInsets.only(left: 20),
//                                          child: CircleAvatar(
//                                            backgroundColor: Colors.red,
//                                            radius: 30,
//                                          ),
//                                        )
//                                      ],
//                                    )));
//                          });
////往Overlay中插入插入OverlayEntry
//                          Overlay.of(ContextTool.shareValue().context)
//                              .insert(entry);
                        },
                        child: Container(
//                          color:Colors.red,
                            child: Column(
                          children: <Widget>[
                            Container(
                              height: (MediaQueryData.fromWindow(window)
                                          .size
                                          .width -
                                      20 -
                                      40) /
                                  3.0,
                              width: (MediaQueryData.fromWindow(window)
                                          .size
                                          .width -
                                      20 -
                                      40) /
                                  3.0,
                              child: Stack(
                                overflow: Overflow.clip,
                                children: <Widget>[
                                  Positioned(
                                    left: 0,
                                    top: 0,
//                                      child: Container(
//                                        color: Colors.blue,
//                                        width:
//                                            (MediaQueryData.fromWindow(window)
//                                                        .size
//                                                        .width -
//                                                    20 -
//                                                    40) /
//                                                3.0,
//                                        height:
//                                            (MediaQueryData.fromWindow(window)
//                                                        .size
//                                                        .width -
//                                                    20 -
//                                                    40) /
//                                                3.0,
////
//                                      ),
                                    child: Image.network(
                                      item.picUrl,
                                      cacheHeight:
                                          ((MediaQueryData.fromWindow(window)
                                                          .size
                                                          .width -
                                                      20 -
                                                      40) /
                                                  3.0)
                                              .toInt(),
                                      cacheWidth:
                                          ((MediaQueryData.fromWindow(window)
                                                          .size
                                                          .width -
                                                      20 -
                                                      40) /
                                                  3.0)
                                              .toInt(),
                                    ),
//                                    child: CachedNetworkImage(
//                                      imageUrl: item.picUrl,
//                                      width: (MediaQueryData.fromWindow(window).size.width-20-40)/3.0,
//                                      height: (MediaQueryData.fromWindow(window).size.width-20-40)/3.0,
//                                      fit: BoxFit.scaleDown,
//                                      placeholder: (context, str) {
//                                        return Container(
//                                          child: Center(
//                                            child: CircularProgressIndicator(),
//                                          ),
//                                        );
//                                      },
//                                    ),
//                                      child: ExtendedImage.network(
//                                        item.picUrl,
//                                        cache: true,
//                                        width:
//                                            (MediaQueryData.fromWindow(window)
//                                                        .size
//                                                        .width -
//                                                    20 -
//                                                    40) /
//                                                3.0,
//                                        height:
//                                            (MediaQueryData.fromWindow(window)
//                                                        .size
//                                                        .width -
//                                                    20 -
//                                                    40) /
//                                                3.0,
//                                        fit: BoxFit.scaleDown,
//                                      )
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                              child: Container(
                                child: Text(item.name,
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.grey,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis),
                              ),
                            )
                          ],
                        )),
                      );

//                      return Container(
//                        color: Colors.red,
//                      );
                    }).toList(),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Container(
                      height: 50,
                      width: double.infinity,
                      child: Container(
                        margin: EdgeInsets.only(left: 10, top: 10),
                        child: Text(
                          '推荐歌曲',
                          style: TextStyle(fontSize: 18),
                        ),
                      )),
                ),
                SliverPadding(
                  padding: EdgeInsets.all(10),
                  sliver: SliverGrid.count(
                    childAspectRatio: 7.5 / 10,
                    crossAxisCount: 3,
                    mainAxisSpacing: 30,
                    crossAxisSpacing: 20,
                    children: _recommandSongList.map((item) {
                      return GestureDetector(
                        onTap: () {
                          Navigator.of(context).pushNamed('/play',
                              arguments: {"song": item.song});
                        },
                        child: Container(
//                          color:Colors.red,
                            child: Column(
                          children: <Widget>[
                            Container(
                              height: (MediaQueryData.fromWindow(window)
                                          .size
                                          .width -
                                      20 -
                                      40) /
                                  3.0,
                              width: (MediaQueryData.fromWindow(window)
                                          .size
                                          .width -
                                      20 -
                                      40) /
                                  3.0,
                              child: Stack(
                                overflow: Overflow.clip,
                                children: <Widget>[
                                  Positioned(
                                    left: 0,
                                    top: 0,
                                    child: Image.network(
                                      item.song.ablumInfo.blurPicUrl,
                                      cacheHeight:
                                          ((MediaQueryData.fromWindow(window)
                                                          .size
                                                          .width -
                                                      20 -
                                                      40) /
                                                  3.0)
                                              .toInt(),
                                      cacheWidth:
                                          ((MediaQueryData.fromWindow(window)
                                                          .size
                                                          .width -
                                                      20 -
                                                      40) /
                                                  3.0)
                                              .toInt(),
                                    ),

//                                    child: CachedNetworkImage(
//                                      imageUrl: item.song.ablumInfo.blurPicUrl,
//                                      width: (MediaQueryData.fromWindow(window)
//                                                  .size
//                                                  .width -
//                                              20 -
//                                              40) /
//                                          3.0,
//                                      height: (MediaQueryData.fromWindow(window)
//                                                  .size
//                                                  .width -
//                                              20 -
//                                              40) /
//                                          3.0,
//                                      fit: BoxFit.scaleDown,
//                                      placeholder: (context, str) {
//                                        return Container(
//                                          child: Center(
//                                            child: CircularProgressIndicator(),
//                                          ),
//                                        );
//                                      },
//                                    ),
//                                  child: ExtendedImage.network(
//                                    item.song.ablumInfo.blurPicUrl,
//                                    cache: true,
//                                    width: (MediaQueryData
//                                        .fromWindow(window)
//                                        .size
//                                        .width -
//                                        20 -
//                                        40) /
//                                        3.0,
//                                    height: (MediaQueryData
//                                        .fromWindow(window)
//                                        .size
//                                        .width -
//                                        20 -
//                                        40) /
//                                        3.0,
//                                    fit: BoxFit.scaleDown,
//                                  ),
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                              child: Container(
                                child: Text(item.name,
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.grey,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis),
                              ),
                            )
                          ],
                        )),
                      );
                    }).toList(),
                  ),
                ),
              ],
            )),
            SortPage(),
            HotPage(),
          ])),
        ],
      ),
    );
  }

  _getBannerFromNet() async {
    Response response;
    Dio dio = Dio();
    response = await dio.get("http://120.79.162.149:3000/banner");
    var jsonStr = response.data;
    var imageList = List();
    if (jsonStr['code'] == 200) {
      List banners = jsonStr['banners'];
      for (Map dict in banners) {
        imageList.add(dict['picUrl']);
      }
      setState(() {
        _banner = imageList;
        _swiperController.autoplay = true;
      });
    }
  }

  _getRecommandFromNet() async {
    Response response;
    Dio dio = Dio();
    response = await dio.get("http://120.79.162.149:3000/personalized");
    var jsonStr = response.data;
    List<PersonalizedInfo> list = List();
    if (jsonStr['code'] == 200) {
      List results = jsonStr['result'];
      for (Map dict in results) {
        PersonalizedInfo info = PersonalizedInfo.fromJson(dict);
        if (info != null) {
          list.add(info);
        }
      }
      setState(() {
        _recommandList = list;
      });
    }
  }

  _getRecommandSongFromNet() async {
    Response response;
    Dio dio = Dio();
    response = await dio.get("http://120.79.162.149:3000/personalized/newsong");
    var jsonStr = response.data;
    List<PersonalizedInfo> list = List();
    if (jsonStr['code'] == 200) {
      List results = jsonStr['result'];
      for (Map dict in results) {
        PersonalizedInfo info = PersonalizedInfo.fromJson(dict);
        if (info != null) {
          list.add(info);
        }
      }

      int noNeedInfoCount = list.length % 3;
      if (list.length >= noNeedInfoCount) {
        for (int i = 0; i < noNeedInfoCount; i++) {
          list.removeLast();
        }
      }

      setState(() {
        _recommandSongList = list;
      });
    }
  }
}

class MyAppBar extends StatefulWidget implements PreferredSizeWidget {
  Widget child;

  MyAppBar({this.child}) : assert(child != null);

  @override
  // TODO: implement preferredSize
  Size get preferredSize =>
      Size.fromHeight(MediaQueryData.fromWindow(window).padding.bottom > 0
          ? kToolbarHeight + 20
          : kToolbarHeight);

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return AppbarState();
  }
}

class AppbarState extends State<MyAppBar> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Container(
      height: widget.preferredSize.height,
      child: widget.child,
    );
  }
}
