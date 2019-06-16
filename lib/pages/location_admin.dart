import 'package:flutter/material.dart';

import './location_create_edit.dart';
import './location_list.dart';
import '../scoped-models/main_model.dart';

import '../widgets/ui_elements/logout_list_tile.dart';


class LocationsAdmin extends StatefulWidget {
  @override
  _LocationsAdminState createState() => _LocationsAdminState();
   final MainModel model;
  LocationsAdmin(this.model);
}

class _LocationsAdminState extends State<LocationsAdmin> {
  
   int _currentIndex = 0;
void onTabTapped(int index) {
   setState(() {
     _currentIndex = index;
   });
 }


  @override
  Widget build(BuildContext context) {
    // Media Queries
    final double deviceWidth = MediaQuery.of(context).size.width;
    print(deviceWidth);
    return DefaultTabController(
      length: 2 ,
      child: WillPopScope(child: Scaffold(
      drawer: Drawer(
        child: Column(
          children: <Widget>[
            AppBar(

              automaticallyImplyLeading: false,
              title: Text('Choose', style: TextStyle(color: Theme.of(context).accentColor),),
            ),
            ListTile(
              leading: Icon(Icons.location_on),
              title: Text('All Locations'),
              onTap: (){
                Navigator.pushReplacementNamed(context, '/');
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
        ),
      ),
      appBar: AppBar(
        title: Text('Manage Locations'),
        backgroundColor: Theme.of(context).accentColor,
        // bottom: TabBar(tabs: <Widget>[
        //   Tab(
        //     icon:  Icon(Icons.add_location),
        //     text: 'Add Locations',),
        //   Tab(
        //     icon: Icon(Icons.list),
        //     text: 'Posted Location',),
        // ],),
      ),
      bottomNavigationBar: BottomNavigationBar(
        onTap: onTabTapped,
        currentIndex: _currentIndex,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.create),
            title: Text('Add Locations'),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            title: Text('My Locations'),
          ),
        ],
      ),

      body: _buildPage(index: _currentIndex),
      // body: TabBarView(
      //   children: <Widget>[
      //     LocationCreateEditPage(),
      //     LocationListPage(model),
      //   ],
      // ),
    ), onWillPop: () => Navigator.pushReplacementNamed(context, '/locations'),),
    );
  }
    Widget _buildPage({int index}) {
    if (index == 0) {
      return LocationCreateEditPage();
    } else if(index == 1) {
      return LocationListPage(widget.model);
    }
  }
}