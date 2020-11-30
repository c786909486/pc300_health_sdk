package com.axun.healthsdk.pc300_health_sdk.model

/**
 *@packageName com.axun.healthsdk.pc300_health_sdk.model
 *@author kzcai
 *@date 2020/7/15
 */
data class BlueDevice (
        var address:String?=null,
        var name:String?=null,
        var type:Int = 0,
        var bondState:Int = 0){



}
