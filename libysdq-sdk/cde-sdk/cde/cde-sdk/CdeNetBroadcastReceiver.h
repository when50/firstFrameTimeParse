#import <Foundation/Foundation.h>
#import "CdeService.h"

//@class Reachability;
@interface ysdq_CdeNetBroadcastReceiver : NSObject
//{  Reachability *hostReach;}
-(id)initWithService:(ysdq_CdeService *)service;
-(void)setNetworkType:(int)type; // set network type, 0: no network, 2: Mobile, 3: Wifi
-(void)stop;
@end
