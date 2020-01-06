import 'package:flutter/foundation.dart';
import 'SongInfo.dart';

class PersonalizedInfo {
  int id;
  String name;
  String copywriter;
  String picUrl;
  num playCount;
  SongInfo song;

  factory PersonalizedInfo.fromJson(Map dict) {
    PersonalizedInfo info = PersonalizedInfo._();
    info.id = dict['id'];
    info.name = dict['name'];
    info.copywriter = dict['copywriter'];
    info.picUrl = dict['picUrl'];
    if (dict['playCount'] != null) {
      info.playCount = num.parse(dict['playCount'].toString());
    }
    if (dict['song'] != null) {
      info.song = SongInfo.fromJson(dict['song']);
    }
    return info;
  }

  PersonalizedInfo._();
}
