import 'dart:convert';
import 'package:http/http.dart' as http;

class AudioRemoteDataSource {
  final String baseUrl;

  AudioRemoteDataSource(this.baseUrl);

  Future<Map<String, dynamic>> uploadAudio(String filePath) async {
    final request = http.MultipartRequest('POST', Uri.parse('$baseUrl/upload'));
    request.files.add(await http.MultipartFile.fromPath('audio', filePath));

    final response = await request.send();
    if (response.statusCode == 200) {
      final responseData = await response.stream.bytesToString();
      return json.decode(responseData);
    } else {
      throw Exception('Failed to upload audio');
    }
  }
} 