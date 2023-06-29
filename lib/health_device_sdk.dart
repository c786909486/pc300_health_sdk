import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:pc300_health_sdk/health_data_plugin.dart';
import 'package:pc300_health_sdk/health_data_plugin_platform_interface.dart';
import 'package:pc300_health_sdk/model/ecg_data_model.dart';
import 'model/blue_device.dart';

typedef Future<dynamic> EventHandlerMap<T>(T event);

class HealthDataSdk {
  static HealthDataSdk? _instance;

  static HealthDataSdk getInstance() {
    if (_instance == null) {
      _instance = HealthDataSdk();
    }
    return _instance!;
  }

  static Future<String?> get platformVersion async {
    return await HealthDataPluginPlatform.instance.getPlatformVersion();
  }

  /// 蓝牙是否打开
  static Future<bool> isOpen() async {
    return await HealthDataPluginPlatform.instance.isOpen();
  }

  /// 打开蓝牙 --> ios 端没只能跳转到系统设置界面😢没办法直接通过代码打开蓝牙
  static Future<bool> openDevice() async {
    return await HealthDataPluginPlatform.instance.openDevice();
  }

  /// 关闭蓝牙 --> ios 端没只能跳转到系统设置界面😢没办法直接通过代码关闭蓝牙
  static Future<bool> closeDevice() async {
    return await HealthDataPluginPlatform.instance.closeDevice();
  }

  ///获取绑定设备
  static Future<List<BlueDevice>> getBondedDevices() async {
    return await HealthDataPluginPlatform.instance.getBondedDevices();
  }

  ///连接设备
  static void connect(String address) {
    return HealthDataPluginPlatform.instance.connect(address);
  }

  ///断开连接
  static void disConnect() {
    return HealthDataPluginPlatform.instance.disConnect();
  }

  static void startDiscovery({int maxTime = 20}) {
    return HealthDataPluginPlatform.instance.startDiscovery(maxTime: maxTime);
  }

  ///开始接收数据 --> ios 端没有这个方法😢
  static void startMeasure() {
    return HealthDataPluginPlatform.instance.startMeasure();
  }

  ///停止接收数据
  static void stopMeasure() {
    return HealthDataPluginPlatform.instance.stopMeasure();
  }

  ///暂停接收数据
  static void pauseMeasure() {
    return HealthDataPluginPlatform.instance.pauseMeasure();
  }

  ///恢复接收数据
  static void continueMeasure() {
    return HealthDataPluginPlatform.instance.continueMeasure();
  }

  ///查询设备版本信息
  static void queryDeviceVer() {
    return HealthDataPluginPlatform.instance.queryDeviceVer();
  }

  ///查询血压模块状态
  static void queryNIBPStatus() {
    return HealthDataPluginPlatform.instance.queryNIBPStatus();
  }

  ///查询血氧模块状态
  static void querySpO2Status() {
    return HealthDataPluginPlatform.instance.querySpO2Status();
  }

  ///查询血糖模块状态
  static void queryGluStatus() {
    return HealthDataPluginPlatform.instance.queryGluStatus();
  }

  ///查询体温模块状态
  static void queryTmpStatus() {
    return HealthDataPluginPlatform.instance.queryTmpStatus();
  }

  ///查询心电模块版本信息
  static void queryECGVer() {
    return HealthDataPluginPlatform.instance.queryECGVer();
  }

  ///血压测量控制
  static void setNIBPAction(bool startMeasure) {
    return HealthDataPluginPlatform.instance.setNIBPAction(startMeasure);
  }

  ///心电测量控制
  static void setECGMotion(bool startMeasure) {
    return HealthDataPluginPlatform.instance.setECGMotion(startMeasure);
  }

  ///设备连接回调
  void addDeviceLinkHandler({
    EventHandlerMap? onConnectSuccess,
    EventHandlerMap? onConnectError,
    EventHandlerMap<BlueDevice>? onFindDevice,
    EventHandlerMap<List>? onDiscoveryComplete,
  }) {
    HealthDataPluginPlatform.instance.addDeviceLinkHandler(
      onConnectSuccess: onConnectSuccess,
      onConnectError: onConnectError,
      onFindDevice: onFindDevice,
      onDiscoveryComplete: onDiscoveryComplete,
    );
  }

  ///健康数据回调
  void addHealthDataHandler({
    EventHandlerMap? onGetDeviceID,
    EventHandlerMap? onGetDeviceVer,
    EventHandlerMap? onGetECGVer,
    EventHandlerMap? onGetSpO2Param,
    EventHandlerMap<OxgenWaveDataModel>? onGetSpO2Wave,
    EventHandlerMap? onGetNIBPAction,
    EventHandlerMap? onGetNIBPRealTime,
    EventHandlerMap? onGetNIBPResult,
    EventHandlerMap? onGetECGAction,
    EventHandlerMap<EcgDataModel>? onGetECGRealTime,
    EventHandlerMap? onGetECGResult,
    EventHandlerMap? onGetTmp,
    EventHandlerMap? onGetGlu,
    EventHandlerMap? onGetNIBPStatus,
    EventHandlerMap? onGetSpO2Status,
    EventHandlerMap? onGetGluStatus,
    EventHandlerMap? onGetTmpStatus,
    EventHandlerMap? onGetPowerOff,
    EventHandlerMap? onConnectLose,
  }) {
    HealthDataPluginPlatform.instance.addHealthDataHandler(
      onGetDeviceID: onGetDeviceID,
      onGetDeviceVer: onGetDeviceVer,
      onGetECGVer: onGetECGVer,
      onGetSpO2Param: onGetSpO2Param,
      onGetSpO2Wave: onGetSpO2Wave,
      onGetNIBPAction: onGetNIBPAction,
      onGetNIBPRealTime: onGetNIBPRealTime,
      onGetNIBPResult: onGetNIBPResult,
      onGetECGAction: onGetECGAction,
      onGetECGRealTime: onGetECGRealTime,
      onGetECGResult: onGetECGResult,
      onGetTmp: onGetTmp,
      onGetGlu: onGetGlu,
      onGetNIBPStatus: onGetNIBPStatus,
      onGetSpO2Status: onGetSpO2Status,
      onGetGluStatus: onGetGluStatus,
      onGetTmpStatus: onGetTmpStatus,
      onGetPowerOff: onGetPowerOff,
      onConnectLose: onConnectLose,
    );
  }
}
