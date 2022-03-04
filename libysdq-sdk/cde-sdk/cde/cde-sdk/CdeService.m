//
//  CdeService.m
//  CdeService
//
//  Created by yuanfeixiong on 14-11-10.
//  Copyright (c) 2014 LeTV. All rights reserved.
//

#import "CdeService.h"
#import "CdeUrl.h"
#import "CdeBase64.h"
#import "CdeNetBroadcastReceiver.h"
#import "CdeReachability.h"
#import "UIDevice-Hardware.h"
#include "service.h"
#include <sys/time.h>
#include <CFNetwork/CFProxySupport.h>

@interface ysdq_CdeService ()

@property (nonatomic,strong) ysdq_CdeNetBroadcastReceiver *netBroadcastReceiver;
@property (nonatomic,assign) long handle;
@property (nonatomic,assign) BOOL open;

@end

@implementation ysdq_CdeService

-(id)initWithParams:(NSString *)params
{
    _open = false;
    NSString *homePath = NSHomeDirectory();
    if(self=[super init]) {
		UIDevice *device = [UIDevice currentDevice];
		NSString *identifier = [[NSBundle mainBundle] bundleIdentifier];
		NSString *realParams = [NSString stringWithFormat:@"hwtype=%@&ostype=ios&cde_home=%@&osversion=%@&%@", [device model],homePath,[device systemVersion], params];
		_handle = ysdq_cdeStartService([realParams UTF8String], identifier ? [identifier UTF8String] : "unknown");
        [self writeLogInfo: [NSString stringWithFormat:@"cde::sdk::initWithParams: Start service, handle: %ld, port: %ld",_handle, ysdq_cdeGetServicePort()]];
        if (_handle > 0) {
			[self setSystemProxySettings];
            _netBroadcastReceiver = [[ysdq_CdeNetBroadcastReceiver alloc] initWithService:self];
			//int res = initLinkShell();
            int res = 0;
            _open = true;
            [self writeLogInfo: [NSString stringWithFormat:@"cde::sdk::initWithParams: Init linkshell result: %@, %d,open(%@)",[self description], res ,_open ? @"true" : @"false"]];
        }
    }
    return self;
}

-(void)stop
{
    self.open = false;
    [self writeLogInfo: [NSString stringWithFormat:@"cde::sdk::stop: %@, open(%@)",[self description], self.open ? @"true" : @"false"]];
    @try {
        ysdq_cdeStopService();
    } @catch (NSException *exception) {
        NSLog(@"stop service :%@",exception);
    } @finally {
        
    }
	if( self.netBroadcastReceiver != nil ){
		[self.netBroadcastReceiver stop];
		self.netBroadcastReceiver = nil;
	}
}

-(int)port
{
    if (self.handle > 0) {
        return (int)ysdq_cdeGetServicePort();
	}
	return 0;
}

-(bool)ready
{
	return self.handle > 0 && ysdq_cdeGetServicePort() > 0;
}

-(int)activate
{
	[self setSystemProxySettings];
	return (int)ysdq_cdeActivateService();
}

-(void)setNetworkType:(int)type
{
	int cdeType = 0;
	switch (type) {
		case NotReachable: cdeType = 0; break;
		case ReachableViaWiFi: cdeType = 3; break;
		case ReachableViaWWAN: cdeType = 2; break;
		default: break;
	}
	
	NSLog(@"CDE: setNetworkType(0:no network; 1:ethernet; 2:mobile; 3:wifi) : %@",[NSString stringWithFormat:@"%d", cdeType]);
	ysdq_cdeSetNetworkType(cdeType);
	
	[self setSystemProxySettings];
}

-(void)setSystemProxySettings
{
	NSString *proxyUrl = @"";
	do
	{
		NSDictionary *proxySettings = CFBridgingRelease(CFNetworkCopySystemProxySettings());
		if( proxySettings == nil ){
			break;
		}
		
        NSURL *url = [NSURL URLWithString:@"http://www.letv.com/"];
		CFURLRef proxyRefUrl = (CFURLRef)CFBridgingRetain(url);
        CFDictionaryRef proxySettingsRef = (CFDictionaryRef)CFBridgingRetain(proxySettings);
        CFArrayRef ref = CFNetworkCopyProxiesForURL(proxyRefUrl, proxySettingsRef);
		NSArray *proxies = CFBridgingRelease(ref);
        CFRelease(proxyRefUrl);
        CFRelease(proxySettingsRef);
		if( proxies == nil ){
			break;
		}
		
		NSUInteger proxyCount = [proxies count];
		for( NSUInteger n = 0; n < proxyCount; n ++ ){
			NSDictionary *settings = [proxies objectAtIndex:n];
			if( settings == nil ){
				continue;
			}
			
			NSString *proxyHost = [settings objectForKey:(NSString *)kCFProxyHostNameKey];
			NSString *proxyPort = [settings objectForKey:(NSString *)kCFProxyPortNumberKey];
			NSString *proxyType = [settings objectForKey:(NSString *)kCFProxyTypeKey];
			NSString *proxyUsername = [settings objectForKey:(NSString *)kCFProxyUsernameKey];
			NSString *proxyPassword = [settings objectForKey:(NSString *)kCFProxyPasswordKey];
			NSString *protocolType = @"";
			if( proxyType != nil ){
				if( [proxyType compare: @"kCFProxyTypeHTTP"] == 0 ){
					protocolType = @"http";
				}
			}
			
			if( proxyUsername == nil ) proxyUsername = @"";
			if( proxyPassword == nil ) proxyPassword = @"";
			if( [protocolType compare:@""] != 0 ){
				proxyUrl = [NSString stringWithFormat:@"%@://%@:%@/proxy?enc=base64&username=%@&password=%@", protocolType, proxyHost, proxyPort,
							ysdq_cdeUrlBase64EncodedString(proxyUsername),
							ysdq_cdeUrlBase64EncodedString(proxyPassword)];
				break;
			}
		}
	}while(false);
	
	NSLog(@"CDE: Detect system proxy url=%@", proxyUrl);
	ysdq_cdeSetGlobalProxyUrl([proxyUrl UTF8String]);
}

-(bool)syncHttpRequest:(NSString *)url
{
	NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
	[request setHTTPMethod:@"GET"];
	[request setURL:[NSURL URLWithString:url]];
		
	NSError *error = nil;
	NSHTTPURLResponse *responseCode = nil;
	[NSURLConnection sendSynchronousRequest:request returningResponse:&responseCode error:&error];
	if([responseCode statusCode] != 200){
		NSLog(@"CDE: Error getting %@, HTTP status code %li", url, (long)[responseCode statusCode]);
		return false;
	}

	return true;
}

-(int)versionNumber
{
    if (self.handle > 0) {
        return (int)ysdq_cdeGetVersionNumber();
	}
	return 0;
}

-(NSString *)versionString
{
    if (self.handle > 0) {
        return [NSString stringWithUTF8String:ysdq_cdeGetVersionString()];
	}
	return @"null";
}

-(NSString *)sdkVersion
{
	return @"0.9.79"; // 2015-06-02
}

-(NSString *)linkshellUrl:(NSString *)url
{
	NSString *result = nil;
	//char *linkUrl = getURLFromLinkShell([url UTF8String]);
    char *linkUrl = NULL; //(char *)[url UTF8String];
	if( linkUrl ){
		result = [NSString stringWithUTF8String:linkUrl];
		free(linkUrl);
		linkUrl = NULL;
	}else{
		result = url;
	}
	return result;
}


-(NSString *)linkshellUrl2:(NSString *)url usingCde:(bool)usingCde
{
	NSString *result = [self linkshellUrl:url];
	if( usingCde ){
		char *trimUrl = ysdq_cdeTrimLinkShellUrlParams([result UTF8String]);
		if( trimUrl ){
			result = [NSString stringWithUTF8String:trimUrl];
			free(trimUrl);
			trimUrl = NULL;
		}
	}
	return result;
}

- (NSString*)fetchAccelerateURL:(NSString *)originURL offset:(int)offset {
    if (!originURL || [originURL length] == 0) {
        return originURL;
    }
    NSString *result = nil;
    const char * url = [originURL UTF8String];
    char * resultUrl = ysdq_acceleratePlay(url, offset);
        if (resultUrl) {
        result = [NSString stringWithUTF8String:resultUrl];
        free(resultUrl);
        resultUrl = NULL;
    }
    return result;
}

-(NSString *)playUrlSync2:(NSString *)linkshellUrl other:(NSString *)other
{
    if(other == nil) other = @"";
    NSString *url = [self playUrl2:linkshellUrl other:other];
    NSString *url1 = [url stringByAppendingString:@"&overLoadProtect=1"];
    NSString *retCode = @"";
    do{
        if(url == nil)
        {
            retCode = @"-1";
            url = @"";
            [self writeLogInfo: [NSString stringWithFormat:@"cde::sdk::playUrlSync2 url is nil,return code:%@",retCode]];
            break;
        }
        if(url1 == nil)
        {
            retCode = @"-2";
            [self writeLogInfo: [NSString stringWithFormat:@"cde::sdk::playUrlSync2 url is nil,return code:%@",retCode]];
            break;
        }
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
        [request setHTTPMethod:@"GET"];
        [request setURL:[NSURL URLWithString:url1]];
        [request setTimeoutInterval:15.0];
        
        NSError *error = nil;
        NSHTTPURLResponse *response = nil;
        NSData * data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
        if(nil != error)
        {
            [self writeLogInfo: [NSString stringWithFormat:@"cde::sdk::playUrlSync2 http get has error(%@:%ld), return code:%@",error.localizedDescription,(long)error.code,retCode]];
            if (error.code == NSURLErrorTimedOut) {
                retCode = @"-7";
                break;
                
            }
            if (error.code == NSURLErrorNetworkConnectionLost) {
                retCode = @"-8";
                break;
            }
            retCode = @"-5";
            break;
        }
        if(nil == data)
        {
            retCode = @"-6";
            [self writeLogInfo: [NSString stringWithFormat:@"cde::sdk::playUrlSync2 data is nil,return code:%@",retCode]];
            break;
        }
        NSString *dataString = [[NSString alloc] initWithData:data
                                                     encoding:NSUTF8StringEncoding];
        [self writeLogInfo: [NSString stringWithFormat:@"cde::sdk::playUrlSync2 http data:%@",dataString]];
        if([response statusCode] != 200){
            retCode = @"-3";
            [self writeLogInfo: [NSString stringWithFormat:@"cde::sdk::playUrlSync2 Error getting %@,HTTP status code (%ld),return code:%@",url1,(long)[response statusCode],retCode]];
            break;
        }else{
            NSString *errCode = @"";
            NSDictionary *ret = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:&error];
            if(nil != error)
            {
                retCode = @"-5";
                [self writeLogInfo: [NSString stringWithFormat:@"cde::sdk::playUrlSync2 http get has error2(%@:%ld), return code:%@",error.localizedDescription,(long)error.code,retCode]];
                break;
            }
            errCode = [ret objectForKey:@"errCode"];
            if(errCode == nil)
            {
                retCode = @"-4";
                [self writeLogInfo: [NSString stringWithFormat:@"cde::sdk::playUrlSync2 errCode is nil,return code:%@",retCode]];
                break;
            }
            retCode = errCode;
        }
    }while(0);
    
    NSDictionary *muRespone = @{@"errCode":retCode,@"playUrl":url};
    NSError *error = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:muRespone
                                                       options:NSJSONWritingPrettyPrinted
                                                         error:&error];
    NSString *jsonString = [[NSString alloc] initWithData:jsonData
                                                 encoding:NSUTF8StringEncoding];
    [self writeLogInfo: [NSString stringWithFormat:@"cde::sdk::playUrlSync2 return json:%@",jsonString]];
    return jsonString;
}
-(NSString *)playUrlSync:(NSString *)linkshellUrl
{
    return [self playUrlSync2:linkshellUrl other:@""];
}

-(NSString *)cacheUrlWithData:(NSString *)data ext:(NSString *)ext g3url:(NSString *)g3url other:(NSString *)other 
{
	struct timeval tv = {0};
	gettimeofday(&tv, NULL);

	NSString *key = [NSString stringWithFormat:@"%u%09u", (unsigned int)tv.tv_sec, (unsigned int)tv.tv_usec];
	ysdq_cdeSetKeyDataCache([key UTF8String], data ? [data UTF8String] : "");

	NSString *params = @"";
	if( g3url != nil && [g3url length] > 0 ){
		NSURL *parsedUrl = [NSURL URLWithString:g3url];
		if( parsedUrl != nil ){
			params = [parsedUrl query];
			//NSLog(@"g3url: %@", g3url);
			//NSLog(@"params: %@", params);
		}
		if( params != nil ) params = [params stringByReplacingOccurrencesOfString:@"?key=" withString:@"?oldkey="];
		if( params != nil ) params = [params stringByReplacingOccurrencesOfString:@"&key=" withString:@"&oldkey="];
		if( params != nil ) params = [params stringByReplacingOccurrencesOfString:@"?stream_id=" withString:@"?oldstream_id="];
		if( params != nil ) params = [params stringByReplacingOccurrencesOfString:@"&stream_id=" withString:@"&oldstream_id="];
	}
	
	NSString *separator = (other != nil && [other length] > 0) ? @"&" : @"";
	NSString *url = [NSString stringWithFormat:@"http://127.0.0.1:%d/play/caches/%@.%@?key=%@&%@%@%@",
					 [self port], key, ext ? ext : @"m3u8", key, params, separator, other];
	return url;
}

-(NSString *)localPlayUrlWithFile:(NSString *)filePath
{
	if( filePath == nil ){
		return nil;
	}
	
	NSString *encodeFile = ysdq_cdeUrlEncodeUriComponent(filePath);
	NSString *url = [NSString stringWithFormat:@"http://127.0.0.1:%d/play/locals/index.m3u8?file=%@",
					 [self port], encodeFile];
	return url;
}

-(void)setChannelSeekPosition:(NSString *)linkshellUrl pos:(double)pos
{
	ysdq_cdeSetChannelSeekPosition([linkshellUrl UTF8String], pos);
}

-(int)getChannelSegmentData:(NSString *)linkshellUrl path:(NSString *)path trunMp4:(bool)trunMp4 requireTime:(double)requireTime width:(int *)width height:(int *)height errorCode:(int *)errorCode offsetTime:(double *)offsetTime duration:(double *)duration
					   size:(int *)size
{
	int result = ysdq_cdeGetSegmentData([linkshellUrl UTF8String], [path UTF8String], false, requireTime, width, height, errorCode, offsetTime, duration, size);
	if( result < 0 && errorCode != nil && *errorCode == 0 ){
		*errorCode = result;
	}
	return result;
}

-(int)writeLogTrace: (NSString *)text
{
	return ysdq_cdeWriteLogLine(1, [text UTF8String]);
}

-(int)writeLogInfo: (NSString *)text
{
	return ysdq_cdeWriteLogLine(2, [text UTF8String]);
}

-(int)writeLogWarining: (NSString *)text
{
	return ysdq_cdeWriteLogLine(4, [text UTF8String]);
}

-(int)writeLogError: (NSString *)text
{
	return ysdq_cdeWriteLogLine(8, [text UTF8String]);
}

-(NSString *)playUrl:(NSString *)linkshellUrl
{
	ysdq_CdeUrl *program = [[ysdq_CdeUrl alloc] initWithUrl:linkshellUrl port:[self port] other:@""];
	return [program play];
}

-(NSString *)playUrl2:(NSString *)linkshellUrl other:(NSString *)other
{
	ysdq_CdeUrl *program = [[ysdq_CdeUrl alloc] initWithUrl:linkshellUrl port:[self port] other:other];
	return [program play];
}

-(NSString *)stopUrl:(NSString *)linkshellUrl
{
	ysdq_CdeUrl *program = [[ysdq_CdeUrl alloc] initWithUrl:linkshellUrl port:[self port] other:@""];
	return [program stop];
}

-(NSString *)pauseUrl:(NSString *)linkshellUrl
{
	ysdq_CdeUrl *program = [[ysdq_CdeUrl alloc] initWithUrl:linkshellUrl port:[self port] other:@""];
	return [program pause];
}

-(NSString *)resumeUrl:(NSString *)linkshellUrl
{
	ysdq_CdeUrl *program = [[ysdq_CdeUrl alloc] initWithUrl:linkshellUrl port:[self port] other:@""];
	return [program resume];
}

-(NSString *)statePlayUrl:(NSString *)linkshellUrl
{
	ysdq_CdeUrl *program = [[ysdq_CdeUrl alloc] initWithUrl:linkshellUrl port:[self port] other:@"cde=1&simple=1&maxDuration=1000"];
	return [program statePlay];
}

-(NSString *)supportUrl:(NSString *)contactNumber
{
	return [NSString stringWithFormat:@"http://127.0.0.1:%d/support/open?contact=%@",[self port], contactNumber];
}

-(NSString *)playErrorsUrl:(NSString *)linkshellUrl
{
    ysdq_CdeUrl *program = [[ysdq_CdeUrl alloc] initWithUrl:linkshellUrl port:[self port] other:@""];
    return [program reportError];
}

-(bool)stopPlay:(NSString *)linkshellUrl
{
	NSString *url = [self stopUrl:linkshellUrl];
	return [self syncHttpRequest:url];
}

-(bool)pausePlay:(NSString *)linkshellUrl
{
	NSString *url = [self pauseUrl:linkshellUrl];
	return [self syncHttpRequest:url];
}

-(bool)resumePlay:(NSString *)linkshellUrl
{
	NSString *url = [self resumeUrl:linkshellUrl];
	return [self syncHttpRequest:url];
}

-(NSString *)supportNumber:(NSString *)contactNumber
{
	NSString *url = [self supportUrl:contactNumber];

	NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
	[request setHTTPMethod:@"GET"];
	[request setURL:[NSURL URLWithString:url]];
		
	NSError *error = nil;
	NSHTTPURLResponse *responseCode = nil;
	NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&responseCode error:&error];
	if([responseCode statusCode] != 200){
		NSLog(@"CDE: Error getting %@, HTTP status code %li", url, (long)[responseCode statusCode]);
		return nil;
	}

	if( data == nil ) return nil;
	return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
}

-(bool)stateUrlExists:(NSString *)linkshellUrl
{
	return self.handle > 0 && ysdq_cdeGetStateTotalDuration(self.handle, [linkshellUrl UTF8String]) >= 0;
}

-(int)stateTotalDuration:(NSString *)linkshellUrl
{
	return self.handle > 0 ? ysdq_cdeGetStateTotalDuration(self.handle, [linkshellUrl UTF8String]) : -2;
}

-(int)stateDownloadedDuration:(NSString *)linkshellUrl
{
	return self.handle > 0 ? ysdq_cdeGetStateDownloadedDuration(self.handle, [linkshellUrl UTF8String]) : -2;
}

-(double)stateDownloadedPercent:(NSString *)linkshellUrl
{
	return self.handle > 0 ? ysdq_cdeGetStateDownloadedPercent(self.handle, [linkshellUrl UTF8String]) : -2;
}

-(int)stateUrgentReceiveSpeed:(NSString *)linkshellUrl
{
	return self.handle > 0 ? ysdq_cdeGetStateUrgentReceiveSpeed(self.handle, [linkshellUrl UTF8String]) : -2;
}

-(int)stateLastReceiveSpeed:(NSString *)linkshellUrl
{
	return self.handle > 0 ? ysdq_cdeGetStateLastReceiveSpeed(self.handle, [linkshellUrl UTF8String]) : -2;
}

- (void)dealloc
{
    [self writeLogInfo: [NSString stringWithFormat:@"cde::sdk::dealloc: %@, open(%@)",[self description], self.open ? @"true" : @"false"]];
    if(self.open) {
        [self stop];
    }
    //[super dealloc];
}

@end
