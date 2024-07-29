import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:typed_data';
import 'package:audioplayers/audioplayers.dart';
import 'package:bloc/bloc.dart';
import 'package:file_picker/file_picker.dart';
import '../model/transscript_model.dart';
import 'audio_events.dart';
import 'audio_states.dart';

class AudioPlayerBloc extends Bloc<AudioPlayerEvent, AudioPlayerState> {
  final AudioPlayer audioPlayer = AudioPlayer();
  Uint8List? audio;
  TransscriptModel? transscriptModel;
  List<Phrase>? interleavePhrases;
  AudioPlayerBloc() : super(InitialState()) {
    on<PickAudioFile>(_pickAudio);
    on<PickJsonFile>(_pickTransscript);
    on<PlayPause>(_playAudio);
    on<PlayAction>(_playDialouge);
    on<PauseAction>(_pauseDialouge);
  }

  void _pickAudio(
      AudioPlayerEvent event, Emitter<AudioPlayerState> emit) async {
    // Emit the loading state
    emit(LoadingAudio());
    // Invoke the GetMoviesUseCase to get the movies data
    final fileOrError = await _pickAudioFile();
    // Process the result and emit the corresponding state
    emit(AudioFileLoaded(fileOrError!));
  }

  Future<Uint8List?> _pickAudioFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['mp3'],
      );
      audio =
          // if (result != null) {
          result!.files.first.bytes!;
      // Uint8List bytes
      // }
      return audio;
    } catch (e) {
      emit(ErrorState(e.toString()));
    }
  }

  void _playAudio(PlayPause event, Emitter<AudioPlayerState> emit) async {
    // Emit the loading state
    emit(PlayingState());
    // Invoke the GetMoviesUseCase to get the movies data
    _playAudioFile(event.soundBytes);
    // Process the result and emit the corresponding state
    emit(PausedState());
  }

  void _playAudioFile(Uint8List soundBytes) {
    audioPlayer.play(BytesSource(soundBytes));
  }

  // void _pauseAudioFile() {
  //   audioPlayer.pause();
  // }
  void _pickTransscript(
      AudioPlayerEvent event, Emitter<AudioPlayerState> emit) async {
    // Emit the loading state
    emit(LoadingJson());
    // Invoke the GetMoviesUseCase to get the movies data
    final fileOrError = await _pickJsonFile();
    // Process the result and emit the corresponding state
    emit(JsonFileLoaded(fileOrError!));
  }

  Future<TransscriptModel?> _pickJsonFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
      );

      String jsonString = utf8.decode(result!.files.first.bytes!);
      TransscriptModel transscriptModelInner =
          TransscriptModel.fromJson(json.decode(jsonString));

      transscriptModel = transscriptModelInner;
      interleavePhrases = interleavePhrasesAction(transscriptModel!);
      words = interleavePhrases!.map((e) => e.words).toList();
      times = interleavePhrases!.map((e) => e.time).toList();
      return transscriptModel;

      // }
    } catch (e) {
      emit(ErrorState(e.toString()));
    }
  }

  late List<String> words;
  late List<int> times;
  Timer? timer;

  int activeIndex = 0;
  bool isPause = false;
  bool isPlaying = false;

  List<Phrase> interleavePhrasesAction(TransscriptModel model) {
    List<Phrase> interleavedPhrases = [];
    List<Speaker> speakers = model.speakers;
    int maxLength =
        speakers.map((s) => s.phrases.length).reduce((a, b) => a > b ? a : b);

    for (int i = 0; i < maxLength; i++) {
      for (var speaker in speakers) {
        if (i < speaker.phrases.length) {
          interleavedPhrases.add(speaker.phrases[i]);
        }
      }
    }

    return interleavedPhrases;
  }

  int remainingTime = 0;

  void _startHighlightAnimation() {
    emit(HighlightingState());

    if (activeIndex < times.length && isPlaying) {
      log("it will be dfined");
      int duration = isPause
          ? 250
          : remainingTime > 0
              ? remainingTime
              : times[activeIndex];

      timer = Timer(Duration(milliseconds: duration), () {
        log("it will be dfined $isPause");
        log("${isPause ? "250" : times[activeIndex]}");

        if (isPause) {
          activeIndex++;
          if (activeIndex >= words.length) {
            timer?.cancel();
            return;
          }
        }
        isPause = !isPause;

        if (activeIndex < words.length) {
          _startHighlightAnimation();
          emit(HighlightState(activeIndex, isPause));
        }
      });
    }
  }

  Duration pausePosition = Duration.zero;

  void _playDialouge(
      AudioPlayerEvent event, Emitter<AudioPlayerState> emit) async {
    // Emit the loading state
    emit(PlayingState());
    // Invoke the GetMoviesUseCase to get the movies data
    _play(event, emit);
    // Process the result and emit the corresponding state
    // emit(PausedState());
  }

  void _play(AudioPlayerEvent event, Emitter<AudioPlayerState> emit) {
    isPlaying = true;
    if (pausePosition == Duration.zero) {
      _playAudioFile(audio!);
    } else {
      audioPlayer.resume();
    }
    _startHighlightAnimation();
  }

  void _pauseDialouge(
      AudioPlayerEvent event, Emitter<AudioPlayerState> emit) async {
    // Emit the loading state
    emit(PlayingState());
    // Invoke the GetMoviesUseCase to get the movies data
    _pause(event, emit);
    // Process the result and emit the corresponding state
    // emit(PausedState());
  }

  void _pause(AudioPlayerEvent event, Emitter<AudioPlayerState> emit) {
    // emit(HighlightingState());
// _pauseAudioFile();
    isPlaying = false;
    audioPlayer.pause();
    audioPlayer.getCurrentPosition().then((position) {
      pausePosition = position!;
      int elapsed = times.take(activeIndex).reduce((a, b) => a + b) +
          times[activeIndex] -
          remainingTime;
      remainingTime = elapsed - pausePosition.inMilliseconds;
    });
    timer?.cancel();
    emit(HighlightState(activeIndex, isPause));
  }
}
