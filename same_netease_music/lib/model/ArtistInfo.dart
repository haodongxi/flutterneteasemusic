class ArtistInfo {
  String name;
  String picUrl;
  bool isTitle;
  int id;
  ArtistInfo();
  factory ArtistInfo.fromJson(Map dict) {
    ArtistInfo info = ArtistInfo();
    info.name = dict['name'];
    info.picUrl = dict['picUrl'];
    info.id = dict['id'];
    return info;
  }
}
