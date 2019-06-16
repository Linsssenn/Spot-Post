import 'package:flutter/material.dart';
import './card_creator.dart';
import 'package:scoped_model/scoped_model.dart';
import '../../models/location.dart';
import '../../scoped-models/main_model.dart';

class LocationsCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
     print('[Locations Widget] build()');
    return ScopedModelDescendant<MainModel>(builder: (BuildContext context, Widget child, MainModel model) {
      // Executes the getter function to get all Locations
      return _buildLocationList(model.displayedLocations);
    },); 
  }

  Widget _buildLocationList(List<LocationMod> locations){
     Size deviceSize;
    //  Widget locationCards;
     return SliverList(
       delegate:  SliverChildBuilderDelegate((BuildContext context, int index) {
         deviceSize = MediaQuery.of(context).size;
        print(deviceSize);
          if(locations.length > 0){
            return Container(height: deviceSize.width > 500.0 ? deviceSize.height : deviceSize.height / 2,
            decoration: ShapeDecoration(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0))),
              child: CardCreator(location: locations[index]),
            );
          }else{
            return Container();
          }
       },
       childCount:locations.length 
     ));
    //  if(locations.length > 0){
        //  ListView.builder for optimization add on Scroll
         // itemBuilder only called for the children that are visible
         // Executes the CardCreator based on locations lenght
        //  Build Multiple locations
      //   locationCards = ListView.builder(
      //   itemBuilder: (BuildContext contex, int index) => CardCreator(location: locations[index]), //_buildlocationItem, //Creates a Card
      //   itemCount: locations.length,
      // );
     
    // }else{
    //    locationCards = Container();
    // }
    // return Container(child: locationCards);
  }

} // Class