import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';

import 'dart:io';

import '../pages/main_locations.dart';

import '../widgets/form_inputs/location.dart';
import '../widgets/form_inputs/image.dart';

import '../widgets/helpers/ensure_visible.dart';
import '../models/location.dart';
import '../models/location_data.dart';

import '../scoped-models/main_model.dart';

class LocationCreateEditPage extends StatefulWidget {

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _LocationCreateEditPageState();
  }
}

class _LocationCreateEditPageState extends State<LocationCreateEditPage>{
  // State widget
  final Map<String, dynamic> _formData = {
    'title': null,
    'description': null,
    'image':null,
    'location':null,
  };
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  // a Helper function use to focus on each textFormField
  final _titleTextController = TextEditingController();
  final _descriptionTextController = TextEditingController();
  final _titleFocusNode = FocusNode();
  final _descriptionFocusNode = FocusNode();

  @override
  Widget build(BuildContext context) {  
  // if widget location is null reeturns as a pageContent
  // else return scaffold with pageContent
    return ScopedModelDescendant<MainModel>(builder: (BuildContext context, Widget child, MainModel model){
       final Widget pageContent  = _buildPageContent(context, model.getSelectedLocation);
      // model.getSelectedLocation == get the current Location from the model
      print( model.selectedLocationIndex.toString());
      return model.selectedLocationIndex == -1 ? pageContent 
      : new Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).accentColor,
        title: Text('Edit Location'),
        ),
        body: pageContent,
      );
    });
  } //Widget build

  Widget _buildPageContent(BuildContext context, LocationMod location){
    // Media Queries
    // Gets current width
    
    final double deviceWidth = MediaQuery.of(context).size.width;
    // if devicewidth > 500 targetwidth = 500 else devicewidth * .95
    final double targetWidth = deviceWidth > 500.0 ? 500.0 : deviceWidth * 0.95;
    final double targetPadding = deviceWidth - targetWidth;
    return Material(child: GestureDetector(
    onTap: (){
      // get rid of focus on textformfield if tap 
      FocusScope.of(context).requestFocus(FocusNode());
    }, 
    child: Container(
      margin: EdgeInsets.symmetric(horizontal: 20.0),
        child: ScopedModelDescendant<MainModel>(builder: (BuildContext context, Widget child, MainModel model){ return Form( 
          key: _formKey,
          child: ListView(
          padding: EdgeInsets.symmetric(horizontal: targetPadding / 2),
          children: <Widget>[
            SizedBox(height: 30.0,),
            _buildTitleTextField(location),
            SizedBox(height: 10.0,),
            _buildDescriptionTextField(location),
            SizedBox(height: 10.0,),
            // SizedBox(height: 10.0,),
            LocationInput(_setLocation, location),
            SizedBox(width: 5.0,),
            ImageInput(_setImage, location),
            Container(
              margin: EdgeInsets.symmetric(vertical: 15),
              child: _buildSubmitButton(),
            ),
            SizedBox(height: 10.0,),
          ],
        ),
        onWillPop: (){
          print('Device BackButton / Back Button pressed!');
          model.selectedLocation(null);
          Navigator.pop(context, false);
          return Future.value(false);
        },
      );}),
    ),
  ));
}

// Get the Location Data
void _setLocation(LocationData locData){
  _formData['location'] = locData;
}

// Get Image File and Data
void _setImage(File image){
  print('SetImage Activated');
  _formData['image'] = image;
}

// No need to pass the function from the parent widget(main.dart)
// Access the MainModel
  Widget _buildSubmitButton(){
    return ScopedModelDescendant<MainModel>(builder: (BuildContext context, Widget child, MainModel model){
      
      return model.isLoading ? Center(child: CircularProgressIndicator(valueColor: new AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor),)) : ButtonTheme(
        minWidth: double.infinity,
        height: 40,
        buttonColor: Theme.of(context).primaryColor,
        child: RaisedButton(
        textColor: Theme.of(context).accentColor,
        child: Text('SAVE', style: TextStyle(letterSpacing: 1.5),),
         shape: new RoundedRectangleBorder(borderRadius: BorderRadius.circular(50.0),),
        onPressed: () => _submitForm(model.addLocation, model.updateLocation, model.selectedLocation,model.selectedLocationIndex,  
      )));
    },);
  }

  Widget _buildTitleTextField(LocationMod location){
    // if(location == null && _titleTextController.text.trim() == ''){
    //   _titleTextController.text = '';
    // }else if(location != null && _titleTextController.text.trim() == ''){
    //   _titleTextController.text = location.title;
    // }else if(location != null && _titleTextController.text.trim() != ''){
    //    _titleTextController.text = _titleTextController.text;
    // }else if(location == null && _titleTextController.text.trim() != ''){
    //   _titleTextController.text = _titleTextController.text;
    // }else{
    //   _titleTextController.text = '';
    // }
  return EnsureVisibleWhenFocused(
      focusNode: _titleFocusNode,
      child: TextFormField(
        focusNode: _titleFocusNode,
      // controller: _titleTextController,
      initialValue: location != null ? location.title : "",
    decoration: InputDecoration(
        labelText: 'Location Name',
      ),
    // Check if there is a selected Index
    // initialValue:location == null ? '' : location.title,
      // Validates the input value
      validator: (String value){
        // if(value.trim().length <= 0){
        if(value.isEmpty || value.length < 5){
          return 'Location Name is required and should atleast 5 characters long';
        }
      },
      autofocus: true,
      onSaved: (String value){
        print('Title field save value: $value');
        _formData['title'] = value;
      },
    ));
  }

  Widget _buildDescriptionTextField(LocationMod location){
    // if(location == null && _descriptionTextController.text.trim() == ''){
    //   _descriptionTextController.text = '';
    // }else if(location != null && _descriptionTextController.text.trim() == ''){
    //   _descriptionTextController.text = location.description;
    // }

    return EnsureVisibleWhenFocused(
      focusNode: _descriptionFocusNode,
      child: TextFormField(
         focusNode: _descriptionFocusNode,
      // controller: _descriptionTextController,
      initialValue: location != null ? location.description : "",
      decoration: InputDecoration(
         labelText: 'Description',
      ),
       maxLines: 4,
        // initialValue:location == null ? '' : location.description,
      validator: (String value){
        // if(value.trim().length <= 0){
        if(value.isEmpty || value.length < 5){
          return 'Description is required and should atleast 5 characters long';
        }
      },
      onSaved: (String value){
        print('Description field save value: $value');
        _formData['description'] = value;
      }
    ));
  }


// Submit method
  void _submitForm(Function addLocation, Function updateLocation, Function setSelectedLocation ,[int selectedLocationIndex]){
    // if one validation gets an error it will not submit
    if(!_formKey.currentState.validate() || (_formData['image'] == null && selectedLocationIndex == -1)){
      return;
    }
    // else continue this line of codes
    // Saves the current State based on the Form Widget
    _formKey.currentState.save();
    if(selectedLocationIndex == -1){
       // access the state function using widget
      addLocation(
        // _titleTextController.text,  
        _formData['title'],
        // _descriptionTextController.text, 
        _formData['description'],
        _formData['image'],
        _formData['location'],
      ).then((bool success) {
        if(success){
        Navigator.pushReplacementNamed(context, '/locations')
          .then((_) => setSelectedLocation(null));
        }else{
          showDialog(context: context, builder: (BuildContext context){
            return AlertDialog(
              title: Text('Something went wrong'),
              content: Text('Please Try Again'),
              actions: <Widget>[
                FlatButton(child: Text('Okay'),
                onPressed: () => Navigator.of(context).pop(),
              )],
            );
          });
        }
      });
    }else{
      updateLocation(
        // _titleTextController.text,
        _formData['title'],
        // _descriptionTextController.text,
        _formData['description'],  
        _formData['image'],
        _formData['location'],
     ).then((bool success){
       if(success){
         Navigator.popAndPushNamed(context,  '/locations') .then((_) => setSelectedLocation(null));
        // Navigator.of(context).pop(MaterialPageRoute(
        //   builder: (BuildContext context) {
        //     return LocationCreateEditPage();
        //   }
        // ));
        }else{
          showDialog(context: context, builder: (BuildContext context){
            return AlertDialog(
              title: Text('Something went wrong'),
              content: Text('Please Try Again'),
              actions: <Widget>[
                FlatButton(child: Text('Okay'),
                onPressed: () => Navigator.of(context).pop(),
              )],
            );
          });
        }
     });
    }
     
  }


}
