//
//  CdeUrl.h
//
//  Created by yuanfeixiong@letv.com on 2014-11-12.
//  Copyright (C) 2014 LeTV
//

#import <Foundation/Foundation.h>

//
// CDE(Cloud Data Entry) Url
//
@interface ysdq_CdeUrl : NSObject

-(id)initWithUrl:(NSString *)playUrl port:(NSInteger)port other:(NSString *)other; // init url params, using service port
-(NSString *)play; // get local url for player, such as http://127.0.0.1:6990/play?enc=base64&url=XXX
-(NSString *)stop; // get local stop url, such as http://127.0.0.1:6990/play/stop?enc=base64&url=XXX
-(NSString *)pause; // get local pause url, such as http://127.0.0.1:6990/play/pause?enc=base64&url=XXX
-(NSString *)resume; // get local resume url, such as http://127.0.0.1:6990/play/resume?enc=base64&url=XXX
-(NSString *)statePlay; // get local state play url, such as http://127.0.0.1:6990/state/play?enc=base64&url=XXX
-(NSString *)reportError;

@end
