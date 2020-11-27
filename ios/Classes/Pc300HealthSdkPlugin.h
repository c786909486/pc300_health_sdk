#import <Flutter/Flutter.h>


static NSString *const onConnectSuccess = @"onConnectSuccess";
static NSString *const onConnectError = @"onConnectError";
static NSString *const OnGetNIBPResult = @"OnGetNIBPResult";
static NSString *const OnGetECGAction = @"OnGetECGAction";
static NSString *const OnGetNIBPRealTime = @"OnGetNIBPRealTime";
static NSString *const OnGetECGRealTime = @"OnGetECGRealTime";
static NSString *const OnGetNIBPStatus = @"OnGetNIBPStatus";
static NSString *const OnGetPowerOff = @"OnGetPowerOff";
static NSString *const OnGetECGResult = @"OnGetECGResult";
static NSString *const OnGetDeviceID = @"OnGetDeviceID";
static NSString *const OnGetGlu = @"OnGetGlu";
static NSString *const OnGetNIBPAction = @"OnGetNIBPAction";
static NSString *const OnGetSpO2Status = @"OnGetSpO2Status";
static NSString *const OnGetDeviceVer = @"OnGetDeviceVer";
static NSString *const OnGetTmpStatus = @"OnGetTmpStatus";
static NSString *const OnGetTmp = @"OnGetTmp";
static NSString *const OnGetECGVer = @"OnGetECGVer";
static NSString *const OnGetSpO2Wave = @"OnGetSpO2Wave";
static NSString *const OnGetSpO2Param = @"OnGetSpO2Param";


@interface Pc300HealthSdkPlugin : NSObject<FlutterPlugin>

- (void)handleMethodCallWithName:(NSString *)methodName withParm:(NSDictionary *)map;

@end
