//
//  NTYKeyValueObserver.m
//  SARRS
//
//  Created by wangchao on 2017/7/9.
//  Copyright © 2017年 Beijing Ninety Culture Co.ltd. All rights reserved.
//

#import "NTYKeyValueObserver.h"
#import <pthread.h>

typedef NSMutableDictionary<NSString*,NTYKeyValueObserveExecutor> NTYKeyValueObserverKeyPaths;

@interface NTYKeyValueObserverMetadata : NSObject
@property (nonatomic, weak) id                             target;
@property (nonatomic, strong) NTYKeyValueObserverKeyPaths *keyPaths;
@end

@implementation NTYKeyValueObserverMetadata
+ (instancetype)metadataWithTarget:(id)target {
    NTYKeyValueObserverMetadata*metadata = [[self alloc] init];
    metadata.target = target;
    return metadata;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _keyPaths = [NSMutableDictionary dictionaryWithCapacity:0x1];
    }
    return self;
}
@end

@interface NTYKeyValueObserver ()

/**
 *  对象地址和对象自身的映射表
 */
@property (nonatomic, strong) NSMutableDictionary<NSString*, NTYKeyValueObserverMetadata*> *metadatas;
@end

@implementation NTYKeyValueObserver
+ (instancetype)observer {
    NTYKeyValueObserver *observer = [[[self class] alloc] init];
    observer.metadatas = [NSMutableDictionary dictionaryWithCapacity:0x1];
    return observer;
}

- (void)dealloc {
    NSLog(@"");
    NSMutableDictionary<NSString*, NTYKeyValueObserverMetadata*> *metadatas = _metadatas;
    [metadatas enumerateKeysAndObjectsUsingBlock:^(NSString*_Nonnull key, NTYKeyValueObserverMetadata*_Nonnull metadata, BOOL*_Nonnull stop) {
        [metadata.keyPaths enumerateKeysAndObjectsUsingBlock:^(NSString*_Nonnull keyPath, NTYKeyValueObserveExecutor _Nonnull obj, BOOL*_Nonnull stop) {
            [metadata.target removeObserver:self forKeyPath:keyPath];
        }];
        [metadata.keyPaths removeAllObjects];
        metadata.target = nil;
    }];

    [metadatas removeAllObjects];
}
- (void)observe:(id)target forKeyPath:(NSString*)keyPath executor:(NTYKeyValueObserveExecutor)block {
    [self observe:target forKeyPath:keyPath context:NULL executor:block];
}
- (void)observe:(id)target forKeyPath:(NSString*)keyPath context:(void*)context executor:(NTYKeyValueObserveExecutor)block {
    if (!target) {
        NSLog(@"target cannot be nil");
        return;
    }
    if (!keyPath) {
        NSLog(@"keyPath cannot be nil");
        return;
    }

    NSString *targetAsKey = STRING(@"0x%p", target);

    [target addObserver:self forKeyPath:keyPath options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld | NSKeyValueObservingOptionPrior context:context];
    NTYKeyValueObserverMetadata *metadata = self.metadatas[targetAsKey];
    if (!metadata) {
        metadata                    = [NTYKeyValueObserverMetadata metadataWithTarget:target];
        self.metadatas[targetAsKey] = metadata;
    }
    metadata.keyPaths[keyPath] = block;
}

- (void)removeObserverForTarget:(id)target forKeyPath:(NSString*)keyPath {
    if (!target) {
        NSLog(@"target cannot be nil");
        return;
    }

    if (!keyPath) {
        NSLog(@"keyPath cannot be nil");
        return;
    }

    NSString                    *targetAsKey = STRING(@"0x%p", target);
    NTYKeyValueObserverMetadata *metadata    = self.metadatas[targetAsKey];

    if (metadata.keyPaths[keyPath]) {
        [target removeObserver:self forKeyPath:keyPath];
        [metadata.keyPaths removeObjectForKey:keyPath];
    }

    if (metadata.keyPaths.count == 0) {
        metadata.target = nil;
        self.metadatas[targetAsKey] = nil;
    }
}

- (void)removeAllObserversForTarget:(id)target {
    if (!target) {
        NSLog(@"target cannot be nil");
        return;
    }
    NSString                    *targetAsKey = STRING(@"0x%p", target);
    NTYKeyValueObserverMetadata *metadata    = self.metadatas[targetAsKey];
    [metadata.keyPaths enumerateKeysAndObjectsUsingBlock:^(NSString*_Nonnull keyPath, NTYKeyValueObserveExecutor _Nonnull obj, BOOL*_Nonnull stop) {
        [target removeObserver:self forKeyPath:keyPath];
    }];
    [metadata.keyPaths removeAllObjects];
    metadata.target             = nil;
    self.metadatas[targetAsKey] = nil;
}

- (void)removeAllObservers {
    NSMutableDictionary<NSString*, NTYKeyValueObserverMetadata*> *metadatas = self.metadatas;
    [metadatas enumerateKeysAndObjectsUsingBlock:^(NSString*_Nonnull key, NTYKeyValueObserverMetadata*_Nonnull metadata, BOOL*_Nonnull stop) {
        [metadata.keyPaths enumerateKeysAndObjectsUsingBlock:^(NSString*_Nonnull keyPath, NTYKeyValueObserveExecutor _Nonnull obj, BOOL*_Nonnull stop) {
            [metadata.target removeObserver:self forKeyPath:keyPath];
        }];
        [metadata.keyPaths removeAllObjects];
        metadata.target = nil;
    }];

    [metadatas removeAllObjects];
}

- (void)observeValueForKeyPath:(NSString*)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id>*)change context:(void*)context {
    if (!object) {
        NSLog(@"target cannot be nil");
        return;
    }
    NSString                    *targetAsKey = STRING(@"0x%p", object);
    NTYKeyValueObserverMetadata *target      = self.metadatas[targetAsKey];
    NTYKeyValueObserveExecutor   executor    = target.keyPaths[keyPath];
    if (executor) {
        executor(target.target, change[NSKeyValueChangeNewKey], change, context);
    }
}

@end

@interface NTYNotificationObserver ()
@property (nonatomic, strong) NSNotificationName  name;
@property (nonatomic, weak) id                    source;
@property (nonatomic, copy) NTYNotificationAction action;
@property (nonatomic, assign) BOOL                disposed;
#if 0
    @property (nonatomic, strong) id              token;
    @property (nonatomic, strong) RACDisposable  *disposable;
#endif // if 0
@end

@implementation NTYNotificationObserver
@synthesize disposed = _disposed;

+ (dispatch_queue_t)queue {
    static dispatch_once_t  onceToken;
    static dispatch_queue_t queue;
    dispatch_once(&onceToken, ^{
        queue = dispatch_queue_create("NTYNotificationObserver-queue", DISPATCH_QUEUE_CONCURRENT);
    });
    return queue;
}

+ (instancetype)observe:(NSNotificationName)name from:(id)source action:(NTYNotificationAction)action {
    return [[self alloc] initWithName:name source:source action:action];
}
#if 1
    - (instancetype)initWithName:(NSNotificationName)name source:(id)source action:(NTYNotificationAction)block {
        self = [super init];
        if (self) {
            self.name   = name;
            self.source = source;
            self.action = block;
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handle:)name:name object:source];
            //self.token = [[NSNotificationCenter defaultCenter] addObserverForName:name object:source queue:[NSOperationQueue mainQueue] usingBlock:block];
        }
        return self;
    }

    - (void)dealloc {
        //dispatch_barrier_async([NTYNotificationObserver queue], ^{
        if (self.disposed) {return;}
        self.disposed = YES;
        self.source   = nil;
        self.action   = nil;
        [[NSNotificationCenter defaultCenter] removeObserver:self name:self.name object:self.source];
        //});
    }

    - (void)handle:(NSNotification*)notification {
        // NSLog(@"%@", [NSThread currentThread]);
        //dispatch_sync([NTYNotificationObserver queue], ^{
        if (self.disposed) {return;}
        self.action(notification);
        //});
    }

    - (void)host:(NSMutableArray<id<NTYObserver> >*)host {
        //dispatch_barrier_async([NTYNotificationObserver queue], ^{
        [host addObject:self];
        //});
    }

    - (void)dispose {
        //dispatch_barrier_async([NTYNotificationObserver queue], ^{
        if (self.disposed) {return;}
        self.disposed = YES;
        self.source   = nil;
        self.action   = nil;
        [[NSNotificationCenter defaultCenter] removeObserver:self name:self.name object:self.source];
        //});
    }
#else // if 0
    - (instancetype)initWithName:(NSNotificationName)name source:(id)source action:(NTYNotificationAction)block {
        self = [super init];
        if (self) {
            self.disposable = [[[NSNotificationCenter defaultCenter] rac_addObserverForName:name object:source]
                               subscribeNext:block];
        }
        return nil;
    }

    - (void)host:(NSMutableArray<id<NTYObserver> >*)host {
        [host addObject:self];
    }

    - (void)dispose {
        [self.disposable dispose];
    }

    - (BOOL)disposed {
        __block BOOL disposed = NO;
        dispatch_sync([NTYNotificationObserver queue], ^{
        disposed = self.disposable.disposed;
    });
        return disposed;
    }
#endif // if 0
@end


//@implementation RACDisposable (NTYObserver)
//- (void)host:(NSMutableArray<id<NTYObserver> >*)host {
//    [host addObject:self];
//}
//@end


@interface NTYSingleKeyValueObserver ()
@property (nonatomic,strong) NSString       *keyPath;
@property (nonatomic,weak) id                target;
@property (nonatomic,copy) NTYKeyValueAction action;
@property (atomic, assign) BOOL              disposed;
@end

@implementation NTYSingleKeyValueObserver

+ (instancetype)observer:(NSString*)keyPath target:(id)target action:(NTYKeyValueAction)block {
    return [[self alloc] initWithKeyPath:keyPath target:target action:block];
}

- (instancetype)initWithKeyPath:(nonnull NSString*)keyPath target:(id)target action:(NTYKeyValueAction)block {
    self = [super init];
    if (self) {
        self.keyPath = keyPath;
        self.target  = target;
        self.action  = block;
        [target addObserver:self forKeyPath:keyPath options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:nil];
    }
    return self;
}

- (void)dealloc {
    [self dispose];
}

- (void)observeValueForKeyPath:(NSString*)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id>*)change context:(void*)context {
    if (![keyPath isEqualToString:self.keyPath]) {
        return;
    }

    NSNumber*new = [change valueForKey:NSKeyValueChangeNewKey];
    NSNumber*old = [change valueForKey:NSKeyValueChangeOldKey];
    if (self.disposed) {return;}
    self.action(new, old);
}

- (void)host:(NSMutableArray<id<NTYObserver> >*)host {
    [host addObject:self];
}

- (void)dispose {
    if (self.disposed) {return;}
    self.disposed = YES;
    [self.target removeObserver:self forKeyPath:self.keyPath];
}
@end
