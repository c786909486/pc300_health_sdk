package com.axun.healthsdk.pc300_health_sdk.utils

import android.bluetooth.BluetoothDevice
import android.bluetooth.BluetoothSocket
import android.content.Context
import android.os.Handler
import android.util.Log
import com.alibaba.fastjson.JSON
import com.axun.healthsdk.pc300_health_sdk.Pc300HealthSdkPlugin
import com.creative.base.BLUReader
import com.creative.base.BLUSender
import com.creative.base.BaseDate
import com.creative.bluetooth.BluetoothOpertion
import com.creative.bluetooth.IBluetoothCallBack
import com.creative.filemanage.ECGFile
import com.creative.pc300.DataType

import com.creative.pc300.ISpotCheckCallBack
import com.creative.pc300.SpotCheck
import java.util.ArrayList

/**
 *@packageName com.yyt.healthbluetoothmansager
 *@author kzcai
 *@date 2019-07-24
 */
class BlueManageUtils {
    lateinit var client: BluetoothOpertion
    private var tag = "BlueManageUtils"
    private lateinit var context: Context
    var currentDevice: BluetoothSocket? = null
    lateinit var healthClient: SpotCheck
    var canLink = true
    var hasHealth = false

    companion object {
        val instance by lazy(LazyThreadSafetyMode.SYNCHRONIZED) {
            BlueManageUtils()
        }

    }

    fun init(context: Context) {
        this.context = context

        client = BluetoothOpertion(context, listener)
    }

    fun startDiscovery(listener: OnBlueToothCallback) {
        bluetoothListener?.onStartDiscovery()
        this.bluetoothListener = listener
        client.Discovery()
    }

    private val listener = object : IBluetoothCallBack {
        override fun OnConnectFail(p0: String?) {
//            Log.d(tag, "连接失败====》$p0")
            if (bluetoothListener != null && p0 != "Connecting") {
                bluetoothListener?.onConnectError(p0!!)
            }
        }

        override fun OnException(p0: Int) {
//            Log.d(tag, "连接错误====》$p0")
            bluetoothListener?.onConnectError(if (p0==1) "搜索超时" else "蓝牙未打开")
        }

        override fun OnDiscoveryCompleted(p0: MutableList<BluetoothDevice>?) {
//            Log.d(tag, "搜索完成====》${p0!!.size}")

            val devices: MutableList<BluetoothDevice> = ArrayList()
            for (item in p0!!) {
                if (!item.name.isNullOrEmpty()&&item.name=="PC_300SNT"&&!devices.contains(item)) {
                    devices.add(item)
                }
            }
            bluetoothListener?.OnDiscoveryCompleted(devices)
        }

        override fun OnFindDevice(p0: BluetoothDevice?) {
//            Log.d(tag, "发现设备====》${p0!!.name?: p0!!.address}")
            if (!p0!!.name.isNullOrEmpty()&&p0!!.name=="PC_300SNT") {
                bluetoothListener?.onFindDevice(p0)
            }


        }

        override fun OnConnected(p0: BluetoothSocket?) {

            healthClient = SpotCheck(BLUReader(p0?.inputStream), BLUSender(p0?.outputStream), healthCallBack)
//            Log.d(tag, "连接成功====》")
            currentDevice = p0
            bluetoothListener?.onConnectSuccess()
            healthClient.Start()
            healthClient.QueryDeviceVer()
//            BlueManageUtils.instance.healthClient.SetECGMotion(true)
//            BlueManageUtils.instance.healthClient.SetNIBPAction(true)
//            BlueManageUtils.instance.healthClient.QueryDeviceVer()
        }
    }

    private val healthCallBack = object : ISpotCheckCallBack {
        /**
         * 血压测量结果
         */
        override fun OnGetNIBPResult(bHR: Boolean, nPulse: Int, nMAP: Int, nSYS: Int, nDIA: Int, nGrade: Int, nBPErr: Int) {

            val map = HashMap<String, Any>()
            map["bHR"] = bHR
            map["nPulse"] = nPulse
            map["nMAP"] = nMAP
            map["nSYS"] = nSYS
            map["nDIA"] = nDIA
            map["nGrade"] = nGrade
            map["nBPErr"] = nBPErr
            map["errorMsg"] = getErrorMessage(nBPErr)
            Log.d(tag, "OnGetNIBPResult===>${map}")
            Pc300HealthSdkPlugin.sendChannelMessage(Pc300HealthSdkPlugin.onGetNIBPResultCode, map)
        }

        /**
         * 心电测量状态改变
         */
        override fun OnGetECGAction(bStart: Boolean) {
//            Log.d(tag, "心电测量状态改变====》$bStart ")
            val map = HashMap<String, Any>()
            map["bStart"] = bStart
            Pc300HealthSdkPlugin.sendChannelMessage(Pc300HealthSdkPlugin.onGetECGActionCode, map)
        }

        /**
         * 获取到实时袖带压力值
         */
        override fun OnGetNIBPRealTime(bHeartbeat: Boolean, nBldPrs: Int) {
            Log.d(tag, "OnGetNIBPRealTime===》${nBldPrs}")
            val map = HashMap<String, Any>()
            map["bHeartbeat"] = bHeartbeat
            map["nBldPrs"] = nBldPrs
            Pc300HealthSdkPlugin.sendChannelMessage(Pc300HealthSdkPlugin.onGetNIBPRealTimeCode, map)

        }

        /**
         * 获取心电实时数据
         */
        override fun OnGetECGRealTime(ecgdata: BaseDate.ECGData?, nHR: Int, bLeadoff: Boolean) {
//            Log.d(tag, "OnGetECGRealTime")
            val map = HashMap<String, Any?>()
            val dataStr = ecgdata?.toAccessorJson()
            map["ecgdata"] = ecgdata
            map["nHR"] = nHR
            map["bLeadoff"] = bLeadoff
            Pc300HealthSdkPlugin.sendChannelMessage(Pc300HealthSdkPlugin.onGetECGRealTimeCode, map.toAccessorJson())
        }

        /**
         * 获取到血压模块状态
         */
        override fun OnGetNIBPStatus(nStatus: Int, nHWMajor: Int, nHWMinor: Int, nSWMajor: Int, nSWMinor: Int) {
            Log.d(tag, "OnGetNIBPStatus")
            val map = HashMap<String, Any?>()
            map["nStatus"] = nStatus
            map["nHWMajor"] = nHWMajor
            map["nHWMinor"] = nHWMinor
            map["nSWMajor"] = nSWMajor
            map["nSWMinor"] = nSWMinor
            Pc300HealthSdkPlugin.sendChannelMessage(Pc300HealthSdkPlugin.onGetNIBPStatusCode, map)
        }


        /**
         * 下位机关机
         */
        override fun OnGetPowerOff() {
//            Log.d(tag, "OnGetPowerOff")
            val map = HashMap<String, Any?>()
            map["result"] = "finish"
            Pc300HealthSdkPlugin.sendChannelMessage(Pc300HealthSdkPlugin.onGetPowerOffCode, map)
        }

        /**
         * 心电测量结果
         */
        override fun OnGetECGResult(nResult: Int, nHR: Int) {
//            Log.d(tag, "OnGetECGResult")
            val map = HashMap<String, Any?>()
            map["nResult"] = nResult
            map["nHR"] = nHR
            map["resultMsg"] = getECGResultMsg(nResult)
            Pc300HealthSdkPlugin.sendChannelMessage(Pc300HealthSdkPlugin.onGetECGResultCode, map)
        }

        /**
         * 获取到血糖模块状态
         */
        override fun OnGetGluStatus(nStatus: Int, nHWMajor: Int, nHWMinor: Int, nSWMajor: Int, nSWMinor: Int) {
//            Log.d(tag, "OnGetGluStatus")
            val map = HashMap<String, Any?>()
            map["nStatus"] = nStatus
            map["nHWMajor"] = nHWMajor
            map["nHWMinor"] = nHWMinor
            map["nSWMajor"] = nSWMajor
            map["nSWMinor"] = nSWMinor
            Pc300HealthSdkPlugin.sendChannelMessage(Pc300HealthSdkPlugin.onGetGluStatusCode, map)
        }

        /**
         * 获取到设备ID
         */
        override fun OnGetDeviceID(sDeviceID: String?) {
//            Log.d(tag, "OnGetDeviceID")
            val map = HashMap<String, Any?>()
            map["sDeviceID"] = sDeviceID
            Pc300HealthSdkPlugin.sendChannelMessage(Pc300HealthSdkPlugin.onGetDeviceIDCode, map)
        }

        /**
         * 获取到血糖值
         * 血糖值只有在nResultStatus=0时有效
         */
        override fun OnGetGlu(nGlu: Int, nGluStatus: Int) {
//            Log.d(tag, "OnGetGlu")
            val map = HashMap<String, Any?>()
            map["nGlu"] = nGlu
            map["nGluStatus"] = nGluStatus
            Pc300HealthSdkPlugin.sendChannelMessage(Pc300HealthSdkPlugin.onGetGluCode, map)
        }

        /**
         * 与设备连接丢失
         */
        override fun OnConnectLose() {
//            Log.d(tag, "OnConnectLose")
            val map = HashMap<String, Any?>()
            map["result"] = "lose"
            Pc300HealthSdkPlugin.sendChannelMessage(Pc300HealthSdkPlugin.onConnectLoseCode, map)
        }

        /**
         * 血压测量状态改变
         */
        override fun OnGetNIBPAction(bStart: Boolean) {
//            Log.d(tag, "OnGetNIBPAction")
            val map = HashMap<String, Any?>()
            map["bStart"] = bStart
            Pc300HealthSdkPlugin.sendChannelMessage(Pc300HealthSdkPlugin.onGetNIBPActionCode, map)
        }

        /**
         * 获取到血氧模块状态
         */
        override fun OnGetSpO2Status(nStatus: Int, nHWMajor: Int, nHWMinor: Int, nSWMajor: Int, nSWMinor: Int) {
//            Log.d(tag, "OnGetSpO2Status")
            val map = HashMap<String, Any?>()
            map["nStatus"] = nStatus
            map["nHWMajor"] = nHWMajor
            map["nHWMinor"] = nHWMinor
            map["nSWMajor"] = nSWMajor
            map["nSWMinor"] = nSWMinor
            Pc300HealthSdkPlugin.sendChannelMessage(Pc300HealthSdkPlugin.onGetSpO2StatusCode, map)
        }

        /**
         * 获取到设备版本信息
         * 充电状态有3重，在DataType中定义
         * BATTERY_NO_CHARGE:没有充电
         * BATTERY_IN_CHARGING:正在充电
         * BATTERY_CHARGING_COMPLETED:充电完成
         */
        override fun OnGetDeviceVer(nHWMajor: Int, nHWMinor: Int, nSWMajor: Int, nSWMinor: Int, nPower: Int, nBattery: Int) {
//            Log.d(tag, "OnGetDeviceVer")
            val map = HashMap<String, Any?>()
            map["nPower"] = nPower
            map["nHWMajor"] = nHWMajor
            map["nHWMinor"] = nHWMinor
            map["nSWMajor"] = nSWMajor
            map["nSWMinor"] = nSWMinor
            map["nBattery"] = nBattery
            Pc300HealthSdkPlugin.sendChannelMessage(Pc300HealthSdkPlugin.onGetDeviceVerCode, map)
        }

        /**
         * 获取到体温模块状态
         */
        override fun OnGetTmpStatus(nStatus: Int, nHWMajor: Int, nHWMinor: Int, nSWMajor: Int, nSWMinor: Int) {
//            Log.d(tag, "OnGetTmpStatus")
            val map = HashMap<String, Any?>()
            map["nStatus"] = nStatus
            map["nHWMajor"] = nHWMajor
            map["nHWMinor"] = nHWMinor
            map["nSWMajor"] = nSWMajor
            map["nSWMinor"] = nSWMinor
            Pc300HealthSdkPlugin.sendChannelMessage(Pc300HealthSdkPlugin.onGetTmpStatusCode, map)
        }

        /**
         * 获取到体温数据
         * 体温值只有在nResultStatus=0时有效
         * 测量的体温值需要转换计算得到实际体温数据
         * nTmp/100+30=实际体温值 结果保留一位小数，不采用四舍五入方式，直接丢掉小数点2位之后的数。如：36.57 = 36.5
         */
        override fun OnGetTmp(bManualStart: Boolean, bProbeOff: Boolean, nTmp: Int, nTmpStatus: Int, nResultStatus: Int) {
//            Log.d(tag, "获取到体温数据====》${if (bManualStart) "手动测量" else "自动测量"}\n ,${if (bProbeOff) "探头脱落" else ""},体温值：$nTmp")
            val map = HashMap<String, Any>()
            map["bManualStart"] = bManualStart
            map["bProbeOff"] = bProbeOff
            map["nTmp"] = nTmp
            map["nTmpStatus"] = nTmpStatus
            map["nResultStatus"] = nResultStatus
            Pc300HealthSdkPlugin.sendChannelMessage(Pc300HealthSdkPlugin.onGetTmpCode, map)

        }

        /**
         * 获取到心电模块版本
         */
        override fun OnGetECGVer(nHWMajor: Int, nHWMinor: Int, nSWMajor: Int, nSWMinor: Int) {
//            Log.d(tag, "OnGetECGVer")
            val map = HashMap<String, Any?>()
            map["nHWMajor"] = nHWMajor
            map["nHWMinor"] = nHWMinor
            map["nSWMajor"] = nSWMajor
            map["nSWMinor"] = nSWMinor
            Pc300HealthSdkPlugin.sendChannelMessage(Pc300HealthSdkPlugin.onGetECGVerCode, map)
        }

        /**
         * 获取到血氧波形数据
         */
        override fun OnGetSpO2Wave(waveData: MutableList<BaseDate.Wave>?) {
//            Log.d(tag, "OnGetSpO2Wave")
            val map = HashMap<String, Any?>()
            map["waveData"] = waveData
            Pc300HealthSdkPlugin.sendChannelMessage(Pc300HealthSdkPlugin.onGetSpO2WaveCode, map.toAccessorJson())
        }

        /**
         * 获取到血氧参数
         */
        override fun OnGetSpO2Param(nSpO2: Int, nPR: Int, nPI: Int, nStatus: Int, nMode: Int) {
//            Log.d(tag, "OnGetSpO2Param")
            val map = HashMap<String, Any?>()
            map["nSpO2"] = nSpO2
            map["nPR"] = nPR
            map["nPI"] = nPI
            map["nStatus"] = nStatus
            map["nMode"] = nMode
            Pc300HealthSdkPlugin.sendChannelMessage(Pc300HealthSdkPlugin.onGetSpO2ParamCode, map)

        }

    }

    private fun getErrorMessage(errorCode: Int): String {
        return when (errorCode) {
            DataType.NIBP_ERROR_CUFF_NOT_WRAPPED -> {
                "气袋没绑好"
            }
            DataType.NIBP_ERROR_OVERPRESSURE_PROTECTION -> {
                "超压保护"
            }

            DataType.NIBP_ERROR_NO_VALID_PULSE -> {
                "干预过多"
            }

            DataType.NIBP_ERROR_RESULT_FAULT -> {
                "结果错误"
            }
            DataType.NIBP_ERROR_AIR_LEAKAG -> {
                "漏气"
            }
            else -> {
                ""
            }
        }
    }

    private fun getECGResultMsg(resultCode: Int): String {
        return when (resultCode) {
            ECGFile.ECG_RESULT_00 -> "节律无异常"
            ECGFile.ECG_RESULT_01 -> "疑似心跳稍快 请注意休息"
            ECGFile.ECG_RESULT_02 -> "疑似心跳过快 请注意休息"
            ECGFile.ECG_RESULT_03 -> "疑似阵发性心跳过快 请咨询医生"
            ECGFile.ECG_RESULT_04 -> "疑似心跳稍缓 请注意休息"
            ECGFile.ECG_RESULT_05 -> "疑似心跳过缓 请注意休息"
            ECGFile.ECG_RESULT_06 -> "疑似心跳间期缩短 请咨询医生"
            ECGFile.ECG_RESULT_07 -> "疑似心跳间期不规则 请咨询医生"
            ECGFile.ECG_RESULT_08 -> "疑似心跳稍快伴有心跳间期缩短 请咨询医生"
            ECGFile.ECG_RESULT_09 -> "疑似心跳稍缓伴有心跳间期缩短 请咨询医生"
            ECGFile.ECG_RESULT_0a -> "疑似心跳稍缓伴有心跳间期不规则 请咨询医生"
            ECGFile.ECG_RESULT_0b -> "波形有漂移"
            ECGFile.ECG_RESULT_0c -> "疑似心跳过快伴有波形漂移 请咨询医生"
            ECGFile.ECG_RESULT_0d -> "疑似心跳过缓伴有波形漂移 请咨询医生"
            ECGFile.ECG_RESULT_0e -> "疑似心跳间期缩短伴有波形漂移 请咨询医生"
            ECGFile.ECG_RESULT_0f -> "疑似心跳间期不规则伴有波形漂移 请咨询医生"
            ECGFile.ECG_RESULT_ff -> "信号较差，请重新测量"
            else -> ""
        }

    }

    fun release() {
        if (currentDevice != null) {
            client.DisConnect(instance.currentDevice!!)
            currentDevice = null
        }
    }

    private var bluetoothListener: OnBlueToothCallback? = null

    interface OnBlueToothCallback {
        fun onStartDiscovery()

        fun OnDiscoveryCompleted(devices: MutableList<BluetoothDevice>)

        fun onConnectSuccess()

        fun onConnectError(error: String)

        fun onFindDevice(device: BluetoothDevice)
    }
}