import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';
import '../scoped-models/main_model.dart';
import '../models/auth.dart';
import '../widgets/helpers/accent_colors_override.dart';

class AuthPage extends StatefulWidget {
  @override
  _AuthPageState createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> with TickerProviderStateMixin{
  // State
  // String _emailValue;
  // String _passwordValue;
  // bool _acceptTerms = false;
  
  final Map<String, dynamic> _formData = {
      'email': null,
      'password': null,
    };

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _passwordTextController =TextEditingController();

  AnimationController _controller;
  Animation<Offset> _slideAnimation;

  AuthMode _authMode = AuthMode.Login;

  @override
  void initState() {
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 300),
    );
    _slideAnimation = Tween<Offset>(
      begin: Offset(0.0, -1.5),
      end: Offset.zero
    ).animate(
      CurvedAnimation(
        parent: _controller, 
        curve: Curves.fastOutSlowIn
      ),
    );
    super.initState();
  }

    @override
  Widget build(BuildContext context) {
    // Media Query
    final double deviceWidth = MediaQuery.of(context).size.width;
    print(deviceWidth);
    final double targetWidth = deviceWidth > 500.0 ? deviceWidth * 0.95 : 500.0;
    // if(deviceWidth > 500){
    //   return ... 
    // }
    final ThemeData theme = Theme.of(context);
  return Scaffold(
    body: SafeArea(
        child:Form(
          key: _formKey, 
          child: SingleChildScrollView(
            padding: EdgeInsets.all(25),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: deviceWidth > 500.0 ? 50.0 : 0.0),
              width: targetWidth,
            child: Column(
            children: <Widget>[
            SizedBox(height: 80.0,),
              Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Image.asset('assets/location_pin.png', width: 60.0,),
                  SizedBox(height: 10.0,),
                  Text('SPOT POST'),
                ],
              ),
              SizedBox(height: 100.0),
            _buildEmailTextField(),
              SizedBox(
                height: 10,
              ),
            _buildPasswordTextField(),
            SizedBox(
                height: 10.0,
              ),
            _buildConfirmPasswordTextField(),
            SizedBox(
                height: 10.0,
              ),
              ScopedModelDescendant(builder: (BuildContext context, Widget child, MainModel model){
                  return model.isLoading ? CircularProgressIndicator(valueColor: new AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor),) :ButtonTheme(
                minWidth: double.infinity,
                height: 50,
                buttonColor: Theme.of(context).primaryColor,
                child:RaisedButton(
                  child: Text(_authMode == AuthMode.Login ? 'SIGN IN' : 'SIGN UP', style: TextStyle(color: theme.accentColor,)),
                  shape: new RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(50.0),
                  ),
                  elevation: 0.0,
                      onPressed: () => _submitForm(model.authenticate),
                    ),
                  );
                },
              ),
              SizedBox(
                height: 20.0,
              ),
              Container(
                height: 30.0,
                child:GestureDetector(
                  onTap: (){
                    setState(() {
                    if(_authMode == AuthMode.Login){
                      setState(() {
                       _authMode = AuthMode.Singup; 
                      });
                      _controller.forward();
                    }else{
                      setState(() {
                       _authMode = AuthMode.Login;
                      });
                      // Removes by animating
                      _controller.reverse();
                    }
                  });
                  },
                  child: Text(
                    _authMode == AuthMode.Login ? 'SIGN UP FOR AN ACCOUNT' : 'SIGN IN YOUR ACCOUNT',
                    style: TextStyle(color: Theme.of(context).primaryColor),
                    textAlign: TextAlign.center,
                  ),
                ),
              )
            ],
          ),),)
        ),
      ),
    );
  }

 
  Widget _buildEmailTextField(){
    
    return AccentColorOverride(
      color: Theme.of(context).primaryColor,
      child:TextFormField(
       validator:validateEmail,
      decoration: InputDecoration(
        // filled: true, Remove
        labelText: 'E-mail'
        ),
        keyboardType: TextInputType.emailAddress,
        onSaved: (String value){
          setState(() {
           _formData['email'] = value; 
          });
        },
    ));
  }



  Widget _buildPasswordTextField(){
    return AccentColorOverride(
      color: Theme.of(context).primaryColor,
      child: TextFormField(
      controller: _passwordTextController,
      validator: (String value){
        if(value.isEmpty){
          return 'Please insert a Password';
        }
        else if(value.length < 5){
          return 'Password should be atleast 5 Characters';
        }
      },
      decoration: InputDecoration(
        // filled: true, Remove
          labelText: 'Password',
        ),
        obscureText: true,
       onSaved: (String value){
        setState(() {
         _formData['password'] = value; 
        });
       },
    ));
  }

    Widget _buildConfirmPasswordTextField(){
    return AccentColorOverride(
      color: Theme.of(context).primaryColor,
      child: FadeTransition(
      opacity: CurvedAnimation(
        parent: _controller,
        curve: Curves.easeIn
      ),
      child: SlideTransition(
        position: _slideAnimation,
        child: TextFormField(
          validator: (String value){
            if(_passwordTextController.text != value && _authMode == AuthMode.Singup){
              return 'Passwords do not match';
            }
          },
         decoration: InputDecoration(
            // filled: true, Remove
              labelText: 'Confirm Password',
            ),
            obscureText: true,
     ),)
    ));
  }


  void _submitForm(Function authenticate) async {
    print(_formData);
    if(!_formKey.currentState.validate()){
      return;
    }
    _formKey.currentState.save();
    Map<String, dynamic> successInformation;
    // LOGIN
    // if(_authMode == AuthMode.Login){
    //   successInformation = await login(_formData['email'], _formData['password']);
    // // SIGNUP 
    // } else{
    //   successInformation = await signup(_formData['email'], _formData['password']);
    // }
     successInformation = await authenticate(_formData['email'], _formData['password'], _authMode);
    // SUCCESS
     if(successInformation['success']){
        // Navigator.pushReplacementNamed(context,'/');
    // ERROR
     } else {
       showDialog(
         context: context,
         builder: (BuildContext context) {
         return AlertDialog(
          title: Text(successInformation['message']),
          actions: <Widget>[
            FlatButton(child: Text('OKAY'), onPressed: (){
              Navigator.of(context).pop();
            },)
          ],
          );
       });
     }
  }

  String validateEmail(String value) {
    Pattern pattern =
        r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
    RegExp regex = new RegExp(pattern);
    if (!regex.hasMatch(value))
      return 'Enter Valid Email';
    else
      return null;
  }


}