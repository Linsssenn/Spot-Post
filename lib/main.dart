import 'package:flutter/material.dart';
import 'package:map_view/map_view.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'pages/main_locations.dart';
import 'pages/location_admin.dart';
import './pages/location_page.dart';
import 'pages/auth.dart';
import './pages/about.dart';
import './widgets/helpers/custom_route.dart';
// Models
import 'package:scoped_model/scoped_model.dart';
import './models/location.dart';
import './scoped-models/main_model.dart';
import './shared/global_config.dart';

import './widgets/helpers/theme_data.dart';

void main(){
  MapView.setApiKey(apiKey);
  runApp(MyApp());
  
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final MainModel _model = MainModel();
  bool _isAuthenticated = false;
  final _platformChannel = MethodChannel('flutter-course.com/battery');

  Future<Null> _getBatteryLevel() async {
     String batteryLevel;
    try {
      final int result = await _platformChannel.invokeMethod('getBatteryLevel');
      batteryLevel = 'Battery level is $result %.';
    } catch (error) {
      batteryLevel ='Failed to get battery level';
    }
    print(batteryLevel);
  }

  @override
  void initState() {
    // TODO: implement initState
    // When the class iniate runs the method 
    // Checks if prefs is created
    _model.autoAuthenticate();
    _model.userSubject.listen((bool isAuthenticated){
      setState(() {
       _isAuthenticated = isAuthenticated;
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    print('building main page');
    print('_isAuthenticated status: ${!_isAuthenticated}');
    return ScopedModel<MainModel>(
      // PassDown LocationsModel to all child widgets
      model: _model,
      child: MaterialApp(
      theme: themeData,
      // home: AuthPage(),
      routes: {
        '/': (BuildContext context) {
          // Check if authenticated or not
          return !_isAuthenticated ? AuthPage() : MainLocationPage(_model);
          },
        '/locations': (BuildContext context) => MainLocationPage(_model),
        '/about' :  (BuildContext context)  {return About();},
        '/admin':  (BuildContext context) {
          return !_isAuthenticated ? AuthPage() : LocationsAdmin(_model);
        },
      },
      onGenerateRoute: (RouteSettings settings) {
        // Checks if authenticated
        if(!_isAuthenticated){
          // CustomRoute Animation
          return CustomRoute<bool>(
            builder: (BuildContext context) => AuthPage()
          );
        }
        final List<String> pathElements = settings.name.split('/'); // 'Location/1' = 'Location' '1'
        // #1 check if 1st element has /
        if(pathElements[0] != ''){
          return null;
        }
        // #2 check if 2nd Element has Location
        if(pathElements[1] == 'location'){
          final String locationId = pathElements[2];
          final LocationMod location = _model.allLocations.firstWhere((LocationMod location) {
            return location.id == locationId;
          });
          return MaterialPageRoute<bool>(
            builder: (BuildContext context) => 
            // Opens single location page base on index
             !_isAuthenticated ? AuthPage() : LocationPage(location: location),
          );
        }
        return null;
      },
      // Redirect to this route if route does not exist
      onUnknownRoute: (RouteSettings settings){
        return MaterialPageRoute(
          builder:  (BuildContext context) => MainLocationPage(_model)
        );
      },
    ) ,);
  }
  
}