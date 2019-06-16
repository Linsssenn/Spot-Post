import 'package:flutter/material.dart';
import './price_tag.dart';
// Model
import 'package:scoped_model/scoped_model.dart';
import '../../scoped-models/main_model.dart';
import '../../models/location.dart';

class CardCreator extends StatelessWidget {
  // Key, value
  // Single location with index
  final LocationMod location;
  
  CardCreator({Key key, @required this.location});

  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;

    print('deviceWidth ${deviceSize}');
      return Card(
        clipBehavior: Clip.antiAlias,
        elevation: 3.0,
        margin: EdgeInsets.all(20.0),
      child: Stack(
        children: <Widget>[
          Hero(
            tag: location.id,
            child:FadeInImage(
            image: NetworkImage(location.image),
            height: deviceSize.height,
            width: deviceSize.width,
            fit: BoxFit.cover,
            placeholder: AssetImage('assets/img-placeholder.png'),
          )),
          Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
                location.title,
                overflow: TextOverflow.ellipsis,
                 softWrap: true,
                style: TextStyle(
                  color: Theme.of(context).accentColor,
                  fontSize: deviceSize.width > 500 ? 28.0 : 18.0,
                  fontWeight: FontWeight.bold
                ),
              ),
            ),
             Positioned(
              bottom: 0.0,
              left: 0.0,
              right: 0.0,
              height: 60.0,
              child: Container(
                width: double.infinity,
                color: Theme.of(context).primaryColor,
                child: cardBottom(context, location),
              )
            ),
        ],
      ),
    );
  }
   Widget cardBottom(BuildContext context, LocationMod location) { 
      final deviceWidth = MediaQuery.of(context).size.width;
     return ScopedModelDescendant<MainModel>(builder: (BuildContext context, Widget child, MainModel model){ 
       return Padding(
        padding: const EdgeInsets.all(5.0),
        child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          // Re run builder from notifyListeners from model.togglelocationFavoriteStatus();
          IconButton(
            icon: Icon(location.isFavorite ? Icons.favorite : Icons.favorite_border),
            iconSize: 25.0,
            color: Theme.of(context).accentColor,
            onPressed: (){
               model.selectedLocation(location.id);
                  model.toggleLocationFavoriteStatus().then((_){
                    model.selectedLocation(null);
                  });
            },
          ),
          SizedBox(width: 10.0,),
          Flexible(
            child: Container(
               padding: new EdgeInsets.only(right: 10),
            //  constraints: BoxConstraints(maxWidth: deviceWidth < 500 ? 100 : 200),
            margin: EdgeInsets.symmetric(horizontal: 10),
            child:Text(location.location.location, textAlign: TextAlign.center,style: TextStyle(color: Theme.of(context).accentColor),overflow: TextOverflow.ellipsis,
                  softWrap: true,),
          ),
          ),
          FittedBox(
            child: ButtonTheme(
              minWidth: 100,
              height: 35,
              child: RaisedButton(
                // Pass data and navigate to new Screen
                // View Single location
                // Future == Promise
                onPressed: (){
                  model.selectedLocation(location.id);
                  Navigator.pushNamed<bool>(
                  context, '/location/' + location.id 
                  ).then((_) => model.selectedLocation(null));
                }, 
                child: Text(
                  "INFO",
                  textAlign: TextAlign.left,
                  style: TextStyle(color: Theme.of(context).primaryColor, fontSize: 16.0, letterSpacing: 1.5),
                ),
                shape: new RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(50.0),
                ),
                color:Theme.of(context).accentColor,
              ),
            )
          ),
          SizedBox(width: 10.0,),
        ],
      ),
    );
  });
}
}