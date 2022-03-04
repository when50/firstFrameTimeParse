//
// BZXLVideoStreamParser.m
// BZXPhoneClient
//
// Created by niuzhaowang on 7/5/14.
// Copyright (c) 2014 Ying Shi Da Quan. All rights reserved.
//

#import "DQLVideoStreamParser.h"
#import "NTYKeyValueObserver/NTYKeyValueObserver.h"
#import "NTYTimer.h"
#import "CdeService.h"
#import "Path/Path.h"
#import "Extension/NSString+NTYExtension.h"
#import "CdeProxy.h"
#import "Extension/NSObject+Cast.h"

void LOG(NSString *msg) {
    NSLog(@"time: %f msg: %@", [NSDate date].timeIntervalSince1970, msg);
}

#if DEBUG
NSString *originVideoUrl;
#endif

typedef enum  {
    CdeType_m3u8,
    CdeType_mp4
} CdeType;

static CdeType                  sCurrentCdeType;
static void                     (^_completedBlock)(NSString *result, NSError *error);
static void                     (^_liveCompletedBlock)(NSString *playUrl, NSString *stopUrl, NSError *error);
static void                     (^_playCompletedBlock)(id /*BZXFilepathDefinition**/ defnition, NSError *error);
static NSString                *_unParsedUrl;
static NTYTimer                *cde_service_timer;

@interface BZXCDEService ()

@property (nonatomic,strong) NSMutableArray  *playURLs;
@property (nonatomic,strong) ysdq_CdeService *cdeService;
@property (nonatomic,strong) NSString        *cdeDownloadPath_;

@end

@implementation BZXCDEService
static long                     servicePort;
static NSString                *urlBody;
static NTYNotificationObserver *networkObserver;

+ (instancetype)shared {
    static BZXCDEService  *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[BZXCDEService alloc] init];
    });
    return instance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.playURLs = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)addPlayURL:(NSString*)urlString {
    [self.playURLs addObject:urlString];
}

- (void)stopAllPlayUrls {
    for (int i = 0; i < self.playURLs.count; i++) {
        NSString *item = self.playURLs[i];
        [self.cdeService stopPlay:item];
    }
    [self.playURLs removeAllObjects];
}

+ (void)stopPlay:(NSString*)urlString {
    [[[self shared] cdeService] stopPlay:urlString];
}

+ (long)startParserService {
    NSLog(@"启动cde服务");
    #define UTP_MAX_CACHE_SIZE    20
    #define UTP_PRE_DOWNLOAD_SIZE 10
    #define UTP_APP_ID            4000

    NSString *appCachePath        = [BZXPath cache];
    NSString *downloaderCachePath = [appCachePath nty_joinPath:@"abc"];
    if (![BZXPath exists:downloaderCachePath]) {
        NSError *error = nil;
        [[NSFileManager defaultManager] createDirectoryAtPath:downloaderCachePath
                                  withIntermediateDirectories:YES
                                                   attributes:nil
                                                        error:&error];
        if (error) {
            NSLog(@"%@", [error localizedDescription]);
        }
    }

    //    NSString *paraString = [NSString stringWithFormat:@"http_port=%d&cache.max_size=%dM&downloader.pre_download_size=%dM&app_id=%d&data_dir=%@&log_level=50000",
    //                            UTP_MAX_CACHE_SIZE,
    //                            UTP_PRE_DOWNLOAD_SIZE,
    //                            UTP_APP_ID,
    //                            downloaderCachePath];
    NSString *appId = @"942"; //[BZXAppConfig shared][@"Player.CDEAppID"];
    /// 影视大全cde端口
    NSString *port = @"7990";
    //NSString *port  = [BZXAppConfig shared][@"Player.CDEPort"];

    NSString *cachePath    = [BZXPath cache];
    NSString *ysdq_cdePath = [cachePath nty_joinPath:@"ysdq_cde"];
    [BZXPath mkdir:ysdq_cdePath];

    NSString *logFilePath = [ysdq_cdePath nty_joinPath:@"ysdq_cde.log"];
    NSString *dataDir     = [ysdq_cdePath nty_joinPath:@"data"];
    [BZXPath mkdir:dataDir];

    /* channel_default_multi:支持多通道，bool类型，1表示支持多通道；此参数解决不能同时播放和下载的问题
     *
     */
#if DEBUG
    int logLevel = 255;
    int logType = 4;
#else
    int logLevel = 255;
    int logType = 0;
#endif
    NSString *cdeParams = [NSString stringWithFormat:@"channel_default_multi=1&port=%@&app_id=%@&auto_active=0&data_dir=%@&log_type=%@&log_file=%@&log_level=%@", port, appId, dataDir, @(logType), logFilePath, @(logLevel)];

    ysdq_CdeService *cdeService = [[self shared] cdeService];
    if ([cdeService ready]) {
        return [cdeService port];
    }

    if (!cdeService) {
        NSLog(@"new cde server");
        cdeService = [[ysdq_CdeService alloc] initWithParams:cdeParams];
        [[self shared] setCdeService:cdeService];
    }
    [CDEProxy initCDEProxy:^(enum ysdq_cde_tag tag, const char *content) {
        switch (tag) {
        case play_ts: {
            
        }
                      break;
        }
    }];

    NSLog(@"cde version:%@", [cdeService versionString]);
    
    // self.cdeService_ = [[CdeService alloc] initWithParams:paraString];
    servicePort = [cdeService port];

    [self startCDETimer];

    return servicePort;
}  // startParserService

#pragma mark - Timer
+ (void)startCDETimer {
    [self stopTimer];

    cde_service_timer = [NTYTimer scheduleWithInterval:5.0 repeats:YES runloop:^(NSTimer *timer) {
        [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
    } block:^(NTYTimer *timer) {
        if ([self isCDEServiceReady]) {
            [self stopTimer];
        } else {
            [self startParserService];
        }
    }];
}

+ (void)stopTimer {
    if (cde_service_timer) {
        [cde_service_timer invalidate];
        cde_service_timer = nil;
    }
}

//+ (NSString*)getDefinitionAttribute:(NSString*)vtype {
//    int       idx    = [vtype intValue];
//    NSString *result = @"smoothUrl";
//    switch (idx) {
//    case 22:
//        result = @"highUrl";
//        break;
//
//    case 21:
//        result = @"standardUrl";
//        break;
//
//    case 9:
//        result = @"smoothUrl";
//        break;
//
//    default:
//        NSLog(@"getDefinitionAttributeForType==%d dose not process",idx);
//        break;
//    }
//
//    return result;
//}
//
//+ (void)testUtpServerWithUrl:(NSString*)url completedBlock:(void (^)(NSString*paredUrl, NSError*error))completeBlock {
//    NSString *ppp  = nil;
//    NSString *p1   = [BZXAppConfig shared][@"Channel.p1"];
//    NSString *p2   = [BZXAppConfig shared][@"Channel.p2"];
//    NSString *p3   = [BZXAppConfig shared][@"Channel.p3"];
//    NSString *uuid = NTYUUIDString();
//
//    ppp = [NSString stringWithFormat:@"&p1=%@&p2=%@&p3=%@&uuid=%@", p1, p2, p3, uuid];
//
//    url             = [url stringByAppendingString:ppp];
//    _unParsedUrl    = url;
//    _completedBlock = completeBlock;
//
//    if (isEmpty(url)) {
//        NSError *error = [[NSError alloc] initWithDomain:@"Fatal Error" code:0 userInfo:@{@"description":@"empty url"}];
//        completeBlock(nil, error);
//
//        return;
//    }
//
//    // [BZXLVideoStreamParser testUtpServer];
//    [BZXCDEService cdeParseUrl];
//}
//
+ (NSString*)appendCDEParams:(NSString*)url {
    
        NSMutableString     *resultURL  = [[NSMutableString alloc] initWithString:url];
        NSMutableDictionary *parameters = [@{
                                               @"sarrs":@"4",
                                               @"os":@"1",
                                               @"acode":@"20",
                                               //@"product":config[@"Channel.platform"],
                                               @"auid":@"ce6d0ceddad026abc313bf0a1d276b61f0d7858f",
                                               //@"nuid":[UIDevice nuid],
                                               @"ldid":@"5c3d87340a57a241f680c00290401fde",
                                               @"version":@"2.7.6",
                                               @"ctime":[NSString stringWithFormat:@"%ld",lround([[NSDate date] timeIntervalSince1970] * 1000)],
                                               @"citycode":@"",
                                               @"site":@"nets",
                                               @"playac":@"ts",
                                           } mutableCopy];

        if (url) {
            //参数排重，如果url中包含同名参数，并且有值，优先用url中的值
            NSURLComponents*cmponents = [[NSURLComponents alloc] initWithString:url];
            for (NSURLQueryItem *item in cmponents.queryItems) {
                if ([[parameters allKeys] containsObject:item.name] && !isEmpty(item.value)) {
                    [parameters setValue:nil forKey:item.name];
                }
            }
        }


        for (NSString *key in parameters) {
            [resultURL appendFormat:@"&%@=%@",key,parameters[key]];
        }
        return resultURL;
}

+ (NSString*_Nullable)getCDESpeededUrl:(NSString*)url {
    NSString *p1   = @"0";
    NSString *p2   = @"0";
    NSString *p3   = @"";
    NSString *uuid = NTYUUIDString();

    NSString *appendArgs = [NSString stringWithFormat:@"&p1=%@&p2=%@&p3=%@&uuid=%@", p1, p2, p3, uuid];
    url = [url stringByAppendingString:appendArgs];
    url = [self appendCDEParams:url];

    if (isEmpty(url)) {
        return nil;
    }

    ysdq_CdeService *cdeService      = [[self shared] cdeService];
    NSString        *linkshellUrl    = [cdeService linkshellUrl:url];
    NSString        *redirectContent = [cdeService playUrlSync:linkshellUrl];
    return redirectContent;
//    NSDictionary    *result          = [NSDictionary cast:[BZXJSON parse:redirectContent]];
//    if ([result[@"errorCode"] integerValue] == 0) {
//        return result[@"playUrl"];
//    } else {
//        NSLog(@"获取playUrl失败，errorCode:%d",[result[@"errorCode"] intValue]);
//        return linkshellUrl;
//    }
}

////该函数暂时没有调用。
//+ (NSString*_Nullable)getCDESpeededUrlSync:(NSString*)url {
//    NSString *p1   = [BZXAppConfig shared][@"Channel.p1"];
//    NSString *p2   = [BZXAppConfig shared][@"Channel.p2"];
//    NSString *p3   = [BZXAppConfig shared][@"Channel.p3"];
//    NSString *uuid = NTYUUIDString();
//
//    NSString *ppp = [NSString stringWithFormat:@"&p1=%@&p2=%@&p3=%@&uuid=%@", p1, p2, p3, uuid];
//    url = [url stringByAppendingString:ppp];
//
//    if (isEmpty(url)) {
//        return nil;
//    }
//
//    ysdq_CdeService *cdeService = [[self shared] cdeService];
//
//    NSString        *linkshellUrl = [cdeService linkshellUrl:url];
//    NSString        *redirectURL  = [cdeService playUrl:linkshellUrl];
//    BOOL             success      = [cdeService syncHttpRequest:redirectURL];
//    NSLog(@"CDE channel open %ld",(long)success);
//
//    return redirectURL;
//}
//
+ (NSString *)getAccelerateURL:(NSString*)url offset:(int)offset {
#if DEBUG
    originVideoUrl = url;
#endif
    ysdq_CdeService *cdeService = [[self shared] cdeService];
    return [cdeService fetchAccelerateURL:url offset:offset];
}
//
+ (BOOL)isCDEServiceReady {
    return [[[self shared] cdeService] ready];
}
//
//+ (void)testCDEServerWithUrl:(NSString*)url completedBlock:(void (^)(NSString*, NSString*, NSError*))completeBlock {
//    ysdq_CdeService *cdeService = [[self shared] cdeService];
//
//    NSString        *linkshellUrl = [cdeService linkshellUrl:url];
//    NSString        *playUrl      = [cdeService playUrl:linkshellUrl];
//    NSString        *stopUrl      = [cdeService stopUrl:linkshellUrl];
//    if (completeBlock) {
//        completeBlock(playUrl, stopUrl, nil);
//    }
//}
//
////无调用
//+ (void)testLivePlayUrl:(NSString*)url completeBlock:(void (^)(NSString*, NSString*, NSError*))completeBlock {
//    sCurrentCdeType = CdeType_m3u8;
//    [self testCDEServerWithUrl:url completedBlock:completeBlock];
//}
//
//+ (void)cdeParseUrl {
//    ysdq_CdeService *cdeService = [[self shared] cdeService];
//
//    NSString        *linkshellUrl = [cdeService linkshellUrl:_unParsedUrl];
//    NSString        *url          = [cdeService playUrl:linkshellUrl];
//
//    NSString        *reLinkShellUrl = [cdeService linkshellUrl:linkshellUrl];
//
//    // NSLog(@"linkShell: %@, re:%@", linkshellUrl, reLinkShellUrl);
//    if ([linkshellUrl isEqualToString:reLinkShellUrl]) {
//        NSLog(@"re equal");
//    }
//    if (sCurrentCdeType == CdeType_mp4) {
//        if (_completedBlock) {
//            _completedBlock(_unParsedUrl,nil);
//        }
//    } else if (sCurrentCdeType == CdeType_m3u8) {
//        // 播放用
//        //[BZXGlobalSingelton shared].currentLVideoLinkShellUrl = linkshellUrl;
//        if (_completedBlock) {
//            _completedBlock(url,nil);
//        }
//    }
//}
//
//#if 0
//    static BZXUtpStatusRequest *utpStatusRequest;
//
//    + (void)testUtpServer {
//        if (!utpStatusRequest) {
//            utpStatusRequest      = [[BZXUtpStatusRequest alloc] init];
//            utpStatusRequest.port = [NSString stringWithFormat:@"%ld",servicePort];
//        }
//        [utpStatusRequest cancel];
//        [utpStatusRequest fetch:^(NTYResult*_Nonnull result) {
//        NSError *error = result.error;
//
//        if (error) {
//            servicePort = [BZXLVideoStreamParser startParserService];
//            [BZXLVideoStreamParser utpParseUrl:_unParsedUrl];
//            // _completedBlock(nil,error);
//            // _requestComplete = TRUE;
//        } else {
//            [BZXLVideoStreamParser utpParseUrl:_unParsedUrl];
//        }
//    }];
//    }
//
//    static BZXUtpParseRequest *parseRequest;
//
//    + (void)utpParseUrl:(NSString*)url {
//        if (!parseRequest) {
//            parseRequest      = [[BZXUtpParseRequest alloc] init];
//            parseRequest.port = [NSString stringWithFormat:@"%ld",servicePort];
//            parseRequest.enc  = @"base64";
//        }
//        NSData   *urlData   = [url dataUsingEncoding:NSUTF8StringEncoding];
//        NSString *base64Url = [BZXLVideoStreamParser base64forData:urlData];
//        parseRequest.url = base64Url;
//        #warning "need check"
//        NSString *finalUrl = @""; // [parseRequest generateFullUrl];
//        if (sCurrentCdeType == CdeType_mp4) {
//            if (_completedBlock) {
//                _completedBlock(url,nil);
//            }
//        } else if (sCurrentCdeType == CdeType_m3u8) {
//            if (_completedBlock) {
//                _completedBlock(finalUrl,nil);
//            }
//        }
//        _requestComplete = TRUE;
//
//        urlBody = base64Url;
//    }
//
//
//
//    + (NSString*)base64forData:(NSData*)theData {
//        const uint8_t *input  = (const uint8_t*)[theData bytes];
//        NSInteger      length = theData.length;
//
//        static char    table[] = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/=";
//
//        NSMutableData *data   = [NSMutableData dataWithLength:((length + 2) / 3) * 4];
//        uint8_t       *output = (uint8_t*)data.mutableBytes;
//
//        NSInteger      i,i2;
//        for (i = 0; i < length; i += 3) {
//            NSInteger value = 0;
//            for (i2 = 0; i2 < 3; i2++) {
//                value <<= 8;
//                if (i + i2 < length) {
//                    value |= (0xFF & input[i + i2]);
//                }
//            }
//
//            NSInteger theIndex = (i / 3) * 4;
//            output[theIndex + 0] = table[(value >> 18) & 0x3F];
//            output[theIndex + 1] = table[(value >> 12) & 0x3F];
//            output[theIndex + 2] = (i + 1) < length? table[(value >> 6) & 0x3F]:'=';
//            output[theIndex + 3] = (i + 2) < length? table[(value >> 0) & 0x3F]:'=';
//        }
//
//        return [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
//    }
//#endif // if 0
//
//+ (NSString*)port {
//    return [NSString stringWithFormat:@"%ld", servicePort];
//}
//
//+ (NSString*)urlBody {
//    return urlBody;
//}
//
//+ (NSString *)lastOriginVideoUrl {
//#ifdef DEBUG
//    return originVideoUrl;
//#else
//    return @"";
//#endif
//
//}
//
//#pragma mark - 防盗链
///*
// * 防盗链加密:stamp为毫秒单位的时间戳
// */
//+ (NSString*_Nullable)appendAntiStealArguments:(NSString*_Nullable)origionURL timeStamp:(NSTimeInterval)stamp {
//    if (isEmpty(origionURL) || stamp <= 0.0) {
//        return nil;
//    } else {
//        NSString *appendString = [self antURLParameters:stamp];
//        return [origionURL stringByAppendingString:appendString];
//    }
//}
//
//+ (NSString*)antURLParameters:(NSTimeInterval)stamp {
//    BZXLogonSingleton *logon        = [BZXLogonSingleton shared];
//    NSString          *uid          = logon.infoModel.uid?:@"";
//    NSString          *version      = NTYAppVersion();
//    NSString          *splatid      = @"";
//    NSString          *timeStamp    = stamp > 0? STRING(@"%ld",(long)(floor(stamp / 1000 + 600))):@"";
//    NSString          *secretKey    = @"adfasfsdfds244566letv";
//    NSString          *jointString  = STRING(@"%@,%@,%@,%@,%@",uid,splatid,version,timeStamp,secretKey);
//    NSString          *md5key       = [jointString nty_md5];
//    NSString          *appendString = STRING(@"&duid=%@&dsplatid=%@&dv=%@&dtm=%@&dkey=%@",uid,splatid,version,timeStamp,md5key);
//    NSLog(@"jointString = %@ -- md5key = %@",jointString,md5key);
//    return appendString;
//}
//
//+ (void)stopStopService {
//    [[[self shared] cdeService] stop];
//    [self.shared setCdeService:nil];
//}

+ (void)activateService {
    [[[self shared] cdeService] activate];
}

//+ (void)report:(const char*)data {
//    NSString     *string = [NSString stringWithUTF8String:data];
//    NSLog(@"string = %@",string);
//    NSDictionary *info = [NSDictionary cast:[BZXJSON parse:string]];
//    NSMutableDictionary *parameters = [@{
//                                         @"sarrs":NONNULL_STR([BZXAppConfig shared][@"Channel.sarrs"]),
//                                         @"os":@"1",
//                                         @"acode":ASReportActionValue_PlayStatus,
//                                         //@"product":[BZXAppConfig shared][@"Channel.platform"],
//                                         @"auid":NONNULL_STR([UIDevice deviceID]),
//                                         //@"nuid":[UIDevice nuid],
//                                         @"ldid":[UIDevice ldid],
//                                         @"version":NTYAppVersion(),
//                                         @"ctime":[NSString stringWithFormat:@"%ld",lround([[NSDate date] timeIntervalSince1970] * 1000)],
//                                         @"citycode":CityInfo,
//                                         @"site":@"nets",
//                                         @"playac":@"ts",
//                                         } mutableCopy];
//    [BZXReportCenter reportCDEActions:[parameters nty_joined:info]];
//}

@end

