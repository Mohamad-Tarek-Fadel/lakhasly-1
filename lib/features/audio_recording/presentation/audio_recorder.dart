import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';

class AudioRecorder extends StatefulWidget {
  const AudioRecorder({super.key});

  @override
  _AudioRecorderState createState() => _AudioRecorderState();
}

class _AudioRecorderState extends State<AudioRecorder> {
  final FlutterSoundRecorder _recorder = FlutterSoundRecorder();
  bool _isRecording = false;

  @override
  void initState() {
    super.initState();
    _recorder.openAudioSession();
  }

  @override
  void dispose() {
    _recorder.closeAudioSession();
    super.dispose();
  }

  void _startRecording() async {
    await _recorder.startRecorder(toFile: 'audio.aac');
    setState(() {
      _isRecording = true;
    });
  }

  void _stopRecording() async {
    await _recorder.stopRecorder();
    setState(() {
      _isRecording = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ElevatedButton(
          onPressed: _isRecording ? _stopRecording : _startRecording,
          child: Text(_isRecording ? 'Stop Recording' : 'Start Recording'),
        ),
      ],
    );
  }
}
