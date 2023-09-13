
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class LoadingWidget extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
      return Center(
        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2,),
      );
  }

}
class LoadingWidgetGreen extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    return Center(
      child: CircularProgressIndicator(color: Colors.green, strokeWidth: 2,),
    );
  }

}