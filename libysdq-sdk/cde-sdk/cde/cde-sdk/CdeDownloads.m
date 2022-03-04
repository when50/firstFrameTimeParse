#import "CdeDownloads.h"
#import "CdeDownloadItem.h"
#import "CdeService.h"
#import "CdeBase64.h"

@interface ysdq_CdeDownloader ()
@property (nonatomic, copy) NSString  *taskId;
@property (nonatomic, strong) NSTimer *timer;
@end

@implementation ysdq_CdeDownloader

- (void)dealloc {
    NSLog(@"%@ dealloced",[self class]);
}

#pragma mark - Public

- (void) add:(NSString*)url
    filePath:(NSString*)filePath
    complete:(void (^)(NSString*))complete {
    @synchronized(self) {
        NSString *base64String = ysdq_cdeUrlBase64EncodedString(url);
        NSString *paraStr      = [NSString stringWithFormat:@"filepath=%@&url=%@", filePath, base64String];
        NSString *urlString    = [self getHttpUrl:@"add" parametersStr:paraStr];
        [self httpGet:urlString complete:^(NSDictionary *response, NSError *error) {
            if (!self) {return;}
            BOOL isSuccess = [self isRequestSuccess:response];
            if (error || !isSuccess) {
                if (complete) {
                    complete(nil);
                }
            } else {
                NSDictionary *item = [self itemAtIndex:0 response:response];
                NSString *taskID = [item valueForKey:@"taskid"];
                self.taskId = taskID;
                [self startTimer];
                if (complete) {
                    complete(taskID);
                }
            }
        }];
    }
}

- (void)stop:(NSString*)taskId complete:(CDEDownloadProcessBlock)complete {
    if (taskId.length == 0) {
        return;
    }

    @synchronized(self) {
        NSString *paraStr   = [NSString stringWithFormat:@"taskid=%@",taskId];
        NSString *urlString = [self getHttpUrl:@"stop" parametersStr:paraStr];
        [self httpGet:urlString complete:^(NSDictionary *response, NSError *error) {
            if (!self) {return;}
            BOOL isSuccess = [self isRequestSuccess:response];
            if (error || !isSuccess) {
                if (complete) {
                    complete(NO);
                }
            } else {
                [self stopTimer];
                if (complete) {
                    complete(YES);
                }
            }
        }];
    }
}

- (void)start:(NSString*)taskId
          url:(NSString*)url
     complete:(CDEDownloadProcessBlock)complete {
    if (taskId.length == 0 || url.length == 0) {
        return;
    }

    @synchronized(self) {
        NSString *encodeUrl = ysdq_cdeUrlBase64EncodedString(url);
        NSString *paraStr   = [NSString stringWithFormat:@"taskid=%@&url=%@",taskId,encodeUrl];
        NSString *urlString = [self getHttpUrl:@"start" parametersStr:paraStr];
        NSLog(@"startURL==%@",urlString);
        [self httpGet:urlString complete:^(NSDictionary *response, NSError *error) {
            if (!self) {return;}
            BOOL isSuccess = [self isRequestSuccess:response];
            if (error || !isSuccess) {
                if (complete) {
                    complete(NO);
                }
            } else {
                self.taskId = taskId;
                [self startTimer];
                if (complete) {
                    complete(YES);
                }
            }
        }];
    }
}

- (void)deleteTask:(NSString*)taskId complete:(CDEDownloadProcessBlock)complete {
    if (taskId.length == 0) {
        return;
    }

    @synchronized(self) {
        NSString *paraStr   = [NSString stringWithFormat:@"taskid=%@",taskId];
        NSString *urlString = [self getHttpUrl:@"del" parametersStr:paraStr];
        [self httpGet:urlString complete:^(NSDictionary *response, NSError *error) {
            if (!self) {return;}
            BOOL isSuccess = [self isRequestSuccess:response];
            if (error || !isSuccess) {
                if (complete) {
                    complete(NO);
                }
            } else {
                [self stopTimer];
                if (complete) {
                    complete(YES);
                }
            }
        }];
    }
}

- (void)deleteAll:(CDEDownloadProcessBlock)complete {
    @synchronized(self) {
        NSString *urlString = [self getHttpUrl:@"del/all"parametersStr:nil];
        [self httpGet:urlString complete:^(NSDictionary *response, NSError *error) {
            if (!self) {return;}
            BOOL isSuccess = [self isRequestSuccess:response];
            if (error || !isSuccess) {
                if (complete) {
                    complete(NO);
                }
            } else {
                [self stopTimer];
                if (complete) {
                    complete(YES);
                }
            }
        }];
    }
}

/*
 * {
 * "code": 0,
 * "data": {
 *        "items": [{
 *                 "completedsize": 159980104,
 *                 "filepath": "/sdcard/download/1.ts",
 *                 "finish": true,
 *                 "name": "1.ts",
 *                 "taskid": "da8a50f2-6532-4598-9a0a-bb670d62f2a3",
 *                 "totalsize": 159980104,
 *                 "code": 159980104,
 *                 "msg": 159980104,
 *                 }]
 *      },
 * "msg": "Success"
 * }
 *
 */

- (void)query:(NSString*)taskId complete:(void (^)(unsigned long long finishSize,BOOL isFinish))complete {
    if (taskId.length == 0) {
        if (complete) {
            complete(0,NO);
        }
        return;
    }

    @synchronized(self) {
        NSString *paraStr   = [NSString stringWithFormat:@"taskid=%@",taskId];
        NSString *urlString = [self getHttpUrl:@"query" parametersStr:paraStr];
        [self httpGet:urlString complete:^(NSDictionary *response, NSError *error) {
            if (!self) {return;}
            BOOL isSuccess = [self isRequestSuccess:response];
            if (isSuccess) {
                NSDictionary *item = [self itemAtIndex:0 response:response];
                BOOL isFinish = [item[@"finish"] boolValue];
                if (isFinish) {
                    [self stopTimer];
                    if (complete) {//表明只是纯粹查询，不需要代理回调
                        complete(0,YES);
                    } else {
                        NSString *taskId = [item valueForKey:@"taskid"];
                        [self stop:taskId complete:nil];

                        if ([self.delegate respondsToSelector:@selector(CdeDownloadDidFinished:)]) {
                            [self.delegate CdeDownloadDidFinished:self];
                        }
                    }
                } else {
                    if (complete) {
                        complete([item[@"completedsize"] longValue],NO);
                    } else {
                        if ([self.delegate respondsToSelector:@selector(CdeDownload:fileSize:finishedSize:)]) {
                            [self.delegate CdeDownload:self fileSize:[item[@"totalsize"] longValue] finishedSize:[item[@"completedsize"] longValue]];
                        }
                        if ([item valueForKeyPath:@"psize"]) {
                            if ([self.delegate respondsToSelector:@selector(CdeDownloadDidChangedProgress:tspsize:tscsize:)]) {
                                [self.delegate CdeDownloadDidChangedProgress:self
                                                                     tspsize:[item[@"psize"] longValue] tscsize:[item[@"csize"] longValue]];
                            }
                        }
                    }
                }
            } else {
                if (complete) {//下载前查询失败
                    complete(0,NO);
                } else {//下载过程中查询,发现失败
                    [self stopTimer];
                    [self.delegate CdeDownloadDidFail:self];
                }
            }
        }];
    }
}

- (NSArray<ysdq_CdeDownloadItem*>*)list {
    @synchronized(self) {
        NSString *urlString = [self getHttpUrl:@"list" parametersStr:nil];
        [self httpGet:urlString complete:^(NSDictionary *response, NSError *error) {
        }];
        return nil;
    }
}

- (void)updateFilePath:(NSString*)filePath
                taskid:(NSString*)taskid
              complete:(CDEDownloadProcessBlock)complete {
    @synchronized(self) {
        NSString *paraStr   = [NSString stringWithFormat:@"taskid=%@&filepath=%@", taskid, filePath];
        NSString *urlString = [self getHttpUrl:@"update" parametersStr:paraStr];
        [self httpGet:urlString complete:^(NSDictionary *response, NSError *error) {
            if (!self) {return;}
            BOOL isSuccess = [self isRequestSuccess:response];
            if (complete) {
                complete(isSuccess);
            }
        }];
    }
}

#pragma mark - Timer

- (void)startTimer {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self stopTimer];
        self.timer = [NSTimer timerWithTimeInterval:2.0 target:self selector:@selector(timerAction:)userInfo:nil repeats:YES];
        [[NSRunLoop currentRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
    });
}

- (void)stopTimer {
    if (self.timer) {
        [self.timer invalidate];
    }
}

- (void)timerAction:(NSTimer*)timer {
    [self query:self.taskId complete:nil];
}

#pragma mark - Private

- (void)httpGet:(NSString*)urlString complete:(void (^)(NSDictionary*response,NSError*error))complete {
    NSString             *url     = [urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSURL                *URL     = [NSURL URLWithString:url];
    NSURLSession         *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *task    = [session dataTaskWithURL:URL completionHandler:^(NSData*_Nullable data, NSURLResponse*_Nullable response, NSError*_Nullable error) {
        if (complete) {
            if (error) {
                complete(nil,error);
            } else {
                NSDictionary *ret = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
                complete(ret,nil);
            }
        }
    }];
    [task resume];
}

- (NSString*)getHttpUrl:(NSString*)cmd parametersStr:(NSString*)paraStr {
    return [NSString stringWithFormat:@"http://%@:%d/download/%@?%@",@"127.0.0.1",7990, cmd,paraStr?:@""];
}

- (BOOL)isRequestSuccess:(NSDictionary*)response {
    NSInteger code = -1;
    if ([response valueForKey:@"code"]) {
        code = [response[@"code"] integerValue];
        if (code != 0) {
            return NO;
        }
    }

    NSDictionary *fristItem = [self itemAtIndex:0 response:response];
    BOOL          isSuccess = ([fristItem[@"code"] integerValue] == 0);
    return isSuccess;
}

- (NSDictionary*)itemAtIndex:(NSInteger)index response:(NSDictionary*)responseDict {
    if ([[responseDict valueForKey:@"data"] valueForKey:@"items"]) {
        NSArray *items = [[responseDict valueForKey:@"data"] valueForKey:@"items"];
        if ([items isKindOfClass:[NSArray class]] && items.count > index) {
            NSDictionary *item = items[index];
            return item;
        }
    }
    return nil;
}
@end
