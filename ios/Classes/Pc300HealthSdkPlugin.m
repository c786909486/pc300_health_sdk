#import "Pc300HealthSdkPlugin.h"
#import "BlueManageUtils.h"

@implementation Pc300HealthSdkPlugin
{
    FlutterMethodChannel *methodChannel;
    BlueManageUtils *manageUtils;
}
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
    FlutterMethodChannel* channel = [FlutterMethodChannel
                                     methodChannelWithName:@"pc300_health_sdk"
                                     binaryMessenger:[registrar messenger]];
    Pc300HealthSdkPlugin* instance = [[Pc300HealthSdkPlugin alloc] initWithChannel:channel registrar:registrar messenger:[registrar messenger]];
    [registrar addMethodCallDelegate:instance channel:channel];
}

- (instancetype)initWithChannel:(FlutterMethodChannel *)channel
                      registrar:(NSObject<FlutterPluginRegistrar>*)registrar
                      messenger:(NSObject<FlutterBinaryMessenger>*)messenger {
    
    if (self) {
        self->methodChannel = channel;
        self->manageUtils =  [BlueManageUtils shareEngine];
    }
    
    return self;
}

- (void)handleMethodCallWithName:(NSString *)methodName withParm:(NSDictionary *)map
{
    if ([methodName isEqualToString:onConnectSuccess])
    {
        ///链接成功
        NSDictionary *parm = @{
            @"success": @YES,
            @"message": @"success"
        };
        [self->methodChannel invokeMethod:@"onConnectSuccess" arguments:[self dataToJsonString:parm]];
    }
    else if([methodName isEqualToString:onConnectError])
    {
        NSDictionary *parm = @{
            @"success": @NO,
            @"message": @"error"
        };
        [self->methodChannel invokeMethod:@"onConnectError" arguments:[self dataToJsonString:parm]];
    }
    else if([methodName isEqualToString:OnGetNIBPResult])
    {
        [self->methodChannel invokeMethod:@"onGetNIBPResult" arguments:[self dataToJsonString:map]];
    }
    else if([methodName isEqualToString:OnGetECGAction])
    {
        [self->methodChannel invokeMethod:@"onGetECGAction" arguments:[self dataToJsonString:map]];
    }
    else if([methodName isEqualToString:OnGetNIBPRealTime])
    {
        [self->methodChannel invokeMethod:@"onGetNIBPRealTime" arguments:[self dataToJsonString:map]];
    }
    else if([methodName isEqualToString:OnGetECGRealTime])
    {
        [self->methodChannel invokeMethod:@"onGetECGRealTime" arguments:[self dataToJsonString:map]];
    }
    else if([methodName isEqualToString:OnGetNIBPStatus])
    {
        [self->methodChannel invokeMethod:@"onGetNIBPStatus" arguments:[self dataToJsonString:map]];
    }
    else if([methodName isEqualToString:OnGetPowerOff])
    {
        [self->methodChannel invokeMethod:@"onGetPowerOff" arguments:[self dataToJsonString:map]];
    }
    else if([methodName isEqualToString:OnGetECGResult])
    {
        [self->methodChannel invokeMethod:@"onGetECGResult" arguments:[self dataToJsonString:map]];
    }
    else if([methodName isEqualToString:OnGetDeviceID])
    {
        [self->methodChannel invokeMethod:@"onGetDeviceID" arguments:[self dataToJsonString:map]];
    }
    else if([methodName isEqualToString:OnGetGlu])
    {
        [self->methodChannel invokeMethod:@"onGetGlu" arguments:[self dataToJsonString:map]];
    }
    else if([methodName isEqualToString:OnGetNIBPAction])
    {
        [self->methodChannel invokeMethod:@"onGetNIBPAction" arguments:[self dataToJsonString:map]];
    }
    else if([methodName isEqualToString:OnGetSpO2Status])
    {
        [self->methodChannel invokeMethod:@"onGetSpO2Status" arguments:[self dataToJsonString:map]];
    }
    else if([methodName isEqualToString:OnGetDeviceVer])
    {
        [self->methodChannel invokeMethod:@"onGetDeviceVer" arguments:[self dataToJsonString:map]];
    }
    else if([methodName isEqualToString:OnGetTmpStatus])
    {
        [self->methodChannel invokeMethod:@"onGetTmpStatus" arguments:[self dataToJsonString:map]];
    }
    else if([methodName isEqualToString:OnGetTmp])
    {
        [self->methodChannel invokeMethod:@"onGetTmp" arguments:[self dataToJsonString:map]];
    }
    else if([methodName isEqualToString:OnGetECGVer])
    {
        [self->methodChannel invokeMethod:@"onGetECGVer" arguments:[self dataToJsonString:map]];
    }
    else if([methodName isEqualToString:OnGetSpO2Wave])
    {
        [self->methodChannel invokeMethod:@"onGetSpO2Wave" arguments:[self dataToJsonString:map]];
    }
    else if([methodName isEqualToString:OnGetSpO2Param])
    {
        [self->methodChannel invokeMethod:@"onGetSpO2Param" arguments:[self dataToJsonString:map]];
    }
}
- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result
{
    if ([@"getPlatformVersion" isEqualToString:call.method])
    {
        result([@"iOS " stringByAppendingString:[[UIDevice currentDevice] systemVersion]]);
    }
    else if ([@"isOpen" isEqualToString:call.method])
    {
        /**
         *
         *  * 蓝牙状态
         */
        result(@([self->manageUtils isOpen]));
    }
    else if ([@"startDiscovery" isEqualToString:call.method])
    {
        /**
         *
         *  * 搜索蓝牙设备
         */
        float time = 10;
        if (call.arguments[@"maxTime"] != nil) time = [call.arguments[@"maxTime"] floatValue];
        
        [self->manageUtils startScan:time scanResult:^(NSMutableArray * _Nonnull deviceList) {
            NSLog(@"_methodChannel - 打印%@",self->methodChannel);
            NSLog(@"_manageUtils - 打印%@",self->manageUtils);
            [self->methodChannel invokeMethod:@"onDiscoveryComplete" arguments:[self dataToJsonString:deviceList]];
        }];
    }
    else if ([@"connect" isEqualToString:call.method])
    {
        /**
         *
         *  * 连接设备
         */
        NSString *address = call.arguments[@"address"];
        [self->manageUtils connectDevice:address];
    }
    else if ([@"disConnect" isEqualToString:call.method])
    {
        /**
         *
         *  * 断开连接
         */
        [self->manageUtils disconnectDevice];
    }
    else if ([@"getBondedDevices" isEqualToString:call.method])
    {
        /**
         *
         *  * 获取设备列表
         */
        result([self dataToJsonString:[self->manageUtils GetDeviceList]]);
    }
    else if ([@"setNIBPAction" isEqualToString:call.method])
    {
        /**
         * @Description 血压测量控制
         **/
        bool startMeasure = call.arguments[@"startMeasure"];
        [self->manageUtils SetNIBPAction:startMeasure];
    }
    else if ([@"setECGMotion" isEqualToString:call.method])
    {
        /**
         * @Description 心电测量控制
         **/
        bool startMeasure = call.arguments[@"startMeasure"];
        [self->manageUtils SetECGAction:startMeasure];
    }
    else if ([@"stopMeasure" isEqualToString:call.method])
    {
        /**
         * @Description 停止接受数据
         **/
        [[CRSpotCheck sharedInstance] closeTimerSpotCheck];
    }
    else if ([@"continueMeasure" isEqualToString:call.method])
    {
        /**
         * @Description 恢复接受数据
         **/
        [[CRSpotCheck sharedInstance] restartTimerSpotCheck];
    }
    else if ([@"queryDeviceVer" isEqualToString:call.method])
    {
        ///查询设备版本信息
        [self->manageUtils QueryDeviceVer];
    }
    else if ([@"queryNIBPStatus" isEqualToString:call.method])
    {
        ///查询血压模块状态
        [self->manageUtils QueryNIBPStatus];
    }
    else if ([@"querySpO2Status" isEqualToString:call.method])
    {
        ///查询血氧模块状态
        [self->manageUtils QuerySpO2Status];
    }
    else if ([@"queryGluStatus" isEqualToString:call.method])
    {
        ///查询血糖模块状态
        [self->manageUtils QueryGluStatus];
    }
    else if ([@"queryTmpStatus" isEqualToString:call.method])
    {
        ///查询体温模块状态
        [self->manageUtils QueryTmpStatus];
    }
    else if ([@"queryECGVer" isEqualToString:call.method])
    {
        ///查询心电模块版本信息
        [self->manageUtils QueryEcgVer];
    }
    else
    {
        result(FlutterMethodNotImplemented);
    }
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
