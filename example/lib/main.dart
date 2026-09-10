import 'dart:convert';

import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:pc300_health_sdk/health_data_plugin.dart';
import 'package:pc300_health_sdk_example/health_data_page.dart';
import 'package:pc300_health_sdk_example/health_widght_page.dart';

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
  String _address = "";
  @override
  void initState() {
    super.initState();
    initPlatformState();
    HealthDeviceLinkUtils.initListener(
        onFinish: (){
          // print("onFinish==========>搜索结束${HealthDeviceLinkUtils.deviceList.length}");
          if(HealthDeviceLinkUtils.deviceList.isNotEmpty){
            var device = HealthDeviceLinkUtils.deviceList[0];
            _address = device.address!;
            // print("deviceInfo=============>"+device.toString());
            // Future.delayed(Duration(milliseconds: 1500),(){
            //
            // });
            HealthDeviceLinkUtils.linkDevice(device);
          }
        },
        onLinkError: (error){
          print("onLinkError==========>连接失败");
        },
        onLinkSuccess: (){
          print("onLinkSuccess==========>连接成功");
        }

    );

    // HealthDataSdk.getInstance().addDeviceLinkHandler(
    //   onDiscoveryComplete: (data) async {
    //     print("来了222");
    //     setState(() {
    //       _platformVersion = "${data.length}";
    //     });
    //     _address = data.first["address"];
    //     for (var item in data) {
    //       print(item);
    //     }
    //     HealthDataSdk.getBondedDevices().then((value) {
    //       print("🍎 - getBondedDevices");
    //       print(value);
    //     });
    //   },
    //   onConnectSuccess: (data) async {
    //     print("🍎 - onConnectSuccess");
    //     print(data.toString());
    //   },
    //   onConnectError: (data) async {
    //     print("来444");
    //     print(data.toString());
    //   },
    //
    //   onFindDevice: (data) async {
    //     _address = data.address;
    //   }
    //
    // );
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
            ElevatedButton(
              child: Text("开始扫描蓝牙设备"),
              onPressed: () {
                HealthDataSdk.startDiscovery(maxTime: 10);
              },
            ),
            ElevatedButton(
              child: Text("关闭蓝牙"),
              onPressed: () {
                HealthDataSdk.closeDevice();
              },
            ),

            ElevatedButton(
              child: Text("获取绑定设备"),
              onPressed: () async {
                List<BlueDevice> item = await HealthDataSdk.getBondedDevices();
                item.forEach((value) {
                  if(value.name!.contains("PC_300")){
                    _address = value.address!;
                  }
                });
              },
            ),

           // ElevatedButton(
           //   child: Text("搜索设备"),
           //   onPressed: ()  {
           //      HealthDataSdk.startDiscovery();
           //   },
           // ),

            ElevatedButton(
              child: Text("连接健康包"),
              onPressed: () {
                if(HealthDeviceLinkUtils.deviceList.isNotEmpty){
                  var device = HealthDeviceLinkUtils.deviceList[0];
                    HealthDeviceLinkUtils.linkDevice(device);
                }
              },
            ),

            ElevatedButton(
              child: Text("测量数据"),
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) {
                  return HealthDataPage();
                }));
              },
            ),


            ElevatedButton(
              child: Text("测量数据Widget"),
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) {
                  return HealthWidgetPage();
                }));
              },
            ),

            ElevatedButton(
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
