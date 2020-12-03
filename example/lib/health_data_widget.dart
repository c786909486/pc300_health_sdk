import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class HealthDataWidget extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _HealthDataState();
}

class _HealthDataState extends State<HealthDataWidget> {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [BoxShadow(blurRadius: 2,spreadRadius: 2,color: Color(0xffeeeeee))],
      ),
      padding: EdgeInsets.all(10),
    );
  }
}
