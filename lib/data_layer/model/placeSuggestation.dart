
class PlaceSuggestation{
  late String placeId;
  late String descreption;

  PlaceSuggestation.fromJson(Map<String,dynamic> json){
    placeId=json['place_id'];
    descreption=json['description'];
  }
}