import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../models/location.dart';
import 'dart:io';

class ImageInput extends StatefulWidget {
  final Function setImage;
  final LocationMod location;

  ImageInput(this.setImage, this.location);

  @override
  _ImageInputState createState() => _ImageInputState();
}

class _ImageInputState extends State<ImageInput> {
  File _imageFile;
  
  @override
  Widget build(BuildContext context) {
    final buttonColor = Theme.of(context).primaryColor;
    Widget previewImage = Text('Please pick an image.');
    if(_imageFile != null ){
      previewImage = Image.file(
          _imageFile, 
          fit: BoxFit.cover, 
          height: 200.0, 
          width: MediaQuery.of(context).size.width,
          alignment: Alignment.topCenter
        );
    }else if(widget.location != null ){
      previewImage = Image.network(
        widget.location.image,
        fit: BoxFit.cover, 
        height: 200.0, 
        width: MediaQuery.of(context).size.width,
        alignment: Alignment.topCenter
      );
    }
    return Column(
      children: <Widget>[
        OutlineButton(
          borderSide: BorderSide(color: buttonColor , width: 2.0),
          onPressed: (){
            _openImagePicker(context);
          },
          child: Row(
            // Centers all content in a row L -> R
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Icon(Icons.camera_alt, color: buttonColor),
              SizedBox(width: 5.0,),
              Text('Add Location Image', style: TextStyle(color: buttonColor),
              ),
            ],
          ),
        ),
        SizedBox(height: 5.0),
        previewImage
      ],
    );
  }

   void _openImagePicker(BuildContext context){
     final buttonColor = Theme.of(context).primaryColor;
    showModalBottomSheet(context: context, builder: (BuildContext context){
      return Container(
        height: 150.0,
        padding: EdgeInsets.all(10.0),
        child: Column(children: <Widget>[
          Text('Pick a Image', style: TextStyle(fontWeight: FontWeight.bold),),
          SizedBox(height: 5.0,),
          FlatButton(
            textColor: buttonColor,
            child: Text('Use Camera'),
            onPressed: (){
              _getImage(context, ImageSource.camera);
            },
          ),
          FlatButton(
            textColor: buttonColor,
            child: Text('Use Gallery'),
            onPressed: (){
               _getImage(context, ImageSource.gallery);
            },
          ),
        ],),
      );
    });
  }

  void _getImage(BuildContext context, ImageSource source){
    ImagePicker.pickImage(source: source, maxWidth: 400.0)
      .then((File image){
        setState(() {
         _imageFile = image; 
        });
        widget.setImage(image);
        Navigator.pop(context);
      });
    } 

}