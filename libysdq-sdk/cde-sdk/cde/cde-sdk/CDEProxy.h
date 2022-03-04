//
//  CDEProxy.h
//  cde-sdk
//
//  Created by yu cao on 2018/9/11.
//  Copyright © 2018年 LeTV. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cde_tag.h"

typedef void(^CDEProxyBlock)(enum ysdq_cde_tag tag,const char *content);


@interface CDEProxy : NSObject

/**
 初始化回调block

 @param block 回调block
 */
+ (void)initCDEProxy:(CDEProxyBlock)block;

@end
