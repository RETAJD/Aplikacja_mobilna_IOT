import 'package:flutter/material.dart';

class WelcomePage extends StatelessWidget{

  @override
  Widget build(BuildContext context){
    return Scaffold(
      body: Container(
         color: Colors.black,
         child: Stack(
          children: [
            Positioned.fill(
              child: Opacity(
                opacity: 0.5,
                child: Image.asset('assets/images/bg_1.png', fit: BoxFit.cover,)
                ), 
              ),
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  ClipOval(
                    child: Container(
                      width: 300,
                      height: 300,
                      color: Colors.white,
                      alignment: Alignment.center,
                      child: Image.asset('assets/images/iot_logo.png', width: 200, height: 200, fit: BoxFit.cover,),
                    ),

                    
          
                  )
                ],
              ),
            ),

          ],
         ),
      ),
    );
  }
}