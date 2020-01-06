class SearchHotInfo {
  String first;
  int second;
  int iconType;

  SearchHotInfo();
  factory SearchHotInfo.fromJson(Map dict) {
    SearchHotInfo info = SearchHotInfo();
    if (dict['first'] != null) {
      info.first = dict['first'];
    }
    if (dict['second'] != null) {
      info.second = dict['second'];
    }
    if (dict['iconType'] != null) {
      info.iconType = dict['iconType'];
    }
    return info;
  }
}
