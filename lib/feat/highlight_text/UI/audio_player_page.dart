import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/audio_bloc.dart';
import '../bloc/audio_events.dart';
import '../model/interleave_sentence_model.dart';

class AudioPlayerWidget extends StatefulWidget {
  final Uint8List sound;
  final List<InterleavedPhrase>? interleavePhrases;
  final int pauseTime;

  AudioPlayerWidget(
      {required this.sound,
      required this.interleavePhrases,
      required this.pauseTime});

  @override
  _AudioPlayerWidgetState createState() => _AudioPlayerWidgetState();
}

class _AudioPlayerWidgetState extends State<AudioPlayerWidget> {
  @override
  void initState() {
    super.initState();
    BlocProvider.of<AudioPlayerBloc>(context).pauseDuration = widget.pauseTime;

    // Interleave phrases and speakers
    var interleavedPhrases = widget.interleavePhrases!;
    BlocProvider.of<AudioPlayerBloc>(context).phrases =
        interleavedPhrases.map((e) => e.words).toList();
    BlocProvider.of<AudioPlayerBloc>(context).times =
        interleavedPhrases.map((e) => e.time).toList();
    BlocProvider.of<AudioPlayerBloc>(context).speakers =
        interleavedPhrases.map((e) => e.speakerName).toList();

    BlocProvider.of<AudioPlayerBloc>(context)
        .audioPlayer
        .onPlayerComplete
        .listen((event) {
      setState(() {
        BlocProvider.of<AudioPlayerBloc>(context).isPlaying = false;
        BlocProvider.of<AudioPlayerBloc>(context).pausePosition = Duration.zero;
        BlocProvider.of<AudioPlayerBloc>(context).activeIndex = -1;
        BlocProvider.of<AudioPlayerBloc>(context).currentPosition =
            Duration.zero;
      });
    });

    BlocProvider.of<AudioPlayerBloc>(context)
        .audioPlayer
        .onPositionChanged
        .listen((Duration currentPosition) {
      setState(() {
        BlocProvider.of<AudioPlayerBloc>(context).currentPosition =
            currentPosition;
      });
      if (BlocProvider.of<AudioPlayerBloc>(context).isPlaying) {
        _updateActiveIndex(currentPosition);
      }
    });

    BlocProvider.of<AudioPlayerBloc>(context)
        .audioPlayer
        .onDurationChanged
        .listen((Duration totalDuration) {
      setState(() {
        BlocProvider.of<AudioPlayerBloc>(context).totalDuration = totalDuration;
      });
    });
  }

  void _updateActiveIndex(Duration currentPosition) {
    int elapsedTime = currentPosition.inMilliseconds;
    int accumulatedTime = 0;

    for (int i = 0;
        i < BlocProvider.of<AudioPlayerBloc>(context).times.length;
        i++) {
      accumulatedTime += BlocProvider.of<AudioPlayerBloc>(context).times[i];
      if (i < BlocProvider.of<AudioPlayerBloc>(context).times.length - 1) {
        accumulatedTime +=
            BlocProvider.of<AudioPlayerBloc>(context).pauseDuration;
      }
      if (elapsedTime < accumulatedTime) {
        if (elapsedTime >=
            accumulatedTime -
                BlocProvider.of<AudioPlayerBloc>(context).pauseDuration) {
          setState(() {
            BlocProvider.of<AudioPlayerBloc>(context).activeIndex = -1;
          });
        } else {
          if (BlocProvider.of<AudioPlayerBloc>(context).activeIndex != i) {
            setState(() {
              BlocProvider.of<AudioPlayerBloc>(context).activeIndex = i;
            });
          }
        }
        break;
      }
    }
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String threeDigits(int n) => n.toString().padLeft(3, '0');

    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    String threeDigitMilliseconds =
        threeDigits(duration.inMilliseconds.remainder(1000));

    return "${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds.$threeDigitMilliseconds";
  }

  @override
  void dispose() {
    BlocProvider.of<AudioPlayerBloc>(context).audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          width: 450,
          decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade600),
              borderRadius: BorderRadius.circular(16)),
          child: Column(
            children: [
              SizedBox(
                width: 400,
                child: Slider(
                  activeColor: const Color.fromARGB(255, 38, 218, 113),
                  value: BlocProvider.of<AudioPlayerBloc>(context)
                      .currentPosition
                      .inMilliseconds
                      .toDouble(),
                  min: 0.0,
                  max: BlocProvider.of<AudioPlayerBloc>(context)
                      .totalDuration
                      .inMilliseconds
                      .toDouble(),
                  onChanged: (double value) {},
                ),
              ),
              SizedBox(
                width: 400,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(_formatDuration(
                        BlocProvider.of<AudioPlayerBloc>(context)
                            .currentPosition)),
                    Text(_formatDuration(
                        BlocProvider.of<AudioPlayerBloc>(context)
                            .totalDuration)),
                  ],
                ),
              ),
              const SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.play_arrow),
                    onPressed: () => BlocProvider.of<AudioPlayerBloc>(context)
                        .add(PlayPause(
                            BlocProvider.of<AudioPlayerBloc>(context).audio!)),
                  ),
                  IconButton(
                    icon: const Icon(Icons.pause),
                    onPressed: () => BlocProvider.of<AudioPlayerBloc>(context)
                        .add(PauseAction()),
                  ),
                  IconButton(
                    icon: const Icon(Icons.fast_forward),
                    onPressed: () => BlocProvider.of<AudioPlayerBloc>(context)
                        .add(ForwardAction()),
                  ),
                  IconButton(
                    icon: const Icon(Icons.replay),
                    onPressed: () => BlocProvider.of<AudioPlayerBloc>(context)
                        .add(RewindAction()),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(
          height: 30,
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: List.generate(
            widget.interleavePhrases!.length,
            (index) => Container(
              margin: const EdgeInsets.only(bottom: 10),
              color:
                  BlocProvider.of<AudioPlayerBloc>(context).activeIndex == index
                      ? const Color.fromARGB(255, 38, 218, 113)
                      : Colors.grey.shade200,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              child: Text(
                "${widget.interleavePhrases![index].speakerName}:  ${widget.interleavePhrases![index].words}",
                style: TextStyle(
                  color:
                      BlocProvider.of<AudioPlayerBloc>(context).activeIndex ==
                              index
                          ? Colors.white
                          : Colors.black,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
