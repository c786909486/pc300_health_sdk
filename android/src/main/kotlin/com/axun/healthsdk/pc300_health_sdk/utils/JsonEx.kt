package com.axun.healthsdk.pc300_health_sdk.utils

import com.alibaba.fastjson.JSON
import com.alibaba.fastjson.TypeReference

/**
 *@packageName com.axun.healthsdk.pc300_health_sdk.utils
 *@author kzcai
 *@date 2020/7/15
 */

/**
 * 使用Accessor来解析json的方法
 */
inline fun <reified K> String.parseAccessorJson(): K {
    return JSON.parseObject(this, object : TypeReference<K>() {}.type)
}

/**
 * 使用Accessor来序列化json的方法
 */
fun Any.toAccessorJson(): String {
    return JSON.toJSONString(this)
}