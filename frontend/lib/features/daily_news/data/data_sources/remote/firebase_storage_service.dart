import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';

class FirebaseStorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<String> uploadImage(File file, String path) async {
    try {
      final ref = _storage.ref().child(path);
      final metadata = SettableMetadata(contentType: 'image/jpeg');
      final uploadTask = ref.putFile(file, metadata);
      final snapshot = await uploadTask;
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      rethrow;
    }
  }
}
