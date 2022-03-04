//
//  NTYTimer.h
//  SARRS
//
//  Created by wangchao9 on 2017/6/28.
//  Copyright © 2017年 Beijing Ninety Culture Co.ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@class NTYTimer;
typedef void (^NTYTimerCallback)(NTYTimer*);
@interface NTYTimer : NSObject
@property (readonly, getter = isValid) BOOL valid;
+ (instancetype)scheduleWithInterval:(NSTimeInterval)interval repeats:(BOOL)repeats block:(NTYTimerCallback)block;

+ (instancetype)scheduleWithInterval:(NSTimeInterval)interval repeats:(BOOL)repeats runloop:(void(^)(NSTimer*timer))runloopAction block:(NTYTimerCallback)block;

- (void)invalidate;

- (void)timerFire;
- (void)timerPause;
@end





