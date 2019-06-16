import 'package:flutter/material.dart';
import 'dart:async';
import 'package:map_view/map_view.dart';
// Models
import '../models/location.dart';
import 'package:scoped_model/scoped_model.dart';
import '../widgets/locations/location_fab.dart';
import '../scoped-models/main_model.dart';
class LocationPage extends StatelessWidget {
  // // Constructor
  final LocationMod location;
  LocationPage({Key key, @required this.location});
  var top = 0.0;
  void _showMap(){
    final List<Marker> markers = <Marker>[
      Marker('position', 'Position', location.location.latitude, location.location.longitude),
      ];
    final cameraPosition = CameraPosition(
      Location(location.location.latitude, location.location.longitude, ), 14.0);
    final mapView = MapView();
    mapView.show(
      MapOptions(
        initialCameraPosition: cameraPosition,
        mapViewType: MapViewType.normal, title: 'Map Location'),
        toolbarActions: [ToolbarAction('Close', 1),
      ]);
    mapView.onToolbarAction.listen((int id) {
      if(id == 1){
        mapView.dismiss();
      }
    });
    mapView.onMapReady.listen((_){
      mapView.setMarkers(markers);
    });
  }

  @override
  Widget build(BuildContext context) {
        return ScopedModelDescendant<MainModel>(builder: (BuildContext context, Widget child, MainModel model){
          print("model.getUser ${model.getUser.id}");
          print("location.userId ${location.userId}");
    return WillPopScope(onWillPop: (){
      // adds a reaction if device BackButton is pressed
      
      print('Device BackButton / Back Button pressed!');
      Navigator.pop(context, false);
      return Future.value(false);
    },
    child: Scaffold(
        // appBar: AppBar(
        //   title: Text(location.title),
        // ),
        body: CustomScrollView(slivers: <Widget>[
          SliverAppBar(
            expandedHeight: 256.0,
            pinned: true,
            flexibleSpace: LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints){
                 top = constraints.biggest.height;
                return FlexibleSpaceBar(
              title: Text(top <= 80 ? location.title : "", style: TextStyle(
                color: Theme.of(context).accentColor
              ),),
                background: Hero(
                tag: location.id,
                child: FadeInImage(
                image: NetworkImage(location.image),
                width: 600, 
                height: 240,
                fit: BoxFit.cover,
                placeholder: AssetImage('assets/img-placeholder.png'),
              ),
            ),
            );
              },
            ),
          ),
          SliverList(
            delegate: SliverChildListDelegate([
              Container(
                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 32),
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Container(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Text(
                              location.title,
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25),
                            ),
                          ),
                        
                          _buildAdressLocation(location: location, model: model),
                          Text(
                          location.userEmail,
                            style: TextStyle(color: Colors.grey[500]),
                          )
                        ],
                      ),
                    )
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 32, vertical: 20),
                child: Text("${location.description}"),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 32),
                // child:
                // RaisedButton(
                //   color: Theme.of(context).primaryColor,
                //   textColor: Colors.white,
                //   child: Text('ALERT'),
                //   onPressed: () => _showWarningDialog(context)
                // ),
              ),
          ]),)
        ],),
        floatingActionButton: LocationFab(location, _showMap),
      ),
    );
     });
  }


  Widget _buildAdressLocation({LocationMod location, MainModel model}){
   if(model.getUser.id == location.userId || location.locationVisible){
    return Padding(
      padding: EdgeInsets.only(bottom: 10),
        child:GestureDetector(
          onTap: _showMap,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Text(
                    location.location.location,
                    style: TextStyle(color: Colors.grey[800]),
                  ),
                  Text(
                    location.location.address,
                    style: TextStyle(color: Colors.grey[800]),
                  ),
                  model.getUser.id == location.userId &&  !location.locationVisible ? 
                  Row(children: <Widget>[
                       Text("Location is hidden", style: TextStyle(color: Colors.grey[800])),
                      Icon(Icons.lock,size: 15,)
                  ],) : Container()
              ],
            )
          )
      );
   }else if(!location.locationVisible){
     return Padding(
       padding: EdgeInsets.only(bottom: 10),
        child:Row(

          children: <Widget>[
            Text("Location is hidden", style: TextStyle(color: Colors.grey[800])),
            Icon(Icons.lock,size: 15,)
          ],
        ),
     );
   }
  }

  //  _showWarningDialog(BuildContext context){
  //   showDialog(
  //     barrierDismissible: false,
  //     context: context,
  //     builder: (BuildContext context) {
  //       return AlertDialog(
  //         title: Text('Are you Sure'),
  //         content: Text('This Action Cannot be Undone'),
  //         actions: <Widget>[
  //           FlatButton(child: Text('DISCARD'), onPressed: (){
  //              Navigator.pop(context);
  //           },),
  //           FlatButton(child: Text('CONTINUE'), onPressed: (){
  //             // 1st delete the Dialog then delete the item
  //             Navigator.pop(context);
  //             Navigator.pop(context, true);
  //           },)
  //         ],
  //       );
  //     }
  //   );
  // }


}