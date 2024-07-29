
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/audio_bloc.dart';
import '../bloc/audio_events.dart';
import '../bloc/audio_states.dart';
import 'audio_player_page.dart';

class FlutterChallenge extends StatefulWidget {
  @override
  _FlutterChallengeState createState() => _FlutterChallengeState();
}

class _FlutterChallengeState extends State<FlutterChallenge> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Interview Challenge'),
        centerTitle: true,
        backgroundColor: const Color.fromARGB(255, 38, 218, 113),
      ),
      body: BlocProvider(
        create: (context) => AudioPlayerBloc(),
        child: BlocListener<AudioPlayerBloc, AudioPlayerState>(
          listener: (context, state) {
            if (state is ErrorState) {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text("Error"),
                  content: Text(state.errorMessage),
                ),
              );
            }
          },
          child: BlocBuilder<AudioPlayerBloc, AudioPlayerState>(
            buildWhen: (previous, current) => previous != current,
            builder: (context, state) => Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  BlocProvider.of<AudioPlayerBloc>(context).audio != null &&
                          BlocProvider.of<AudioPlayerBloc>(context)
                                  .transscriptModel !=
                              null
                      ? const Text(
                          "You are ready to GO!",
                          style: TextStyle(fontSize: 20, color: Colors.green),
                        )
                      : const Text("Please pick the audio file and transscript first",
                          style: TextStyle(fontSize: 20, color: Colors.grey)),
                  const SizedBox(height: 50),
                  ElevatedButton.icon(
                    onPressed: () {
                      BlocProvider.of<AudioPlayerBloc>(context)
                          .add(PickAudioFile());
                    },
                    icon: const Icon(Icons.audiotrack, color: Colors.white),
                    label: const Text(
                      'Pick Sound File',
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color.fromARGB(186, 0, 0, 0)),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          const Color.fromARGB(255, 38, 218, 113),
                      textStyle: const TextStyle(color: Colors.white), 
                      padding:
                          const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      elevation: 5,
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: () {
                      BlocProvider.of<AudioPlayerBloc>(context)
                          .add(PickJsonFile());
                    },
                    icon: const Icon(Icons.lyrics_outlined, color: Colors.white),
                    label: const Text(
                      'Pick Transscript File',
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color.fromARGB(186, 0, 0, 0)),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          const Color.fromARGB(255, 38, 218, 113), 
                      textStyle: const TextStyle(color: Colors.white), 
                      padding:
                          const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      elevation: 5,
                    ),
                  ),
                  const SizedBox(height: 30),
                  if (BlocProvider.of<AudioPlayerBloc>(context).audio != null &&
                      BlocProvider.of<AudioPlayerBloc>(context)
                              .transscriptModel !=
                          null) ...[
                    AudioPlayerWidget(
                      sound: BlocProvider.of<AudioPlayerBloc>(context).audio!,
                      interleavePhrases:
                          BlocProvider.of<AudioPlayerBloc>(context)
                              .interleavePhrases!,
                              pauseTime:BlocProvider.of<AudioPlayerBloc>(context)
                              .transscriptModel!.pause ,
                    )
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
