import 'package:scoped_model/scoped_model.dart';
import 'package:rxdart/subjects.dart'; 

import '../models/user.dart';
import '../models/auth.dart';
import './locations.dart';
import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

mixin UserModel on LocationsModel{

  Timer _authTimer;
  // Stores locally like a session
  PublishSubject<bool> _userSubject = PublishSubject();
 
 User get getUser {
   return authenticatedUser;
 }

 PublishSubject<bool> get userSubject{
   return _userSubject;
 }

  Future<Map<String, dynamic>> authenticate(String email, String password, [AuthMode mode = AuthMode.Login]) async {
  //  authenticatedUser = User(id: 'qwewqe12', email: email, password: password);
   final Map<String, dynamic> authData = {
      'email':email,
      'password':password,
      'returnSecureToken':true,
    };
     isLoading = true;
     notifyListeners();
    try {
    
    http.Response response;
    if (mode == AuthMode.Login) {
    response = await http.post(
      'https://www.googleapis.com/identitytoolkit/v3/relyingparty/verifyPassword?key=AIzaSyD_9SW4bim5dTM_eojnlXMyyhXezGNxr9w',
      body: json.encode(authData),
      headers: {'Content-Type': 'application/json'},

      );
    }else {
      response = await http.post(
        'https://www.googleapis.com/identitytoolkit/v3/relyingparty/signupNewUser?key=AIzaSyD_9SW4bim5dTM_eojnlXMyyhXezGNxr9w',
        body: json.encode(authData), 
        headers: {'Content-type': 'application/json'}, 
      );
    }

   
    print('response status code ${response.statusCode}');
    final Map<String, dynamic> responseData = json.decode(response.body);
      bool hasError = true;
      String message = 'Something went wrong.';
      
    if(responseData.containsKey('idToken')){
      print('ID Token');
      hasError = false;
      message = 'Authentication succeded';
      authenticatedUser = User(
        id: responseData['localId'], 
        email: email, 
        token: responseData['idToken'],
      );
      print('localId ${responseData['localId']}');
      print('idToken ${responseData['idToken']}');
      print('refreshToken ${responseData['refreshToken']}');
      print('expiresIn ${responseData['expiresIn']}');
       _userSubject.add(true);
      DateTime now = DateTime.now();
      DateTime expiryTime;
      if(responseData.containsKey('expiresIn')){
        setAuthTimeout(int.parse(responseData['expiresIn']));
           expiryTime = now.add(Duration(seconds: int.parse(responseData['expiresIn'])));
      }else{
        setAuthTimeout(1000);
        expiryTime = now.add(Duration(seconds: 1000));
      }
      // Stores the token
     final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('token', responseData['idToken']);
    prefs.setString('userEmail', email);
    prefs.setString('userId', responseData['localId']);
    prefs.setString('expiryTime', expiryTime.toIso8601String());
    print('expiryTime.toIso8601String() ${expiryTime.toIso8601String()}');
    }else if(responseData['error']['message'] == 'EMAIL_NOT_FOUND'){
      message = 'This email was not found.';
    }else if(responseData['error']['message'] == 'EMAIL_EXISTS'){
      message = 'This email aready exists.';
    }else if(responseData['error']['message'] == 'INVALID_PASSWORD'){
      message = 'Invalid Password';
    }
    print(' response.body ${json.decode(response.body)}');
    isLoading = false;
    notifyListeners();
    return {'success': !hasError, 'message': message};
    } catch (error) {
       print('Error cathch $error');
    isLoading = false;
    notifyListeners();
    return {'success': false, 'message': 'An Error Occured'};
    }
  }

  // Retrieves the token
  // Runs when opens the app
  void autoAuthenticate() async{
   
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String token = prefs.getString('token');
    final String expiryTime = prefs.getString('expiryTime');
    if(token != null){
      final DateTime now = DateTime.now();
      final parsedExpiryTime = DateTime.parse(expiryTime);
       print('autoAuthenticate ${parsedExpiryTime}');
      if(parsedExpiryTime.isBefore(now)){
        authenticatedUser = null;
        notifyListeners();
        return;
      }
      final String userEmail = prefs.getString('userEmail');
      final String userId = prefs.getString('userId');
      final tokenLifespan = parsedExpiryTime.difference(now).inSeconds;
      authenticatedUser = User(id: userId, email: userEmail, token: token);
      _userSubject.add(true);
      setAuthTimeout(tokenLifespan);
      notifyListeners();
    }
  }

  void logout() async {
    print('Logout');
    authenticatedUser = null;
    _authTimer.cancel();
    selLocationId = null;
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove('token');
    prefs.remove('userEmail');
    prefs.remove('userId');
     _userSubject.add(false);
  }

  // Automatically Logout
  void setAuthTimeout(int time){
    _authTimer = Timer(Duration(days: time * 10000), (){
      logout();
    });
  }

  // Future<Map <String, dynamic>> signup(String email, String password) async {
  //   isLoading = true;
  //   notifyListeners();
  //   final Map<String, dynamic> authData = {
  //     'email':email,
  //     'password':password,
  //   };
  //   final http.Response response = await http.post('https://www.googleapis.com/identitytoolkit/v3/relyingparty/signupNewUser?key=AIzaSyD_9SW4bim5dTM_eojnlXMyyhXezGNxr9w',body: json.encode(authData), headers: {'Content-type': 'application/json'} );
  //   final Map<String, dynamic> responseData = json.decode(response.body);
  //   bool hasError = true;
  //   String message = 'Something went wrong.';
  //   if(responseData.containsKey('idToken')){
  //     hasError = false;
  //     message = 'Authentication succeded';
  //   }else if(responseData['error']['message'] == 'EMAIL_EXISTS'){
  //     message = 'This email aready exists.';
  //   }
  //   print('Singn up response.body ${json.decode(response.body)}');
  //   isLoading = false;
  //   notifyListeners();
  //   return {'success': !hasError, 'message': message};
    
  // }

}
