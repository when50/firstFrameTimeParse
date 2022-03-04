//
//  NSObject+Cast.h
//  SafePrograming
//
//  Created by wangchao9 on 2017/4/26.
//  Copyright © 2017年 wangchao9. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (Cast)
+ (instancetype)cast:(id)object;
+ (BOOL)has:(id)object;
- (BOOL)isEmpty;
@end
