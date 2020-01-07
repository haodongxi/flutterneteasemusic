import 'dart:math';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_seekbar/flutter_seekbar.dart'
    show ProgressValue, SectionTextModel, SeekBar;
import 'package:same_netease_music/model/SongInfo.dart';
import '../Tool/audioControl.dart';
import 'package:dio/dio.dart';
import '../model/PersonalizedInfo.dart';
import '../Tool/contextTool.dart';

class PlayPage extends StatefulWidget {
  Map arguments;

  PlayPage(arguments) {
    this.arguments = arguments;
  }

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return PlayState();
  }
}

class PlayState extends State<PlayPage> with TickerProviderStateMixin {
  String _rightTimeOfSing = "00:00:00";
  String _leftCurrentTimeOfSing = "00:00:00";
  double _numOfSing = 0.1;
  double _currentNumOfSing = 0;
  AudioPlayerState _playState = AudioPlayerState.STOPPED;
  String _playUrl;
  AnimationController controller;
  SongInfo _currentSongDetail;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    AudioControl.ShareValue()
        .audioPlayer
        .onDurationChanged
        .listen((Duration dutation) {
      print("1111" + dutation.toString());
      AudioControl.ShareValue().lastUrlCountTime = dutation;
      setState(() {
        _numOfSing = dutation.inSeconds
            .toDouble(); //(dutation.inHours*3600+dutation.inMinutes*60+dutation.inSeconds).toDouble();
        _rightTimeOfSing = AudioControl.ShareValue().toFormatString(dutation);
      });
    });

    AudioControl.ShareValue()
        .audioPlayer
        .onAudioPositionChanged
        .listen((Duration dutation) {
      setState(() {
        _currentNumOfSing = dutation.inSeconds
            .toDouble(); //(dutation.inHours*3600+dutation.inMinutes*60+dutation.inSeconds).toDouble();
        _leftCurrentTimeOfSing =
            AudioControl.ShareValue().toFormatString(dutation);
      });
    });

    AudioControl.ShareValue()
        .audioPlayer
        .onPlayerStateChanged
        .listen((AudioPlayerState state) {
      print("3333" + state.toString());
      setState(() {
        _playState = state;
      });
    });

    AudioControl.ShareValue().audioPlayer.onSeekComplete.listen((_) {
      print("4444");
    });

    _playState = AudioControl.ShareValue().audioPlayer.state;

    controller =
        AnimationController(duration: const Duration(seconds: 15), vsync: this);
    //动画开始、结束、向前移动或向后移动时会调用StatusListener
    controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        //动画从 controller.forward() 正向执行 结束时会回调此方法
        print("status is completed");
        //重置起点
        controller.reset();
        //开启
        controller.forward();
      } else if (status == AnimationStatus.dismissed) {
        //动画从 controller.reverse() 反向执行 结束时会回调此方法
        print("status is dismissed");
      } else if (status == AnimationStatus.forward) {
        print("status is forward");
        //执行 controller.forward() 会回调此状态
      } else if (status == AnimationStatus.reverse) {
        //执行 controller.reverse() 会回调此状态
        print("status is reverse");
      }
    });
    controller.forward();
    if (widget?.arguments['song']?.ablumInfo?.blurPicUrl == null) {
      _getSongDetailFromNet();
    }
    _getMp3FromNet();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      body: Container(
        color: Colors.white,
        width: MediaQueryData.fromWindow(window).size.width,
        height: MediaQueryData.fromWindow(window).size.height,
        child: Center(
          child: Stack(
            children: [
              CachedNetworkImage(
                imageUrl: widget.arguments['song'].ablumInfo.blurPicUrl == null
                    ? (_currentSongDetail?.ablumInfo?.blurPicUrl == null
                        ? ""
                        : _currentSongDetail.ablumInfo.blurPicUrl)
                    : widget.arguments['song'].ablumInfo.blurPicUrl,
                width: MediaQueryData.fromWindow(window).size.width,
                height: MediaQueryData.fromWindow(window).size.height,
                fit: BoxFit.cover,
                placeholder: (BuildContext context, String url) {
                  return Container(
                    color: Colors.black,
                  );
                },
              ),
              BackdropFilter(
                filter: new ImageFilter.blur(sigmaX: 3, sigmaY: 3),
                child: new Container(
                  color: Colors.black.withOpacity(0.7),
                  width: MediaQueryData.fromWindow(window).size.width,
                  height: MediaQueryData.fromWindow(window).size.height,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Container(
                        margin: EdgeInsets.only(
                            top: MediaQueryData.fromWindow(window).padding.top),
                        height: 70,
                        child: Stack(
                          children: <Widget>[
                            IconButton(
                                icon: Icon(Icons.arrow_back_ios),
                                color: Colors.white,
                                onPressed: () {
                                  Navigator.of(context).pop();
                                }),
                            Center(
                              child: Container(
                                margin: EdgeInsets.only(top: 10),
                                width: 150,
                                child: Column(
                                  children: <Widget>[
                                    Text(
                                      widget.arguments['song'].name,
                                      style: TextStyle(
                                          color: Colors.white, fontSize: 18),
                                      maxLines: 1,
                                    ),
                                    Text(
                                      widget.arguments['song'].artNames,
                                      style: TextStyle(
                                          color: Colors.white, fontSize: 16),
                                      maxLines: 1,
                                    )
                                  ],
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.only(bottom: 130),
                        height: 250,
                        width: 250,
                        child: Center(
                          child: RotationTransition(
                            turns: controller,
                            alignment: Alignment.center,
                            child: Container(
                              height: 230,
                              width: 230,
                              decoration: BoxDecoration(
                                color: Colors.black,
                                borderRadius:
                                    BorderRadius.all(Radius.circular(230 / 2)),
                                image: DecorationImage(
                                    image: NetworkImage(widget.arguments['song']
                                                .ablumInfo.blurPicUrl ==
                                            null
                                        ? (_currentSongDetail
                                                    ?.ablumInfo?.blurPicUrl ==
                                                null
                                            ? ""
                                            : _currentSongDetail
                                                .ablumInfo.blurPicUrl)
                                        : widget.arguments['song'].ablumInfo
                                            .blurPicUrl),
                                    fit: BoxFit.cover),
                              ),
                            ),
                          ),
                        ),
                        decoration: BoxDecoration(
                          color: Colors.grey,
                          borderRadius:
                              BorderRadius.all(Radius.circular(250 / 2)),
                        ),
                      ),
                      Container(
                        height: 150,
                        width: double.infinity,
                        child: Column(
                          children: <Widget>[
                            Container(
                              padding: EdgeInsets.only(left: 30, right: 30),
                              child: Row(
                                children: <Widget>[
                                  Container(
                                    height: 30,
                                    width: 60,
                                    child: Center(
                                        child: Text(
                                      _leftCurrentTimeOfSing,
                                      style: TextStyle(
                                          fontSize: 11, color: Colors.white),
                                      textAlign: TextAlign.right,
                                    )),
                                  ),
                                  Expanded(
                                    child: Container(
                                      height: 30,
                                      padding:
                                          EdgeInsets.only(left: 10, right: 10),
                                      child: SeekBar(
                                        progresseight: 5,
                                        min: 0,
                                        max: _numOfSing,
                                        value: _currentNumOfSing,
                                        backgroundColor: Colors.black,
                                        indicatorColor: Colors.white,
                                        onValueChanged: (ProgressValue value) {
//                                          print(_numOfSing);
//                                          print(value.value);
                                          double seekSecond =
                                              _numOfSing * value.progress;
                                          print(seekSecond);
                                          AudioControl.ShareValue()
                                              .audioPlayer
                                              .seek(Duration(
                                                  seconds: seekSecond.toInt()));
                                        },
                                      ),
                                    ),
                                  ),
                                  Container(
                                    height: 30,
                                    width: 60,
                                    child: Center(
                                        child: Text(
                                      _rightTimeOfSing,
                                      style: TextStyle(
                                          fontSize: 11, color: Colors.white),
                                      textAlign: TextAlign.left,
                                    )),
                                  ),
                                ],
                              ),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Container(
                                  width: 50,
                                  height: 50,
                                  margin: EdgeInsets.only(right: 20),
                                  child: IconButton(
                                      icon: Icon(
                                        Icons.skip_previous,
                                        size: 50,
                                        color: Colors.white,
                                      ),
                                      onPressed: () {
                                        print("previous");
                                      }),
                                ),
                                Container(
                                  width: 50,
                                  height: 50,
                                  child: IconButton(
                                      icon: Icon(
                                        _playState == AudioPlayerState.PLAYING
                                            ? Icons.pause_circle_filled
                                            : Icons.play_circle_outline,
                                        size: 50,
                                        color: Colors.white,
                                      ),
                                      onPressed: () {
                                        print("5555");
                                        if (_playUrl != null) {
                                          if (AudioControl.ShareValue()
                                                  .playUrl ==
                                              null) {
                                            AudioControl.ShareValue()
                                                .play(_playUrl);
                                          } else if (_playUrl !=
                                              AudioControl.ShareValue()
                                                  .playUrl) {
                                            AudioControl.ShareValue()
                                                .play(_playUrl);
                                          } else {
                                            if (_playState ==
                                                AudioPlayerState.PLAYING) {
                                              AudioControl.ShareValue().pause();
                                            } else if (_playState ==
                                                AudioPlayerState.PAUSED) {
                                              AudioControl.ShareValue()
                                                  .resume(_playUrl);
                                            } else {
                                              AudioControl.ShareValue()
                                                  .play(_playUrl);
                                            }
                                          }
                                        }
                                      }),
                                ),
                                Container(
                                  width: 50,
                                  height: 50,
                                  margin: EdgeInsets.only(left: 20),
                                  child: IconButton(
                                      icon: Icon(
                                        Icons.skip_next,
                                        size: 50,
                                        color: Colors.white,
                                      ),
                                      onPressed: () {
                                        print("next");
                                      }),
                                ),
                              ],
                            ),
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
    );
  }

  _getMp3FromNet() async {
    Response response;
    Dio dio = Dio();
    response = await dio.get("http://120.79.162.149:3000/music/url",
        queryParameters: {"id": widget.arguments['song'].id});
    var jsonStr = response.data;
    List<PersonalizedInfo> list = List();
    if (jsonStr['code'] == 200) {
      List results = jsonStr['data'];
      if (results.length > 0) {
        _playUrl = results[0]['url'];
        if (AudioControl.ShareValue().playUrl == null ||
            AudioControl.ShareValue().playUrl != _playUrl) {
          AudioControl.ShareValue().play(_playUrl);
        } else {
          Duration duration = AudioControl.ShareValue().lastUrlCountTime;
          if (duration != null) {
            setState(() {
              _numOfSing = duration.inSeconds.toDouble();
              _rightTimeOfSing =
                  AudioControl.ShareValue().toFormatString(duration);
            });
          }
        }
        print('7777....$_playUrl');
      }
    }
  }

  _getSongDetailFromNet() async {
    Response response;
    Dio dio = Dio();
    response = await dio.get("http://120.79.162.149:3000/song/detail",
        queryParameters: {"ids": widget.arguments['song'].id});
    var jsonStr = response.data;
    List<PersonalizedInfo> list = List();
    if (jsonStr['code'] == 200) {
      List results = jsonStr['songs'];
      if (results.length > 0) {
        Map songInfoDict = results[0];
        _currentSongDetail = SongInfo.fromJson(songInfoDict);
        setState(() {});
      }
    }
  }

  @override
  void dispose() {
    controller.dispose();
    // TODO: implement dispose
    super.dispose();
  }
}
