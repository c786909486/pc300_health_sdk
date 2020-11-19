//
//  CRSpotCheck.h
//  health
//
//  Created by Creative on 14-8-21.
//  Copyright (c) 2014年 creative. All rights reserved.
//

#import <Foundation/Foundation.h>
//#import "BLEPort.h"
#import "CRCommon.h"
#import "CreativePeripheral.h"


#define MODE_OVER 0
#define MODE_ING 1
#define MODE_NULL 255
#define NIBP_ERROR_NO_ERROR 0
#define NIBP_ERROR_CUFF_NOT_WRAPPED 1
#define NIBP_ERROR_OVERPRESSURE_PROTECTION 2
#define NIBP_ERROR_NO_VALID_PULSE 3
#define NIBP_ERROR_EXCESSIVE_MOTION 4
#define NIBP_ERROR_RESULT_FAULT 5
#define NIBP_ERROR_AIR_LEAKAG 6
#define NIBP_ERROR_LOW_POWER 7




@protocol  SpotCheckDelegate;
@interface CRSpotCheck : NSObject
{
    //CreativePeripheral *SpotCheckPort;

}
@property (assign,nonatomic) id<SpotCheckDelegate> delegate;
+(CRSpotCheck *)sharedInstance;
-(void) SetNIBPAction:(BOOL)bFlag port:(CreativePeripheral *)currentPort;
-(void) SetECGAction:(BOOL)bFlag port:(CreativePeripheral *)currentPort;
-(void) QueryDeviceVer:(CreativePeripheral *)currentPort;
-(void) QueryEcgVer:(CreativePeripheral *)currentPort;
//-(void) ReissueECGPack;
-(void) QueryNIBPStatus:(CreativePeripheral *)currentPort;
-(void) QuerySpO2Status:(CreativePeripheral *)currentPort;
-(void) QueryGluStatus:(CreativePeripheral *)currentPort;
-(void) QueryTmpStatus:(CreativePeripheral *)currentPort;

-(void) initSpotCheckPort:(CreativePeripheral *)healthPort;
-(void)closeTimerSpotCheck;
-(void)restartTimerSpotCheck;
//@property (nonatomic) CreativePeripheral *SpotCheckPort;
-(void)setTimePC300:(CreativePeripheral *)currentPort Time:(NSString *)time;
@end


@protocol SpotCheckDelegate <NSObject>
@required




@optional
-(void)spotCheck:(CRSpotCheck *)spotCheck OnGetDeviceID:(NSData *)sDeviceID;

-(void)spotCheck:(CRSpotCheck *)spotCheck OnGetDeviceVer:(int)nHWMajeor HWMinor:(int)nHWMinor SWMajor:(int)nSWMajeor SWMinor:(int)nSWMinor Power:(int)nPower;

-(void)spotCheck:(CRSpotCheck *)spotCheck OnGetECGVer:(int)nHWMajeor HWMinor:(int)nHWMinor SWMajor:(int)nSWMajeor SWMinor:(int)nSWMinor;


-(void)spotCheck:(CRSpotCheck *)spotCheck OnGetSpo2Wave:(struct dataWave *)wave;



-(void)spotCheck:(CRSpotCheck *)spotCheck OnGetECGRealTime:(struct ecgWave)wave HR:(int)nHR lead:(BOOL)bLeadOff  ;

-(void)spotCheck:(CRSpotCheck *)spotCheck OnGetECGResult:(int)nResult HR:(int)nHR;

-(void)spotCheck:(CRSpotCheck *)spotCheck OnGetTmp:(BOOL)bManualStart ProbeOff:(BOOL)ProbeOff Temp:(int)Tmp TempStatus:(int)TmpStatus ResultStatus:(int)nResultStatus;

-(void)spotCheck:(CRSpotCheck *)spotCheck OnGetGlu:(int)nGlu ResultStatus:(int) nGluStatus andUnit:(int)gluUnit;

-(void)spotCheck:(CRSpotCheck *)spotCheck OnGetNibpStatus:(int)nStatus HWMajor:(int)nHWMajor HWMinor:(int)nHWMinor SWMajor:(int)nSWMajor SWMinor:(int)nSWMinor;

-(void)spotCheck:(CRSpotCheck *)spotCheck OnGetSpO2Status:(int)nStatus HWMajor:(int)nHWMajor HWMinor:(int)nHWMinor SWMajor:(int)nSWMajor SWMinor:(int)nSWMinor;

-(void)spotCheck:(CRSpotCheck *)spotCheck OnGetGluStatus:(int)nStatus HWMajor:(int)nHWMajor HWMinor:(int)nHWMinor SWMajor:(int)nSWMajor SWMinor:(int)nSWMinor;

-(void)spotCheck:(CRSpotCheck *)spotCheck OnGetTmpStatus:(int)nStatus HWMajor:(int)nHWMajor HWMinor:(int)nHWMinor SWMajor:(int)nSWMajor SWMinor:(int)nSWMinor;
-(void)spotCheck:(CRSpotCheck *)spotCheck OnGetEcgGain:(int)gain;
-(void)spotCheck:(CRSpotCheck *)spotCheck OnGetNIBPAction:(BOOL)bStart;

-(void)spotCheck:(CRSpotCheck *)spotCheck OnGetECGAction:(BOOL)bStart;

-(void)OnGetPowerOff:(CRSpotCheck *)spotCheck;
-(void)spotCheck:(CRSpotCheck *)spotCheck OnGetSpo2Param:(BOOL)bProbeOff spo2Value:(int)nSpO2 prValue:(int)nPR piValue:(int)nPI mMode:(int)nMode spo2Status:(int)nStatus;
-(void)spotCheck:(CRSpotCheck *)spotCheck OnGetTemp:(float)tempValue;

//-(void)spotCheck:(CRSpotCheck *)spotCheck OnGetNibpError:(int)nError;
-(void)spotCheck:(CRSpotCheck *)spotCheck OnGetNIBPResult:(BOOL)bHR Pulse:(int)nPulse MAP:(int)nMap SYS:(int)nSys Dia:(int)nDia Grade:(int)nGrade BPErr:(int)nBPErr;

-(void)spotCheck:(CRSpotCheck *)spotCheck OnGetNIBPRealTime:(BOOL)bHeartBeat NIBP:(int)nNIBP;

-(void)timeSynchroniztion:(CRSpotCheck *)spotCheck;

@end

