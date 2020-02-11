import 'dart:convert';
import 'dart:math';

import 'AblumInfo.dart';
import 'ArtistInfo.dart';
import 'dart:convert' as convert;

class SongInfo {
  String name;
  int id;
  int copyrightId;
  List<ArtistInfo> arts;
  AlbumInfo ablumInfo;
  get artNames {
    String names = "";
    for (ArtistInfo info in arts) {
      if (info == arts[0]) {
        names = names + info.name;
      } else {
        names = names + "/" + info.name;
      }
    }
    return names;
  }

  SongInfo();
  factory SongInfo.fromJson(Map dict) {
    SongInfo info = SongInfo();
    info.name = dict['name'];
    info.id = dict['id'];
    info.copyrightId = dict['copyrightId'];
    if (dict['artists'] != null && (dict['artists'] is List)) {
      info.arts = List();
      for (Map artDict in dict['artists']) {
        ArtistInfo artInfo = ArtistInfo.fromJson(artDict);
        info.arts.add(artInfo);
      }
    }

    if (dict['album'] != null && (dict['album'] is Map)) {
      info.ablumInfo = AlbumInfo.fromJson(dict['album']);
    } else if (dict['al'] != null && (dict['al'] is Map)) {
      info.ablumInfo = AlbumInfo.fromJson(dict['al']);
    }

    //兼容热歌榜单
    if (dict['ar'] != null && (dict['ar'] is List)) {
      info.arts = List();
      for (Map artDict in dict['ar']) {
        ArtistInfo artInfo = ArtistInfo.fromJson(artDict);
        info.arts.add(artInfo);
      }
    }

    return info;
  }

  String modelToJsonStr() {
    Map json = {'id': id, 'name': name};
    List artistList = List();
    for (ArtistInfo info in arts) {
      Map tempArtInfo = {
        "name": info.name,
        "picUrl": info.picUrl,
        "id": info.id
      };
      artistList.add(tempArtInfo);
    }
    json['artists'] = artistList;
    String doneJsonStr = convert.jsonEncode(json);
    print(doneJsonStr);
    return doneJsonStr;
  }
}
