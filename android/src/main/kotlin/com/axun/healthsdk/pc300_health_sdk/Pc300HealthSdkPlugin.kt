package com.axun.healthsdk.pc300_health_sdk

import android.annotation.SuppressLint
import android.bluetooth.BluetoothAdapter
import android.bluetooth.BluetoothDevice
import android.os.Build
import android.os.Handler
import android.os.Looper
import android.os.Message
import android.util.Log
import androidx.annotation.NonNull
import androidx.annotation.RequiresApi
import com.axun.healthsdk.pc300_health_sdk.model.BlueDevice
import com.axun.healthsdk.pc300_health_sdk.utils.BlueManageUtils
import com.axun.healthsdk.pc300_health_sdk.utils.toAccessorJson
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.PluginRegistry.Registrar

/** Pc300HealthSdkPlugin */
public class Pc300HealthSdkPlugin : FlutterPlugin, MethodCallHandler ,ActivityAware{
    override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        this.flutterPluginBinding = flutterPluginBinding
        BlueManageUtils.instance.init(flutterPluginBinding.applicationContext)
//        BluetoothContext.set(flutterPluginBinding.applicationContext)

    }

    override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
        flutterPluginBinding = null
    }

    override fun onDetachedFromActivity() {
        BlueManageUtils.instance.release()
        channel?.setMethodCallHandler(null)
        channel = null

    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {

    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        instance.channel = MethodChannel(flutterPluginBinding?.binaryMessenger, "pc300_health_sdk")
       instance.channel ?.setMethodCallHandler(Pc300HealthSdkPlugin())
    }

    override fun onDetachedFromActivityForConfigChanges() {

    }
    // This static function is optional and equivalent to onAttachedToEngine. It supports the old
    // pre-Flutter-1.12 Android projects. You are encouraged to continue supporting
    // plugin registration via this function while apps migrate to use the new Android APIs
    // post-flutter-1.12 via https://flutter.dev/go/android-project-migration.
    //
    // It is encouraged to share logic between onAttachedToEngine and registerWith to keep
    // them functionally equivalent. Only one of onAttachedToEngine or registerWith will be called
    // depending on the user's project. onAttachedToEngine or registerWith must both be defined
    // in the same class.
    companion object {

        const val TAG = "Pc300HealthSdkPlugin"
        val instance by lazy(LazyThreadSafetyMode.SYNCHRONIZED) {
            Pc300HealthSdkPlugin()
        }


        @JvmStatic
        fun registerWith(registrar: Registrar) {
            BlueManageUtils.instance.init(registrar.context())
            instance.channel  = MethodChannel(registrar.messenger(), "pc300_health_sdk")
            instance.channel ?.setMethodCallHandler(Pc300HealthSdkPlugin())
        }


        val blueDeviceListener = object : BlueManageUtils.OnBlueToothCallback {
            override fun onStartDiscovery() {
                Log.d("blueSearchStatus===》","开始搜索")
            }

            @RequiresApi(Build.VERSION_CODES.JELLY_BEAN_MR2)
            override fun OnDiscoveryCompleted(devices: MutableList<BluetoothDevice>) {

                val list: MutableList<BlueDevice> = ArrayList()
                devices.forEach {
                    val item = BlueDevice(address = it.address,
                            name = it.name, type = it.type, bondState = it.bondState)
                    list.add(item)
                }
                sendChannelMessage(onDiscoveryCompleteCode,list.toAccessorJson())

            }

            override fun onConnectSuccess() {
                val map = HashMap<String, Any>()
                map["success"] = true
                map["message"] = "success"
                sendChannelMessage(onConnectSuccessCode, map)
            }

            override fun onConnectError(error: String) {
                val map = HashMap<String, Any>()
                map["success"] = false
                map["message"] = error
                sendChannelMessage(onConnectErrorCode, map)
            }


            @RequiresApi(Build.VERSION_CODES.JELLY_BEAN_MR2)
            override fun onFindDevice(device: BluetoothDevice) {
                Log.d("66666",device.name)
                val item = BlueDevice(address = device.address,
                        name = device.name, type = device.type, bondState = device.bondState)
                sendChannelMessage(onFindDeviceCode,item.toAccessorJson())
            }

        }


        fun sendChannelMessage(messageCode: Int, value: Any?) {
            val message = Message()
            message.what = messageCode
            message.obj = value;
            handler.sendMessage(message)
        }

        var handler = @SuppressLint("HandlerLeak")
        object : Handler(Looper.getMainLooper()) {
            override fun handleMessage(msg: Message?) {
                super.handleMessage(msg)
                when (msg?.what) {
                    onConnectSuccessCode -> {
                        instance.channel?.invokeMethod("onConnectSuccess", msg.obj)
                    }

                    onConnectErrorCode -> {
                        instance.channel?.invokeMethod("onConnectError", msg.obj)
                    }

                    /*获取设备id*/
                    onGetDeviceIDCode -> {
                        instance.channel?.invokeMethod("onGetDeviceID",msg.obj)
                    }
                    /*获取到设备版本信息*/
                    onGetDeviceVerCode -> {
                        instance.channel?.invokeMethod("onGetDeviceVer",msg.obj)
                    }
                    /*获取到心电模块版本*/
                    onGetECGVerCode -> {
                        instance.channel?.invokeMethod("onGetECGVer",msg.obj)
                    }
                    /*获取到血氧参数*/
                    onGetSpO2ParamCode -> {
                        instance.channel?.invokeMethod("onGetSpO2Param",msg.obj)
                    }
                    /*获取到血氧波形数据*/
                    onGetSpO2WaveCode -> {
                        instance.channel?.invokeMethod("onGetSpO2Wave",msg.obj)
                    }
                    /*血压测量状态改变*/
                    onGetNIBPActionCode -> {
                        instance.channel?.invokeMethod("onGetNIBPAction",msg.obj)
                    }

                    /*获取到实时袖带压力值*/
                    onGetNIBPRealTimeCode -> {
                        instance.channel?.invokeMethod("onGetNIBPRealTime",msg.obj)
                    }

                    /*血压测量结果*/
                    onGetNIBPResultCode -> {
                        instance.channel?.invokeMethod("onGetNIBPResult",msg.obj)
                    }
                    /*心电测量状态改变*/
                    onGetECGActionCode -> {
                        instance.channel?.invokeMethod("onGetECGAction",msg.obj)
                    }
                    /*获取心电实时数据*/
                    onGetECGRealTimeCode -> {
                        instance.channel?.invokeMethod("onGetECGRealTime",msg.obj)
                    }
                    /*心电测量结果*/
                    onGetECGResultCode -> {
                        instance.channel?.invokeMethod("onGetECGResult",msg.obj)
                    }
                    /*获取到体温数据*/
                    onGetTmpCode -> {
                        instance.channel?.invokeMethod("onGetTmp",msg.obj)
                    }
                    /*获取到血糖值*/
                    onGetGluCode -> {
                        instance.channel?.invokeMethod("onGetGlu",msg.obj)
                    }
                    /*获取到血压模块状态*/
                    onGetNIBPStatusCode -> {
                        instance.channel?.invokeMethod("onGetNIBPStatus",msg.obj)
                    }
                    /*获取到血氧模块状态*/
                    onGetSpO2StatusCode -> {
                        instance.channel?.invokeMethod("onGetSpO2Status",msg.obj)
                    }
                    /*获取到血糖模块状态*/
                    onGetGluStatusCode -> {
                        instance.channel?.invokeMethod("onGetGluStatus",msg.obj)
                    }
                    /*获取到体温模块状态*/
                    onGetTmpStatusCode -> {
                        instance.channel?.invokeMethod("onGetTmpStatus",msg.obj)
                    }
                    /*下位机关机*/
                    onGetPowerOffCode -> {
                        instance.channel?.invokeMethod("onGetPowerOff",msg.obj)
                    }
                    /*与设备连接丢失*/
                    onConnectLoseCode -> {
                        instance.channel?.invokeMethod("onConnectLose",msg.obj)
                    }
                    /*获取全部设备*/
                    onDiscoveryCompleteCode -> {
                        instance.channel?.invokeMethod("onDiscoveryComplete",msg.obj)
                    }

                    /*查询到设备*/
                    onFindDeviceCode->{

                        instance.channel?.invokeMethod("onFindDevice",msg.obj)
                    }

                }
            }
        }

        /*连接成功*/
        val onConnectSuccessCode = 0x100
        /*连接失败*/
        val onConnectErrorCode = 0x101

        /*获取全部设备列表*/
        val onDiscoveryCompleteCode = 0x121

        val onFindDeviceCode = 0x122

        /*获取到设备ID*/
        val onGetDeviceIDCode = 0x102

        /*获取到设备版本信息*/
        val onGetDeviceVerCode = 0x103

        /*获取到心电模块版本*/
        val onGetECGVerCode = 0x104

        /*获取到血氧参数*/
        val onGetSpO2ParamCode = 0x105

        /*获取到血氧波形数据*/
        val onGetSpO2WaveCode = 0x106

        /*血压测量状态改变*/
        val onGetNIBPActionCode = 0x107

        /*血压测量结果*/
        val onGetNIBPResultCode = 0x108

        /*心电测量状态改变*/
        val onGetECGActionCode = 0x109

        /*获取心电实时数据*/
        val onGetECGRealTimeCode = 0x110

        /*心电测量结果*/
        val onGetECGResultCode = 0x111

        /*获取到体温数据*/
        val onGetTmpCode = 0x112

        /*获取到血糖值*/
        val onGetGluCode = 0x113

        /*获取到血压模块状态*/
        val onGetNIBPStatusCode = 0x114

        /*获取到血氧模块状态*/
        val onGetSpO2StatusCode = 0x115

        /*获取到血糖模块状态*/
        val onGetGluStatusCode = 0x116

        /*获取到体温模块状态*/
        val onGetTmpStatusCode = 0x117

        /*下位机关机*/
        val onGetPowerOffCode = 0x118

        /*与设备连接丢失*/
        val onConnectLoseCode = 0x119

        /*获取到实时袖带压力值*/
        val onGetNIBPRealTimeCode = 0x120
    }


    private var channel: MethodChannel? = null
    private var flutterPluginBinding:FlutterPlugin.FlutterPluginBinding?=null



    @RequiresApi(Build.VERSION_CODES.JELLY_BEAN_MR2)
    override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
        when (call.method) {
            "getPlatformVersion" -> {
                result.success("Android ${android.os.Build.VERSION.RELEASE}")
            }

            /**
             * @Description 检查蓝牙是否打开
             **/
            "isOpen" -> {
                val isOpen = BlueManageUtils.instance.client.isOpen
                result.success(isOpen)
            }

            /**
             * @Description 打开蓝牙
             **/
            "openDevice" -> {
                val open = BlueManageUtils.instance.client.Open()
                result.success(open)
            }

            /**
             * @Description 关闭蓝牙
             **/
            "closeDevice" -> {
                val close = BlueManageUtils.instance.client.Close()
                result.success(close.toString())
            }

            /**
             * @Description 获取已绑定设备
             **/
            "getBondedDevices" -> {
                val devices = BlueManageUtils.instance.client.bondedDevices
                val list: MutableList<BlueDevice> = ArrayList()

                devices.forEach {
                    val item = BlueDevice(address = it.address,
                            name = it.name, type = it.type, bondState = it.bondState)
                    list.add(item)
                }
                result.success(list.toAccessorJson())
            }

            /**
             * @Description 连接设备
             **/
            "connect" -> {
                val address = call.argument<String>("address")
                val device = BluetoothAdapter.getDefaultAdapter().getRemoteDevice(address)
                BlueManageUtils.instance. client.StopDiscovery()
                BlueManageUtils.instance.client.Connect(device)
            }

            /**
             * @Description 断开连接
             **/
            "disConnect" -> {
                BlueManageUtils.instance.release()
            }

            /**
             * @Description 开始搜索设备
             **/
            "startDiscovery"->{
                BlueManageUtils.instance.startDiscovery(blueDeviceListener)
            }

            /**
             * @Description 开始接受数据
             **/
            "startMeasure" -> {
                BlueManageUtils.instance.healthClient.Start()
            }

            /**
             * @Description 停止接受数据
             **/
            "stopMeasure" -> {
                BlueManageUtils.instance.healthClient.Stop()
            }

            /**
             * @Description 暂停接受数据
             **/
            "pauseMeasure" -> {
                BlueManageUtils.instance.healthClient.Pause()
            }

            /**
             * @Description 恢复接受数据
             **/
            "continueMeasure" -> {
                BlueManageUtils.instance.healthClient.Continue()
            }

            /**
             * @Description 查询设备版本信息
             **/
            "queryDeviceVer" -> {
                BlueManageUtils.instance.healthClient.QueryDeviceVer()
            }

            /**
             * @Description 查询血压模块状态
             **/
            "queryNIBPStatus" -> {
                BlueManageUtils.instance.healthClient.QueryNIBPStatus()
            }

            /**
             * @Description 查询血氧模块状态
             **/
            "querySpO2Status" -> {
                BlueManageUtils.instance.healthClient.QuerySpO2Status()
            }

            /**
             * @Description 查询血糖模块状态
             **/
            "queryGluStatus" ->{
                BlueManageUtils.instance.healthClient.QueryGluStatus()
            }

            /**
             * @Description 查询体温模块状态
             **/
            "queryTmpStatus"->{
                BlueManageUtils.instance.healthClient.QueryTmpStatus()
            }

            /**
             * @Description 查询心电模块版本信息
             **/
            "queryECGVer" -> {
                BlueManageUtils.instance.healthClient.QueryECGVer()
            }

            /**
             * @Description 血压测量控制
             **/
            "setNIBPAction" -> {
                val startMeasure = call.argument<Boolean>("startMeasure")
                BlueManageUtils.instance.healthClient.SetNIBPAction(startMeasure?:false)
            }

            /**
             * @Description 心电测量控制
             **/
            "setECGMotion"->{
                val startMeasure = call.argument<Boolean>("startMeasure")
                BlueManageUtils.instance.healthClient.SetECGMotion(startMeasure?:false)
            }

            else -> {
                result.notImplemented()
            }
        }
    }






}
