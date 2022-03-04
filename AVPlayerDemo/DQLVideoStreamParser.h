//
//  BZXLVideoStreamParser.h
//  Le123PhoneClient
//
//  Created by niuzhaowang on 7/5/14.
//  Copyright (c) 2014 Ying Shi Da Quan. All rights reserved.
//

#import <Foundation/Foundation.h>
#define NTYUUIDString() [[NSUUID UUID] UUIDString]
#define isEmpty(aItem) \
    ( \
     aItem == nil \
     ||[aItem isEmpty] \
    )

NS_ASSUME_NONNULL_BEGIN
@interface BZXCDEService : NSObject
+ (instancetype)shared;

+ (long)startParserService;
//+ (void)testUtpServerWithUrl:(NSString*)url completedBlock:(void (^)(NSString*paredUrl, NSError*error))completeBlock;
//+ (void)testLivePlayUrl:(NSString*)url completeBlock:(void (^)(NSString*playUrl, NSString*stopUrl, NSError*error))completeBlock;

//是testUtpServerWithUrl:的同步方法
+ (NSString*_Nullable)getCDESpeededUrl:(NSString*)url;

#if 0 // 该函数叫暂时无调用
//+ (NSString*_Nullable)getCDESpeededUrlSync:(NSString*)url;
#endif

+ (BOOL)isCDEServiceReady;

+ (NSString*)port;
+ (NSString*)urlBody;
#if DEBUG
+ (NSString*)lastOriginVideoUrl;
#endif

//MARK:防盗链
+ (NSString * _Nullable)appendAntiStealArguments:(NSString * _Nullable) origionURL timeStamp:(NSTimeInterval)stamp;
+ (NSString*)antURLParameters:(NSTimeInterval)stamp;

//关闭所有的播放通道
//- (void)addPlayURL:(NSString*)urlString;
+ (void)stopPlay:(NSString*)urlString;
+ (void)stopStopService;
+ (void)activateService;

+ (NSString *)getAccelerateURL:(NSString*)url offset:(int)offset;

@end
NS_ASSUME_NONNULL_END

