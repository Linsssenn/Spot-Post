
import 'package:mime/mime.dart';
import 'package:firebase_storage/firebase_storage.dart';

import 'dart:async';
import 'dart:io';


class ImageUpload {
  // use Static to access the method to other class
  static Future<Map<String, dynamic>> uploadImage(File image, String title) async{
    final mimeTypeData = lookupMimeType(image.path).split('/'); // image/jpeg
    final splitString = image.path.toString().split('/');
    // if(mimeTypeData[1].toString() != 'image'){
    //   return null;
    // }
    print('${splitString.toString()}');
    print('File Path ${image.path.toString()}');
    final StorageReference firebaseStorageRef = FirebaseStorage.instance.ref().child(title+mimeTypeData[1]);
    final StorageUploadTask task = firebaseStorageRef.putFile(image);
    final url = await (await task.onComplete).ref.getDownloadURL();
    print('Download Url = $url');
    final Map<String, dynamic> imageData = {
      'imagePath': image.path.toString(),
      'imageUrl': url,
    };
    return imageData;
   }

   static Future<String> deleteFireBaseStorageItem(String fileUrl) {

    String filePath = fileUrl.replaceAll(
      new RegExp(r'https://firebasestorage.googleapis.com/v0/b/flutter-sample-35082.appspot.com/o/'), '');

    filePath = filePath.replaceAll(new RegExp(r'%2F'), '/');

    filePath = filePath.replaceAll(new RegExp(r'(\?alt).*'), '');

    StorageReference storageReferance = FirebaseStorage.instance.ref();

    return storageReferance.child(filePath)
      .delete().then((_) {
        return 'Successfully deleted $filePath storage item';
      }).catchError((error){
        return 'An Error Occured in deleting the file';
      });

   }
}