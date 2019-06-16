import 'dart:convert';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:map_view/map_view.dart';
import 'package:location/location.dart' as geoloc;
import 'package:geocoder/geocoder.dart';
import 'package:flutter/services.dart';

import '../helpers/ensure_visible.dart';

import '../../models/location_data.dart';
import '../../models/location.dart';
import '../../shared/global_config.dart';

class LocationInput extends StatefulWidget {
  final Function setLocation;
  final LocationMod location;
  LocationInput(this.setLocation, this.location);
  
  @override
  _LocationInputState createState() => _LocationInputState();
}

class _LocationInputState extends State<LocationInput> {
  //  Uri _staticMapUri;
  final FocusNode _addressInputFocusNode = FocusNode();
  // Controller cannot use initValue
  final TextEditingController _addressInputController = TextEditingController();
  
  LocationData _locationData;
  Map<String, dynamic> _currentLoc;
  
   StreamSubscription<Map<String, double>> _locationSubscription;
   Map<String, double> _startLocation;
  Map<String, double> _currentLocation;

  geoloc.Location _location = new geoloc.Location();
  bool _permission = false;
  String error;

  @override
  void initState() {
    _addressInputFocusNode.addListener(_updateLocation);
    if(widget.location != null){
      print('initState run');
      _addressInputController.text = widget.location.location.location;
      _getStaticMap(address: widget.location.location.location, geocode: false);
    }
     super.initState();
     //initPlatformState();
     _locationSubscription =
        _location.onLocationChanged().listen((Map<String, double> result) {
          if(mounted){
          setState(() {
            _currentLocation = result;
          });
          }
        });
      
   // _getStaticMap();
   
  }

  @override
  void dispose() {
    _addressInputFocusNode.removeListener(_updateLocation);
    super.dispose();
  }

  //  initPlatformState() async {
  //    Map<String, double> location;
  //    try {
  //     _permission = await _location.hasPermission();
  //     location = await _location.getLocation();


  //     error = null;
  //   } on PlatformException catch (e) {
  //     if (e.code == 'PERMISSION_DENIED') {
  //       error = 'Permission denied';
  //     } else if (e.code == 'PERMISSION_DENIED_NEVER_ASK') {
  //       error = 'Permission denied - please ask the user to enable it from the app settings';
  //     }
  //     location = null;
  //   }

  //   // If the widget was removed from the tree while the asynchronous platform
  //   // message was in flight, we want to discard the reply rather than calling
  //   // setState to update our non-existent appearance.
  //   //if (!mounted) return;

  //   setState(() {
  //       _startLocation = location;
  //   });

  //  }



  void _getStaticMap({String address, bool geocode = true, double lat, double lng}) async {
    // if AddressFormField is Empty
    if(address.isEmpty){
      setState(() {
      //  _staticMapUri = null;
      _locationData = null;
      });
      widget.setLocation(null);
      return;
    }
    // Else
    // final Uri uri = Uri.https(
    //   'maps.googleapis.com', 
    //   '/maps/api/geocode/json', 
    //   {'address': address, 'key': 'apiKey'});
    // final http.Response response = await http.get(uri);
    // final decodedResponse = json.decode(response.body);
    // print(decodedResponse);
    // API KEY 'apiKey'

    // From coordinates
    // final coordinates = new Coordinates(1.10, 45.50);
    // addresses = await Geocoder.local.findAddressesFromCoordinates(coordinates);
    // first = addresses.first;
    // print("${first.featureName} : ${first.addressLine}");

    // From a query
     print(geocode);
     print(address);
     if(geocode){
      
      //  Create Location / Default
    final query = address;
    final addresses = await Geocoder.local.findAddressesFromQuery(query);
    final Map<dynamic, dynamic> resultsMap =  addresses.first.toMap();
    print(resultsMap);
    final coords = resultsMap['coordinates'];
     _locationData = LocationData(
       location: address, 
       latitude: coords['latitude'], 
       longitude: coords['longitude'],
       address: resultsMap['addressLine']
      );
    }else if(lat == null && lng == null){
      // Location from Edit
      _locationData = widget.location.location;
    }else{
      // _getUserLocation
      _locationData = LocationData(
        address: address, 
        latitude: lat, 
        longitude: lng,
        location: _addressInputController.text,
        );
    }

    // final StaticMapProvider staticMapViewProvider = StaticMapProvider(apiKey);
    // final Uri staticMapUri = staticMapViewProvider.getStaticUriWithMarkers(
    //   [
    //     Marker('position', 'Position', _locationData.latitude, _locationData.longitude)
    //   ],
    //   center: Location(_locationData.latitude, _locationData.longitude),
    //   width: 500,
    //   height: 300,
    //   maptype: StaticMapViewType.roadmap
    // );
    widget.setLocation(_locationData);
    // if(mounted){
    //    setState(() {
    //  _staticMapUri = staticMapUri;
    // });
    // }
   
  }

  void _updateLocation(){
    if(!_addressInputFocusNode.hasFocus){
      // Get the text of the TextFormField using controller
     
      _getStaticMap(address: _addressInputController.text);
    }
  }

  Future<String> _getAddress(double lat, double lng) async {
    //From coordinates
    final coordinates = new Coordinates(lat, lng);
    final addresses = await Geocoder.local.findAddressesFromCoordinates(coordinates);
   final Map<dynamic, dynamic> resultsMap =  addresses.first.toMap();
   return resultsMap['addressLine'].toString();
  }

  
  void _getUserLocation() async{
    final location = geoloc.Location();
    Map<String, dynamic> getLoc;
      location.onLocationChanged().listen((Map<String, double> result){
        setState(() {
         _currentLoc = result;  
        });
      });
    try {
      _permission = await location.hasPermission();
     getLoc = await location.getLocation();
    } catch (error) { 
      showDialog(context: context, builder: (BuildContext context){
        return AlertDialog(
          title: Text('Could not fetch Location'),
          content: Text('Please Try Again'),
          actions: <Widget>[
            FlatButton(child: Text('Okay'), onPressed: (){
              Navigator.pop(context);
            },)
          ],
        );
      });
      getLoc = null;
    }
   
     print(_currentLoc);
    if(_currentLoc == null){
      setState(() {
        _currentLoc = getLoc;
      });
    }
    if(_currentLoc != null){
    final address = await _getAddress(_currentLoc['latitude'],_currentLoc['longitude']);
    _getStaticMap(address: address ,geocode: false, lat: _currentLoc['latitude'], lng: _currentLoc['longitude']);
    print('_getUserLocation Ends');
    }
  }

   void _showWarningDialog(BuildContext context){
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Location Invalid'),
          content: Text('Please Insert value to the location'),
          actions: <Widget>[
            FlatButton(child: Text('OK'), onPressed: (){
               Navigator.pop(context);
            },),
            // FlatButton(child: Text('CONTINUE'), onPressed: (){
            //   // 1st delete the Dialog then delete the item
            //   Navigator.pop(context);
            //   Navigator.pop(context, true);
            // },)
          ],
        );
      }
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
       TextFormField(
            controller: _addressInputController,
            //  cannot use initValue
            validator: (String value){
              if(_locationData == null || value.isEmpty){
                return 'No valid Location Found';
              }
            },
            decoration: InputDecoration(labelText: 'Location', suffixIcon: IconButton(icon: Icon(Icons.search),
             iconSize: 20,
             onPressed: (){
              _getStaticMap(address: _addressInputController.text);
             
            },)),
            
          ),

        SizedBox(height: 10.0,),
        FlatButton(
          child: Text('Locate User'),
            onPressed: (){
              if(_addressInputController.text != ''){
                _getUserLocation();
              }else{
              _showWarningDialog(context);
              }
            },
        ),
        Card(
          child: _locationData == null ? Container() : Container(
            padding: EdgeInsets.all(5.0),
            alignment: Alignment.center,
            child: Column(
              children: <Widget>[
                SizedBox(height: 10.0,),
                Text(_locationData == null ? '' : _locationData.address),
                Text(_locationData == null ? '' : 'Latitude: ${_locationData.latitude} Longitude: ${_locationData.longitude}'),
              ],
            ),
          ),
        ),
      //  _staticMapUri == null ? Container() : Image.network(_staticMapUri.toString(), ),
      ],
    );
  }
}
