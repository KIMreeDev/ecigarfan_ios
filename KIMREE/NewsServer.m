//
//  NewsServer.m
//  ECIGARFAN
//
//  Created by JIRUI on 14-6-4.
//  Copyright (c) 2014年 JIRUI. All rights reserved.
//

#import "NewsServer.h"
#import "ErrorHelper.h"
#import "ArchiveServer.h"
static NewsServer *instance;

@interface NewsServer (){

}
@end
@implementation NewsServer
@synthesize newsList;
- (id)init
{
    self = [super init];
    if (self) {
        newsList = [[NSMutableArray alloc] init];//所有帖子
    }
    return self;
}
/*
 * @brief 初始化
 */
+ (NewsServer *)sharedInstance
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[NewsServer alloc] init];
    });
    return instance;
}
/*
 归档消息数组
 */
- (void)archiveNews:(NSArray *)news key:(NSString *)key
{
    dispatch_async(dispatch_get_global_queue(0, 0), ^(void){
        [[ArchiveServer defaultArchiver] archiveObject:news key:key];
    });
}
/*
 加载本地
 */
- (void)loadCacheNewsListWithType:(NSString *)type delegate:(id<NewsServerDelegate>)delegate{
    NSInteger count = 0;
    NSInteger customerID = 0;//根据登录用户的ID存储文件
    NSDictionary *dic=[[LocalStroge sharedInstance] getObjectAtKey:F_USER_INFORMATION filePath:NSDocumentDirectory];
    customerID = [[dic objectForKey:@"customer_id"]integerValue];
    NSString *myFile = [NSString stringWithFormat:@"%@_%li",C_FILE_POSTS_My, (long)customerID];
    
    NSArray *array = [[ArchiveServer defaultArchiver] unarchiveWithKey:myFile];
    if (array.count) {
        [newsList removeAllObjects];
        [newsList addObjectsFromArray:array];
    }
    count = newsList.count;
    if (delegate && [delegate respondsToSelector:@selector(didLoadCacheNewsListFinished:type:count:)]) {
        [delegate didLoadCacheNewsListFinished:self type:NULL count:count];//回掉已加载本地完成
    }
}
/*
 *重新请求消息（刷新）
 */
- (void)reloadNewsListWithType:(NSString *)type delegate:(id<NewsServerDelegate>)delegate{
    NSDictionary *dic=[[LocalStroge sharedInstance] getObjectAtKey:F_USER_INFORMATION filePath:NSDocumentDirectory];
    NSInteger customerID = [[dic objectForKey:@"customer_id"]integerValue];//从后台取得customerID数据
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params setObject:@(customerID) forKey:@"customer_id"];
    [[JRRequestManager shareInstance]
     startRequestWithCmd:API_CMD_NEWS_LIST
     method:JRRequestMethodPOST
     params:params
     key:API_CMD_NEWS_LIST
     failed:^(JRRequest *request,NSError *error){
         NSInteger code = error.code;
         NSString *msg = [ErrorHelper messageWithCode:code];
         if (delegate && [delegate respondsToSelector:@selector(didReloadNewsListFailed:type:errorCode:message:)]) {
             [delegate didReloadNewsListFailed:self type:NULL errorCode:code message:msg];
         }
     }
     finished:^(JRRequest *request,JRResponse *response){
         if (!response.code) {
             if (delegate && [delegate respondsToSelector:@selector(didReloadNewsListFailed:type:errorCode:message:)]) {
                 [delegate didReloadNewsListFailed:self type:NULL errorCode:!response.code message:response.msg];
             }
         }
         else{
             NSArray *array = [response.data valueForKey:@"list"];
             [self handleReloadNews:array delegate:delegate];
         }
     }];
    
}

//重新刷新消息并存储
- (void)handleReloadNews:(NSArray *)news delegate:(id<NewsServerDelegate>)delegate
{
    NSInteger updateCount = 0;
    if (news.count > 0) {
        for (NSDictionary *dict in news) {
            NewsModel *newModel = [[NewsModel alloc] init];
            [newModel loadData:dict];
            [self.newsList insertObject:newModel atIndex:0];
            updateCount++;//更新数量
        }
        //保存数据到本地
        NSInteger customerID = 0;//根据登录用户的ID存储文件
        NSDictionary *dic=[[LocalStroge sharedInstance] getObjectAtKey:F_USER_INFORMATION filePath:NSDocumentDirectory];
        customerID = [[dic objectForKey:@"customer_id"]integerValue];
        NSString *myFile = [NSString stringWithFormat:@"%@_%li",C_FILE_POSTS_My, (long)customerID];
        
        [self archiveNews:self.newsList key:myFile];
    }
    if (delegate && [delegate respondsToSelector:@selector(didReloadNewsListFinished:type:updateCount:)]) {
        [delegate didReloadNewsListFinished:self type:NULL updateCount:updateCount];
    }
}
/*
 * 8
 * @brief 删除帖子,提交到服务器后保存本地
 */
- (void)deleteNews:(NewsModel *)news
            failed:(void(^)(NSInteger code,NSString *msg))failed
          finished:(void(^)(JRRequest *request,JRResponse *response))finished
{
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params setObject:@(news.newsID) forKey:@"news_id"];//帖子id
    [[JRRequestManager shareInstance]
     startRequestWithCmd:API_CMD_NEWS_DELETE
     method:JRRequestMethodPOST
     params:params
     key:API_CMD_NEWS_DELETE
     failed:^(JRRequest *request,NSError *error){
         NSInteger code = error.code;
         NSString *msg = [ErrorHelper messageWithCode:!code];
         failed(code,msg);//失败返回
     }
     finished:^(JRRequest *request,JRResponse *response){
         if (!response.code) {
             finished(request, response);//返回
         }
         else{
             [self deleteNews:news];
             finished(request, response);//返回
         }
     }];
}

//删除帖子
- (void)deleteNews:(NewsModel *)news
{
    if ([self.newsList containsObject:news]) {
        [self.newsList removeObject:news];
        NSInteger customerID = 0;//根据登录用户的ID存储文件
        NSDictionary *dic=[[LocalStroge sharedInstance] getObjectAtKey:F_USER_INFORMATION filePath:NSDocumentDirectory];
        customerID = [[dic objectForKey:@"customer_id"]integerValue];
        NSString *myFile = [NSString stringWithFormat:@"%@_%li",C_FILE_POSTS_My, (long)customerID];
        
        [self archiveNews:self.newsList key:myFile];
    }
}


@end
