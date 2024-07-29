
import 'dart:typed_data';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import '../bloc/audio_bloc.dart';
import '../model/transscript_model.dart';

class AudioPlayerWidget extends StatefulWidget {
  final Uint8List sound;
  final List<InterleavedPhrase>? interleavePhrases;
  final int pauseTime;

  AudioPlayerWidget({required this.sound,required this.interleavePhrases,required this.pauseTime});

  @override
  _AudioPlayerWidgetState createState() => _AudioPlayerWidgetState();
}

class _AudioPlayerWidgetState extends State<AudioPlayerWidget> {

  AudioPlayer audioPlayer = AudioPlayer();
  Duration pausePosition = Duration.zero;
  int activeIndex = -1;
  late int pauseDuration;
  bool isPlaying = false;
  late List<int> times;
  late List<String> phrases;
  late List<String> speakers;

  Duration currentPosition = Duration.zero;
  Duration totalDuration = Duration.zero;

  @override
  void initState() {
    super.initState();
    pauseDuration = widget.pauseTime;

    // Interleave phrases and speakers
    var interleavedPhrases = widget.interleavePhrases!;
    phrases = interleavedPhrases.map((e) => e.words).toList();
    times = interleavedPhrases.map((e) => e.time).toList();
    speakers = interleavedPhrases.map((e) => e.speakerName).toList();

    audioPlayer.onPlayerComplete.listen((event) {
      setState(() {
        isPlaying = false;
        pausePosition = Duration.zero;
        activeIndex = -1;
        currentPosition = Duration.zero;
      });
    });

    audioPlayer.onPositionChanged.listen((Duration currentPosition) {
      setState(() {
        this.currentPosition = currentPosition;
      });
      if (isPlaying) {
        _updateActiveIndex(currentPosition);
      }
    });

    audioPlayer.onDurationChanged.listen((Duration totalDuration) {
      setState(() {
        this.totalDuration = totalDuration;
      });
    });
  }

  void _updateActiveIndex(Duration currentPosition) {
    int elapsedTime = currentPosition.inMilliseconds;
    int accumulatedTime = 0;

    for (int i = 0; i < times.length; i++) {
      accumulatedTime += times[i];
      if (i < times.length - 1) {
        accumulatedTime += pauseDuration;
      }
      if (elapsedTime < accumulatedTime) {
        if (elapsedTime >= accumulatedTime - pauseDuration) {
          setState(() {
            activeIndex = -1;
          });
        } else {
          if (activeIndex != i) {
            setState(() {
              activeIndex = i;
            });
          }
        }
        break;
      }
    }
  }

  void _playAudio() {
    setState(() {
      isPlaying = true;
      if (activeIndex == -1) {
        activeIndex = 0;
      }
    });
    if (pausePosition == Duration.zero) {
      audioPlayer.play(BytesSource(widget.sound));
    } else {
      audioPlayer.seek(pausePosition);
      audioPlayer.resume();
    }
    audioPlayer.onPlayerStateChanged.listen((state) {
      if (state == PlayerState.completed) {
        setState(() {
          isPlaying = false;
          activeIndex = -1;
        });
      }
    });
  }

  void _pauseAudio() {
    setState(() {
      isPlaying = false;
    });
    audioPlayer.pause();
    audioPlayer.getCurrentPosition().then((position) {
      if (position != null) {
        pausePosition = position;
        print('Active $activeIndex Paused at: ${pausePosition.inMilliseconds}');
      }
    });
  }

  void _rewindAudio() {
    if (activeIndex > 0) {
      int rewindTime = sumTillIndex(times, activeIndex - 1);
      audioPlayer.seek(Duration(milliseconds: rewindTime)).then((_) {
        setState(() {
          activeIndex--;
          isPlaying = true;
        });
      });
    } else {}
  }

  void _forwardAudio() {
    if (activeIndex < times.length - 1) {
      int forwardTime = sumTillIndex(times, activeIndex + 1);
      audioPlayer.seek(Duration(milliseconds: forwardTime + 250)).then((_) {
        setState(() {
          activeIndex++;
          isPlaying = true;
        });
      });
    } else {}
  }

  int sumTillIndex(List<int> list, int index) {
    if (index < 0 || index >= list.length) {
      throw ArgumentError('Index out of range');
    }
    return list.sublist(0, index).fold(0, (previous, element) => previous + element);
  }

String _formatDuration(Duration duration) {
  String twoDigits(int n) => n.toString().padLeft(2, '0');
  String threeDigits(int n) => n.toString().padLeft(3, '0');
  
  String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
  String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
  String threeDigitMilliseconds = threeDigits(duration.inMilliseconds.remainder(1000));

  return "${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds.$threeDigitMilliseconds";
}


  @override
  void dispose() {
    audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SizedBox(height: 20),
        Container(padding: EdgeInsets.symmetric(vertical: 10),width: 450,decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade600),borderRadius: BorderRadius.circular(16)),child: Column(children: [
      SizedBox(width: 400,
          child: Slider(activeColor: Color.fromARGB(255, 38, 218, 113),
            value: currentPosition.inMilliseconds.toDouble(),
            min: 0.0,
            max: totalDuration.inMilliseconds.toDouble(),
            onChanged: (double value) {
              // setState(() {
              //   currentPosition = Duration(seconds: value.toInt());
              // });
              // audioPlayer.seek(currentPosition);
            },
          ),
        ),
        SizedBox(width: 400,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(_formatDuration(currentPosition)),
              Text(_formatDuration(totalDuration)),
            ],
          ),
        ),
                   const SizedBox(height: 30),

        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              icon: const Icon(Icons.play_arrow),
              onPressed: _playAudio,
            ),
            IconButton(
              icon: const Icon(Icons.pause),
              onPressed: _pauseAudio,
            ),
            IconButton(
              icon: const Icon(Icons.fast_forward),
              onPressed: _forwardAudio,
            ),
            IconButton(
              icon: const Icon(Icons.replay),
              onPressed: _rewindAudio,
            ),
          ],
        ),
        ],),),
  
        const SizedBox(
          height: 30,
        ),
        Column(crossAxisAlignment: CrossAxisAlignment.start,
          children: List.generate(
            widget.interleavePhrases!.length,
            (index) => Container(
              margin: const EdgeInsets.only(bottom: 10),
              color: activeIndex == index
                  ? Color.fromARGB(255, 38, 218, 113)
                  : Colors.grey.shade200,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              child: Text(widget.interleavePhrases![index].speakerName +":  "+
                widget.interleavePhrases![index].words,
                style: TextStyle(
                  color: activeIndex == index ? Colors.white : Colors.black,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
