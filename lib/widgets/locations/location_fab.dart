import 'package:flutter/material.dart';
import '../../models/location.dart';
import 'package:scoped_model/scoped_model.dart';
import '../../scoped-models/main_model.dart';
import 'dart:math' as math;
import 'package:url_launcher/url_launcher.dart';

class LocationFab extends StatefulWidget {
  // Constructor
  final LocationMod location;
  final Function showMap;
  LocationFab(this.location, this.showMap);

  @override
  _LocationFabState createState() => _LocationFabState();
}

class _LocationFabState extends State<LocationFab> with TickerProviderStateMixin {
  AnimationController _controller;
  
  @override
  void initState() {
    // TODO: implement initState
    // Defined Animation Controller
    _controller = AnimationController(
      vsync: this, 
      duration: Duration(milliseconds: 200),
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
  
    return ScopedModelDescendant<MainModel>(builder: (BuildContext context, Widget child, MainModel model){
        // print(model.getSelectedLocation.isFavorite);
      return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Container(
          height: 60.0,
          width: 60.0,
          alignment: FractionalOffset.topCenter,
          child: ScaleTransition(
            scale: CurvedAnimation(
              parent: _controller,
              curve: Interval(0.0, 1.0, curve: Curves.easeOut)
            ),
            child: FloatingActionButton(
              backgroundColor: Theme.of(context).accentColor,
              mini: true,
              heroTag: "contact",
              onPressed: () async {
                final url = 'mailto:${widget.location.userEmail}';
                if(await canLaunch(url)){
                  await launch(url);
                }else{
                  throw 'Could not Launch';
                }
              },
              child: Icon(Icons.mail, color: Theme.of(context).primaryColor,),
            ),
          ),
        ),
        Container(
          height: 60.0,
          width: 60.0,
          alignment: FractionalOffset.topCenter,
          child: ScaleTransition(
            scale: CurvedAnimation(
              parent: _controller,
              curve: Interval(0.0, 1.0, curve: Curves.easeOut)
            ),
            child: _buildLocationFab(model)
          ),
        ),
        Container(
          height: 60.0,
          width: 60.0,
          alignment: FractionalOffset.topCenter,
          child: ScaleTransition(
            scale: CurvedAnimation(
              parent: _controller,
              curve: Interval(0.0, 1.0, curve: Curves.easeOut)
            ),
            child: FloatingActionButton(
              backgroundColor: Colors.white,
              mini: true,
              heroTag: "favorite",
              onPressed: (){
                // model.selectedLocation(widget.location.id);
                  model.toggleLocationFavoriteStatus().then((_){
                     model.selectedLocation(widget.location.id);
                  });
              },
              child: Icon(model.getSelectedLocation.isFavorite ?
                Icons.favorite : Icons.favorite_border, color: Colors.redAccent,),
            ),
          ),
        ),
        Container(
          height: 70.0,
          width: 56.0,
          child: FloatingActionButton(
            backgroundColor: Theme.of(context).primaryColor,
            heroTag: "options",
            onPressed: (){
              if(_controller.isDismissed){
                _controller.forward(); // plays the animation
              }else{
                _controller.reverse();
              }
            },
            child: AnimatedBuilder(

              animation: _controller,
              builder: (BuildContext context, Widget child ){
              return Transform(
                alignment: FractionalOffset.center,
                transform: Matrix4.rotationZ(_controller.value * 0.5 * math.pi),
                child: Icon(_controller.isDismissed ? Icons.more_vert : Icons.close,),);
            },)
            ),
          ),
        ],
      );
     },
    );
  }

  Widget _buildLocationFab(MainModel model){
    if(model.getUser.id == widget.location.userId || widget.location.locationVisible){
    return FloatingActionButton(
      backgroundColor: Theme.of(context).accentColor,
      mini: true,
      heroTag: "showmap",
      onPressed: () {
        widget.showMap();
      },
      child: Icon(Icons.map, color: Theme.of(context).primaryColor,),
    );
    }else if(!widget.location.locationVisible){
      return FloatingActionButton(
      backgroundColor: Theme.of(context).accentColor,
      mini: true,
      heroTag: "showmap",
      onPressed: () => _showWarningDialog(context),
      child: Icon(Icons.lock, color: Theme.of(context).primaryColor,),
    );
    }
  }

    _showWarningDialog(BuildContext context){
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Message'),
          content: Text('Location is Hidden/Private'),
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
}