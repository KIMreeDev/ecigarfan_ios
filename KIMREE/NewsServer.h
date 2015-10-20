//
//  NewsServer.h
//  ECIGARFAN
//
//  Created by JIRUI on 14-6-4.
//  Copyright (c) 2014年 JIRUI. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NewsModel.h"
@class NewsServer;
@protocol NewsServerDelegate <NSObject>
/*
 请求完成与失败协议
 1.成功刷新消息回调
 2.刷新消息错误回调
 */
- (void)didLoadCacheNewsListFinished:(NewsServer*)server type:(NSString *)type count:(NSInteger)count;
- (void)didReloadNewsListFinished:(NewsServer *)server type:(NSString *)type updateCount:(NSInteger)count;
- (void)didReloadNewsListFailed:(NewsServer *)server type:(NSString *)type errorCode:(NSInteger)code message:(NSString *)msg;
@end

@interface NewsServer : NSObject
@property(nonatomic,readonly) NSMutableArray *newsList;//所有帖子（只生成getter方法）
+ (NewsServer *)sharedInstance; //初始化
- (void)loadCacheNewsListWithType:(NSString *)type delegate:(id<NewsServerDelegate>)delegate;//筛选本地运单
- (void)reloadNewsListWithType:(NSString *)type delegate:(id<NewsServerDelegate>)delegate;//重新加载帖子

@end
