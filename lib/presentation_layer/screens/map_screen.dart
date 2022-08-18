import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_maps_firbase_omar/business_logic_layer/cubit/Maps/maps_cubit.dart';
import 'package:flutter_maps_firbase_omar/business_logic_layer/cubit/phone_auth/phone_auth_cubit.dart';
import 'package:flutter_maps_firbase_omar/constents/my_colors.dart';
import 'package:flutter_maps_firbase_omar/data_layer/model/place.dart';
import 'package:flutter_maps_firbase_omar/data_layer/model/placeSuggestation.dart';
import 'package:flutter_maps_firbase_omar/data_layer/model/place_directions.dart';
import 'package:flutter_maps_firbase_omar/helper/location_helper.dart';
import 'package:flutter_maps_firbase_omar/presentation_layer/widgets/distance_and_time.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:material_floating_search_bar/material_floating_search_bar.dart';
import 'package:uuid/uuid.dart';

import '../widgets/drawer.dart';
import '../widgets/place_item.dart';



class MapScreen extends StatefulWidget {
  const MapScreen({Key? key}) : super(key: key);

  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  PhoneAuthCubit phoneAuthCubit=PhoneAuthCubit();
  FloatingSearchBarController searchBarController=FloatingSearchBarController();
  static Position? position;
  Completer<GoogleMapController>_mapController=Completer();
  static final CameraPosition _myCurrentLocationCameraPosition=CameraPosition(
    bearing: 0.0,
    target: LatLng(position!.latitude,position!.longitude),
    tilt: 0.0,
    zoom: 17,
  );
  List<dynamic> places=[];
  //thisvariables for get place location
  Set<Marker> markers=Set();
  late PlaceSuggestation placeSuggestation;
  late Place selectedPlace;
  late Marker searchedPlaceMarker;
  late Marker currentLocationMarker;
  late CameraPosition goToSearchedForPlaceCamera;
  //this variables for get directions
  PlaceDirections? placeDirections;
  var progressIndicator=false;
  late List<LatLng> polyLinePoints;
  var isSearchedPlaceMarkerClicked=false;
  var isTimeAndDistanceVisible=false;
  late String time;
  late String distanc;


  //methods for get place location
  void buildCameraNewPosition(){
    goToSearchedForPlaceCamera=CameraPosition(
      bearing: 0.0,
      tilt: 0.0,
      target:LatLng(
        selectedPlace.result.geometry.location.lat,
        selectedPlace.result.geometry.location.lng,
      ) ,
      zoom: 13,
    );
  }
  void getSelectedPlaceLocation(){
    final sesstionToken=Uuid().v4();
    BlocProvider.of<MapsCubit>(context).emitPlaceLocation(placeSuggestation.placeId, sesstionToken);
  }
  Widget buildSelectedPlacesLocationBloc(){
    return BlocListener<MapsCubit,MapsState>(
      listener: (context, state){
        if(state is PlaceLocationLoaded){
          selectedPlace=(state).place;
          goToMySearchedForLocation();
          getDirections();
        }
      },
      child: Container(),
    );
  }
  void getDirections(){
    BlocProvider.of<MapsCubit>(context).emitPlaceDirections(
      LatLng(position!.latitude, position!.longitude),
      LatLng(
        selectedPlace.result.geometry.location.lat,
        selectedPlace.result.geometry.location.lng,
      ),
    );
  }
  Future<void> goToMySearchedForLocation()async{
    buildCameraNewPosition();
    final GoogleMapController googleMapController =await _mapController.future;
    googleMapController.animateCamera(CameraUpdate.newCameraPosition(goToSearchedForPlaceCamera));
    buildSearchedPlaceMarker();
  }
  void buildSearchedPlaceMarker(){
    searchedPlaceMarker=Marker(
      position: goToSearchedForPlaceCamera.target,
      markerId: MarkerId('1'),
      onTap:(){
        buildCurrentLocationMarker();
        //show time and distance
        setState(() {
          isSearchedPlaceMarkerClicked=true;
          isTimeAndDistanceVisible=true;

        });
      },
      infoWindow: InfoWindow(
        title: '${placeSuggestation.descreption}',
      ),
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
    );
    addMarkerToMarkersAndUpdateUi(searchedPlaceMarker);
  }
  void buildCurrentLocationMarker(){
    currentLocationMarker=Marker(
      position: LatLng(position!.latitude,position!.longitude),
      markerId: MarkerId('2'),
      onTap: (){},
      infoWindow: InfoWindow(
        title: 'Your Current Location',
      ),
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
    );
    addMarkerToMarkersAndUpdateUi(currentLocationMarker);
  }
  void addMarkerToMarkersAndUpdateUi(Marker marker){
    setState(() {
      markers.add(marker);
    });
  }
  //last of methods get place location

  @override
  initState(){
    super.initState();
    getMyCurrentLocation();
  }
  Future<void> getMyCurrentLocation()async{
    position =await LocationHelper.determineCurrentLocation().whenComplete((){setState(() {});});
    //position=await Geolocator.getLastKnownPosition().whenComplete((){setState(() {});});
  }
  Widget buildMap(){
    return GoogleMap(
      initialCameraPosition: _myCurrentLocationCameraPosition,
      markers: markers,
      polylines: placeDirections!=null
        ? {
            Polyline(
            polylineId: const PolylineId('my_poly_line'),
            color: Colors.black,
            width: 2,
            points: polyLinePoints,
    )
      }
      : {},
      mapType: MapType.normal,
      myLocationEnabled: true,
      zoomControlsEnabled: false,
      myLocationButtonEnabled: false,
      onMapCreated: (GoogleMapController controller){
        _mapController.complete(controller);
      },
    );
  }
  Future<void> _goToMyCurrentLocation()async{
    final GoogleMapController controller=await _mapController.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(_myCurrentLocationCameraPosition));
  }
  Widget buildFloatingSearchBar(){
    final isPortrait=MediaQuery.of(context).orientation==Orientation.portrait;
    return FloatingSearchBar(
      progress: progressIndicator,
      controller: searchBarController,
      hint: 'search aplace',
      hintStyle: TextStyle(fontSize: 18),
      elevation: 6,
      queryStyle: TextStyle(fontSize: 18),
      border: BorderSide(style: BorderStyle.none),
      margins: EdgeInsets.fromLTRB(20, 70, 20, 0),
      padding: EdgeInsets.fromLTRB(2, 0, 2, 0),
      height: 52,
      iconColor: MyColors.blue,
      scrollPadding: const EdgeInsets.only(top: 16,bottom: 56),
      transitionDuration: const Duration(milliseconds: 600),
      transitionCurve: Curves.easeInOut,
      physics: const BouncingScrollPhysics(),
      axisAlignment: isPortrait?0.0:-1,
      openAxisAlignment: 0.0,
      width: isPortrait?600:500,
      debounceDelay: const Duration(milliseconds: 500),
      onQueryChanged: (query){
        getPlacesSuggestion(query);
      },
      onFocusChanged: (_){
        //hide distance and time row
        setState(() {
          isTimeAndDistanceVisible=false;
        });
      },
      transition: CircularFloatingSearchBarTransition(),
      actions: [FloatingSearchBarAction(
        showIfOpened: false,
        child: CircularButton(icon: Icon(Icons.place,color: Colors.black.withOpacity(0.6),),onPressed: (){},),
      )],
      builder: (context,transition){
        return ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              buildSuggestionsBloc(),
              buildSelectedPlacesLocationBloc(),
              buildDirectionsBloc(),
            ],
          ),
        );
      },
    );
  }
  Widget buildDirectionsBloc(){
    return BlocListener<MapsCubit,MapsState>(
      listener: (context,state){
        if(state is DirectionsLoaded){
          placeDirections=(state).placeDirections;
          getPolyLinePoints();
        }
      },
      child: Container(),
    );
  }
  void getPolyLinePoints(){
    polyLinePoints=placeDirections!.polyLinePoints
        .map((e) => LatLng(e.latitude, e.longitude))
        .toList();
  }
  void getPlacesSuggestion(String query){
    final sesstionToken=Uuid().v4();
    BlocProvider.of<MapsCubit>(context).emitPlaceSuggestions(query, sesstionToken);
  }
  Widget buildSuggestionsBloc(){
    return BlocBuilder<MapsCubit,MapsState>(
      builder: (context, state){
        if(state is PlacesLoaded){
          places=(state).places;
          if(places.length!=0){
            return buildPlacesList();
          }else{
            return Container();
          }
        }else{
          return Container();
        }
      },
    );
  }
  Widget buildPlacesList(){
    return ListView.builder(
        itemBuilder: (ctx,index){
          return InkWell(
            onTap: (){
              placeSuggestation=places[index];
              searchBarController.close();
              getSelectedPlaceLocation();
              polyLinePoints.clear();
              removeAllMarkerAndUpdateUi();
              },
            child: PlaceItem(suggestation: places[index]),
          );
        },
      itemCount: places.length,
      shrinkWrap: true,
      physics: ClampingScrollPhysics(),
    );
  }
  void removeAllMarkerAndUpdateUi(){
    setState(() {
      markers.clear();
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: MyDrawer(),
      body: Stack(
        fit: StackFit.expand,
        children: [
          position!=null
              ? buildMap()
              :Center(
                child: Container(
                  child: CircularProgressIndicator(backgroundColor: MyColors.blue,),
                ),
              ),
          buildFloatingSearchBar(),
          isSearchedPlaceMarkerClicked ? DistanceAndTime(isTimeAndDistanceVisible: isTimeAndDistanceVisible,placeDirections: placeDirections,)
              : Container(),
        ],
      ),
      floatingActionButton: Container(
        margin: EdgeInsets.fromLTRB(0, 0, 8, 30),
        child: FloatingActionButton(
          backgroundColor: MyColors.blue,
          onPressed: _goToMyCurrentLocation,
          child: Icon(Icons.place,color: Colors.white,),
        ),
      ),
    );
  }
}


/*
body: Column(
        children: [
          Center(
            child: Container(
              padding: EdgeInsets.all(20),
              child: BlocProvider<PhoneAuthCubit>(
                create: (context)=>phoneAuthCubit,
                child: ElevatedButton(
                  onPressed: ()async{
                    await phoneAuthCubit.logOut();
                    Navigator.of(context).pushReplacementNamed(loginScreen);
                  },
                  child:Text('logOut',style: TextStyle(color: Colors.white,fontSize: 16),),
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size(110,50),
                    primary: Colors.black,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
 */
