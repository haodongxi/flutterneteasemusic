import 'package:audioplayers/audioplayers.dart';
class AudioControl {
  static AudioControl _value = AudioControl._();
  AudioControl._();
  factory AudioControl.ShareValue(){
    return _value;
  }


  int microsecondsPerMillisecond = 1000;
  int millisecondsPerSecond = 1000;
  int secondsPerMinute = 60;
  int minutesPerHour = 60;
  int hoursPerDay = 24;
  String playUrl;
  AudioPlayer audioPlayer = AudioPlayer();
  play(url,{isLocal = false,isAsset=false}) async {
    playUrl = url;

    int result = await audioPlayer.play(url,isLocal: isLocal);
    if (result == 1) {
      // success
    }
  }
  pause() async {
    int result = await audioPlayer.pause();
    if (result == 1) {
      // success
    }
  }
  stop() async {
    int result = await audioPlayer.stop();
    if (result == 1) {
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
      // success
    }
  }

  String toFormatString(Duration duration) {
    String twoDigits(int n) {
      if (n >= 10) return "$n";
      return "0$n";
    }

    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(minutesPerHour));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(secondsPerMinute));
    return "${duration.inHours}:$twoDigitMinutes:$twoDigitSeconds";
  }

}
