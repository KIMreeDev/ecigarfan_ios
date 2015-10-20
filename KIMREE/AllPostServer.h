//
//  AllPostServer.h
//  ECIGARFAN
//
//  Created by JIRUI on 14-5-28.
//  Copyright (c) 2014年 JIRUI. All rights reserved.
//

#import <Foundation/Foundation.h>
#include "Post.h"
@class AllPostServer;
@protocol AllPostServerDelegate <NSObject>
/*
 请求完成与失败协议
 1.成功刷新帖子回调
 2.刷新帖子错误回调
 3.成功加载下一页回调
 4.加载下一页错误回调
 */
- (void)didLoadCachePostListFinished:(AllPostServer *)server type:(NSInteger)type count:(NSInteger)count;
- (void)didReloadAllPostListFinished:(AllPostServer *)server type:(NSInteger)type updateCount:(NSInteger)count;
- (void)didReloadAllPostListFailed:(AllPostServer *)server type:(NSInteger)type errorCode:(NSInteger)code message:(NSString *)msg;

- (void)didLoadNextAllPostListFinished:(AllPostServer *)server type:(NSInteger)type isLoadAll:(BOOL)isLoadAll;
- (void)didLoadNextAllPostListFailed:(AllPostServer *)server type:(NSInteger)type errorCode:(NSInteger)code message:(NSString *)msg;
@end

@interface AllPostServer : NSObject
@property(nonatomic,readonly) NSMutableArray *allPostListMod1;//所有帖子（只生成getter方法）
@property(nonatomic,readonly) NSMutableArray *allPostListMod2;//所有帖子（只生成getter方法）
@property(nonatomic,readonly) NSMutableArray *allPostListMod3;//所有帖子（只生成getter方法）
@property(nonatomic,readonly) NSMutableArray *allPostListMod4;//所有帖子（只生成getter方法）
+ (AllPostServer *)sharedInstance; //初始化
- (void)loadCachePostListWithType:(NSInteger)type delegate:(id<AllPostServerDelegate>)delegate;//筛选本地运单
- (void)reloadAllPostListWithType:(NSInteger)type delegate:(id<AllPostServerDelegate>)delegate;//重新加载帖子
- (void)loadNextPostListWithType:(NSInteger)type delegate:(id<AllPostServerDelegate>)delegate;//加载下一页帖子
- (void)addPost:(Post *)post
         failed:(void(^)(NSInteger code,NSString *msg))failed
       finished:(void(^)(JRRequest *request,JRResponse *response))finished;//添加帖子
- (void)deletePost:(Post *)post;
@end
