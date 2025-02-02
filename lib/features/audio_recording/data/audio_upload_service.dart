import 'dart:io';
import 'package:http/http.dart' as http;

class AudioUploadService {
  Future<void> uploadAudio(File audioFile) async {
    var request = http.MultipartRequest(
      'POST',
      Uri.parse('http://your-fastapi-backend-url/upload'),
    );
    request.files
        .add(await http.MultipartFile.fromPath('file', audioFile.path));
    var response = await request.send();

    if (response.statusCode == 200) {
      print('Uploaded successfully');
    } else {
      print('Failed to upload');
    }
  }
}
