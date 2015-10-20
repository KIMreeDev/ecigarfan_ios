//
//  OtherPostServer.h
//  ECIGARFAN
//
//  Created by JIRUI on 14-6-11.
//  Copyright (c) 2014年 JIRUI. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Post.h"
@class OtherPostServer;
@protocol OtherPostServerDelegate <NSObject>
/*
 请求完成与失败协议
 1.成功刷新帖子回调
 2.刷新帖子错误回调
 3.成功加载下一页回调
 4.加载下一页错误回调
 */
- (void)didReloadOtherPostListFinished:(OtherPostServer *)server type:(NSString *)type updateCount:(NSInteger)count;
- (void)didReloadOtherPostListFailed:(OtherPostServer *)server type:(NSString *)type errorCode:(NSInteger)code message:(NSString *)msg;

- (void)didLoadNextOtherPostListFinished:(OtherPostServer *)server type:(NSString *)type isLoadAll:(BOOL)isLoadAll;
- (void)didLoadNextOtherPostListFailed:(OtherPostServer *)server type:(NSString *)type errorCode:(NSInteger)code message:(NSString *)msg;
@end

@interface OtherPostServer : NSObject
@property(nonatomic,readonly) NSMutableArray *allPostList;//所有帖子（只生成getter方法）
+ (OtherPostServer *)sharedInstance; //初始化
- (void)reloadOtherPostListWithID:(NSInteger)customerID delegate:(id<OtherPostServerDelegate>)delegate;//重新加载帖子
- (void)loadNextOtherPostListWithID:(NSInteger)customerID delegate:(id<OtherPostServerDelegate>)delegate;//加载下一页帖子

@end
