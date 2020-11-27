import 'dart:convert';

import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:pc300_health_sdk/health_data_plugin.dart';
import 'package:pc300_health_sdk_example/health_data_page.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MainPage(),
    );
  }
}

class MainPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _MainState();
  }
}

class _MainState extends State<MainPage> {
  String _platformVersion = 'Unknown';
  bool _bluStatue;
  // String _bondDeviceStr = "";
  @override
  void initState() {
    super.initState();
    initPlatformState();
    HealthDataSdk.getInstance().addDeviceLinkHandler(
      onDiscoveryComplete: (data) async {
        print("来了222");
        setState(() {
          _platformVersion = "${data.length}";
        });
        for (var item in data) {
          print(item);
        }
      },
      onConnectSuccess: (data) async {
        print(data.toString());
      },
      onConnectError: (data) async {
        print(data.toString());
      },
    );
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    String platformVersion = "iOS版本没有实现监听蓝牙开启状态的方法";
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      bool isOpen = await HealthDataSdk.isOpen();
      platformVersion = isOpen ? "打开" : "关闭";
    } on PlatformException {
      platformVersion = 'Failed to get platform version.';
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _platformVersion = platformVersion;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Plugin example app'),
      ),
      body: Container(
        alignment: Alignment.center,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text('蓝牙状态: $_platformVersion\n'),
            FlatButton(
              child: Text("开始扫描蓝牙设备"),
              onPressed: () {
                print("来了");
                HealthDataSdk.startDiscovery(maxTime: 10);
              },
            ),
            FlatButton(
              child: Text("关闭蓝牙"),
              onPressed: () {
                HealthDataSdk.closeDevice();
              },
            ),

            FlatButton(
              child: Text("获取绑定设备"),
              onPressed: () async {
                List<BlueDevice> item = await HealthDataSdk.getBondedDevices();
                item.forEach((value) {
                  print(value.toString());
                });
              },
            ),

//            FlatButton(
//              child: Text("搜索设备"),
//              onPressed: ()  {
//                 HealthDataSdk.startDiscovery();
//              },
//            ),

            FlatButton(
              child: Text("连接健康包"),
              onPressed: () {
                HealthDataSdk.connect("8C:DE:52:C2:A7:0B");
              },
            ),

            FlatButton(
              child: Text("测量数据"),
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) {
                  return HealthDataPage();
                }));
              },
            ),

            FlatButton(
              child: Text("断开连接"),
              onPressed: () {
                HealthDataSdk.disConnect();
              },
            ),
          ],
        ),
      ),
    );
  }
}
