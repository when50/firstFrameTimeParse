//
//  NTYTimer.m
//  SARRS
//
//  Created by wangchao9 on 2017/6/28.
//  Copyright © 2017年 Beijing Ninety Culture Co.ltd. All rights reserved.
//

#import "NTYTimer.h"

@interface NTYTimer ()
@property (nonatomic,strong) NSTimer       *timer;
@property (nonatomic,copy) NTYTimerCallback block;

//Pause & Resume
@property (nonatomic,copy) NSDate *pauseStart;
@property (nonatomic,copy) NSDate *previousFireDate;
@end

@implementation NTYTimer
+ (instancetype)scheduleWithInterval:(NSTimeInterval)interval repeats:(BOOL)repeats block:(NTYTimerCallback)block {
    NTYTimer *timer = [[[self class] alloc] init];
    [timer scheduleWithInterval:interval repeats:repeats block:block];
    return timer;
}

+ (instancetype)scheduleWithInterval:(NSTimeInterval)interval repeats:(BOOL)repeats runloop:(void (^)(NSTimer*))runloopAction block:(NTYTimerCallback)block {
    NTYTimer *timer = [[[self class] alloc] init];
    [timer scheduleWithInterval:interval repeats:repeats block:block];
    if (runloopAction) {
        runloopAction(timer.timer);
    }
    return timer;
}

- (void)scheduleWithInterval:(NSTimeInterval)interval repeats:(BOOL)repeats block:(NTYTimerCallback)block {
    self.block = block;
    [self.timer invalidate];
    self.timer = [NSTimer scheduledTimerWithTimeInterval:interval target:self selector:@selector(onTimer:)userInfo:nil repeats:repeats];
}

- (void)onTimer:(NSTimer*)timer {
    NTYTimer *strongSelf = self;
    if (strongSelf.block) {
        strongSelf.block(strongSelf);
    }
}

- (BOOL)isValid {
    return self.timer.isValid;
}

- (void)invalidate {
    [self.timer invalidate];
    self.timer = nil;
}
- (void)timerFire {
    [self.timer setFireDate:[NSDate distantPast]];
}
- (void)timerPause {
    [self.timer setFireDate:[NSDate distantFuture]];
}

- (void)dealloc {
    [self.timer invalidate];
    self.timer = nil;
}

@end

