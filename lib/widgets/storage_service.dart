import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';
import '../constants.dart';
import 'package:uuid/uuid.dart';

class StorageService {
  Future<File> _compressedImage(String imageId, File image) async {
    // get temporary directory path with path provider package. it is a local instance on the users device
    final tempDir = await getTemporaryDirectory();
    final path = tempDir.path;
    File compressedImageFile = await FlutterImageCompress.compressAndGetFile(
      image.absolute.path,
      '$path/img_$imageId.jpg',
      quality: 70,
    );
    return compressedImageFile;
  }

  // downloaded url
  Future<String> _uploadImage(String path, String imageId, File image) async {
    StorageUploadTask uploadTask = storageRef.child(path).putFile(image);
    StorageTaskSnapshot storageSnap = await uploadTask.onComplete;
    String downloadUrl = await storageSnap.ref.getDownloadURL();
    return downloadUrl;
  }

  // upload chat image method for chat profile picture
  Future<String> uploadChatImage(String url, File imageFile) async {
    // ensure that the image id for the images is always different/unique
    String imageId = Uuid().v4();
    File image = await _compressedImage(imageId, imageFile);

    // for updating profile imags
    if (url != null) {
      // extract id from image url
      RegExp exp = RegExp(r'chat_(.*).jpg');
      imageId = exp.firstMatch(url)[1];
    }

    String downloadUrl =
        await _uploadImage('images/chats/chat_$imageId.jpg', imageId, image);

    return downloadUrl;
  }

  // Message Image
  Future<String> uploadMessageImage(File imageFile) async {
    String imageId = Uuid().v4();
    File image = await _compressedImage(imageId, imageFile);
    String downloadUrl = await _uploadImage(
        'images/messages/messaget_$imageId.jpg', imageId, image);

    return downloadUrl;
  }
}
