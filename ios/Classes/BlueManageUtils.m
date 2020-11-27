//
//  BlueManageUtils.m
//  pc300_health_sdk
//
//  Created by axun on 2020/11/19.
//

#import "BlueManageUtils.h"
#import "CRCreativeSDK.h"


@interface BlueManageUtils()<CreativeDelegate,SpotCheckDelegate>
@property (nonatomic, strong) Pc300HealthSdkPlugin *healthSdkPlugin;
@property (nonatomic, strong) CreativePeripheral *currentPeripheral;
@property (nonatomic, strong) NSMutableArray *deviceList;
//@property (nonatomic, copy) scanResult_block scanResult;
//@property (nonatomic, copy) OnConnectSuccess_block onConnectSuccess;

@end

@implementation BlueManageUtils

+ (instancetype)shareEngine
{
    static BlueManageUtils *_sharedEngine = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedEngine = [[[self class] alloc] init];
//        _sharedEngine.healthSdkPlugin = [[Pc300HealthSdkPlugin alloc] init];
        [CRCreativeSDK sharedInstance].delegate = _sharedEngine;
        [CRSpotCheck sharedInstance].delegate = _sharedEngine;
    });
    return _sharedEngine;
}

- (BOOL)isOpen
{
    switch ([CRCreativeSDK sharedInstance].isState) {
        case CENTRAL_STATE_POWEREDOFF:
            return NO;
            break;
        case CENTRAL_STATE_POWEREDON:
            return YES;
            break;
        default:
            return NO;
            break;
    }
}
- (void) startScan:(float)timeout
{
    [self.deviceList removeAllObjects];
    [[CRCreativeSDK sharedInstance] startScan:timeout];
}

- (void) stopScan
{
    [[CRCreativeSDK sharedInstance] stopScan];
}

- (NSMutableArray *) GetDeviceList
{
    return [[CRCreativeSDK sharedInstance] GetDeviceList];
}
- (void)connectDevice:(NSString *) myPeripheralAddress
{
    
    [[CRCreativeSDK sharedInstance] stopScan];
    for (CreativePeripheral *peripheral in [[CRCreativeSDK sharedInstance] GetDeviceList]) {
        if ([myPeripheralAddress isEqualToString:peripheral.peripheral.identifier.UUIDString]) {
            self.currentPeripheral = peripheral;
            NSLog(@"第一次拿到 - %@",self.currentPeripheral);
            [[CRCreativeSDK sharedInstance] connectDevice:peripheral];
        }
    }
}
- (void)disconnectDevice
{
    NSLog(@"断开连接时 - %@",self.currentPeripheral.advName);
    return [[CRCreativeSDK sharedInstance] disconnectDevice:self.currentPeripheral];
}

#pragma mark - CreativeDelegate
///当搜索到一个蓝牙设备时调用。
-(void)crManager:(CRCreativeSDK *)crManager OnFindDevice:(CreativePeripheral *)port
{
    
    if (port.advName != nil) {
        NSLog(@"%@ - %@",port.advName,port.peripheral.identifier);
        if ([port.advName containsString:@"PC_300"]) {
            [self.deviceList addObject:@{
                @"name":port.advName != nil ? port.advName : @"",
                @"address":port.peripheral.identifier.UUIDString,
                @"bondState":@(port.peripheral.state),
                @"type":@1,
            }];
        }
        
    }
}
///搜索完成时调用
-(void)OnSearchCompleted:(CRCreativeSDK *)crManager
{
//    if (self.scanResult) {
//        self.scanResult(self.deviceList);
//    }
    [self.methodChannel invokeMethod:@"onDiscoveryComplete" arguments:[self dataToJsonString:self.deviceList]];
}
///与设备连接成功时调用。
-(void)crManager:(CRCreativeSDK *)crManager OnConnected:(CreativePeripheral *)peripheral withResult:(resultCodeType)result CurrentCharacteristic:(CBCharacteristic *)theCurrentCharacteristic
{
    if (result == RESULT_SUCCESS) {
        [[CRSpotCheck sharedInstance] QueryDeviceVer:peripheral];
        NSDictionary *parm = @{
            @"success": @YES,
            @"message": @"success"
        };
        [self.methodChannel invokeMethod:@"onConnectSuccess" arguments:parm];//[self dataToJsonString:parm]
    } else {
        NSDictionary *parm = @{
            @"success": @NO,
            @"message": @"error"
        };
        [self.methodChannel invokeMethod:@"onConnectError" arguments:parm];
    }
    
}
///连接失败。
-(void)crManager:(CRCreativeSDK *)crManager OnConnectFail:(CBPeripheral *)port
{
    NSDictionary *parm = @{
        @"success": @NO,
        @"message": @"error"
    };
    [self.methodChannel invokeMethod:@"onConnectError" arguments:parm];
}

///血压测量控制
-(void) SetNIBPAction:(BOOL)bFlag
{
    [[CRSpotCheck sharedInstance] SetNIBPAction:bFlag port:self.currentPeripheral];
}
///心电测量控制
-(void) SetECGAction:(BOOL)bFlag
{
    [[CRSpotCheck sharedInstance] SetECGAction:bFlag port:self.currentPeripheral];
}
///查询设备版本信息
-(void) QueryDeviceVer
{
    [[CRSpotCheck sharedInstance] QueryDeviceVer:self.currentPeripheral];
}
///查询心电模块版本信息
-(void) QueryEcgVer
{
    [[CRSpotCheck sharedInstance] QueryEcgVer:self.currentPeripheral];
}
///查询血压模块状态
-(void) QueryNIBPStatus
{
    [[CRSpotCheck sharedInstance] QueryNIBPStatus:self.currentPeripheral];
}
///查询血氧模块状态
-(void) QuerySpO2Status
{
    [[CRSpotCheck sharedInstance] QuerySpO2Status:self.currentPeripheral];
}
///查询血糖模块状态
-(void) QueryGluStatus
{
    [[CRSpotCheck sharedInstance] QueryGluStatus:self.currentPeripheral];
}
///查询体温模块状态
-(void) QueryTmpStatus
{
    [[CRSpotCheck sharedInstance] QueryTmpStatus:self.currentPeripheral];
}
/**
 * 血压测量结果
 */
-(void)spotCheck:(CRSpotCheck *)spotCheck OnGetNIBPResult:(BOOL)bHR Pulse:(int)nPulse MAP:(int)nMap SYS:(int)nSys Dia:(int)nDia Grade:(int)nGrade BPErr:(int)nBPErr
{
    NSMutableDictionary *map = [NSMutableDictionary dictionary];
    map[@"bHR"] = @(bHR);
    map[@"nPulse"] =@(nPulse);
    map[@"nMAP"] = @(nMap);
    map[@"nSYS"] = @(nSys);
    map[@"nDIA"] = @(nDia);
    map[@"nGrade"] = @(nGrade);
    map[@"nBPErr"] = @(nBPErr);
    map[@"errorMsg"] = [self ShowNibpError:nBPErr];
//    [self.healthSdkPlugin handleMethodCallWithName:OnGetNIBPResult withParm:map];
    [self.methodChannel invokeMethod:@"onGetNIBPResult" arguments:map];
}
/**
 * 心电测量状态改变
 */
-(void)spotCheck:(CRSpotCheck *)spotCheck OnGetECGAction:(BOOL)bStart
{
    NSMutableDictionary *map = [NSMutableDictionary dictionary];
    map[@"bStart"] = @(bStart);
//    [self.healthSdkPlugin handleMethodCallWithName:OnGetECGAction withParm:map];
    [self.methodChannel invokeMethod:@"onGetECGAction" arguments:map];
}
/**
 * 获取到实时袖带压力值
 */
-(void)spotCheck:(CRSpotCheck *)spotCheck OnGetNIBPRealTime:(BOOL)bHeartBeat NIBP:(int)nNIBP
{
    NSMutableDictionary *map = [NSMutableDictionary dictionary];
    map[@"bHeartbeat"] = @(bHeartBeat);
    map[@"nBldPrs"] = @(nNIBP);
//    [self.healthSdkPlugin handleMethodCallWithName:OnGetNIBPRealTime withParm:map];
    [self.methodChannel invokeMethod:@"onGetNIBPRealTime" arguments:map];
}
/**
 * 获取心电实时数据
 */
-(void)spotCheck:(CRSpotCheck *)spotCheck OnGetECGRealTime:(struct ecgWave)wave HR:(int)nHR lead:(BOOL)bLeadOff
{
    NSMutableDictionary *map = [NSMutableDictionary dictionary];
    NSMutableArray *tempArr = [NSMutableArray array];
    for (int i = 0; i < 25; i++) {
        [tempArr addObject:@{
            @"data":@(wave.wave[i].nWave),
            @"flag":wave.wave[i].bPulse ? @1 : @0
        }];
    }
    map[@"ecgdata"] = @{@"data":tempArr,@"frameNum":@(wave.frameNum)};
    map[@"nHR"] = @(nHR);
    map[@"bLeadoff"] = @(bLeadOff);
//    [self.healthSdkPlugin handleMethodCallWithName:OnGetECGRealTime withParm:map];
    [self.methodChannel invokeMethod:@"onGetECGRealTime" arguments:map];
}
/**
 * 获取到血压模块状态
 */
-(void)spotCheck:(CRSpotCheck *)spotCheck OnGetNibpStatus:(int)nStatus HWMajor:(int)nHWMajor HWMinor:(int)nHWMinor SWMajor:(int)nSWMajor SWMinor:(int)nSWMinor
{
    NSMutableDictionary *map = [NSMutableDictionary dictionary];
    map[@"nStatus"] = @(nStatus);
    map[@"nHWMajor"] = @(nHWMajor);
    map[@"nHWMinor"] = @(nHWMinor);
    map[@"nSWMajor"] = @(nSWMajor);
    map[@"nSWMinor"] = @(nSWMinor);
//    [self.healthSdkPlugin handleMethodCallWithName:OnGetECGRealTime withParm:map];
    [self.methodChannel invokeMethod:@"onGetNIBPStatus" arguments:map];
}
/**
 * 下位机关机
 */
-(void)OnGetPowerOff:(CRSpotCheck *)spotCheck
{
    NSMutableDictionary *map = [NSMutableDictionary dictionary];
    map[@"result"] = @"finish";
//    [self.healthSdkPlugin handleMethodCallWithName:OnGetPowerOff withParm:map];
    [self.methodChannel invokeMethod:@"onGetPowerOff" arguments:map];
}
/**
 * 心电测量结果
 */
-(void)spotCheck:(CRSpotCheck *)spotCheck OnGetECGResult:(int)nResult HR:(int)nHR
{
    NSMutableDictionary *map = [NSMutableDictionary dictionary];
    map[@"nResult"] = @(nResult);
    map[@"nHR"] = @(nHR);
    map[@"resultMsg"] = [self getECGResultMsg:nResult];
//    [self.healthSdkPlugin handleMethodCallWithName:OnGetECGResult withParm:map];
    [self.methodChannel invokeMethod:@"onGetECGResult" arguments:map];
}
/**
 * 获取到设备ID
 */
-(void)spotCheck:(CRSpotCheck *)spotCheck OnGetDeviceID:(NSData *)sDeviceID
{
    NSMutableDictionary *map = [NSMutableDictionary dictionary];
    map[@"sDeviceID"] = [[NSString alloc] initWithData:sDeviceID encoding:NSUTF8StringEncoding];
//    [self.healthSdkPlugin handleMethodCallWithName:OnGetDeviceID withParm:map];
    [self.methodChannel invokeMethod:@"onGetDeviceID" arguments:map];
}
/**
 * 获取到血糖值
 * 血糖值只有在nResultStatus=0时有效
 */
-(void)spotCheck:(CRSpotCheck *)spotCheck OnGetGlu:(int)nGlu ResultStatus:(int) nGluStatus andUnit:(int)gluUnit
{
    NSMutableDictionary *map = [NSMutableDictionary dictionary];
    map[@"nGlu"] = @(nGlu);
    map[@"nGluStatus"] = @(nGluStatus);
    map[@"gluUnit"] = @(gluUnit);
//    [self.healthSdkPlugin handleMethodCallWithName:OnGetECGResult withParm:map];
    [self.methodChannel invokeMethod:@"onGetGlu" arguments:map];
}
/**
 * 与设备连接丢失 - iOSsdk没有这个接口
 */
/**
 * 血压测量状态改变
 */
-(void)spotCheck:(CRSpotCheck *)spotCheck OnGetNIBPAction:(BOOL)bStart
{
    NSMutableDictionary *map = [NSMutableDictionary dictionary];
    map[@"bStart"] = @(bStart);
//    [self.healthSdkPlugin handleMethodCallWithName:OnGetNIBPAction withParm:map];
    [self.methodChannel invokeMethod:@"onGetNIBPAction" arguments:map];
}
/**
 * 获取到血氧模块状态
 */
-(void)spotCheck:(CRSpotCheck *)spotCheck OnGetSpO2Status:(int)nStatus HWMajor:(int)nHWMajor HWMinor:(int)nHWMinor SWMajor:(int)nSWMajor SWMinor:(int)nSWMinor
{
    NSMutableDictionary *map = [NSMutableDictionary dictionary];
    map[@"nStatus"] = @(nStatus);
    map[@"nHWMajor"] = @(nHWMajor);
    map[@"nHWMinor"] = @(nHWMinor);
    map[@"nSWMajor"] = @(nSWMajor);
    map[@"nSWMinor"] = @(nSWMinor);
//    [self.healthSdkPlugin handleMethodCallWithName:OnGetSpO2Status withParm:map];
    [self.methodChannel invokeMethod:@"onGetSpO2Status" arguments:map];
}
/**
 * 获取到设备版本信息
 * 充电状态有3重，在DataType中定义
 * BATTERY_NO_CHARGE:没有充电
 * BATTERY_IN_CHARGING:正在充电
 * BATTERY_CHARGING_COMPLETED:充电完成
 */
-(void)spotCheck:(CRSpotCheck *)spotCheck OnGetDeviceVer:(int)nHWMajeor HWMinor:(int)nHWMinor SWMajor:(int)nSWMajeor SWMinor:(int)nSWMinor Power:(int)nPower
{
    NSMutableDictionary *map = [NSMutableDictionary dictionary];
    map[@"nPower"] = @(nPower);
    map[@"nHWMajor"] = @(nHWMajeor);
    map[@"nHWMinor"] = @(nHWMinor);
    map[@"nSWMajor"] = @(nSWMajeor);
    map[@"nSWMinor"] = @(nHWMinor);
    map[@"nBattery"] = @100;
//    [self.healthSdkPlugin handleMethodCallWithName:OnGetDeviceVer withParm:map];
    [self.methodChannel invokeMethod:@"onGetDeviceVer" arguments:map];
}
/**
 * 获取到体温模块状态
 */
-(void)spotCheck:(CRSpotCheck *)spotCheck OnGetTmpStatus:(int)nStatus HWMajor:(int)nHWMajor HWMinor:(int)nHWMinor SWMajor:(int)nSWMajor SWMinor:(int)nSWMinor
{
    NSMutableDictionary *map = [NSMutableDictionary dictionary];
    map[@"nStatus"] = @(nStatus);
    map[@"nHWMajor"] = @(nHWMajor);
    map[@"nSWMinor"] = @(nHWMinor);
    map[@"nSWMajor"] = @(nSWMajor);
    map[@"nHWMinor"] = @(nHWMinor);
//    [self.healthSdkPlugin handleMethodCallWithName:OnGetTmpStatus withParm:map];
    [self.methodChannel invokeMethod:@"onGetTmpStatus" arguments:map];
}
/**
 * 获取到体温数据
 * 体温值只有在nResultStatus=0时有效
 * 测量的体温值需要转换计算得到实际体温数据
 * nTmp/100+30=实际体温值 结果保留一位小数，不采用四舍五入方式，直接丢掉小数点2位之后的数。如：36.57 = 36.5
 */
-(void)spotCheck:(CRSpotCheck *)spotCheck OnGetTmp:(BOOL)bManualStart ProbeOff:(BOOL)ProbeOff Temp:(int)Tmp TempStatus:(int)TmpStatus ResultStatus:(int)nResultStatus
{
    NSMutableDictionary *map = [NSMutableDictionary dictionary];
    map[@"bManualStart"] = @(bManualStart);
    map[@"bProbeOff"] = @(ProbeOff);
    map[@"nTmp"] = @(Tmp);
    map[@"nTmpStatus"] = @(TmpStatus);
    map[@"nResultStatus"] = @(nResultStatus);
//    [self.healthSdkPlugin handleMethodCallWithName:OnGetTmp withParm:map];
    [self.methodChannel invokeMethod:@"onGetTmp" arguments:map];
}
-(void)spotCheck:(CRSpotCheck *)spotCheck OnGetTemp:(float)tempValue
{
    NSLog(@"%f",tempValue);
    NSMutableDictionary *map = [NSMutableDictionary dictionary];
    map[@"bManualStart"] = @"";
    map[@"bProbeOff"] = @"";
    map[@"nTmp"] = @(tempValue);
    map[@"nTmpStatus"] = @"";
    map[@"nResultStatus"] = @"";
//    [self.healthSdkPlugin handleMethodCallWithName:OnGetTmp withParm:map];
    [self.methodChannel invokeMethod:@"onGetTmp" arguments:map];
}
/**
 * 获取到心电模块版本
 */
-(void)spotCheck:(CRSpotCheck *)spotCheck OnGetECGVer:(int)nHWMajeor HWMinor:(int)nHWMinor SWMajor:(int)nSWMajeor SWMinor:(int)nSWMinor
{
    NSMutableDictionary *map = [NSMutableDictionary dictionary];
    map[@"nHWMajor"] = @(nHWMajeor);
    map[@"nHWMinor"] = @(nHWMinor);
    map[@"nSWMajor"] = @(nSWMajeor);
    map[@"nSWMinor"] = @(nSWMinor);
//    [self.healthSdkPlugin handleMethodCallWithName:OnGetECGVer withParm:map];
    [self.methodChannel invokeMethod:@"onGetECGVer" arguments:map];
}
/**
 * 获取到血氧波形数据
 */
-(void)spotCheck:(CRSpotCheck *)spotCheck OnGetSpo2Wave:(struct dataWave *)wave
{
    NSMutableDictionary *map = [NSMutableDictionary dictionary];
    NSMutableArray *tempArr = [NSMutableArray array];
    for (int i = 0; i < 10; i++) {
        [tempArr addObject:@{
            @"data":@(wave[i].nWave),
            @"flag":wave[i].bPulse ? @1 : @0
        }];
    }
    map[@"waveData"] = tempArr;
    [self.methodChannel invokeMethod:@"onGetSpO2Wave" arguments:map];
//    [self.healthSdkPlugin handleMethodCallWithName:OnGetSpO2Wave withParm:map];
}
/**
        * 获取到血氧参数
        */
-(void)spotCheck:(CRSpotCheck *)spotCheck OnGetSpo2Param:(BOOL)bProbeOff spo2Value:(int)nSpO2 prValue:(int)nPR piValue:(int)nPI mMode:(int)nMode spo2Status:(int)nStatus
{
    NSMutableDictionary *map = [NSMutableDictionary dictionary];
    map[@"nSpO2"] = @(nSpO2);
    map[@"nPR"] = @(nPR);
    map[@"nPI"] = @(nPI);
    map[@"nStatus"] = @(nStatus);
    map[@"nMode"] = @(nMode);
//    [self.healthSdkPlugin handleMethodCallWithName:OnGetSpO2Param withParm:map];
    [self.methodChannel invokeMethod:@"onGetSpO2Param" arguments:map];
}

- (NSMutableArray *)deviceList
{
    if (!_deviceList) {
        _deviceList = [NSMutableArray array];
    }
    return _deviceList;
}

-(NSString *) ShowNibpError:(int)nError
{
    NSString *message = @"";
    switch (nError) {
        case NIBP_ERROR_CUFF_NOT_WRAPPED:
            message = @"气袋没绑好";
            break;
        case NIBP_ERROR_OVERPRESSURE_PROTECTION:
            message = @"超压保护";
            break;
        case NIBP_ERROR_NO_VALID_PULSE:
            message = @"没有有效的脉冲测量";
            break;
        case NIBP_ERROR_EXCESSIVE_MOTION:
            message = @"干扰过多";
            break;
        case NIBP_ERROR_RESULT_FAULT:
            message = @"结果无效";
            break;
        case NIBP_ERROR_AIR_LEAKAG:
            message = @"漏气";
            break;
        case NIBP_ERROR_LOW_POWER:
            message = @"电池电量低，测量终止。";
            break;
        default:
            break;
    }
    return message;
}
-(NSString *) getECGResultMsg:(int)nResult
{
    NSString *message = @"";
    switch (nResult) {
        case 0:
            message = @"节律无异常";
            break;
        case 1:
            message = @"疑似心跳稍快 请注意休息";
            break;
        case 2:
            message = @"疑似心跳过快 请注意休息";
            break;
        case 3:
            message = @"疑似阵发性心跳过快 请咨询医生";
            break;
        case 4:
            message = @"疑似心跳稍缓 请注意休息";
            break;
        case 5:
            message = @"疑似心跳过缓 请注意休息";
            break;
        case 6:
            message = @"疑似心跳间期缩短 请咨询医生";
            break;
        case 7:
            message = @"疑似心跳间期不规则 请咨询医生";
            break;
        case 8:
            message = @"疑似心跳稍快伴有心跳间期缩短 请咨询医生";
            break;
        case 9:
            message = @"疑似心跳稍缓伴有心跳间期缩短 请咨询医生";
            break;
        case 10:
            message = @"疑似心跳稍缓伴有心跳间期不规则 请咨询医生";
            break;
        case 11:
            message = @"波形有漂移";
            break;
        case 12:
            message = @"疑似心跳过快伴有波形漂移 请咨询医生";
            break;
        case 13:
            message = @"疑似心跳过缓伴有波形漂移 请咨询医生";
            break;
        case 14:
            message = @"疑似心跳间期缩短伴有波形漂移 请咨询医生";
            break;
        case 15:
            message = @"疑似心跳间期不规则伴有波形漂移 请咨询医生";
            break;
        case 16:
            message = @"信号较差，请重新测量";
            break;
        default:
            break;
    }
    return message;
}

///data转json字符串
- (NSString *)dataToJsonString:(id)obj
{
    NSError *parseError = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:obj options:NSJSONWritingPrettyPrinted error:&parseError];
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    return jsonString;
}
@end
