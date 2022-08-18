
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_maps_firbase_omar/business_logic_layer/cubit/phone_auth/phone_auth_cubit.dart';
import 'package:flutter_maps_firbase_omar/constents/my_colors.dart';
import 'package:flutter_maps_firbase_omar/constents/strings.dart';

class LoginScreen extends StatelessWidget {
   LoginScreen({Key? key}) : super(key: key);

  final GlobalKey<FormState>_phoneFormKey=GlobalKey();
  late String phoneNumber;

  Widget _buildIntroTexts(){
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('What is Your Phone Number?',style: TextStyle(color: Colors.black,fontSize: 24,fontWeight: FontWeight.bold),),
        SizedBox(height: 30,),
        Container(
          margin:EdgeInsets.symmetric(horizontal: 2),
          child: Text('please enter your phone number to verify your account.',style: TextStyle(color: Colors.black,fontSize: 18),),
        ),
      ],
    );
  }
  Widget _buildFprmPhoneField(){
    return Row(
      children: [
        Expanded(
          flex: 1,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 12,vertical: 16),
            decoration: BoxDecoration(
              border: Border.all(color:MyColors.lightGrey ),
              borderRadius: BorderRadius.all(Radius.circular(6)),
            ),
            child: Text(generateCountryFlag()+' +20',style: TextStyle(fontSize: 18,letterSpacing: 2.0),),
          ),
        ),
        SizedBox(width: 16,),
        Expanded(
          flex: 2,
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 12,vertical: 2),
            decoration: BoxDecoration(
              border: Border.all(color:MyColors.blue ),
              borderRadius: BorderRadius.all(Radius.circular(6)),
            ),
            child: TextFormField(
              autofocus: true,
              style: TextStyle(
                fontSize: 18,
                letterSpacing: 2.0,
              ),
              decoration: InputDecoration(border: InputBorder.none,),
              cursorColor: Colors.black,
              keyboardType: TextInputType.phone,
              validator: (value){
                if(value!.isEmpty){
                  return 'Please enter your phone Number!';
                }else if(value.length<11){
                  return 'Too short for a phone Number!';
                }
                return null;
              },
              onSaved: (value){
                phoneNumber=value!;
              },
            ),
          ),
        ),
      ],
    );
  }
  String generateCountryFlag(){
    String countryCode='eg';
    String flag= countryCode.toUpperCase().replaceAllMapped(RegExp(r'[A-Z]'), (match) => String.fromCharCode(match.group(0)!.codeUnitAt(0)+127397));
    return flag;
  }
  Future<void>_register(BuildContext context)async{
    if(!_phoneFormKey.currentState!.validate()){
      Navigator.pop(context);
      return;
    }else{
      Navigator.pop(context);
      _phoneFormKey.currentState!.save();
      BlocProvider.of<PhoneAuthCubit>(context).submitPhoneNumber(phoneNumber);
    }
  }
  Widget _buildNextButton(BuildContext context){
    return Align(
      alignment: Alignment.centerRight,
      child: ElevatedButton(
        onPressed: (){
          showProgressIndicator(context);
          _register(context);
        },
        child: Text('Next',style: TextStyle(color: Colors.white,fontSize: 16),),
        style: ElevatedButton.styleFrom(
          minimumSize: Size(110,50),
          primary: Colors.black,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
        ),
      ),
    );
  }
  Widget _buildPhoneNumberSubmittedBloc(){
    return BlocListener<PhoneAuthCubit,PhoneAuthState>(
      listenWhen: (previous,current){
        return previous!=current;
      },
      listener: (context,state){
        if(state is Loading){
          showProgressIndicator(context);
        }
        if(state is PhoneNumberSubmitted){
          Navigator.pop(context);
          Navigator.of(context).pushNamed(otpScreen,arguments: phoneNumber);
        }
        if(state is ErrorOccured){
          Navigator.pop(context);
          String errorMsg=(state).errorMsg;
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(errorMsg),backgroundColor: Colors.black,duration: Duration(seconds: 5),));
        }
      },
      child: Container(),
    );
  }
  void showProgressIndicator(BuildContext context){
    AlertDialog alertDialog=AlertDialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      content: Center(
        child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.black),),
      ),
    );
    showDialog(
        barrierColor:Colors.white.withOpacity(0),
        barrierDismissible: false,
        context: context,
        builder:(context){return alertDialog;}
        );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
          backgroundColor: Colors.white,
          body: Form(
            key: _phoneFormKey,
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 32,vertical: 88),
              child: SingleChildScrollView (
                physics: NeverScrollableScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildIntroTexts(),
                    SizedBox(height: MediaQuery.of(context).size.height*0.13,),
                    _buildFprmPhoneField(),
                    SizedBox(height: MediaQuery.of(context).size.height*0.05,),
                    _buildNextButton(context),
                    _buildPhoneNumberSubmittedBloc(),
                  ],
                ),
              ),
            ),
          ),
        ),
    );
  }
}
