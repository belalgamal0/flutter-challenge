import 'dart:typed_data';

abstract class AudioPlayerEvent {}

class PickJsonFile extends AudioPlayerEvent {}

class PickAudioFile extends AudioPlayerEvent {}
class PrepareAction extends AudioPlayerEvent {}
class PlayAction extends AudioPlayerEvent {}
class AnimateAction extends AudioPlayerEvent {}
class PauseAction extends AudioPlayerEvent {}
class ForwardAction extends AudioPlayerEvent {}
class RewindAction extends AudioPlayerEvent {}

class PlayPause extends AudioPlayerEvent {
  Uint8List soundBytes;
  PlayPause(this.soundBytes);
}

class HighlightNextPhrase extends AudioPlayerEvent {}

class ResetHighlight extends AudioPlayerEvent {}