<h1>Flutter Audio Player with Highlighted Transcripts</h1></br>
Overview</br>
This Flutter application is designed to play audio files while highlighting the corresponding spoken phrases based on provided transcript metadata. It includes functionality to play, pause, rewind, and forward audio, and visually highlights the current phrase being spoken.</br>

Features</br>
Audio Playback: Play audio files with support for basic controls (play, pause, rewind, forward).</br>
Phrase Highlighting: Display and highlight phrases from the transcript metadata in sync with the audio playback.</br>
Playback Controls: Buttons for controlling playback (play, pause, rewind, forward).</br>
Synchronization: Accurate synchronization of audio playback with phrase highlighting.</br></br>
Requirements</br>
Flutter SDK: Ensure you have Flutter installed. This application was developed using Flutter version 3.22.3.</br>
Dart SDK: Required version 3.4.4.</br>
Audio File: MP3 format.</br>
Transcript Metadata: JSON file with phrase timings and durations.</br>

Control Playback:</br>
Use the playback controls to manage audio:</br>

Play: Start audio playback.</br>
Pause: Pause audio playback.</br>
Rewind: Rewind the audio.</br>
Forward: Forward the audio.</br>
View Highlights:</br>
The application will display and highlight the phrases from the transcript based on the current playback position.</br>

Implementation Details</br>
Architecture</br>
Bloc Pattern: Used for state management, ensuring clear separation of concerns.</br>
Clean Architecture: Helps maintain a modular and testable codebase.</br>
Key Components
AudioPlayerWidget: User interface for audio controls and playback.</br>
TranscriptWidget: Displays and highlights the current phrase based on playback position.</br>
Synchronization Issues</br>
Forwarding Accuracy: There were challenges with accurately forwarding the audio. Ongoing improvements are being made for better precision.</br>
Future Improvements</br>
Format Support: Add support for additional audio formats beyond MP3.</br>
Error Handling: Enhance error handling for missing files or corrupted metadata.</br>
Performance Optimization: Improve performance benchmarks for smoother playback and highlighting.</br>

<h1>Frequently Asked Questions (FAQ)</h1></br>
Is there a maximum file size for the audio file that the app should support?</br>
There is no maximum file size for the audio file. The app can handle audio files of any size.</br>
</br>
Is there a maximum size or length for the transcript metadata JSON that the app should handle?</br>
There is no maximum size or length for the transcript metadata JSON. The app is designed to handle JSON files of any size.</br>
</br>
Should the app handle different audio formats besides MP3, or is MP3 the only required format?</br>
Currently, the app supports only MP3 audio files and JSON metadata. Support for additional audio formats is not implemented.</br>
</br>
Are there any performance benchmarks or responsiveness requirements for the app, especially for larger files?</br>
Performance benchmarks or specific responsiveness requirements are not applied. The app is designed to handle audio playback and transcript highlighting without strict performance constraints.</br>
</br>
How should the app handle errors, such as invalid audio files or corrupt metadata JSON?</br>
The app implements simple error handling by notifying the user with an alert if something goes wrong, such as invalid audio files or corrupt metadata JSON.</br>
</br>
Are there any edge cases we must be aware of, such as overlapping phrases or missing time durations in the transcript?</br>
There are no specific edge cases like overlapping phrases or missing time durations that the app needs to handle. The app assumes that the transcript metadata is well-formed and complete.</br>
