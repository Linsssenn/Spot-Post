import 'package:flutter/material.dart';

import './location_data.dart';

class LocationMod {
  final String id;
  final String title;
  final String description;
  final String image;
  final String imagePath;
  final bool isFavorite;
  final String userEmail;
  final String userId;
  final LocationData location;
  final dynamic wishListUser;
  final bool locationVisible;
  final dynamic favoriteCount;

  // Constructor
  LocationMod({
    this.id,
    @required this.title,
    @required this.description,
    @required this.image,
    @required this.imagePath,
    this.isFavorite = false ,
    @required this.userEmail,
    @required this.userId,
    @required this.location,
    this.wishListUser,
    this.locationVisible = false,
    this.favoriteCount = 0,
    });
    
}