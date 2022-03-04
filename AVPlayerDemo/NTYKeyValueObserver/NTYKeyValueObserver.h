//
//  NTYKeyValueObserver.h
//  SARRS
//
//  Created by wangchao on 2017/7/9.
//  Copyright © 2017年 Beijing Ninety Culture Co.ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#define STRING(fmt, ...) [NSString stringWithFormat:fmt,##__VA_ARGS__]

NS_ASSUME_NONNULL_BEGIN
typedef void (^NTYKeyValueObserveExecutor)(id target, id newValue, NSDictionary<NSKeyValueChangeKey,id> *change, void *context);
@interface NTYKeyValueObserver : NSObject
+ (instancetype)observer;

- (void)observe:(id)target forKeyPath:(NSString*)keyPath executor:(NTYKeyValueObserveExecutor)block;
- (void)observe:(id)target forKeyPath:(NSString*)keyPath context:(nullable void*)context executor:(NTYKeyValueObserveExecutor)block;

- (void)removeObserverForTarget:(id)target forKeyPath:(NSString*)keyPath;
- (void)removeAllObserversForTarget:(id)target;
- (void)removeAllObservers;
@end


@protocol NTYObserver <NSObject>
- (void)dispose;
- (void)host:(NSMutableArray<id<NTYObserver> >*)host;
@end

typedef id<NTYObserver> NTYObserverType;

typedef void (^NTYNotificationAction)(NSNotification *notification);
@interface NTYNotificationObserver : NSObject<NTYObserver>
+ (instancetype)observe:(NSNotificationName)name from:(id __nullable)source action:(NTYNotificationAction)action;
- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithName:(NSNotificationName)name source:(nullable id)source action:(NTYNotificationAction)block;
@end

#define NTYNotificationObserve(__notification__, __source__, __action__) \
    [NTYNotificationObserver observe: __notification__ from: __source__ action: ^ (NSNotification * _Nonnull notification) { \
         @strongify(self);if (!self) {return;} \
         [self __action__: notification]; \
     }]


#define NTYSingleKeyObserve(__keyPath__, __target__, __action__) \
    [NTYSingleKeyValueObserver observer:__keyPath__ target:__target__ action:^(id  _Nonnull newValue, id  _Nonnull oldValue) { \
        @strongify(self);if (!self) {return;} \
        [self __action__:newValue oldValue:oldValue]; \
    }]

//@interface RACDisposable (NTYObserver)<NTYObserver>
//@end

typedef void (^NTYKeyValueAction)(id newValue, id oldValue);
@interface NTYSingleKeyValueObserver : NSObject<NTYObserver>
- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithKeyPath:(nonnull NSString*)keyPath target:(id)target action:(NTYKeyValueAction)block;
+ (instancetype)observer:(NSString*)keyPath target:(id)target action:(NTYKeyValueAction)block;
@end
NS_ASSUME_NONNULL_END
