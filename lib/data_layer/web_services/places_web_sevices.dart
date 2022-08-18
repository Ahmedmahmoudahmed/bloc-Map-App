import 'package:dio/dio.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../constents/strings.dart';

class PlacesWebServices{
  late Dio dio;

  PlacesWebServices(){
    BaseOptions options =BaseOptions(
      connectTimeout: 20*1000,
      receiveTimeout: 20*1000,
      receiveDataWhenStatusError: true,
    );
    dio=Dio(options);
  }

  Future<List<dynamic>> fetchSuggestation(String place,String sesstionToken)async{
    try{
      Response response=await dio.get(suggestationBaseUrl,queryParameters: {
        'input':place,
        'types':'address',
        'components':'country:eg',
        'key':googleAPIKey,
        'sessiontoken':sesstionToken,
      });
      return response.data['predictions'];
    }catch(error){
      print(error.toString());
      return [];
    }
  }


  Future<dynamic> getPlaceLocation(String placeId,String sesstionToken)async{
    try{
      Response response=await dio.get(placeLocationBaseUrl,queryParameters: {
        'place_id':placeId,
        'fields':'geometry',
        'key':googleAPIKey,
        'sessiontoken':sesstionToken,
      });
      return response.data;
    }catch(error){
      return Future.error('Place Location Error: ',StackTrace.fromString('this is its trace'));
    }
  }

  //origin equal current location
  Future<dynamic> getDirections(LatLng origin,LatLng destination)async{
    try{
      Response response=await dio.get(directionsBaseUrl,queryParameters: {
        'origin':'${origin.latitude},${origin.longitude}',
        'destination':'${destination.latitude},${destination.longitude}',
        'key':googleAPIKey,
      });
      print(response.data);
      print('kkkk');
      print(response.statusCode);
      return response.data;
    }catch(error){
      return Future.error('Place Location Error: ',StackTrace.fromString('this is its trace'));
    }
  }
}