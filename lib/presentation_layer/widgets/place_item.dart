import 'package:flutter/material.dart';
import 'package:flutter_maps_firbase_omar/constents/my_colors.dart';
import 'package:flutter_maps_firbase_omar/data_layer/model/placeSuggestation.dart';

class PlaceItem extends StatelessWidget {
  final PlaceSuggestation suggestation;
  const PlaceItem({Key? key,required this.suggestation}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var subTitle=suggestation.descreption.replaceAll(suggestation.descreption.split(',')[0], '');
    return Container(
      width: double.infinity,
      margin: EdgeInsetsDirectional.fromSTEB(8, 8, 8, 8),
      padding: EdgeInsetsDirectional.all(4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          ListTile(
            leading: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: MyColors.lightBlue,
              ),
              child: Icon(Icons.place,color: MyColors.blue,),
            ),
            title: RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: '${suggestation.descreption.split(',')[0]}\n',
                    style: TextStyle(color: Colors.black,fontSize: 18,fontWeight: FontWeight.bold),
                  ),
                  TextSpan(
                    text: subTitle.substring(2),
                    style: TextStyle(color: Colors.black,fontSize: 16,),
                  ),
                ]
              ),
            ),
          ),
        ],
      ),

    );
  }
}
