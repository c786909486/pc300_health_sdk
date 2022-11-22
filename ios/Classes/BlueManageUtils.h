//
//  BlueManageUtils.h
//  pc300_health_sdk/Users/axun/Desktop/BlueManageUtils.m
//
//  Created by axun on 2020/11/19.
//
#if TARGET_IPHONE_SIMULATOR

#import <Foundation/Foundation.h>
#import "Pc300HealthSdkPlugin.h"


//typedef void(^scanResult_block)(NSMutableArray *deviceList);
//typedef void(^OnConnectSuccess_block)(int isConnect);
@interface BlueManageUtils : NSObject

@end
#else
#import <Foundation/Foundation.h>
#import "CRSpotCheck.h"
#import "Pc300HealthSdkPlugin.h"

NS_ASSUME_NONNULL_BEGIN

//typedef void(^scanResult_block)(NSMutableArray *deviceList);
//typedef void(^OnConnectSuccess_block)(int isConnect);
@interface BlueManageUtils : NSObject

+ (instancetype)shareEngine;
@property (nonatomic, strong) FlutterMethodChannel *methodChannel;

- (BOOL) isOpen;

- (void) startScan:(float)timeout;

- (void) stopScan;

/**

* 获取搜索到的设备列表 */

-(NSMutableArray *)GetDeviceList;
/**

* 连接一个蓝牙设备 */

- (void)connectDevice:(NSString *) myPeripheralAddress;

/* 断开当前蓝牙的连接 */
- (void)disconnectDevice;

-(void) SetNIBPAction:(BOOL)bFlag;
-(void) SetECGAction:(BOOL)bFlag;
-(void) QueryDeviceVer;
-(void) QueryEcgVer;
-(void) QueryNIBPStatus;
-(void) QuerySpO2Status;
-(void) QueryGluStatus;
-(void) QueryTmpStatus;
@end

NS_ASSUME_NONNULL_END

#endif

