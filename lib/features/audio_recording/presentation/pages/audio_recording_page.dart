import 'package:flutter/material.dart';
import '../widgets/audio_recorder_widget.dart';

class AudioRecordingPage extends StatelessWidget {
  const AudioRecordingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Lakhasly'),
      ),
      body: Center(
        child: AudioRecorderWidget(),
      ),
    );
  }
} 