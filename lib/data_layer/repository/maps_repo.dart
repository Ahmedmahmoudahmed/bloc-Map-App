

import 'package:flutter_maps_firbase_omar/data_layer/model/place.dart';
import 'package:flutter_maps_firbase_omar/data_layer/model/placeSuggestation.dart';
import 'package:flutter_maps_firbase_omar/data_layer/model/place_directions.dart';
import 'package:flutter_maps_firbase_omar/data_layer/web_services/places_web_sevices.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapsRepository{
  final PlacesWebServices placesWebServices;

  MapsRepository(this.placesWebServices);

  Future<List<dynamic>> fetchSuggestation(String place,String sesstionToken)async{
    final suggestions=await placesWebServices.fetchSuggestation(place, sesstionToken);
    return suggestions.map((sug) => PlaceSuggestation.fromJson(sug)).toList();
  }

  Future<Place> getPlaceLocation(String placeId,String sesstionToken)async{
    final placeDetails=await placesWebServices.getPlaceLocation(placeId, sesstionToken);
    var readyPlace=Place.fromJson(placeDetails);
    return readyPlace;
  }

  Future<PlaceDirections> getDirections(LatLng origin,LatLng destination)async{
    final directions=await placesWebServices.getDirections(origin, destination);
    return PlaceDirections.fromJson(directions);
  }

}