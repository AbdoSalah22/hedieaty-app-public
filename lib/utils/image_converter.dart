import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';

class ImageConverter {
  final ImagePicker _picker = ImagePicker();

  /// Picks an image from the gallery, compresses it, and converts it to a Base64 string
  Future<String?> pickAndCompressImageToString() async {
    var selectedImage = await _picker.pickImage(source: ImageSource.gallery);
    if (selectedImage != null) {
      try {
        // Read image as bytes
        var imageBytes = await File(selectedImage.path).readAsBytes();

        // Decode image bytes into an image object
        img.Image? image = img.decodeImage(imageBytes);

        if (image != null) {
          // Resize the image to reduce size (optional step)
          img.Image resizedImage = img.copyResize(image, width: 800); // You can change the width here

          // Compress the image (JPEG with quality of 80)
          List<int> compressedBytes = img.encodeJpg(resizedImage, quality: 80);

          // Convert the compressed image to Base64 string
          var imageString = base64Encode(compressedBytes);
          return imageString;
        }
      } catch (e) {
        // Handle any errors
        print("Error while picking, compressing, or converting image: $e");
        return null;
      }
    }
    return null;
  }

  /// Converts a Base64 string to an image widget
  Uint8List? stringToImage(String base64String) {
    try {

      // Decode the Base64 string to bytes
      Uint8List bytes = base64Decode(base64String);
      // Return an Image widget from the bytes
      return bytes;
    } catch (e) {
      // Handle errors in conversion
      print("Error while converting string to image: $e");
      return null;  // Show a placeholder if error occurs
    }
  }
}