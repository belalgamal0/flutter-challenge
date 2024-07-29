// import 'package:flutter/material.dart';
// import 'package:file_picker/file_picker.dart';
// import 'package:audioplayers/audioplayers.dart';
// import 'dart:convert';

// void main() {
//   runApp(MyApp());
// }

// class MyApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       home: AudioPlayerScreen(),
//     );
//   }
// }

// class AudioPlayerScreen extends StatefulWidget {
//   @override
//   _AudioPlayerScreenState createState() => _AudioPlayerScreenState();
// }

// class _AudioPlayerScreenState extends State<AudioPlayerScreen> {
//   AudioPlayer _audioPlayer = AudioPlayer();
//   String? _audioPath;
//   Map<String, dynamic>? _metadata;
//   int _currentPhraseIndex = 0;

//   void _pickFiles() async {
//     // Pick audio file
//     FilePickerResult? audioResult = await FilePicker.platform.pickFiles(
//       type: FileType.audio,
//     );
//     if (audioResult != null) {
//       setState(() {
//         _audioPath = audioResult.files.single.path;
//       });
//     }

//     // Pick metadata file
//     FilePickerResult? metadataResult = await FilePicker.platform.pickFiles(
//       type: FileType.custom,
//       allowedExtensions: ['json'],
//     );
//     if (metadataResult != null) {
//       String jsonString = await File(metadataResult.files.single.path!).readAsString();
//       setState(() {
//         _metadata = json.decode(jsonString);
//       });
//     }
//   }

//   void _playAudio() {
//     if (_audioPath != null) {
//       _audioPlayer.play(_audioPath!, isLocal: true);
//     }
//   }

//   // Implement other functions (pause, rewind, forward)

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Audio Player with Transcript'),
//       ),
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             ElevatedButton(
//               onPressed: _pickFiles,
//               child: Text('Pick Files'),
//             ),
//             if (_audioPath != null && _metadata != null) ...[
//               ElevatedButton(
//                 onPressed: _playAudio,
//                 child: Text('Play'),
//               ),
//               // Other buttons (Pause, Rewind, Forward)
//               Expanded(
//                 child: ListView.builder(
//                   itemCount: _metadata!['speakers'].length,
//                   itemBuilder: (context, index) {
//                     var speaker = _metadata!['speakers'][index];
//                     return Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(speaker['name'], style: TextStyle(fontWeight: FontWeight.bold)),
//                         ...speaker['phrases'].map<Widget>((phrase) {
//                           int phraseIndex = speaker['phrases'].indexOf(phrase);
//                           bool isHighlighted = _currentPhraseIndex == phraseIndex;
//                           return Text(
//                             phrase['words'],
//                             style: TextStyle(
//                               backgroundColor: isHighlighted ? Colors.yellow : Colors.transparent,
//                             ),
//                           );
//                         }).toList(),
//                       ],
//                     );
//                   },
//                 ),
//               ),
//             ],
//           ],
//         ),
//       ),
//     );
//   }
// }
