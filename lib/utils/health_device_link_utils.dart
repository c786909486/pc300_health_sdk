import 'package:flutter/material.dart';
import 'package:pc300_health_sdk/health_data_plugin.dart';
import 'package:pc300_health_sdk/model/blue_device.dart';

typedef void LinkDeviceListener();

typedef void LinkErrorListener(String error);

class HealthDeviceLinkUtils {
  static BlueDevice device;

  static List<BlueDevice> deviceList = [];

  static BlueDevice _selectDevice;

  static bool isOnline = false;

  static void initListener(
      {LinkDeviceListener onStart, LinkDeviceListener onFinish,LinkDeviceListener onLinkSuccess,LinkErrorListener onLinkError}) async {

    onStart();
    HealthDataSdk.getBondedDevices().then((value) {
      for(var item in value){
        if(item.name.contains("PC300")&&!deviceList.contains(item)){
          deviceList.add(item);
        }
      }
    });
    HealthDataSdk.getInstance().addDeviceLinkHandler(
        onDiscoveryComplete: (data) async {
          for(var item in data){
            BlueDevice bd = BlueDevice.fromJson(item);
            if(!deviceList.contains(bd)){
              deviceList.add(bd);
            }
          }
          onFinish();
        },
        onConnectSuccess: (data) async {
          onLinkSuccess();
          device = _selectDevice;
          isOnline = true;
        },
        onConnectError: (data) async {
          if(data["message"]=="搜索超时"){
            onFinish();
          }else{
            onLinkError(data["message"]);
          }
        },
        onFindDevice: (data) async {
          if(!deviceList.contains(data)){
            deviceList.add(data);
          }

          onFinish();
        });

    // HealthDataSdk.startDiscovery(maxTime: 10);
  }

  static void linkDevice(BlueDevice device){
    HealthDataSdk.connect(device.address);
    _selectDevice = device;

  }
}
