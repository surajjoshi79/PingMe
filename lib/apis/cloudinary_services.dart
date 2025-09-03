import 'dart:convert';
import 'dart:io';
import 'package:chat_app/secret.dart';
import 'package:http/http.dart' as http;
import 'package:file_picker/file_picker.dart';

class CloudinaryService{

  static Future<String> uploadToCloudinary(FilePickerResult filePickerResult) async{
    File file=File(filePickerResult.files.single.path!);

    String cloudName=Secret.cloudName;

    var uri=Uri.parse("https://api.cloudinary.com/v1_1/$cloudName/image/upload");
    var request=http.MultipartRequest("POST",uri);
    var fileBytes = await file.readAsBytes();
    var multipartFile = http.MultipartFile.fromBytes(
      'file',
      fileBytes,
      filename: file.path.split("/").last,
    );

    request.files.add(multipartFile);

    request.fields['upload_preset'] = "present-for-upload-chat";
    request.fields['resource_type'] = "image";

    var response = await request.send();

    var responseBody = await response.stream.bytesToString();

    if(response.statusCode==200){
      var jsonResponse=jsonDecode(responseBody);
      return Future.value(jsonResponse['secure_url']);
    }

    return Future.value('');
  }

  static Future<String> uploadProfilePicture(String imagePath) async{
    File file=File(imagePath);

    String cloudName=Secret.cloudName;

    var uri=Uri.parse("https://api.cloudinary.com/v1_1/$cloudName/image/upload");
    var request=http.MultipartRequest("POST",uri);
    var fileBytes = await file.readAsBytes();
    var multipartFile = http.MultipartFile.fromBytes(
      'file',
      fileBytes,
      filename: file.path.split("/").last,
    );

    request.files.add(multipartFile);

    request.fields['upload_preset'] = "present-for-upload-chat";
    request.fields['resource_type'] = "image";

    var response = await request.send();

    var responseBody = await response.stream.bytesToString();

    if(response.statusCode==200){
      var jsonResponse=jsonDecode(responseBody);
      return Future.value(jsonResponse['secure_url']);
    }

    return Future.value('');
  }

  static Future<String?> uploadPdfToCloudinary(File pdfFile) async {
    final cloudName = Secret.cloudName;
    final uploadPreset = "present-for-upload-chat";

    final uri = Uri.parse('https://api.cloudinary.com/v1_1/$cloudName/raw/upload');

    final request = http.MultipartRequest('POST', uri)
      ..fields['upload_preset'] = uploadPreset
      ..fields['resource_type'] = 'raw'
      ..files.add(await http.MultipartFile.fromPath('file', pdfFile.path));

    final response = await request.send();

    if (response.statusCode == 200) {
      final resStr = await response.stream.bytesToString();
      final url = jsonDecode(resStr)['secure_url'];
      return url;
    }

    return null;
  }

  static Future<String> uploadAudioMsg(String audioPath) async{
    File file=File(audioPath);

    String cloudName=Secret.cloudName;

    var uri=Uri.parse("https://api.cloudinary.com/v1_1/$cloudName/video/upload");
    var request=http.MultipartRequest("POST",uri);
    var fileBytes = await file.readAsBytes();
    var multipartFile = http.MultipartFile.fromBytes(
      'file',
      fileBytes,
      filename: file.path.split("/").last,
    );

    request.files.add(multipartFile);

    request.fields['upload_preset'] = "present-for-upload-chat";
    request.fields['resource_type'] = "video";

    var response = await request.send();

    var responseBody = await response.stream.bytesToString();

    if(response.statusCode==200){
      var jsonResponse=jsonDecode(responseBody);
      return Future.value(jsonResponse['secure_url']);
    }

    return Future.value('');
  }

}