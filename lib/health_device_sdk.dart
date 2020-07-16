import 'dart:async';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:pc300_health_sdk/model/ecg_data_model.dart';
import 'model/blue_device.dart';

typedef Future<dynamic> EventHandler(String res);
typedef Future<dynamic> EventHandlerMap(Map<String, dynamic> event);

class HealthDataSdk {
  static const MethodChannel _channel = const MethodChannel('pc300_health_sdk');

  static HealthDataSdk _instance;

  static HealthDataSdk getInstance() {
    if (_instance == null) {
      _instance = HealthDataSdk();
    }
    return _instance;
  }

  HealthDataSdk() {
    _channel.setMethodCallHandler(_handleMethod);
  }

  ///连接成功事件
  EventHandlerMap _onConnectSuccess;

  ///连接失败
  EventHandlerMap _onConnectError;

  ///获取设备id
  EventHandlerMap _onGetDeviceID;

  ///获取到设备版本信息
  EventHandlerMap _onGetDeviceVer;

  ///获取到心电模块版本
  EventHandlerMap _onGetECGVer;

  ///获取到血氧参数
  EventHandlerMap _onGetSpO2Param;

  ///获取到血氧波形数据
  EventHandlerMap _onGetSpO2Wave;

  ///血压测量状态改变
  EventHandlerMap _onGetNIBPAction;

  ///获取到实时袖带压力值
  EventHandlerMap _onGetNIBPRealTime;

  ///血压测量结果
  EventHandlerMap _onGetNIBPResult;

  ///心电测量状态改变
  EventHandlerMap _onGetECGAction;

  ///获取心电实时数据
  EventHandlerMap _onGetECGRealTime;

  ///心电测量结果
  EventHandlerMap _onGetECGResult;

  ///获取体温数据
  EventHandlerMap _onGetTmp;

  ///获取到血糖值
  EventHandlerMap _onGetGlu;

  ///获取到血压模块状态
  EventHandlerMap _onGetNIBPStatus;

  ///获取到血氧模块状态
  EventHandlerMap _onGetSpO2Status;

  ///获取到血糖模块状态
  EventHandlerMap _onGetGluStatus;

  ///获取到体温模块状态
  EventHandlerMap _onGetTmpStatus;

  ///下位机关机
  EventHandlerMap _onGetPowerOff;

  ///与设备连接丢失
  EventHandlerMap _onConnectLose;

  ///设备连接回调
  void addDeviceLinkHandler({
    EventHandlerMap onConnectSuccess,
    EventHandlerMap onConnectError,
  }) {
    this._onConnectSuccess = onConnectSuccess;
    this._onConnectError = onConnectError;
  }

  ///健康数据回调
  void addHealthDataHandler({
    EventHandlerMap onGetDeviceID,
    EventHandlerMap onGetDeviceVer,
    EventHandlerMap onGetECGVer,
    EventHandlerMap onGetSpO2Param,
    EventHandlerMap onGetSpO2Wave,
    EventHandlerMap onGetNIBPAction,
    EventHandlerMap onGetNIBPRealTime,
    EventHandlerMap onGetNIBPResult,
    EventHandlerMap onGetECGAction,
    EventHandlerMap onGetECGRealTime,
    EventHandlerMap onGetECGResult,
    EventHandlerMap onGetTmp,
    EventHandlerMap onGetGlu,
    EventHandlerMap onGetNIBPStatus,
    EventHandlerMap onGetSpO2Status,
    EventHandlerMap onGetGluStatus,
    EventHandlerMap onGetTmpStatus,
    EventHandlerMap onGetPowerOff,
    EventHandlerMap onConnectLose,
  }) {
    this._onGetTmp = onGetTmp;
    this._onGetDeviceID = onGetDeviceID;
    this._onGetDeviceVer = onGetDeviceVer;
    this._onGetECGVer = onGetECGVer;
    this._onGetSpO2Param = onGetSpO2Param;
    this._onGetSpO2Wave = onGetSpO2Wave;
    this._onGetNIBPAction = onGetNIBPAction;
    this._onGetNIBPRealTime = onGetNIBPRealTime;
    this._onGetNIBPResult = onGetNIBPResult;
    this._onGetECGAction = onGetECGAction;
    this._onGetECGRealTime = onGetECGRealTime;
    this._onGetECGResult = onGetECGResult;
    this._onGetGlu = onGetGlu;
    this._onGetNIBPStatus = onGetNIBPStatus;
    this._onGetSpO2Status = onGetSpO2Status;
    this._onGetGluStatus = onGetGluStatus;
    this._onGetTmpStatus = onGetTmpStatus;
    this._onGetPowerOff = onGetPowerOff;
    this._onConnectLose = onConnectLose;
  }

  Future<dynamic> _handleMethod(MethodCall call) async {
    print(call.method +
        "***************************\ndata:" +
        call.arguments.toString());
    switch (call.method) {

      ///连接设备成功
      case "onConnectSuccess":
        return _onConnectSuccess(call.arguments.cast<String, dynamic>());

      ///连接设备失败
      case "onConnectError":
        return _onConnectError(call.arguments.cast<String, dynamic>());

      ///获取设备id
      case "onGetDeviceID":
        return _onGetDeviceID(call.arguments.cast<String, dynamic>());

      ///获取到设备版本信息
      case "onGetDeviceVer":
        return _onGetDeviceVer(call.arguments.cast<String, dynamic>());

      ///获取到心电模块版本
      case "onGetECGVerCode":
        return _onGetECGVer(call.arguments.cast<String, dynamic>());

      ///获取到血氧参数
      case "onGetSpO2Param":
        return _onGetSpO2Param(call.arguments.cast<String, dynamic>());

      ///获取到血氧波形数据
      case "onGetSpO2Wave":
        return _onGetSpO2Wave(jsonDecode(call.arguments).cast<String, dynamic>());

      ///血压测量状态改变
      case "onGetNIBPAction":
        return _onGetNIBPAction(call.arguments.cast<String, dynamic>());

      ///获取到实时袖带压力值
      case "onGetNIBPRealTime":
        return _onGetNIBPRealTime(call.arguments.cast<String, dynamic>());

      ///血压测量结果
      case "onGetNIBPResult":
        return _onGetNIBPResult(call.arguments.cast<String, dynamic>());

      ///心电测量状态改变
      case "onGetECGAction":
        return _onGetECGAction(call.arguments.cast<String, dynamic>());

      ///获取心电实时数据
      case "onGetECGRealTime":
//        Map<String,dynamic> map = {"dad":"dadasd"};
        Map<String,dynamic> map = jsonDecode(call.arguments);
        return _onGetECGRealTime(map);

      ///心电测量结果
      case "onGetECGResult":
        return _onGetECGResult(call.arguments.cast<String, dynamic>());

      ///获取体温数据
      case "onGetTmp":
        return _onGetTmp(call.arguments.cast<String, dynamic>());

      ///获取到血糖值
      case "onGetGlu":
        return _onGetGlu(call.arguments.cast<String, dynamic>());

      ///获取到血压模块状态
      case "onGetNIBPStatus":
        return _onGetNIBPStatus(call.arguments.cast<String, dynamic>());

      ///获取到血氧模块状态
      case "onGetSpO2Status":
        return _onGetSpO2Status(call.arguments.cast<String, dynamic>());

      ///获取到血糖模块状态
      case "onGetGluStatus":
        return _onGetGluStatus(call.arguments.cast<String, dynamic>());

      ///获取到体温模块状态
      case "onGetTmpStatus":
        return _onGetTmpStatus(call.arguments.cast<String, dynamic>());

      ///下位机关机
      case "onGetPowerOff":
        return _onGetPowerOff(call.arguments.cast<String, dynamic>());

      ///与设备连接丢失
      case "onConnectLose":
        return _onConnectLose(call.arguments.cast<String, dynamic>());
      default:
        throw new UnsupportedError("Unrecongnized Event");
    }
  }

  static Future<String> get platformVersion async {
    final String version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }

  /// 蓝牙是否打开
  static Future<bool> isOpen() async {
    String isOpen = await _channel.invokeMethod('isOpen');
    return isOpen == 'true';
  }

  /// 打开蓝牙
  static Future<bool> openDevice() async {
    String openResult = await _channel.invokeMethod("openDevice");
    return openResult == 'true';
  }

  /// 关闭蓝牙
  static Future<bool> closeDevice() async {
    String openResult = await _channel.invokeMethod("closeDevice");
    return openResult == 'true';
  }

  ///获取绑定设备
  static Future<List<BlueDevice>> getBondedDevices() async {
    String listStr = await _channel.invokeMethod("getBondedDevices");
    List<dynamic> list = json.decode(listStr);
    return list.map((value) {
      return BlueDevice.fromJson(value);
    }).toList();
  }

  ///连接设备
  static void connect(String address) {
    _channel.invokeMethod("connect", {"address": address});
  }

  static void disConnect() {
    _channel.invokeMethod("disConnect");
  }
}
