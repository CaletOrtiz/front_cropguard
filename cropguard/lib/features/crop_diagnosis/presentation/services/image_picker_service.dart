import 'package:image_picker/image_picker.dart';

/// Devuelve [XFile] (compatible con web, Android e iOS).
/// No usar dart:io `File` aquí: en Flutter web lanza
/// "Unsupported operation: _Namespace".
class ImagePickerService {
  final ImagePicker _picker = ImagePicker();

  Future<XFile?> pickImageFromCamera() {
    return _picker.pickImage(source: ImageSource.camera, imageQuality: 85);
  }

  Future<XFile?> pickImageFromGallery() {
    return _picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
  }
}
