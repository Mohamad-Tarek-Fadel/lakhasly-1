import 'package:flutter/material.dart';

class AudioResultDisplay extends StatelessWidget {
  final String transcription;
  final String analysis;

  const AudioResultDisplay({super.key, required this.transcription, required this.analysis});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text('Transcription: $transcription'),
        Text('Analysis: $analysis'),
      ],
    );
  }
}
