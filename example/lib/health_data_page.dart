import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pc300_health_sdk/health_data_plugin.dart';

class HealthDataPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _HealthDataState();
  }
}

class _HealthDataState extends State<HealthDataPage> {
  String _tmp = "体温：";
  String _wave = "111";

  @override
  void initState() {
    super.initState();
    HealthDataSdk.getInstance().addHealthDataHandler(onGetTmp: (data) async {
      ///体温数据
      double value = data["nTmp"] / 100 + 30;
      setState(() {
        _tmp = "体温：" + value.toString();
      });
    }, onGetNIBPRealTime: (data) async {
      ///血压测量实时数据
      String msg = "血压测量数据：" + data["nBldPrs"].toString();
      setState(() {
        _tmp = msg;
      });
    }, onGetNIBPResult: (data) async {
      ///血压测量结果
      String msg = "血压测量结果：\n收缩压：" + data["nSYS"].toString() + "\n舒张压：" + data["nDIA"].toString();
      setState(() {
        _tmp = msg;
      });
    },onGetSpO2Wave:(data) async{
      ///获取到血氧波形数据
      setState(() {
        _wave = data.toString();
      });
    },onGetSpO2Param:(data)async{
      ///获取血氧参数
      setState(() {
        _tmp = data.toString();
      });
    },onGetECGAction:(data) async{
      ///心电测量状态改变
      setState(() {
        _tmp = data.toString();
      });

    },onGetECGRealTime:(data) async{
      ///获取心电实时数据
      setState(() {

        _tmp = data.ecgdata.data[0].data.toString();
      });
    },onGetECGResult:(data) async{
      ///获取心电结果
      setState(() {
        _tmp = data.toString();
      });
    },onGetPowerOff:(data) async{
      ///下位机关机
      setState(() {
        _tmp = data.toString();
      });
    },onConnectLose: (data) async{
      ///设备丢失
      setState(() {
        _tmp = data.toString();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("健康测量"),
      ),
      body: Container(
        alignment: Alignment.center,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            FlatButton(
              child: Text("测量血压"),
              onPressed: (){
                HealthDataSdk.setNIBPAction(true);
              },
            ),
          Text(_tmp),Text(_wave)],
        ),
      ),
    );
  }
}
