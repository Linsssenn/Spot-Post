import 'package:flutter/material.dart';

import '../widgets/locations/locations_card.dart';
import '../widgets/ui_elements/logout_list_tile.dart';
import 'package:scoped_model/scoped_model.dart';
import '../scoped-models/main_model.dart';


class MainLocationPage extends StatefulWidget {
  final MainModel model;
  MainLocationPage(this.model);
  @override
  _MainLocationPageState createState() => _MainLocationPageState();
}

class _MainLocationPageState extends State<MainLocationPage> {

  @override
  initState(){
    // When locations page is loaded automatically get data from the server
    widget.model.fetchLocations();
    super.initState();
  }
  
  Widget build(BuildContext context) {
    return Scaffold(
      drawer:_buildSideDrawer(context) ,
      // LocationManager -> Locations
      // Renders a List of Location Card
      body:ScopedModelDescendant(builder: (BuildContext context, Widget child, MainModel model){
      return RefreshIndicator(child: CustomScrollView(
        slivers: <Widget>[
          appBar(),
          _buildLocationsList(),
        ],
      ), onRefresh: () => model.fetchLocations());
      }),
    );
  }

  //appbar
  Widget appBar() => SliverAppBar(
    backgroundColor: Theme.of(context).scaffoldBackgroundColor,
    pinned: true,
    expandedHeight: 130.0,
    flexibleSpace: FlexibleSpaceBar(
    centerTitle: true,
    title: Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: <Widget>[
        Container(
          margin: EdgeInsets.fromLTRB(10, 40, 0, 0),
          child:  Text('Spot Post', style: TextStyle(fontWeight: FontWeight.w500)),
        ),
        Container(
          margin: EdgeInsets.fromLTRB(0, 35, 0, 0),
          child:ScopedModelDescendant<MainModel>(builder: (BuildContext context, Widget child, MainModel model){
          return IconButton(
            icon: Icon(model.displayFavoritesOnly ? Icons.favorite : Icons.favorite_border),
            onPressed: (){
               model.toggleDisplayMode();
            },
          );
          })
        )
      ],
    ),
  ),
);

  


  Widget _buildSideDrawer(BuildContext context){
    return Drawer(child: Column(
        children: <Widget>[
          AppBar( 
            // set to false to hide the hamburger button
            automaticallyImplyLeading: false,
            title: Text('Choose', style: TextStyle(color: Theme.of(context).accentColor),),),
          ListTile(
            leading: Icon(Icons.edit),
            title: Text('Manage Locations'),
            onTap: (){
              Navigator.pushReplacementNamed(context, '/admin'
              );
            },
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.person),
            title: Text('About'),
            onTap: (){
              Navigator.pushNamed(context, '/about'
              );
            },
          ),
           Divider(),
          LogoutListTile()
        ],
      )
    );
  }

  // Loading
  Widget _buildLocationsList(){
    return ScopedModelDescendant(builder: (BuildContext context, Widget child, MainModel model){
      Widget content = SliverToBoxAdapter(
        child:  Center(child: Text('No Locations Found!')),
      );
      if(model.displayedLocations.length > 0 && !model.getIsLoading){
        content = LocationsCard();
      }else if(model.getIsLoading){
        content = SliverToBoxAdapter( 
          child: Center(child:CircularProgressIndicator(
            valueColor: new AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor),
          ))
        );
      }

      return content;
      // Lets you refresh the page
      // return RefreshIndicator(onRefresh: model.fetchLocations,child: content);
    },);
  }
}