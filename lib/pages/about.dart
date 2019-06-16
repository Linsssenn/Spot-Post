import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class About extends StatelessWidget {
    
  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;
    return Scaffold(
      body: Stack(
        children: <Widget>[
         
          _buildCoverImage(screenSize),
          SafeArea(
            child: SingleChildScrollView(
              child: Column(
                children: <Widget>[
                   AppBar(
                     iconTheme: IconThemeData(
                      color: Colors.white, //change your color here
                    ),
                     title: Text("ABOUT", style: TextStyle(color: Colors.white),), backgroundColor: Colors.transparent, elevation: 0.0,
                    ),
                  SizedBox(height: screenSize.height / 6.0),
                  _buildProfileImage(),
                   SizedBox(height: 15.0),
                  _buildFullName(context),
                  _buildStatus(context),
                   SizedBox(height: 8.0),
                  _buildBio(context),
                   SizedBox(height: 8.0),
                  _buildSeparator(screenSize),
                  SizedBox(height: 20.0),
                  ButtonTheme(
                minWidth: screenSize.width / 1.2,
                height: 50,
                buttonColor: Theme.of(context).primaryColor,
                child:RaisedButton(
                  child: Text("SEND A MESSAGE", style: TextStyle(color: Colors.white,)),
                  shape: new RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(50.0),
                  ),
                  
                  elevation: 2.0,
                      onPressed: () async {
                final url = 'mailto:${_email}';
                if(await canLaunch(url)){
                  await launch(url);
                }else{
                  throw 'Could not Launch';
                }
              },
                    ),
                  ),
                   SizedBox(height: 10.0),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  final String _fullName = "Linssen Diocares III";
  final String _status = "Software Developer";
  final String _bio =
      "\"Hi, I'm Linssen! I am a student at Cavite State University Silang-Campus, I'm a web designer and developer with a great passion for building beautiful new things from scratch. I am also a follower of Christ who worship the Father our Almighty God\"";
  final String _email = "vhynlinssen@gmail.com";


  Widget _buildCoverImage(Size screenSize) {
    return ClipPath(
      clipper: Mclipper(),
      child: Container(
        decoration: BoxDecoration( boxShadow: [
          BoxShadow(
          color: Colors.black45,
          offset: Offset(0.0, 10.0),
          blurRadius: 10.0)
        ],),
        child: Container(
        height: screenSize.height / 2.3,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/background2.png'),
            fit: BoxFit.cover,
            ),
            boxShadow: [
          BoxShadow(
          color: Colors.black45,
          offset: Offset(0.0, 10.0),
          blurRadius: 10.0)
        ]
          ),
        ),
      )
      
    );
  }

   Widget _buildProfileImage() {
    return Center(
      child: Container(
        width: 200.0,
        height: 200.0,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/15871560_1390614220971620_3677871838608923021_n.jpg'),
            fit: BoxFit.cover,
          ),
          borderRadius: BorderRadius.circular(140.0),
          color: Colors.white,
          border: Border.all(
            color: Colors.white,
            width: 10.0,
          ),
          boxShadow: [
            BoxShadow(
                color: Colors.black26,
                offset: Offset(0.0, 10.0),
                blurRadius: 7.0)
          ]
        ),
      ),
    );
  }

  Widget _buildFullName(BuildContext context) {
    TextStyle _nameTextStyle = TextStyle(

      color: Theme.of(context).primaryColor,
      fontSize: 28.0,
      fontWeight: FontWeight.w700,
    );

    return Text(
      _fullName,
      style: _nameTextStyle,
    );
  }

  Widget _buildStatus(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 4.0, horizontal: 6.0),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: BorderRadius.circular(4.0),
      ),
      child: Text(
        _status,
        style: TextStyle(
          fontFamily: 'Spectral',
          color: Colors.black,
          fontSize: 20.0,
          fontWeight: FontWeight.w300,
        ),
      ),
    );
  }

   Widget _buildBio(BuildContext context) {
    TextStyle bioTextStyle = TextStyle(
      fontFamily: 'Spectral',
      fontWeight: FontWeight.w400,//try changing weight to w500 if not thin
      fontStyle: FontStyle.italic,
      color: Color(0xFF799497),
      fontSize: 16.0,
    );

    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      padding: EdgeInsets.all(8.0),
      child: Text(
        _bio,
        textAlign: TextAlign.center,
        style: bioTextStyle,
      ),
    );
  }

  Widget _buildSeparator(Size screenSize) {
    return Container(
      width: screenSize.width / 1.6,
      height: 2.0,
      color: Colors.black54,
      margin: EdgeInsets.only(top: 4.0),
    );
  }




}

class Mclipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = new Path();
    path.lineTo(0.0, size.height - 40.0);

    var controlPoint = Offset(size.width / 4, size.height);
    var endpoint = Offset(size.width / 2, size.height);

    path.quadraticBezierTo(
        controlPoint.dx, controlPoint.dy, endpoint.dx, endpoint.dy);

    var controlPoint2 = Offset(size.width * 3 / 4, size.height);
    var endpoint2 = Offset(size.width, size.height - 40.0);

    path.quadraticBezierTo(
        controlPoint2.dx, controlPoint2.dy, endpoint2.dx, endpoint2.dy);

    path.lineTo(size.width, 0.0);

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return true;
  }
}