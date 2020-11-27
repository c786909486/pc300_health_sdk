#import "Pc300HealthSdkPlugin.h"
#import "BlueManageUtils.h"

@interface Pc300HealthSdkPlugin()

//@property (nonatomic, strong) FlutterMethodChannel *methodChannel;
@property (nonatomic, strong) BlueManageUtils *manageUtils;

@end

@implementation Pc300HealthSdkPlugin
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
//        self.methodChannel = channel;
        [BlueManageUtils shareEngine].methodChannel = channel;
        self.manageUtils =  [BlueManageUtils shareEngine];
        
    }
    
    return self;
}

- (void)dealloc
{
    NSLog(@"我走了啊啊啊啊啊啊啊啊啊");
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
        result(@([self.manageUtils isOpen]));
    }
    else if ([@"startDiscovery" isEqualToString:call.method])
    {
        /**
         *
         *  * 搜索蓝牙设备
         */
        float time = 10;
        if (call.arguments[@"maxTime"] != nil) time = [call.arguments[@"maxTime"] floatValue];
        [self.manageUtils startScan:time];
    }
    else if ([@"connect" isEqualToString:call.method])
    {
        /**
         *
         *  * 连接设备
         */
        NSString *address = call.arguments[@"address"];
        [self.manageUtils connectDevice:address];
    }
    else if ([@"disConnect" isEqualToString:call.method])
    {
        /**
         *
         *  * 断开连接
         */
        [self.manageUtils disconnectDevice];
    }
    else if ([@"getBondedDevices" isEqualToString:call.method])
    {
        /**
         *
         *  * 获取设备列表
         */
        NSMutableArray *tempArr = [NSMutableArray array];
        for (CreativePeripheral *peripheral in [self.manageUtils GetDeviceList]) {
            if ([peripheral.advName containsString:@"PC_300"]) {
                [tempArr addObject:@{
                    @"name":peripheral.advName != nil ? peripheral.advName : @"",
                    @"address":peripheral.peripheral.identifier.UUIDString,
                    @"bondState":@(peripheral.peripheral.state),
                    @"type":@1,
                }];
            }
        }
        result([self dataToJsonString:tempArr]);
    }
    else if ([@"setNIBPAction" isEqualToString:call.method])
    {
        /**
         * @Description 血压测量控制
         **/
        bool startMeasure = call.arguments[@"startMeasure"];
        [self.manageUtils SetNIBPAction:startMeasure];
    }
    else if ([@"setECGMotion" isEqualToString:call.method])
    {
        /**
         * @Description 心电测量控制
         **/
        bool startMeasure = call.arguments[@"startMeasure"];
        [self.manageUtils SetECGAction:startMeasure];
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
        [self.manageUtils QueryDeviceVer];
    }
    else if ([@"queryNIBPStatus" isEqualToString:call.method])
    {
        ///查询血压模块状态
        [self.manageUtils QueryNIBPStatus];
    }
    else if ([@"querySpO2Status" isEqualToString:call.method])
    {
        ///查询血氧模块状态
        [self.manageUtils QuerySpO2Status];
    }
    else if ([@"queryGluStatus" isEqualToString:call.method])
    {
        ///查询血糖模块状态
        [self.manageUtils QueryGluStatus];
    }
    else if ([@"queryTmpStatus" isEqualToString:call.method])
    {
        ///查询体温模块状态
        [self.manageUtils QueryTmpStatus];
    }
    else if ([@"queryECGVer" isEqualToString:call.method])
    {
        ///查询心电模块版本信息
        [self.manageUtils QueryEcgVer];
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
