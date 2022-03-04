//
//  CdeService.h
//
//  Created by yuanfeixiong@letv.com on 2014-11-12.
//  Copyright (C) 2014 LeTV
//

#import <Foundation/Foundation.h>

//
// CDE(Cloud Data Entry) Service
//
@interface ysdq_CdeService : NSObject

-(id)initWithParams:(NSString *)params; // startup service runtime
-(void)stop; // stop service runtime
-(int)versionNumber; // get cde version number, such as 843
-(int)port; // get service running http port
-(bool)ready; // is service ready
-(int)activate; // activate cde when application did become active
-(void)setNetworkType:(int)type; // set network type, 0: no network, 1: Mobile, 2: Wifi
-(void)setSystemProxySettings; // set system proxy settings to cde
-(bool)syncHttpRequest:(NSString *)url; // do sync http request
-(NSString *)versionString; // get cde version string, such as 0.8.43
-(NSString *)sdkVersion; // get cde sdk version, such as 0.1

-(NSString *)linkshellUrl:(NSString *)url; // get linkshell url
-(NSString *)linkshellUrl2:(NSString *)url usingCde:(bool)usingCde; // get linkshell url with options
-(NSString *)cacheUrlWithData:(NSString *)data ext:(NSString *)ext g3url:(NSString *)g3url other:(NSString *)other; // get cache url with data
-(NSString *)localPlayUrlWithFile:(NSString *)filePath; // get local m3u8 play url with file path
-(void)setChannelSeekPosition:(NSString *)linkshellUrl pos:(double)pos; // set seek position
-(int)getChannelSegmentData:(NSString *)linkshellUrl path:(NSString *)path trunMp4:(bool)trunMp4 requireTime:(double)requireTime width:(int *)width height:(int *)height errorCode:(int *)errorCode offsetTime:(double *)offsetTime duration:(double *)duration
						size:(int *)size; // get channel segment data by url

// new log api
-(int)writeLogTrace: (NSString *)text;
-(int)writeLogInfo: (NSString *)text;
-(int)writeLogWarining: (NSString *)text;
-(int)writeLogError: (NSString *)text;

// urls only
-(NSString *)playUrl:(NSString *)linkshellUrl; // get play url
-(NSString *)playUrl2:(NSString *)linkshellUrl other:(NSString *)other; // get play url with others
-(NSString *)stopUrl:(NSString *)linkshellUrl; // get stop url
-(NSString *)pauseUrl:(NSString *)linkshellUrl; // get pause url
-(NSString *)resumeUrl:(NSString *)linkshellUrl; // get resume url
-(NSString *)statePlayUrl:(NSString *)linkshellUrl; // get state play url
-(NSString *)supportUrl:(NSString *)contactNumber; // get support url

-(NSString *)playErrorsUrl:(NSString *)linkshellUrl; // get play errors url

// actions with sync http
-(NSString *)playUrlSync:(NSString *)linkshellUrl; // get play url  sync
-(NSString *)playUrlSync2:(NSString *)linkshellUrl other:(NSString *)other; // get play url sync with others
-(bool)stopPlay:(NSString *)linkshellUrl; // do stop play, sync
-(bool)pausePlay:(NSString *)linkshellUrl; // do pause play, sync
-(bool)resumePlay:(NSString *)linkshellUrl; // do resume play, sync
-(NSString *)supportNumber:(NSString *)contactNumber; // get support number

// new state api
-(bool)stateUrlExists:(NSString *)linkshellUrl;
-(int)stateTotalDuration:(NSString *)linkshellUrl;
-(int)stateDownloadedDuration:(NSString *)linkshellUrl;
-(double)stateDownloadedPercent:(NSString *)linkshellUrl;
-(int)stateUrgentReceiveSpeed:(NSString *)linkshellUrl;
-(int)stateLastReceiveSpeed:(NSString *)linkshellUrl;

/**
 CDE预缓冲方法，获取预缓冲URL并且开始预缓冲

 @param originURL 原始url
 @param offset 播放历史，单位s
 @return 预缓冲后的URL，需要传给playURL方法
 */
- (NSString*)fetchAccelerateURL:(NSString *)originURL offset:(int)offset;

@end
