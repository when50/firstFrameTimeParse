//
//  CDEProxy.m
//  cde-sdk
//
//  Created by yu cao on 2018/9/11.
//  Copyright © 2018年 LeTV. All rights reserved.
//

#include "cde_proxy.h"
#include "service.h"
#import "CDEProxy.h"


@interface CDEProxy ()

@property (nonatomic,copy) CDEProxyBlock cdeCallbackBlock;

+ (void)callBackFunction:(int)tag data:(const char*)data;

@end

#ifdef __cplusplus

class ysdq_cde_proxyImpl : public ysdq_cde_proxy
{
    void invoker(const int& tag, const char *data) {
        [CDEProxy callBackFunction:tag data:data];
    }
};

#endif

@implementation CDEProxy

+ (instancetype)shared {
    static CDEProxy * instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[CDEProxy alloc] init];
    });
    return instance;
}

+ (void)callBackFunction:(int)tag data:(const char*)data {
    if ([[self shared] cdeCallbackBlock]) {
        CDEProxyBlock cdeCallbackBlock = [[self shared] cdeCallbackBlock];
        cdeCallbackBlock((ysdq_cde_tag)tag,data);
    }
}

+ (void)initCDEProxy:(CDEProxyBlock)block {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
#ifdef __cplusplus
    ysdq_cde_proxyImpl * impl = new ysdq_cde_proxyImpl();
    ysdq_cdeSetHandler(impl);
#endif
    });
    [[self shared] setCdeCallbackBlock:block];
}

@end





