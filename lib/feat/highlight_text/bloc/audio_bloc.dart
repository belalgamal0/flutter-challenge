import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:audioplayers/audioplayers.dart';
import 'package:bloc/bloc.dart';
import 'package:file_picker/file_picker.dart';
import '../model/interleave_sentence_model.dart';
import '../model/transscript_model.dart';
import 'audio_events.dart';
import 'audio_states.dart';

class AudioPlayerBloc extends Bloc<AudioPlayerEvent, AudioPlayerState> {
  final AudioPlayer audioPlayer = AudioPlayer();
  Duration pausePosition = Duration.zero;
  int activeIndex = -1;
  late int pauseDuration;
  bool isPlaying = false;
  late List<int> times;
  late List<String> phrases;
  late List<String> speakers;
  Duration currentPosition = Duration.zero;
  Duration totalDuration = Duration.zero;
  Uint8List? audio;
  TransscriptModel? transscriptModel;
  List<InterleavedPhrase>? interleavePhrases;
  AudioPlayerBloc() : super(InitialState()) {
    on<PickAudioFile>(_pickAudio);
    on<PickJsonFile>(_pickTransscript);
    on<PlayPause>(_playAudio);
    on<PauseAction>(_pauseDialouge);
    on<ForwardAction>(_forwardAudio);
    on<RewindAction>(_rewindAudio);
  }

  void _pickAudio(
      AudioPlayerEvent event, Emitter<AudioPlayerState> emit) async {
    emit(LoadingAudio());
    final fileOrError = await _pickAudioFile();
    emit(AudioFileLoaded(fileOrError!));
  }

  Future<Uint8List?> _pickAudioFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['mp3'],
      );
      audio = result!.files.first.bytes!;

      return audio;
    } catch (e) {
      emit(ErrorState(e.toString()));
    }
  }

  void _playAudio(PlayPause event, Emitter<AudioPlayerState> emit) async {
    emit(PlayingState());
    _playAudioFile(event.soundBytes);
  }

  void _playAudioFile(Uint8List soundBytes) {
    isPlaying = true;
    if (activeIndex == -1) {
      activeIndex = 0;
    }
    if (pausePosition == Duration.zero) {
      audioPlayer.play(BytesSource(audio!));
    } else {
      audioPlayer.seek(pausePosition);
      audioPlayer.resume();
    }
    audioPlayer.onPlayerStateChanged.listen((state) {
      if (state == PlayerState.completed) {
        isPlaying = false;
        activeIndex = -1;
      }
    });
    emit(PlayingSuccessState());
  }

  void _pickTransscript(
      AudioPlayerEvent event, Emitter<AudioPlayerState> emit) async {
    emit(LoadingJson());
    final fileOrError = await _pickJsonFile();
    emit(JsonFileLoaded(fileOrError!));
  }

  Future<TransscriptModel?> _pickJsonFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
      );

      String jsonString = utf8.decode(result!.files.first.bytes!);
      TransscriptModel transscriptModelInner = TransscriptModel.fromJson(json.decode(jsonString));
      transscriptModel = transscriptModelInner;
      interleavePhrases = interleavePhrasesAction(transscriptModel!);
      words = interleavePhrases!.map((e) => e.words).toList();
      times = interleavePhrases!.map((e) => e.time).toList();
      return transscriptModel;
    } catch (e) {
      emit(ErrorState(e.toString()));
    }
  }

  late List<String> words;
  Timer? timer;

  bool isPause = false;
  List<InterleavedPhrase> interleavePhrasesAction(TransscriptModel model) {
    List<InterleavedPhrase> interleavedPhrases = [];
    List<Speaker> speakers = model.speakers;
    int maxLength =
        speakers.map((s) => s.phrases.length).reduce((a, b) => a > b ? a : b);

    for (int i = 0; i < maxLength; i++) {
      for (var speaker in speakers) {
        if (i < speaker.phrases.length) {
          interleavedPhrases.add(InterleavedPhrase(
            speakerName: speaker.name,
            words: speaker.phrases[i].words,
            time: speaker.phrases[i].time,
          ));
        }
      }
    }

    return interleavedPhrases;
  }

  int remainingTime = 0;

  void _pauseDialouge(
      AudioPlayerEvent event, Emitter<AudioPlayerState> emit) async {
    _pause(event, emit);
  }

  void _pause(AudioPlayerEvent event, Emitter<AudioPlayerState> emit) {
    emit(PausingState());
    isPlaying = false;
    audioPlayer.pause();
    audioPlayer.getCurrentPosition().then((position) {
      if (position != null) {
        pausePosition = position;
      }
    });
    emit(PausedState());
  }

  int sumTillIndex(List<int> list, int index) {
    if (index < 0 || index >= list.length) {
      throw ArgumentError('Index out of range');
    }
    return list
        .sublist(0, index)
        .fold(0, (previous, element) => previous + element);
  }

  void _forwardAudio(AudioPlayerEvent event, Emitter<AudioPlayerState> emit) {
    emit(ForwardingState());
    if (activeIndex < times.length - 1) {
      int forwardTime = sumTillIndex(times, activeIndex + 1);
      audioPlayer.seek(Duration(milliseconds: forwardTime + 250)).then((_) {
        activeIndex++;
        isPlaying = true;
      });
      emit(PlayingState());
    }
  }

  void _rewindAudio(AudioPlayerEvent event, Emitter<AudioPlayerState> emit) {
    emit(RewindingState());
    if (activeIndex > 0) {
      int rewindTime = sumTillIndex(times, activeIndex - 1);
      audioPlayer.seek(Duration(milliseconds: rewindTime)).then((_) {
        activeIndex--;
        isPlaying = true;
      });
      emit(PlayingState());
    }
  }
}
