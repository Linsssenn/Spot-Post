import 'package:flutter/material.dart';
import './location_create_edit.dart';

import 'package:scoped_model/scoped_model.dart';
import '../scoped-models/main_model.dart';

import '../models/location.dart';

class LocationListPage extends StatefulWidget {
    final MainModel model;
  LocationListPage(this.model);
  @override
  _LocationListPageState createState() => _LocationListPageState();
}

class _LocationListPageState extends State<LocationListPage> {
//  final MainModel model = MainModel();
  @override
  void initState() {
    widget.model.fetchLocations(onlyForUser: true);
    // TODO: implement initState
    super.initState();
  } 

  @override
  Widget build(BuildContext context) {
    // print(Locations);
    return ScopedModelDescendant<MainModel>(builder: (BuildContext context, Widget child, MainModel model){
      print('model is loaded$model');
      return model.isLoading ? Center(child: CircularProgressIndicator(valueColor: new AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor),)) : ListView.builder(
        padding: EdgeInsets.all(10),
        itemBuilder: (BuildContext context, int index){
          // Swipe data and remove from view but do not delete the data
          return Dismissible(
            key: Key(model.allLocations[index].title),
            onDismissed: (DismissDirection direction){
              
              if(direction == DismissDirection.endToStart){
                model.selectedLocation(model.allLocations[index].id);
               model.deleteLocation();
                print('Swipte end to Start');
              }else if(direction == DismissDirection.startToEnd){
                print('Swiped start to end');
              }else{
                print('Other Swiping');
              }
            },
            background: Container(color: Colors.red[400],),
            child: Column(children: <Widget>[
              ListTile(
                leading: CircleAvatar(backgroundImage: NetworkImage(model.allLocations[index].image)),
                title: Text(model.allLocations[index].title),
                subtitle: Text('${model.allLocations[index].location.location.toString()}'),
                trailing: _buildEditButton(context, model.allLocations[index], model),
              ),
              Divider(),
            ],
          ),);
        },
        itemCount: model.allLocations.length,
      );
    });
  }

  Widget _buildEditButton(BuildContext context, LocationMod location, MainModel model){
      return Row(
        mainAxisAlignment: MainAxisAlignment.end,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          IconButton(icon:
          Icon(Icons.edit_location), 
          iconSize: 35, 
        onPressed: (){
        model.selectedLocation(location.id);
        Navigator.of(context).push(MaterialPageRoute(
          builder: (BuildContext context){
            return LocationCreateEditPage();
          }
        ),);
      }),
      IconButton(icon:
          Icon(location.locationVisible ? Icons.location_on : Icons.location_off), 
          iconSize: 35, 
          color:location.locationVisible ? Theme.of(context).primaryColor : Colors.red,
        onPressed: (){
           model.selectedLocation(location.id);
                  model.toggleLocationVisibleStatus().then((_){
                    model.selectedLocation(null);
                  });
        // model.selectedLocation(model.allLocations[index].id);
      }),
        ],
      );
  }
}