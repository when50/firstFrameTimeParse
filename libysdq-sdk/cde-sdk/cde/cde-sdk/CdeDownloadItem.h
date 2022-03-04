//
//  CdeDownloadItem.h
//
//  Created by yuanfeixiong@letv.com on 2014-11-12.
//  Copyright (C) 2014 LeTV
//

#import <Foundation/Foundation.h>

//
// CDE(Cloud Data Entry) Download Item
//
@interface ysdq_CdeDownloadItem : NSObject
{
}

@property (nonatomic, copy) NSString  *apptag_;
@property (nonatomic, copy) NSString *taskid_;
@property (nonatomic, assign) NSInteger state_; // started = 1  finished = 2  pending = 3  failed = 4  paused = 5  removed = 6
@property (nonatomic, copy) NSString *stateName_;
@property (nonatomic, assign) int removedState_;
@property (nonatomic, assign) int priority_;
@property (nonatomic, assign) int errorCode_;
@property (nonatomic, copy) NSString *url_;
@property (nonatomic, copy) NSString *filename_;
@property (nonatomic, copy) NSString *filepathTmp_;
@property (nonatomic, copy) NSString *filepath_;
@property (nonatomic, copy) NSString *createTime_;
@property (nonatomic, assign) float progress_;
@property (nonatomic, assign) long finishedSize_;
@property (nonatomic, assign) long size_;
@property (nonatomic, copy) NSString *fileext_;
@property (nonatomic, assign) long downloadRate_;
@property (nonatomic, copy) NSString *expireTime_;
@property (nonatomic, assign) int fileErrorCode_;
@property (nonatomic, copy) NSString *base64Url_;
@property (nonatomic, copy) NSString *other_;

@end
