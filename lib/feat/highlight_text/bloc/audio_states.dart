import 'dart:typed_data';

import '../model/transscript_model.dart';

abstract class AudioPlayerState {}

class InitialState extends AudioPlayerState {}
class LoadingAudio extends AudioPlayerState {}
class LoadingAction extends AudioPlayerState {}
class LoadedAction extends AudioPlayerState {}
class LoadingJson extends AudioPlayerState {}
class ErrorState extends AudioPlayerState {
  final String errorMessage;
  ErrorState(this.errorMessage);
}

class JsonFileLoaded extends AudioPlayerState {
  final TransscriptModel transscriptModel;

  JsonFileLoaded(this.transscriptModel);
}

class AudioFileLoaded extends AudioPlayerState {
  final Uint8List audioBytes;

  AudioFileLoaded(this.audioBytes);
}

class PlayingState extends AudioPlayerState {}

class PausedState extends AudioPlayerState {}
class HighlightingState extends AudioPlayerState {}

class HighlightState extends AudioPlayerState {
  final int currentIndex;
  final bool isPause;

  HighlightState(this.currentIndex, this.isPause);
}
