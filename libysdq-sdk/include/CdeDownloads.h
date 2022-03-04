//
//  CdeDownloads.h
//
//  Created by yuanfeixiong@letv.com on 2014-11-12.
//  Copyright (C) 2014 LeTV
//

#import <Foundation/Foundation.h>
#import "CdeDownloadItem.h"

@class ysdq_CdeDownloader;

@protocol ysdq_CdeDownloadDelegate <NSObject>
@optional
- (void)CdeDownload:(ysdq_CdeDownloader*)cdeDownload
           fileSize:(unsigned long long)fileSize
       finishedSize:(unsigned long long)finishedSize;
- (void)CdeDownloadDidChangedProgress:(ysdq_CdeDownloader*)cdeDownload;
- (void)CdeDownloadDidFinished:(ysdq_CdeDownloader*)cdeDownload;
- (void)CdeDownloadDidDidFail:(ysdq_CdeDownloader*)cdeDownload;
@end


typedef void (^CDEDownloadProcessBlock)(BOOL success);
//
// CDE(Cloud Data Entry) Downloads
//
@interface ysdq_CdeDownloader : NSObject
@property (nonatomic, weak)id<ysdq_CdeDownloadDelegate> delegate;

- (void) add:(NSString*)url
    filePath:(NSString*)filePath
    complete:(void (^)(NSString*taskID))complete;                           //新添加任务
- (void)stop:(NSString*)taskId complete:(CDEDownloadProcessBlock)complete;  //暂停或完成后stop
- (void)start:(NSString*)taskId
          url:(NSString*)url
     complete:(CDEDownloadProcessBlock)complete; //断点续传
- (void)deleteTask:(NSString*)taskId complete:(CDEDownloadProcessBlock)complete;
//- (void)deleteAll:(CDEDownloadProcessBlock)complete;
- (void)query:(NSString*)taskId complete:(void (^)(unsigned long long finishSize,BOOL isFinish))complete; //单个任务信息,返回值表示是否下载完成，查询不到也代表未下载完成
//- (NSArray<ysdq_CdeDownloadItem*>*)list;                                      //所有任务信息

- (void)updateFilePath:(NSString*)filePath
                taskid:(NSString*)taskid
              complete:(CDEDownloadProcessBlock)complete;//更新指定taskID的filepath
@end

