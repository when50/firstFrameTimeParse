#import "CdeNetBroadcastReceiver.h"
#import "CdeReachability.h"
#include "service.h"

@implementation ysdq_CdeNetBroadcastReceiver
{
ysdq_CdeReachability *hostReachable_;
ysdq_CdeService *service_;
}

-(id)initWithService:(ysdq_CdeService *)service;
{
    if (self=[super init]) {
        service_ = service;
        [self startNetBroadcastReceiver];
    }
    return self;
    
}

-(void)stop
{
	service_ = nil;
	[[NSNotificationCenter defaultCenter] removeObserver:self name:ysdq_kCdeReachabilityChangedNotification object:nil];
	if( hostReachable_ != nil ){
		[hostReachable_ stopNotifier];
		hostReachable_ = nil;
	}
}

-(void)setNetworkType:(int)type
{
	ysdq_cdeSetNetworkType(type);
	//[self applyServiceParams:[NSString stringWithFormat:@"params?enviroment.networkType=%d", type]];
}

- (void)reachabilityChanged:(NSNotification *)note
{
    ysdq_CdeReachability* curReach = [note object];
    NSParameterAssert([curReach isKindOfClass: [ysdq_CdeReachability class]]);
    //CdeNetworkStatus status = [curReach currentReachabilityStatus];
	[self applyNetworkStatus:curReach];
}

- (void)applyNetworkStatus:(ysdq_CdeReachability *)reach
{
	ysdq_CdeNetworkStatus status = [reach currentReachabilityStatus];
	int netType = 0; // 0, no network; 1, ethernet; 2, mobile; 3, wifi
	// NSString* statusString = @"";
	switch (status)
	{
		case NotReachable:{
			netType = 0;
			break;
		}
		case ReachableViaWWAN:{
			netType = 2;
			break;
		}
		case ReachableViaWiFi:{
			netType = 3;
			break;
		}
	}
	NSLog(@"CDE: Network Status Channged(0:no network; 1:ethernet; 2:mobile; 3:wifi) : %@",[NSString stringWithFormat:@"%d", netType]);
	
	[self setNetworkType:netType];
}

- (void)startNetBroadcastReceiver
{
    hostReachable_ = [ysdq_CdeReachability reachabilityWithHostName:@"www.letv.com"];
	//hostReachable_ = [CdeReachability reachabilityForInternetConnection];
	[hostReachable_ startNotifier];
	
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(reachabilityChanged:)
												 name: ysdq_kCdeReachabilityChangedNotification
											   object: nil];
	
	// apply current network
	//[self applyNetworkStatus:hostReachable_];
}

- (void)applyServiceParams:(NSString *)params
{
	if( service_ == nil ){
		return;
	}
    [self getDataFrom:[NSString stringWithFormat:@"http://127.0.0.1:%d/control/%@", [service_ port], params]];
}

- (NSString *) getDataFrom:(NSString *)url
{
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setHTTPMethod:@"GET"];
    [request setURL:[NSURL URLWithString:url]];
    
    NSError *error = nil;
    NSHTTPURLResponse *responseCode = nil;
    NSData *oResponseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&responseCode error:&error];
    if([responseCode statusCode] != 200){
        NSLog(@"CDE: Error getting %@, HTTP status code %li", url, (long)[responseCode statusCode]);
        return nil;
    }
    
    return [[NSString alloc] initWithData:oResponseData encoding:NSUTF8StringEncoding];
}

- (void)dealloc
{
	[self stop];
	//[super dealloc];
}


@end
