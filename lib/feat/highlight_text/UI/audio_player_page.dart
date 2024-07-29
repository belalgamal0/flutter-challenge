
import 'dart:typed_data';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import '../model/transscript_model.dart';

class AudioPlayerWidget extends StatefulWidget {
  final Uint8List sound;
  final List<Phrase>? interleavePhrases;
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
  late List<String> sen;

  @override
  void initState() {
    super.initState();
    pauseDuration=widget.pauseTime;
    sen = widget.interleavePhrases!.map((e) => e.words).toList();
    times = widget.interleavePhrases!.map((e) => e.time).toList();

    audioPlayer.onPlayerComplete.listen((event) {
      setState(() {
        isPlaying = false;
        pausePosition = Duration.zero;
        activeIndex = -1;
      });
    });

    audioPlayer.onPositionChanged.listen((Duration currentPosition) {
      if (isPlaying) {
        _updateActiveIndex(currentPosition);
      }
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
    } else {
    }
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
    } else {
    }
  }

  int sumTillIndex(List<int> list, int index) {
    if (index < 0 || index >= list.length) {
      throw ArgumentError('Index out of range');
    }
    return list
        .sublist(0, index)
        .fold(0, (previous, element) => previous + element);
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
        const SizedBox(
          height: 30,
        ),
        Column(
          children: List.generate(
            sen.length,
            (index) => Container(
              margin: const EdgeInsets.only(bottom: 10),
              color: activeIndex == index
                  ? Colors.orangeAccent
                  : Colors.grey.shade200,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              child: Text(
                sen[index],
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
