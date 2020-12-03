import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'health_data_widget.dart';

class HealthWidgetPage extends StatefulWidget{
  @override
  State<StatefulWidget> createState() => _HealthWidgetState();

}

class _HealthWidgetState extends State<HealthWidgetPage>{
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("测量数据"),),
      body: Stack(
        children: [
          Container(height: 200,
          margin: EdgeInsets.all(16),
          child: HealthDataWidget(),)
        ],
      ),
    );
  }

}