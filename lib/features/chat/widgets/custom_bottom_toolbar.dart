import 'package:flutter/material.dart';

class CustomBottomToolbar extends StatelessWidget {
  const CustomBottomToolbar({
    super.key,
    required this.isRecording,
    required this.isUploading,
    required this.onRecordPressed,
    required this.onMediaPressed,
  });

  final bool isRecording;
  final bool isUploading;
  final VoidCallback onRecordPressed;
  final VoidCallback onMediaPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: const Color(0xFF2D2D2D),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.attach_file),
            color: Colors.tealAccent,
            onPressed: onMediaPressed,
          ),
          FloatingActionButton(
            onPressed: onRecordPressed,
            backgroundColor: isRecording ? Colors.red : Colors.tealAccent,
            child: Icon(
              isRecording ? Icons.stop : Icons.mic,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }
} 