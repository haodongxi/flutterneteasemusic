import 'package:flutter/cupertino.dart';

import 'SongInfo.dart';

class PlayListDetailInfo {
  int id;
  String name;
  String coverImgUrl;
  List<SongInfo> tracks;
  int trackCount;
  num playCount;

  factory PlayListDetailInfo.fromJson(Map dict) {
    PlayListDetailInfo info = PlayListDetailInfo._();
    info.name = dict['name'];
    info.id = dict['id'];
    info.coverImgUrl = dict['coverImgUrl'];
    if (dict['playCount'] != null) {
      info.playCount = num.parse(dict['playCount'].toString());
    }
    if (dict['trackCount'] != null) {
      info.trackCount = dict['trackCount'];
    }
    if (dict['tracks'] != null) {
      info.tracks = List();
      for (Map songDict in dict['tracks']) {
        info.tracks.add(SongInfo.fromJson(songDict));
      }
    } else if (dict['hotSongs'] != null) {
      //兼容歌手歌曲详情
      info.tracks = List();
      for (Map songDict in dict['hotSongs']) {
        info.tracks.add(SongInfo.fromJson(songDict));
      }
    } else {
      info.tracks = List();
    }

    if (info.coverImgUrl == null && dict['picUrl'] != null) {
      //兼容歌手歌曲详情
      info.coverImgUrl = dict['picUrl'];
    }

    if (info.trackCount == null) {
      //兼容歌手歌曲详情
      info.trackCount = info.tracks.length;
    }

    return info;
  }

  PlayListDetailInfo._();
}
