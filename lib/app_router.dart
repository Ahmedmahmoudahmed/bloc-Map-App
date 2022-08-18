
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_maps_firbase_omar/business_logic_layer/cubit/Maps/maps_cubit.dart';
import 'package:flutter_maps_firbase_omar/business_logic_layer/cubit/phone_auth/phone_auth_cubit.dart';
import 'package:flutter_maps_firbase_omar/data_layer/repository/maps_repo.dart';
import 'package:flutter_maps_firbase_omar/data_layer/web_services/places_web_sevices.dart';
import 'package:flutter_maps_firbase_omar/presentation_layer/screens/login_screen.dart';
import 'package:flutter_maps_firbase_omar/presentation_layer/screens/map_screen.dart';
import 'package:flutter_maps_firbase_omar/presentation_layer/screens/otp_screen.dart';

import 'constents/strings.dart';

class AppRouter{
  PhoneAuthCubit? phoneAuthCubit;
  AppRouter(){
    phoneAuthCubit=PhoneAuthCubit();
  }

  Route? generateRoute(RouteSettings settings){
    switch(settings.name){
      case loginScreen:
        return MaterialPageRoute(builder: (_)=>BlocProvider<PhoneAuthCubit>.value(
          value: phoneAuthCubit!,
          child: LoginScreen(),
        ),
        );
      case otpScreen:
        final phoneNumber=settings.arguments;
        return MaterialPageRoute(builder: (_)=>BlocProvider<PhoneAuthCubit>.value(
          value: phoneAuthCubit!,
          child: OtpScreen(phoneNumber:phoneNumber),
        ),
        );
      case mapScreen:
        return MaterialPageRoute(builder: (_)=>BlocProvider(
            create: (BuildContext context)=>MapsCubit(MapsRepository(PlacesWebServices())),
            child: MapScreen(),
        ));
    }
  }
}