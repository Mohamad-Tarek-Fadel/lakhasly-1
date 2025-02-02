import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import '../../data/datasources/audio_remote_data_source.dart';

class AudioRecorderWidget extends StatefulWidget {
  final Function(String, String)? onTranscriptionReceived;

  const AudioRecorderWidget({
    super.key,
    this.onTranscriptionReceived,
  });

  @override
  _AudioRecorderWidgetState createState() => _AudioRecorderWidgetState();
}

class _AudioRecorderWidgetState extends State<AudioRecorderWidget> {
  final FlutterSoundRecorder _recorder = FlutterSoundRecorder();
  final AudioRemoteDataSource _audioRemoteDataSource =
      AudioRemoteDataSource('http://your-backend-url');
  bool _isRecording = false;
  bool _isUploading = false;
  String? _filePath;
  bool _hasPermission = false;

  @override
  void initState() {
    super.initState();
    _initRecorder();
  }

  Future<void> _initRecorder() async {
    await _recorder.openAudioSession();
    await _requestPermission();
  }

  @override
  void dispose() {
    _recorder.closeAudioSession();
    super.dispose();
  }

  Future<void> _requestPermission() async {
    final status = await Permission.microphone.request();
    setState(() {
      _hasPermission = status == PermissionStatus.granted;
    });

    if (!_hasPermission) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Microphone permission is required to record audio'),
        ),
      );
    }
  }

  Future<void> _startRecording() async {
    if (!_hasPermission) {
      await _requestPermission();
      if (!_hasPermission) return;
    }

    try {
      Directory tempDir = await getTemporaryDirectory();
      _filePath =
          '${tempDir.path}/audio_${DateTime.now().millisecondsSinceEpoch}.aac';

      await _recorder.startRecorder(
        toFile: _filePath,
        codec: Codec.aacADTS,
      );

      setState(() {
        _isRecording = true;
      });
    } catch (e) {
      print('Error starting recording: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to start recording')),
      );
    }
  }

  Future<void> _stopRecording() async {
    try {
      String? path = await _recorder.stopRecorder();
      setState(() {
        _isRecording = false;
        _filePath = path;
      });
    } catch (e) {
      print('Error stopping recording: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to stop recording')),
      );
    }
  }

  Future<void> _uploadAudio() async {
    if (_filePath == null) return;

    setState(() {
      _isUploading = true;
    });

    try {
      final result = await _audioRemoteDataSource.uploadAudio(_filePath!);
      if (widget.onTranscriptionReceived != null) {
        widget.onTranscriptionReceived!(
          result['transcription'] ?? '',
          result['analysis'] ?? '',
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to upload audio: $e')),
      );
    } finally {
      setState(() {
        _isUploading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton.icon(
                onPressed: _isUploading
                    ? null
                    : (_hasPermission
                        ? (_isRecording ? _stopRecording : _startRecording)
                        : _requestPermission),
                icon: Icon(_isRecording ? Icons.stop : Icons.mic),
                label:
                    Text(_isRecording ? 'Stop Recording' : 'Start Recording'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _isRecording ? Colors.red : null,
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
              ),
              if (_filePath != null && !_isRecording) ...[
                SizedBox(width: 16),
                ElevatedButton.icon(
                  onPressed: _isUploading ? null : _uploadAudio,
                  icon: _isUploading
                      ? SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Icon(Icons.upload),
                  label: Text(_isUploading ? 'Uploading...' : 'Upload'),
                ),
              ],
            ],
          ),
          if (_filePath != null && !_isUploading) ...[
            SizedBox(height: 16),
            Text(
              'Recording saved at:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              _filePath!,
              style: TextStyle(fontSize: 12),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}
