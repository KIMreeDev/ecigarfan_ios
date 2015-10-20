//
//  MyPostServer.m
//  ECIGARFAN
//
//  Created by JIRUI on 14-5-27.
//  Copyright (c) 2014年 JIRUI. All rights reserved.
//

#import "MyPostServer.h"
#import "ErrorHelper.h"
#import "ArchiveServer.h"
#import "AllPostServer.h"
#define UDK_ALL_MYPOST_LIST_PAGE @"udk.all.mypost.list.page"
static MyPostServer *instance;

@interface MyPostServer (){
    NSInteger allPage;
}

@end
@implementation MyPostServer
@synthesize allPostList;

- (id)init
{
    self = [super init];
    if (self) {
        allPostList = [[NSMutableArray alloc] init];//所有帖子
        allPage = [S_USER_DEFAULTS integerForKey:UDK_ALL_MYPOST_LIST_PAGE];//从本地取帖子页数
    }
    return self;
}
/*
 * @brief 初始化
 */
+ (MyPostServer *)sharedInstance
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[MyPostServer alloc] init];
    });
    return instance;
}
/*
 归档帖子数组
 */
- (void)archivePosts:(NSArray *)posts key:(NSString *)key
{
    dispatch_async(dispatch_get_global_queue(0, 0), ^(void){
        [[ArchiveServer defaultArchiver] archiveObject:posts key:key];
    });
}
/*
 加载本地
 */
- (void)loadCachePostListWithType:(Post *)post delegate:(id<PostServerDelegate>)delegate{
    NSInteger count = 0;
    NSInteger customerID = 0;//根据登录用户的ID读取文件
    NSDictionary *dic=[[LocalStroge sharedInstance] getObjectAtKey:F_USER_INFORMATION filePath:NSDocumentDirectory];
    customerID = [[dic objectForKey:@"customer_id"]integerValue];
    NSString *myFile = [NSString stringWithFormat:@"%@_%li",C_FILE_POSTS_My, (long)customerID];
    NSArray *array = [[ArchiveServer defaultArchiver] unarchiveWithKey:myFile];
    [allPostList removeAllObjects];
    [allPostList addObjectsFromArray:array];
    count = allPostList.count;
    if (delegate && [delegate respondsToSelector:@selector(didLoadCacheMyPostListFinished:type:count:)]) {
        [delegate didLoadCacheMyPostListFinished:self type:NULL count:count];//回掉已加载本地完成
    }
}
/*
 *重新请求帖子（刷新）
 */
- (void)reloadPostListWithType:(Post *)post delegate:(id<PostServerDelegate>)delegate{
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params setObject:@(1) forKey:@"page"];
    [params setObject:@(C_API_LIST_NUM) forKey:@"count"];
    [params setObject:@(post.customerID) forKey:@"customer_id"];//发帖人
    [[JRRequestManager shareInstance]
     startRequestWithCmd:API_CMD_ALLPOST_LIST
     method:JRRequestMethodPOST
     params:params
     key:API_CMD_ALLPOST_LIST
     failed:^(JRRequest *request,NSError *error){
         NSInteger code = error.code;
         NSString *msg = [ErrorHelper messageWithCode:!code];
         if (delegate && [delegate respondsToSelector:@selector(didReloadMyPostListFailed:type:errorCode:message:)]) {
             [delegate didReloadMyPostListFailed:self type:NULL errorCode:code message:msg];
         }
     }
     finished:^(JRRequest *request,JRResponse *response){
         if (!response.code) {
             if (delegate && [delegate respondsToSelector:@selector(didReloadMyPostListFailed:type:errorCode:message:)]) {
                 [delegate didReloadMyPostListFailed:self type:NULL errorCode:!response.code message:response.msg];
             }
         }
         else{
             NSArray *array = [response.data valueForKey:@"list"];
             if (!array.count) {
                 [self.allPostList removeAllObjects];
                 NSDictionary *dic=[[LocalStroge sharedInstance] getObjectAtKey:F_USER_INFORMATION filePath:NSDocumentDirectory];
                 NSInteger customerID = [[dic objectForKey:@"customer_id"]integerValue];
                 NSString *myFile = [NSString stringWithFormat:@"%@_%li",C_FILE_POSTS_My, (long)customerID];
                 [self archivePosts:self.allPostList key:myFile];
                 if (delegate && [delegate respondsToSelector:@selector(didReloadMyPostListFinished:type:updateCount:)]) {
                     [delegate didReloadMyPostListFinished:self type:NULL updateCount:0];
                 }
                 return ;
             }
             [self handleReloadMyPostWithPosts:array delegate:delegate];
         }
     }];
    
}

//重新加载帖子并存储
- (void)handleReloadMyPostWithPosts:(NSArray *)posts delegate:(id<PostServerDelegate>)delegate
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
        //保存数据到本地
        [allPostList removeAllObjects];
        [allPostList addObjectsFromArray:array];
        allPage = 1;
        [S_USER_DEFAULTS setInteger:allPage forKey:UDK_ALL_MYPOST_LIST_PAGE];//归档帖子列表页数
        [S_USER_DEFAULTS synchronize];
        NSInteger customerID = 0;//根据登录用户的ID存储文件
        NSDictionary *dic=[[LocalStroge sharedInstance] getObjectAtKey:F_USER_INFORMATION filePath:NSDocumentDirectory];
        customerID = [[dic objectForKey:@"customer_id"]integerValue];
        NSString *myFile = [NSString stringWithFormat:@"%@_%li",C_FILE_POSTS_My, (long)customerID];
        
        [self archivePosts:allPostList key:myFile];//归档所有的帖子
    }
    if (delegate && [delegate respondsToSelector:@selector(didReloadMyPostListFinished:type:updateCount:)]) {
        [delegate didReloadMyPostListFinished:self type:NULL updateCount:updateCount];
    }
}
/*
 * 6
 * @brief 加载下一页帖子
 */
- (void)loadNextPostListWithType:(Post *)post delegate:(id<PostServerDelegate>)delegate{
    allPage++;
    [[JRRequestManager shareInstance]
     startRequestWithCmd:API_CMD_ALLPOST_LIST
     method:JRRequestMethodPOST
     params:@{@"page":@(allPage),
              @"count":@(C_API_LIST_NUM),
              @"customer_id":@(post.customerID)//发帖人ID
              }
     key:API_CMD_ALLPOST_LIST
     failed:^(JRRequest *request,NSError *error){
         NSInteger code = error.code;
         NSString *msg = [ErrorHelper messageWithCode:!code];
         if (delegate && [delegate respondsToSelector:@selector(didLoadNextMyPostListFailed:type:errorCode:message:)]) {
             [delegate didLoadNextMyPostListFailed:self type:NULL errorCode:code message:msg];
         }
     }
     finished:^(JRRequest *request,JRResponse *response){
         if (!response.code) {
             if (delegate && [delegate respondsToSelector:@selector(didLoadNextMyPostListFailed:type:errorCode:message:)]) {
                 [delegate didLoadNextMyPostListFailed:self type:NULL errorCode:!response.code message:response.msg];
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
                 [S_USER_DEFAULTS setInteger:allPage forKey:UDK_ALL_MYPOST_LIST_PAGE];
                 [S_USER_DEFAULTS synchronize];
                 NSInteger customerID = 0;//根据登录用户的ID存储文件
                 NSDictionary *dic=[[LocalStroge sharedInstance] getObjectAtKey:F_USER_INFORMATION filePath:NSDocumentDirectory];
                 customerID = [[dic objectForKey:@"customer_id"]integerValue];
                 NSString *myFile = [NSString stringWithFormat:@"%@_%li",C_FILE_POSTS_My, (long)customerID];
                 
                 [self archivePosts:allPostList key:myFile];
             }
             //看帖子是否都添加正确
             BOOL isLoadAll = array.count >= count;
             if (delegate && [delegate respondsToSelector:@selector(didLoadNextMyPostListFinished:type:isLoadAll:)]) {
                 [delegate didLoadNextMyPostListFinished:self type:NULL isLoadAll:isLoadAll];
             }
         }
     }];
}


/*
 * 8
 * @brief 删除帖子,提交到服务器后保存本地
 */
- (void)deletePost:(Post *)post
            failed:(void(^)(NSInteger code,NSString *msg))failed
          finished:(void(^)(JRRequest *request,JRResponse *response))finished
{
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    if (post.subID) {
        [params setObject:@(post.subID) forKey:@"sub_id"];//帖子id
        [params setObject:@(post.modID) forKey:@"mod_id"];//版块id
        [params setObject:@(post.customerID) forKey:@"customer_id"];//发帖人
    }
    [[JRRequestManager shareInstance]
     startRequestWithCmd:API_CMD_POST_DELETE
     method:JRRequestMethodPOST
     params:params
     key:API_CMD_POST_DELETE
     failed:^(JRRequest *request,NSError *error){
         NSInteger code = error.code;
         NSString *msg = [ErrorHelper messageWithCode:!code];
         failed(code,msg);//失败返回
     }
     finished:^(JRRequest *request,JRResponse *response){
         if (!response.code) {
             finished(request,response);//返回
         }
         else{
             [self deletePost:post];
             finished(request,response);//返回
         }
     }];
}

//删除帖子
- (void)deletePost:(Post *)post
{
    if ([self.allPostList containsObject:post]) {
        [self.allPostList removeObject:post];
        [[AllPostServer sharedInstance]deletePost:post];
        NSDictionary *dic=[[LocalStroge sharedInstance] getObjectAtKey:F_USER_INFORMATION filePath:NSDocumentDirectory];
        NSInteger customerID = [[dic objectForKey:@"customer_id"]integerValue];

        NSString *myFile = [NSString stringWithFormat:@"%@_%li",C_FILE_POSTS_My, (long)customerID];
        
        [self archivePosts:self.allPostList key:myFile];
    }
}
@end
