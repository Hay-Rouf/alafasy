import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:provider/provider.dart';

import '../notifier.dart';

enum DownloadState {
  download,
  downloading,
  deleted,
  downloaded,
}

class DownloadButton extends StatefulWidget {
  const DownloadButton(
      {Key? key,
        required this.name, required this.notifier, required this.url})
      : super(key: key);
  final PlayerNotifier notifier;
  final String name;
  final String url;

  @override
  State<DownloadButton> createState() => _DownloadButtonState();
}

class _DownloadButtonState extends State<DownloadButton> {
  bool tapped = false;
  DownloadState downloading = DownloadState.download;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        tapped
            ? Builder(builder: (context) {
          return widget.notifier.percentage > 0
              ? CircularPercentIndicator(
            radius: 20,
            progressColor:Colors.black,
            percent: widget.notifier.percentage / 100,
            center: Text('${widget.notifier.percentage}%'),
          )
              : const Icon(Icons.done);
        })
            : Container(),
        Builder(builder: (context) {
          var path = '${Provider.of<PlayerNotifier>(context,listen: false).folder}${widget.name}.mp3';
          var check = FileSystemEntity.typeSync(path);
          var notFound = FileSystemEntityType.notFound;
          if (check == notFound) {
            if (downloading == DownloadState.download) {
              return IconButton(
                icon: const Icon(Icons.download),
                onPressed: () {
                  setState(() {
                    tapped = !tapped;
                    downloading = DownloadState.downloading;
                  });
                  widget.notifier.download(
                    url: widget.url,
                    name: widget.name,
                  );
                },
              );
            }
          }
          return IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () {
                downloading = DownloadState.download;
                // widget.downloader
                //     .deleteFile(name: widget.name, qariName: widget.qari);
              });
        }),
      ],
    );
  }
}

class SeekBar extends StatelessWidget {
  const SeekBar({
    Key? key,
    required this.notifier,
  }) : super(key: key);
  final PlayerNotifier notifier;

  @override
  Widget build(BuildContext context) {
    double sliderValue = 0.0;
    return StreamBuilder<PositionData>(
        stream: notifier.positionDataStream,
        builder: (context, snapshot) {
          final positionData = snapshot.data;
          Duration duration = positionData?.duration ?? notifier.defaultDuration;
          Duration position = positionData?.position ?? Duration.zero;
          sliderValue = min(position.inMilliseconds.toDouble(),
              duration.inMilliseconds.toDouble());

          return Column(
            children: [
              Slider(
                min: 0.0,
                max: duration.inMilliseconds.toDouble(),
                value: sliderValue,
                onChanged: (value) {
                  notifier.seekAudio(Duration(milliseconds: value.round()));
                },
              ),
              Padding(
                padding: const EdgeInsets.only(left: 25.0, right: 25),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        formatTime(
                            position < duration ? position : Duration.zero),
                        // style:
                        //     TextStyle(color: AppColor.kSwatchColor.shade200),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        formatTime(duration),
                        textAlign: TextAlign.end,
                        // style:
                        //     TextStyle(color: AppColor.kSwatchColor.shade200),
                      ),
                    ),
                  ],
                ),
              )
            ],
          );
        });
  }
}


class PlayerTools extends StatelessWidget {
  const PlayerTools({Key? key, required this.notifier}) : super(key: key);
  final PlayerNotifier notifier;

  @override
  Widget build(BuildContext context) {
    double size = MediaQuery.of(context).size.width * 0.05;
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                onPressed: notifier.changeLoop,
                icon: repeatButton(notifier.loop),
              ),
              IconButton(
                  onPressed: notifier.skipToPrevious,
                  icon: Icon(Icons.skip_previous,
                    size: size,
                  )),
              StreamBuilder<PlayerState>(
                stream: notifier.playerStateStream,
                builder: (context, snapshot) {
                  final playerState = snapshot.data;
                  final processingState = playerState?.processingState;
                  final playing = playerState?.playing;
                  if (processingState == ProcessingState.loading ||
                      processingState == ProcessingState.buffering) {
                    return Container(
                      //padding: EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const CircularProgressIndicator(
                          color: Colors.black,
                        ));
                  } else if (playing == false) {
                    return InkWell(
                      onTap: notifier.play,
                      child: Container(
                        //width: _width * 0.24,
                        //height: _width * 0.24,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          border: Border.all(
                            width: 3,
                            color: Colors.black,
                          ),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Icon(
                          Icons.play_arrow,
                          size: MediaQuery.of(context).size.width * 0.05,
                        ),
                      ),
                    );
                  } else if (processingState == ProcessingState.completed) {
                    return InkWell(
                      onTap: () => notifier.seekAudio(Duration.zero),
                      child: Container(
                        //width: _width * 0.24,
                        //height: _width * 0.24,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          border: Border.all(
                            width: 3,
                            color: Colors.black,
                          ),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Icon(
                          Icons.play_arrow,
                          size: MediaQuery.of(context).size.width * 0.05,
                        ),
                      ),
                    );
                  } else {
                    return InkWell(
                      onTap: notifier.pause,
                      child: Container(
                        //  width: _width * 0.24,
                        //  height: _width * 0.24,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            width: 3,
                            color: Colors.black,
                          ),
                        ),
                        child: Icon(
                          Icons.pause,
                          size: MediaQuery.of(context).size.width * 0.058,
                        ),
                      ),
                    );
                  }
                },
              ),
              IconButton(
                onPressed: notifier.skipToNext,
                icon: Icon(
                  Icons.skip_next,
                  size: MediaQuery.of(context).size.width * 0.05,
                ),
              ),
              StreamBuilder<double>(
                stream: notifier.speedStream,
                builder: (context, snapshot) => IconButton(
                  icon: Icon(Icons.speed),
                  onPressed: () {
                    showSliderDialog(
                      context: context,
                      title: "Adjust speed",
                      // divisions: 10,
                      min: 0.5,
                      max: 1.5,
                      value: notifier.speed,
                      stream: notifier.speedStream,
                      onChanged: notifier.setsSpeed, divisions: 5,
                    );
                  },
                ),
              ),
            ],
          );
  }
}
void showSliderDialog({
  required BuildContext context,
  required String title,
  required int divisions,
  required double min,
  required double max,
  String valueSuffix = '',
  required double value,
  required Stream<double> stream,
  required ValueChanged<double> onChanged,
}) {
  showDialog<void>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(title, textAlign: TextAlign.center),
      content: StreamBuilder<double>(
        stream: stream,
        builder: (context, snapshot) => Container(
          height: 100.0,
          child: Column(
            children: [
              Text('${snapshot.data?.toStringAsFixed(1)}$valueSuffix',
                  style: TextStyle(
                      fontFamily: 'Fixed',
                      fontWeight: FontWeight.bold,
                      fontSize: 24.0)),
              Slider(
                divisions: divisions,
                min: min,
                max: max,
                value: snapshot.data ?? value,
                onChanged: onChanged,
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
Icon repeatButton(Loop loopChecker) {
  if (loopChecker == Loop.all) {
    return const Icon(Icons.repeat);
  } else if (loopChecker == Loop.one) {
    return const Icon(Icons.repeat_one);
  } else {
    return const Icon(Icons.reorder);
  }
}
String formatTime(Duration? duration) {
  String twoDigit(int n) => n.toString().padLeft(2, '0');
  if (duration !=  null){
    final hour = twoDigit(duration.inHours);
    final minutes = twoDigit(duration.inMinutes.remainder(60));
    final seconds = twoDigit(duration.inSeconds.remainder(60));

    return [
      if (duration.inHours > 0) hour,
      minutes,
      seconds,
    ].join(':');
  }
  else{
    return '';
  }
}