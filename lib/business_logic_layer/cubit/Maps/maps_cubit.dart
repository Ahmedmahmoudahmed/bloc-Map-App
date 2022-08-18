import 'package:bloc/bloc.dart';
import 'package:flutter_maps_firbase_omar/data_layer/model/place.dart';
import 'package:flutter_maps_firbase_omar/data_layer/model/placeSuggestation.dart';
import 'package:flutter_maps_firbase_omar/data_layer/model/place_directions.dart';
import 'package:flutter_maps_firbase_omar/data_layer/repository/maps_repo.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:meta/meta.dart';

part 'maps_state.dart';

class MapsCubit extends Cubit<MapsState> {
  final MapsRepository mapsRepository;
  MapsCubit(this.mapsRepository) : super(MapsInitial());

  void emitPlaceSuggestions(String place,String sesstionToken){
    mapsRepository.fetchSuggestation(place, sesstionToken).then((value){
      emit(PlacesLoaded(value));
    });
  }

  void emitPlaceLocation(String placeId,String sesstionToken){
    mapsRepository.getPlaceLocation(placeId, sesstionToken).then((value){
      emit(PlaceLocationLoaded(value));
    });
  }

  void emitPlaceDirections(LatLng origin,LatLng destination){
    mapsRepository.getDirections(origin, destination).then((value){
      emit(DirectionsLoaded(value));
    });
  }

}
