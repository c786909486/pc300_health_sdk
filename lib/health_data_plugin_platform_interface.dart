import 'package:flutter/services.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'health_data_plugin_method_channel.dart';
import 'health_device_sdk.dart';
import 'model/blue_device.dart';
import 'model/ecg_data_model.dart';
import 'model/oxygen_wave_data_model.dart';

abstract class HealthDataPluginPlatform extends PlatformInterface {
  /// Constructs a UnifyPayPluginPlatform.
  HealthDataPluginPlatform() : super(token: _token);

  static final Object _token = Object();

  static HealthDataPluginPlatform _instance = HealthDataPluginMethodChannel();

  /// The default instance of [UnifyPayPluginPlatform] to use.
  ///
  /// Defaults to [MethodChannelUnifyPayPlugin].
  static HealthDataPluginPlatform get instance => _instance;



  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [UnifyPayPluginPlatform] when
  /// they register themselves.
  static set instance(HealthDataPluginPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }


  /// 蓝牙是否打开
   Future<bool> isOpen() async {
    throw UnimplementedError('isOpen() has not been implemented.');
  }

  /// 打开蓝牙 --> ios 端没只能跳转到系统设置界面😢没办法直接通过代码打开蓝牙
   Future<bool> openDevice() async {
    throw UnimplementedError('openDevice() has not been implemented.');
  }

  /// 关闭蓝牙 --> ios 端没只能跳转到系统设置界面😢没办法直接通过代码关闭蓝牙
   Future<bool> closeDevice() async {
    throw UnimplementedError('closeDevice() has not been implemented.');
  }

  ///获取绑定设备
   Future<List<BlueDevice>> getBondedDevices() async {
    throw UnimplementedError('getBondedDevices() has not been implemented.');
  }

  ///连接设备
   void connect(String address) {
    throw UnimplementedError('connect() has not been implemented.');
  }

  ///断开连接
   void disConnect() {
    throw UnimplementedError('disConnect() has not been implemented.');
  }

   void startDiscovery({int maxTime = 20}) {
    throw UnimplementedError('startDiscovery() has not been implemented.');
  }

  ///开始接收数据 --> ios 端没有这个方法😢
   void startMeasure() {
    throw UnimplementedError('startMeasure() has not been implemented.');
  }

  ///停止接收数据
   void stopMeasure() {
    throw UnimplementedError('stopMeasure() has not been implemented.');
  }

  ///暂停接收数据
   void pauseMeasure() {
    throw UnimplementedError('pauseMeasure() has not been implemented.');
  }

  ///恢复接收数据
   void continueMeasure() {
    throw UnimplementedError('continueMeasure() has not been implemented.');
  }

  ///查询设备版本信息
   void queryDeviceVer() {
    throw UnimplementedError('queryDeviceVer() has not been implemented.');
  }

  ///查询血压模块状态
   void queryNIBPStatus() {
    throw UnimplementedError('queryNIBPStatus() has not been implemented.');
  }

  ///查询血氧模块状态
   void querySpO2Status() {
    throw UnimplementedError('querySpO2Status() has not been implemented.');
  }

  ///查询血糖模块状态
   void queryGluStatus() {
    throw UnimplementedError('queryGluStatus() has not been implemented.');
  }

  ///查询体温模块状态
   void queryTmpStatus() {
    throw UnimplementedError('queryTmpStatus() has not been implemented.');
  }

  ///查询心电模块版本信息
   void queryECGVer() {
    throw UnimplementedError('queryECGVer() has not been implemented.');
  }

  ///血压测量控制
   void setNIBPAction(bool startMeasure) {
    throw UnimplementedError('setNIBPAction() has not been implemented.');
  }

  ///心电测量控制
   void setECGMotion(bool startMeasure) {
    throw UnimplementedError('setECGMotion() has not been implemented.');
  }

  ///设备连接回调
  void addDeviceLinkHandler({
    EventHandlerMap? onConnectSuccess,
    EventHandlerMap? onConnectError,
    EventHandlerMap<BlueDevice>? onFindDevice,
    EventHandlerMap<List>? onDiscoveryComplete,
  }) {
    throw UnimplementedError('addDeviceLinkHandler() has not been implemented.');

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
    throw UnimplementedError('addHealthDataHandler() has not been implemented.');

  }
}
