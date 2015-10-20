//
//  OtherPostServer.m
//  ECIGARFAN
//
//  Created by JIRUI on 14-6-11.
//  Copyright (c) 2014年 JIRUI. All rights reserved.
//

#import "OtherPostServer.h"
#import "ErrorHelper.h"
#import "ArchiveServer.h"
static OtherPostServer *instance;

@interface OtherPostServer ()
{
    NSInteger allPage;
}
@end

@implementation OtherPostServer
@synthesize allPostList;
- (id)init
{
    self = [super init];
    if (self) {
        allPostList = [[NSMutableArray alloc] init];//所有帖子
        allPage = 1;//页数
    }
    return self;
}
/*
 * @brief 初始化
 */
+ (OtherPostServer *)sharedInstance
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[OtherPostServer alloc] init];
    });
    return instance;
}
/*
 *重新请求帖子（刷新）
 */
- (void)reloadOtherPostListWithID:(NSInteger)customerID delegate:(id<OtherPostServerDelegate>)delegate{
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params setObject:@(1) forKey:@"page"];
    [params setObject:@(C_API_LIST_NUM) forKey:@"count"];
    [params setObject:@(customerID) forKey:@"customer_id"];//发帖人
    [[JRRequestManager shareInstance]
     startRequestWithCmd:API_CMD_ALLPOST_LIST
     method:JRRequestMethodPOST
     params:params
     key:API_CMD_ALLPOST_LIST
     failed:^(JRRequest *request,NSError *error){
         NSInteger code = error.code;
         NSString *msg = [ErrorHelper messageWithCode:!code];
         if (delegate && [delegate respondsToSelector:@selector(didReloadOtherPostListFailed:type:errorCode:message:)]) {
             [delegate didReloadOtherPostListFailed:self type:NULL errorCode:code message:msg];
         }
     }
     finished:^(JRRequest *request,JRResponse *response){
         if (!response.code) {
             if (delegate && [delegate respondsToSelector:@selector(didReloadOtherPostListFailed:type:errorCode:message:)]) {
                 [delegate didReloadOtherPostListFailed:self type:NULL errorCode:!response.code message:response.msg];
             }
         }
         else{
             NSArray *array = [response.data valueForKey:@"list"];
             [self handleReloadOtherPostWithPosts:array delegate:delegate];
         }
     }];
    
}
//重新加载帖子
- (void)handleReloadOtherPostWithPosts:(NSArray *)posts delegate:(id<OtherPostServerDelegate>)delegate
{
    NSInteger updateCount = 0;
    NSMutableArray *array = [[NSMutableArray alloc] init];
    if (posts.count > 0) {
        for (NSDictionary *dict in posts) {
            Post *post = [[Post alloc] init];
            [post loadData:dict];
            [array addObject:post];
            if (![allPostList containsObject:post]) {
                updateCount++;//更新帖子数量
            }
        }
        //保存数据
        [allPostList removeAllObjects];
        [allPostList addObjectsFromArray:array];
        allPage = 1;
    }
    if (delegate && [delegate respondsToSelector:@selector(didReloadOtherPostListFinished:type:updateCount:)]) {
        [delegate didReloadOtherPostListFinished:self type:NULL updateCount:updateCount];
    }
}
/*
 * 6
 * @brief 加载下一页帖子
 */
- (void)loadNextOtherPostListWithID:(NSInteger)customerID delegate:(id<OtherPostServerDelegate>)delegate{
    allPage++;
    [[JRRequestManager shareInstance]
     startRequestWithCmd:API_CMD_ALLPOST_LIST
     method:JRRequestMethodPOST
     params:@{@"page":@(allPage),
              @"count":@(C_API_LIST_NUM),
              @"customer_id":@(customerID)//发帖人ID
              }
     key:API_CMD_ALLPOST_LIST
     failed:^(JRRequest *request,NSError *error){
         NSInteger code = error.code;
         NSString *msg = [ErrorHelper messageWithCode:!code];
         if (delegate && [delegate respondsToSelector:@selector(didLoadNextOtherPostListFailed:type:errorCode:message:)]) {
             [delegate didLoadNextOtherPostListFailed:self type:NULL errorCode:code message:msg];
         }
     }
     finished:^(JRRequest *request,JRResponse *response){
         if (!response.code) {
             if (delegate && [delegate respondsToSelector:@selector(didLoadNextOtherPostListFailed:type:errorCode:message:)]) {
                 [delegate didLoadNextOtherPostListFailed:self type:NULL errorCode:!response.code message:response.msg];
             }
         }
         else{
             NSInteger count = [[response.data valueForKey:@"count"] integerValue];
             NSArray *array = [response.data valueForKey:@"list"];
             NSMutableArray *posts = [[NSMutableArray alloc] init];
             if (array.count > 0) {
                 for (NSDictionary *dict in array) {
                     Post *post = [[Post alloc] init];
                     [post loadData:dict];
                     [posts addObject:post];
                 }
                 //保存数据
                 [allPostList removeAllObjects];
                 [allPostList addObjectsFromArray:posts];
            }
             //看帖子是否都添加正确
             BOOL isLoadAll = array.count >= count;
             if (delegate && [delegate respondsToSelector:@selector(didLoadNextOtherPostListFinished:type:isLoadAll:)]) {
                 [delegate didLoadNextOtherPostListFinished:self type:NULL isLoadAll:isLoadAll];
             }
         }
     }];
}

@end
