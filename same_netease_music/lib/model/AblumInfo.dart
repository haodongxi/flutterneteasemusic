class AlbumInfo {
  String name;
  int id;
  int picId;
  String blurPicUrl;
  AlbumInfo();
  factory AlbumInfo.fromJson(Map dict) {
    AlbumInfo info = AlbumInfo();
    info.name = dict['name'];
    info.id = dict['id'];
    info.picId = dict['picId'];
    info.blurPicUrl = dict['blurPicUrl'];
    if (info.blurPicUrl == null) {
      //兼容歌手
      info.blurPicUrl = dict['picUrl'];
    }
    return info;
  }
}
