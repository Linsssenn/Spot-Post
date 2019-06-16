import 'package:scoped_model/scoped_model.dart';
import 'package:http/http.dart' as http;
// import 'package:mime/mime.dart';
// import 'package:http_parser/http_parser.dart';
// import 'package:firebase_storage/firebase_storage.dart';

import 'dart:convert';
import 'dart:async';
import 'dart:io';

import '../models/location.dart';
import '../models/user.dart';
import '../models/location_data.dart';
import './helper/image_upload.dart';




mixin LocationsModel on Model {
  
  // State || Variables
  List<LocationMod> locations = [];
  User authenticatedUser;
  String selLocationId;
  bool isLoading = false;
  bool _showFavorites = false;

  // GETTER METHODS 
  List<LocationMod> get allLocations {
    return List.from(locations);
  }

  // Gets the lis fo the locations
   List<LocationMod> get displayedLocations {
     if(_showFavorites){
       // returns a filtered list locations that isFavorite = true
       return locations.where(
         (LocationMod location) => location.isFavorite).toList();
     }
    return List.from(locations);

  }

  String get selectedLocationId{
    return selLocationId;
  }

  String get selectedUser{
    return authenticatedUser.id;
  }

  LocationMod get getSelectedLocation {
    // Check if selectedLocation = null
    if(selectedLocationId == null){
      print("getSelectedLocation didnt work");
      return null;
      
    }
    return locations.firstWhere((LocationMod location){
      return location.id == selLocationId;
    });
  }

  bool get displayFavoritesOnly {
    // return locations.contains('wishListUser');
    
    if( locations.contains('wishListUser')){
      _showFavorites = true;
    }
    return _showFavorites;
  }

  int get selectedLocationIndex { 
    // Get the index based on location ID
    return locations.indexWhere((LocationMod location) {
     
        return location.id == selLocationId;
      });
  }



  // Methods

   void selectedLocation(String locationId){
    selLocationId = locationId;
    // Updates the UI based on the State
    if(locationId != null){
      notifyListeners();
    }
    //  notifyListeners();
  }

   Future<Null> toggleLocationFavoriteStatus() async {
    // Get the selected Location favorite status
    final bool isCurrentlyFavorite = getSelectedLocation.isFavorite;
    final bool newFavoriteStatus = !isCurrentlyFavorite;
    dynamic wishListUser = getSelectedLocation.wishListUser;
    final String userID = getSelectedLocation.userId;
    print('newFavoriteStatus $newFavoriteStatus');

    try {
    http.Response response;
    if(newFavoriteStatus){
      print('getSelectedLocation.id ${getSelectedLocation.id}');
    response = await http.post(
        'https://flutter-sample-35082.firebaseio.com/locations/${getSelectedLocation.id}/wishListUser/${authenticatedUser.id}.json?auth=${authenticatedUser.token}', 
        body: json.encode(true)
      );
    }else{
    response = await http.delete(
        'https://flutter-sample-35082.firebaseio.com/locations/${getSelectedLocation.id}/wishListUser/${authenticatedUser.id}.json?auth=${authenticatedUser.token}'
      );
    }
      if (response.statusCode != 200 && response.statusCode != 201 || getSelectedLocation.id == null){
        
      }
        final LocationMod updatedLocation = LocationMod(
      id: getSelectedLocation.id,
      title: getSelectedLocation.title,
      description: getSelectedLocation.description,
      image: getSelectedLocation.image,
      imagePath: getSelectedLocation.imagePath,
      isFavorite: newFavoriteStatus,
      userEmail: getSelectedLocation.userEmail,
      userId: getSelectedLocation.userId,
      location: getSelectedLocation.location,
      locationVisible: getSelectedLocation.locationVisible,
    );
    print('${getSelectedLocation.userEmail}');
    locations[selectedLocationIndex] = updatedLocation;
    
    // Update all scope model listeners
    // Re run builder methods
    } catch (error) {
      print(error);
    }
    selLocationId = null;
    notifyListeners();
    return;
  }

  

  Future<Null> toggleLocationVisibleStatus() async {
    String test = getSelectedLocation.title;
    String id = getSelectedLocation.id;
    dynamic wishListUser = getSelectedLocation.wishListUser;
    final bool isVisible = getSelectedLocation.locationVisible;
    final bool newVisible = !isVisible;
    print("Test ${test}, Id ${id}, Visible ${isVisible}");
   try {
    final Map<String, dynamic> locationData = {
      'title': getSelectedLocation.title,
      'description': getSelectedLocation.description,
      'imagePath':getSelectedLocation.imagePath,
      'imageUrl':getSelectedLocation.image,
      'userEmail': authenticatedUser.email,
      'userId': authenticatedUser.id,
      'isFavorite': getSelectedLocation.isFavorite,
      'loc_location':getSelectedLocation.location.location,
      'loc_lat': getSelectedLocation.location.latitude,
      'loc_lng': getSelectedLocation.location.longitude,
      'loc_address': getSelectedLocation.location.address,
      'wishListUser' : wishListUser != null ? wishListUser : null,
      'locationVisible' : newVisible,
    };
      final http.Response response = await http.put(
        'https://flutter-sample-35082.firebaseio.com/locations/${getSelectedLocation.id}.json?auth=${authenticatedUser.token}', 
        body: json.encode(locationData));
        print('update Response body ${response.body}');
       

      if (response.statusCode != 200 && response.statusCode != 201 || getSelectedLocation.id == null){
            selLocationId = null;
            notifyListeners();
           return;
        }
        final LocationMod updatedLocation = LocationMod(
          id: getSelectedLocation.id,
          title: getSelectedLocation.title, 
          description: getSelectedLocation.description, 
          image: getSelectedLocation.image,
          imagePath: getSelectedLocation.imagePath, 
          userEmail: getSelectedLocation.userEmail,
          userId: getSelectedLocation.userId,
          isFavorite: getSelectedLocation.isFavorite,
          location: getSelectedLocation.location,
          wishListUser : wishListUser != null ? wishListUser : null,
          locationVisible: newVisible,
        );
        locations[selectedLocationIndex] = updatedLocation;
    // Update all scope model listeners
    // Re run builder methods
   } catch (error) {
      print(error);
    }
    selLocationId = null;
    notifyListeners();
    return;
  }

  void toggleDisplayMode(){
    _showFavorites = !_showFavorites;
    // Show the changes on the view
    notifyListeners();
    
  }

 
  // HTTP METHODS
  // dynamic = mix value
  // Retruns a future
  Future<bool> addLocation(String title, String description, File image,  LocationData locData) async {
    isLoading = true;
    notifyListeners(); // updates the ui when something is change
   final uploadData = await ImageUpload.uploadImage(image, title);
   
    if(uploadData == null){
      print('upload failed');
      return false;
    }

    final Map<String, dynamic> locationData = {
      'title': title,
      'description': description,
      'imagePath':uploadData['imagePath'],
      'imageUrl':uploadData['imageUrl'],
      'userEmail': authenticatedUser.email,
      'userId': authenticatedUser.id,
      'loc_location':locData.location,
      'loc_lat': locData.latitude,
      'loc_lng': locData.longitude,
      'loc_address': locData.address,
      'locationVisible': true,

    };
    // Async Await use to get rid .then blocks
    try {
      final http.Response response = await http.post(
        'https://flutter-sample-35082.firebaseio.com/locations.json?auth=${authenticatedUser.token}', body:json.encode(locationData), // Convert Map to JSON
      );
      if(response.statusCode != 200 && response.statusCode != 201){
        isLoading = false;
        notifyListeners();
        return false;
      }
      final Map<String, dynamic> responseData = json.decode(response.body);
        print(responseData);
        final LocationMod newLocation = LocationMod(
          id: responseData['name'],
          title: title, 
          description: description, 
          image:uploadData['imageUrl'],
          imagePath: uploadData['imagePath'], 
          userEmail: authenticatedUser.email, 
          userId: authenticatedUser.id,
          location: locData
        );
        isLoading = false;
        locations.add(newLocation);
        notifyListeners();
        print('new locations $locations');
      return true;
      } catch (error) {
        isLoading = false;
        notifyListeners();
        return false;
      }
  }

  Future<bool> updateLocation(String title, String description, File image, LocationData locData) async {
    isLoading = true;
    notifyListeners();
    String imageUrl = getSelectedLocation.image;
    String imagePath = getSelectedLocation.imagePath;
    dynamic wishListUser = getSelectedLocation.wishListUser;

    if(image != null){
      final uploadData = await ImageUpload.uploadImage(image, title);
  
      if(uploadData == null){
        print('upload failed');
        return false;
      }
        imageUrl = uploadData['imageUrl'];
        imagePath =uploadData['imagePath'];
    }
    print('updateLocation ${getSelectedLocation.isFavorite}');
    final Map<String, dynamic> updateData = {
      'title': title,
      'description': description,
      'imagePath':imagePath ,
      'imageUrl':imageUrl,
      'userEmail': getSelectedLocation.userEmail,
      'userId': getSelectedLocation.userId,
      'isFavorite': getSelectedLocation.isFavorite,
      'loc_location':locData.location,
      'loc_lat': locData.latitude,
      'loc_lng': locData.longitude,
      'loc_address': locData.address,
      'locationVisible': getSelectedLocation.locationVisible,
      'wishListUser': getSelectedLocation.wishListUser
    };

    try {
      final http.Response response = await http.put(
        'https://flutter-sample-35082.firebaseio.com/locations/${getSelectedLocation.id}.json?auth=${authenticatedUser.token}', 
      body: json.encode(updateData));
          print('update Response body ${response.body}');
        final LocationMod updatedLocation = LocationMod(
          id: getSelectedLocation.id,
          title: title, 
          description: description, 
          image: imageUrl,
          imagePath: imagePath, 
          userEmail: getSelectedLocation.userEmail,
          userId: getSelectedLocation.userId,
          isFavorite: getSelectedLocation.isFavorite,
          location: locData,
          wishListUser : wishListUser != null ? wishListUser : null
        );
        print('${getSelectedLocation.userEmail}');
        isLoading = false;
        locations[selectedLocationIndex] = updatedLocation; 
        notifyListeners();
        selLocationId = null;
        return true;
     } catch (error) {
       isLoading = false;
       notifyListeners();
       selLocationId = null;
       return false;
     }
    
  }

  Future<Null> fetchLocations({onlyForUser = false}){
    isLoading = true;
    selLocationId = null;
    notifyListeners();
   return http.get('https://flutter-sample-35082.firebaseio.com/locations.json?auth=${authenticatedUser.token}')
    .then<Null>((http.Response response) {
      final List<LocationMod> fetchLocationList = [];
      final Map<String, dynamic> locationListData = json.decode(response.body);
      print('locationListData ${locationListData}');
      
      if(locationListData == null){
        isLoading = false;
        notifyListeners();
        return;
      }
      locationListData.forEach((String locationId, dynamic  locationData) {
        final Map<String, dynamic> wishListUser = locationData['wishListUser'];
        bool wishUser = false;
        if(wishListUser != null){
          print(wishListUser.length);
          print(wishListUser["${authenticatedUser.id}"].toString());
          // wishUser = wishListUser.containsKey(authenticatedUser.id);
          if(wishListUser.containsKey(authenticatedUser.id)){
            wishUser = true; 
          }else{
            wishUser = false;
          }
        }

        // if(wishUser == false){

        // }
        // if(wishListUser["${authenticatedUser.id}"] != null){
        //   print(wishListUser["${authenticatedUser.id}"].toString());
        // }
        // if(wishListUser.containsKey(locationId)){}
        // print(wishListUser.containsKey(authenticatedUser.id));
        // if(wishListUser.isNotEmpty){
        //   print(wishListUser.length);
        // }else{

        // }
        
        final LocationMod location = LocationMod(
          id: locationId,
          title: locationData['title'],
          description: locationData['description'],
          image: locationData['imageUrl'],
          imagePath: locationData['imagePath'],
          userEmail: locationData['userEmail'],
          userId: locationData['userId'],
          location: LocationData(
            address: locationData['loc_address'],
            latitude: locationData['loc_lat'],
            longitude: locationData['loc_lng'],
            location: locationData['loc_location']
          ),
          isFavorite: wishUser ? true : false,
          locationVisible: locationData['locationVisible'],
          wishListUser: wishListUser
          // locationsData['wishListUser'] as Map<String, dynamic>).containsKey(authenticatedUser.id
        );
      fetchLocationList.add(location);
      });
      notifyListeners();
     print('locationListData ${locationListData}');
      // Updates UI
      // Only fetch user's posted location
      locations = onlyForUser ? fetchLocationList.where((LocationMod location){
        return location.userEmail == authenticatedUser.email;
      }).toList() : fetchLocationList;
       isLoading = false;
      notifyListeners();
    }).
    catchError((error) {
      print('Error cathch $error');
       isLoading = false;
       notifyListeners();
       return;
    });
  }

  

  
  Future<bool> deleteLocation() {
    isLoading = true;
    final deletedLocationId = getSelectedLocation.id;
      final int selectedLocationIndex = locations.indexWhere((LocationMod location) {
        return location.id == selLocationId;
      });
      return ImageUpload.deleteFireBaseStorageItem(getSelectedLocation.image).then((String response){
        print('Response $response');
         locations.removeAt(selectedLocationIndex);
         selLocationId = null;
          notifyListeners();
      }).then((_){
        return http.delete('https://flutter-sample-35082.firebaseio.com/locations/$deletedLocationId.json?auth=${authenticatedUser.token}');
      }).then((http.Response response){
        print('HTTP Response $response');
        isLoading = false;
        notifyListeners();
        return true;
      }).catchError((error) {
        isLoading = false;
        notifyListeners();
        return false;
      });
   
  }
 
} // Locations Model


mixin UtilityModel on LocationsModel{
  bool get getIsLoading {
    return isLoading;
  }
}