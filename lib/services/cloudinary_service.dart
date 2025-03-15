import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';

class CloudinaryService {
  static const String cloudName = "dwtfvcrfr";
  static const String uploadPreset = "flutter_ecommerce";

  static Future<String?> uploadImage(XFile imageFile) async {
    try {
      final uri = Uri.parse(
        "https://api.cloudinary.com/v1_1/$cloudName/image/upload",
      );
      var request = http.MultipartRequest('POST', uri)
        ..fields['upload_preset'] = uploadPreset;

      if (kIsWeb) {
        Uint8List imageBytes = await imageFile.readAsBytes();
        request.files.add(
          http.MultipartFile.fromBytes(
            'file',
            imageBytes,
            filename: imageFile.name,
            contentType: MediaType('image', 'jpeg'),
          ),
        );
      } else {
        request.files.add(
          await http.MultipartFile.fromPath('file', imageFile.path),
        );
      }

      var response = await request.send();
      if (response.statusCode == 200) {
        final res = json.decode(await response.stream.bytesToString());
        return res['secure_url'];
      } else {
        debugPrint("Upload failed: ${response.reasonPhrase}");
        return null;
      }
    } catch (e) {
      debugPrint("Error uploading image: $e");
      return null;
    }
  }
}
