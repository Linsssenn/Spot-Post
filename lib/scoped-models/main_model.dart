import 'package:scoped_model/scoped_model.dart';
import './locations.dart';
import './user.dart';


class MainModel extends Model with  LocationsModel, UserModel, UtilityModel {}