//
//  NSObject+Cast.m
//  SafePrograming
//
//  Created by wangchao9 on 2017/4/26.
//  Copyright © 2017年 wangchao9. All rights reserved.
//

#import "NSObject+Cast.h"

@implementation NSObject (Cast)
+ (instancetype)cast:(id)object {
    if (!object) {
        return nil;
    }

    if ([object isKindOfClass:self]) {
        return object;
    }

    NSLog(@"类型转换失败. 无法将%@转换为%@ %@", NSStringFromClass([object class]), NSStringFromClass(self), [NSThread callStackSymbols]);
    return nil;
}

+ (BOOL)has:(id)object {
    if (!object) {
        return NO;
    }
    return [object isKindOfClass:self];
}

- (BOOL)isEmpty {
    id aItem = self;
    if ([(aItem) isKindOfClass:[NSNull class]]) {
        return YES;
    }
    if (([(aItem) respondsToSelector:@selector(length)])
        && ([((id)(aItem)) length] == 0)) {
        return YES;
    }
    if (([aItem respondsToSelector:@selector(count)])
        && ([((id)(aItem)) count] == 0)) {
        return YES;
    }
    return NO;
}
@end
