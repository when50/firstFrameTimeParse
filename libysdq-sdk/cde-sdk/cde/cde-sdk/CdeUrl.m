#import "CdeUrl.h"
#import "CdeBase64.h"
#import "UIDevice-Hardware.h"

@implementation ysdq_CdeUrl
{
NSString *encode_;
NSString *url_;
NSString *other_;
int port_;
}

-(id)initWithUrl:(NSString *)playUrl port:(NSInteger)port other:(NSString *)other
{
    if(self=[super init])
    {
		//encode_ = @"base64";
		//url_= cdeUrlBase64EncodedString(playUrl);
		encode_ = @"raw";
		url_ = ysdq_cdeUrlEncodeUriComponent(playUrl);
		port_ = (int)port;
		other_ = other;
    }
	return self;
}

-(NSString *)createUrl:(NSString *)actionName
{
    NSString *url = [NSString stringWithFormat:@"http://127.0.0.1:%d/%@?enc=%@&url=%@", port_, actionName, encode_, url_];
	if( other_ != nil && [other_ length] > 0 ){
		url = [url stringByAppendingString:@"&"];
		url = [url stringByAppendingString:other_];
	}
    return url;
}

-(NSString *)play
{
	return [self createUrl:@"play"];
}

-(NSString *)stop
{
	return [self createUrl:@"play/stop"];
}

-(NSString *)pause
{
	return [self createUrl:@"play/pause"];
}

-(NSString *)resume
{
	return [self createUrl:@"play/resume"];
}

-(NSString *)statePlay
{
	return [self createUrl:@"state/play"];
}

-(NSString *)reportError
{
    return [self createUrl:@"report/error"];
}

-(NSString *)getDeviceParams
{
    UIDevice *device = [UIDevice currentDevice];
    NSString *params = [NSString stringWithFormat:@"product=%@&platform=%@&version=%@", [device systemName],[device model],[device systemVersion]];
	NSString *base64String = ysdq_cdeUrlBase64EncodedString(params);
    return base64String;
}

-(NSString *)getDeviceParams1
{
    UIDevice *device = [UIDevice currentDevice];
    NSString *params = [NSString stringWithFormat:@"model=%@&version=%@&mac=%@", [device model],[device systemVersion],[device macAddress]];
	NSString *base64String = ysdq_cdeUrlBase64EncodedString(params);
    return base64String;
}

@end
