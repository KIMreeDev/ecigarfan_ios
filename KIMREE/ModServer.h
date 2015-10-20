//
//  ModServer.h
//  ECIGARFAN
//
//  Created by JIRUI on 14-6-17.
//  Copyright (c) 2014年 JIRUI. All rights reserved.
//

#import <Foundation/Foundation.h>
@class ModServer;
@protocol ModServerDelegate <NSObject>
/*
 请求完成与失败协议
 1.成功刷新版块回调
 2.刷新版块错误回调
 */
- (void)didLoadCacheModListFinished:(ModServer*)server type:(NSString *)type count:(NSInteger)count;
- (void)didReloadModListFinished:(ModServer *)server type:(NSString *)type updateCount:(NSInteger)count;
- (void)didReloadModListFailed:(ModServer *)server type:(NSString *)type errorCode:(NSInteger)code message:(NSString *)msg;
@end

@interface ModServer : NSObject
@property(nonatomic,readonly) NSMutableArray *modList;//所有帖子（只生成getter方法）
+ (ModServer *)sharedInstance; //初始化
- (void)loadCacheModListWithType:(NSString *)type delegate:(id<ModServerDelegate>)delegate;//筛选本地运单
- (void)reloadModListWithType:(NSString *)type delegate:(id<ModServerDelegate>)delegate;//重新加载帖子

@end
