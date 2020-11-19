//
//  CRCommon.h
//  CreativeHealthSDK
//
//  Created by Creative on 14-7-9.
//  Copyright (c) 2014年 creative. All rights reserved.
//

#ifndef CreativeHealthSDK_CRCommon_h
#define CreativeHealthSDK_CRCommon_h

#define BUFFERCOUNT 100


Byte pBuffer[BUFFERCOUNT];  //蓝牙写入数据

//缓冲区
struct dataWave
{
    BOOL bPulse;
    int nWave;
};
struct spo2Data
{
    BOOL bProbeOff;
    int nSpO2;
    int nPR;
    int nPi;
    int nMode;
    int nPower;
    int nStatus;
    int nBattery;
    
};
struct ecgWave
{
    int frameNum;
    struct dataWave wave[25];
};

int nBufferTail;
int nBufferHead;
int nBufferValue;

BOOL bAnalyzePackage;
BOOL bWaveTimer;  //一旦监听到数据，就置true

#endif
