import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:just_audio/just_audio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:rxdart/rxdart.dart';

import 'data/data.dart';
import 'main.dart';

enum Loop { all, one, off }

class PlayerNotifier extends ChangeNotifier {
  String? song;
  AudioPlayer player = AudioPlayer();
  Dio downloader = Dio();
  double height = 0.0;
  double width = 0.0;

  get playLength => player.sequence?.length;

  get playerStateStream => player.playerStateStream;

  get speedStream => player.speedStream;

  double get speed => player.speed;

  List songNames = data.keys.toList();
  List songLists = data.values.toList();
  String songName = '';

  int percentage = 0;
  String folder = '${downloadDirectory.path}/music/';

  getSongs(int index) {
    if (list.isNotEmpty) {
      list.clear();
    }

    List fileList = [];
    var file = Directory(folder).listSync();
    for (var element in file) {
      fileList.add(element.path);
    }
    fileList.sort();
    print(fileList);
    for (var element in fileList) {
      list.add(
        AudioSource.uri(
          Uri.file(element),
        ),
      );
    }
    setAudioSource(list,index:index);
    play();
  }

  progress(downloaded, total) {
    double percentageCount = (downloaded / total) * 100;
    if (percentageCount < 100) {
      percentage = percentageCount.round();
      notifyListeners();
    } else {
      percentage = 0;
      notifyListeners();
    }
    notifyListeners();
  }

  download({required String url, required String name}) async {
    String fileName = '${folder + name}.mp3';
    try {
      await downloader.download(
        url,
        fileName,
        onReceiveProgress: progress,
        options: Options(
          followRedirects: false,
          receiveTimeout: 0,
        ),
      );
    } catch (e) {
      print(e.toString());
    }
  }

  String dataName1 = 'Mishary bn Rashid Alafasy';

  String get dataName2 => _dataName;

  String _dataName = '';

  playFirst(String name) {
    _dataName = name;
    player.setAudioSource(AudioSource.file('$folder$name'));
    play();
    notifyListeners();
  }

  get setsSpeed => player.setSpeed;

  Duration defaultDuration = const Duration(seconds: 2);


  Stream<PositionData> get positionDataStream {
    return Rx.combineLatest3<Duration, Duration, Duration?, PositionData>(
        player.positionStream,
        player.bufferedPositionStream,
        player.durationStream,
        (position, bufferedPosition, duration) => PositionData(
            position, bufferedPosition, duration ?? Duration.zero));
  }

  int get currentIndex => player.currentIndex ?? 1;

  Stream get currentIndexStream => player.currentIndexStream;

  List<AudioSource> list = [];

  setAudioSource(List<AudioSource> children,{int? index}) async {
    try {
      final playlist = ConcatenatingAudioSource(
        children: children,
      );
      await player.setAudioSource(playlist,
          initialIndex: index, initialPosition: Duration.zero);
      player.setLoopMode(LoopMode.all);
    } catch (e) {
      print(e.toString());
    }
  }

  seekAudio(durationToSeek) async {
    if (durationToSeek is double) {
      await player.seek(Duration(milliseconds: durationToSeek.toInt()));
      play();
    } else if (durationToSeek is Duration) {
      await player.seek(durationToSeek);
      play();
    }
  }

  Future<void> play() async {
    await player.play();
  }

  Future<void> pause() async {
    await player.pause();
  }

  Future<void> skipToNext() async {
    await player.seekToNext();
  }

  Future<void> skipToPrevious() async {
    await player.seekToPrevious();
  }

  Future<void> seek(Duration position) async {
    player.seek(position);
  }

  stop() async {
    await player.stop();
  }

  initSize({size}) {
    height = size.height;
    width = size.width;
  }

  changeLoop() async {
    if (loop == Loop.all) {
      loop = Loop.one;
      notifyListeners();
      await player.setLoopMode(LoopMode.one);
    } else if (loop == Loop.one) {
      loop = Loop.off;
      notifyListeners();
      await player.setLoopMode(LoopMode.off);
    } else if (loop == Loop.off) {
      loop = Loop.all;
      notifyListeners();
      await player.setLoopMode(LoopMode.all);
    }
    // print(loop);
  }

  Loop loop = Loop.all;
}

class PositionData {
  final Duration position;
  final Duration bufferedPosition;
  final Duration duration;

  PositionData(this.position, this.bufferedPosition, this.duration);
}
