import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_maps_firbase_omar/app_router.dart';
import 'package:flutter_maps_firbase_omar/constents/strings.dart';

late String initialRoute;

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  //state of user loin or not if closed app
  FirebaseAuth.instance.authStateChanges().listen((user) {
    if(user==null){
      initialRoute=loginScreen;
    }else{
      initialRoute=mapScreen;
    }
  });
  runApp(MyApp(appRouter: AppRouter(),));
}

class MyApp extends StatelessWidget {
  final AppRouter appRouter;

  const MyApp({Key? key,required this.appRouter}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.blue,),
      onGenerateRoute: appRouter.generateRoute,
      initialRoute: initialRoute,
    );
  }
}

