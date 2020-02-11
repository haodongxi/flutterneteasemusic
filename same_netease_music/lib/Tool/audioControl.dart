import 'package:audioplayers/audioplayers.dart';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:same_netease_music/controller/play.dart';
import 'contextTool.dart';
import '../model/SongInfo.dart';

class AudioControl {
  static AudioControl _value = AudioControl._();
  AudioControl._();
  factory AudioControl.ShareValue() {
    return _value;
  }

  int microsecondsPerMillisecond = 1000;
  int millisecondsPerSecond = 1000;
  int secondsPerMinute = 60;
  int minutesPerHour = 60;
  int hoursPerDay = 24;
  String playUrl;
  int songId;
  Duration lastUrlCountTime;
  SongInfo currentSongInfo;

  AudioPlayer audioPlayer = AudioPlayer()
    ..onPlayerStateChanged.listen((AudioPlayerState state) {});
  OverlayEntry _entry = null;

  play(url, id, {isLocal = false, isAsset = false}) async {
    playUrl = url;
    songId = id;
    int result = await audioPlayer.play(url, isLocal: isLocal);
    if (result == 1) {
      audioPlayer.onPlayerStateChanged.listen((AudioPlayerState state) {
        if (_entry != null) {
          displayPlayStateToolWidget();
        }
      });
      // success
    }
  }

  pause() async {
    int result = await audioPlayer.pause();
    if (result == 1) {
//      _setPlayStateToolWidget();
      // success
    }
  }

  stop() async {
    int result = await audioPlayer.stop();
    if (result == 1) {
//      _setPlayStateToolWidget();
      // success
    }
  }

  seekTime(milliseconds) async {
    int result = await audioPlayer.seek(Duration(microseconds: milliseconds));
    if (result == 1) {
      // success
    }
  }

  resume(url) async {
    int result = await audioPlayer.resume();
    if (result == 1) {
//      _setPlayStateToolWidget();
      // success
    }
  }

  String toFormatString(Duration duration) {
    String twoDigits(int n) {
      if (n >= 10) return "$n";
      return "0$n";
    }

    String twoDigitMinutes =
        twoDigits(duration.inMinutes.remainder(minutesPerHour));
    String twoDigitSeconds =
        twoDigits(duration.inSeconds.remainder(secondsPerMinute));
    return "${duration.inHours}:$twoDigitMinutes:$twoDigitSeconds";
  }

  removePlayingTool() {
    if (_entry != null) {
      _entry.remove();
    }
    _entry = null;
  }

  displayPlayStateToolWidget() {
    removePlayingTool();
    AudioPlayerState state = audioPlayer.state;
    //创建OverlayEntry
    _entry = OverlayEntry(builder: (BuildContext context) {
      return Positioned(
          bottom: 0,
          left: 0,
          child: GestureDetector(
            onTap: () {
              Navigator.of(context)
                  .pushNamed('/play', arguments: {"song": currentSongInfo});
            },
            child: Container(
                width: MediaQueryData.fromWindow(window).size.width,
                height: MediaQueryData.fromWindow(window).padding.bottom > 0
                    ? 90
                    : 60,
                color: Colors.white,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Container(
                      margin: EdgeInsets.only(left: 20),
                      child: CircleAvatar(
                        backgroundColor: Colors.black,
                        radius: 25,
                        backgroundImage: NetworkImage(
                            currentSongInfo?.ablumInfo?.blurPicUrl == null
                                ? ""
                                : currentSongInfo.ablumInfo.blurPicUrl),
                      ),
                    ),
                    Container(
                        margin: EdgeInsets.only(left: 20),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Container(
                                width: 150,
                                child: Text(
                                  currentSongInfo == null
                                      ? ""
                                      : currentSongInfo.name,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    decoration: TextDecoration.none,
                                    fontWeight: FontWeight.normal,
                                    fontSize: 16,
                                  ),
                                )),
                            Container(
                                width: 150,
                                child: Text(
                                  currentSongInfo == null
                                      ? ""
                                      : currentSongInfo.artNames,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    decoration: TextDecoration.none,
                                    fontWeight: FontWeight.normal,
                                    fontSize: 14,
                                  ),
                                )),
                          ],
                        )),
                    Expanded(
                      child: Container(
                        alignment: Alignment.topRight,
                        child: Container(
                            margin: EdgeInsets.only(right: 20, top: 5),
                            height: 50,
                            width: 50,
                            child: GestureDetector(
                              onTap: () {
                                if (state == AudioPlayerState.PLAYING) {
                                  audioPlayer.pause().then((value) {
                                    if (value == 1) {
//                                      displayPlayStateToolWidget();
                                    }
                                  });
                                } else {
                                  if (state == AudioPlayerState.COMPLETED) {
                                    audioPlayer.play(playUrl).then((value) {
                                      if (value == 1) {
//                                        displayPlayStateToolWidget();
                                      }
                                    });
                                  } else {
                                    audioPlayer.resume().then((value) {
                                      if (value == 1) {
//                                        displayPlayStateToolWidget();
                                      }
                                    });
                                  }
                                }
                              },
                              child: Icon(
                                state == AudioPlayerState.PLAYING
                                    ? Icons.pause_circle_filled
                                    : Icons.play_circle_outline,
                                size: 40,
                              ),
                            )),
                      ),
                    )
                  ],
                )),
          ));
    });
//往Overlay中插入插入OverlayEntry
    Overlay.of(ContextTool.shareValue().context).insert(_entry);
  }
}
