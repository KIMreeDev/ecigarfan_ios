//
//  MyPostServer.h
//  ECIGARFAN
//
//  Created by JIRUI on 14-5-27.
//  Copyright (c) 2014年 JIRUI. All rights reserved.
//

#import <Foundation/Foundation.h>
#include "Post.h"
@class MyPostServer;
@protocol PostServerDelegate <NSObject>
/*
 请求完成与失败协议
 1.成功刷新帖子回调
 2.刷新帖子错误回调
 3.成功加载下一页回调
 4.加载下一页错误回调
 */
- (void)didLoadCacheMyPostListFinished:(MyPostServer*)server type:(NSString *)type count:(NSInteger)count;
- (void)didReloadMyPostListFinished:(MyPostServer *)server type:(NSString *)type updateCount:(NSInteger)count;
- (void)didReloadMyPostListFailed:(MyPostServer *)server type:(NSString *)type errorCode:(NSInteger)code message:(NSString *)msg;

- (void)didLoadNextMyPostListFinished:(MyPostServer *)server type:(NSString *)type isLoadAll:(BOOL)isLoadAll;
- (void)didLoadNextMyPostListFailed:(MyPostServer *)server type:(NSString *)type errorCode:(NSInteger)code message:(NSString *)msg;
@end

@interface MyPostServer : NSObject
@property(nonatomic,readonly) NSMutableArray *allPostList;//所有帖子（只生成getter方法）
+ (MyPostServer *)sharedInstance; //初始化
- (void)loadCachePostListWithType:(Post *)post delegate:(id<PostServerDelegate>)delegate;//筛选本地运单
- (void)reloadPostListWithType:(Post *)post delegate:(id<PostServerDelegate>)delegate;//重新加载帖子
- (void)loadNextPostListWithType:(Post *)post delegate:(id<PostServerDelegate>)delegate;//加载下一页帖子
- (void)deletePost:(Post *)post
            failed:(void(^)(NSInteger code,NSString *msg))failed
          finished:(void(^)(JRRequest *request,JRResponse *response))finished;
@end
