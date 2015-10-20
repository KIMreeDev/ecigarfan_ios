//
//  AllPostServer.m
//  ECIGARFAN
//
//  Created by JIRUI on 14-5-28.
//  Copyright (c) 2014年 JIRUI. All rights reserved.
//

#import "AllPostServer.h"
#import "ErrorHelper.h"
#import "ArchiveServer.h"
#define UDK_ALL_POST_MOD0_LIST_PAGE @"udk.all.post.mod0.list.page"
#define UDK_ALL_POST_MOD1_LIST_PAGE @"udk.all.post.mod1.list.page"
#define UDK_ALL_POST_MOD2_LIST_PAGE @"udk.all.post.mod2.list.page"
#define UDK_ALL_POST_MOD3_LIST_PAGE @"udk.all.post.mod3.list.page"
static AllPostServer *instance;

@interface AllPostServer (){
    NSInteger allPage_mod0;//版块1
    NSInteger allPage_mod1;//版块2
    NSInteger allPage_mod2;
    NSInteger allPage_mod3;
}
@end

@implementation AllPostServer
@synthesize allPostListMod1,allPostListMod2,allPostListMod3,allPostListMod4;

/*
 创建
 */
- (id)init
{
    self = [super init];
    if (self) {
        allPostListMod1 = [[NSMutableArray alloc]init];
        allPostListMod2 = [[NSMutableArray alloc]init];
        allPostListMod3 = [[NSMutableArray alloc]init];
        allPostListMod4 = [[NSMutableArray alloc]init];
        
        allPage_mod0 = [S_USER_DEFAULTS integerForKey:UDK_ALL_POST_MOD0_LIST_PAGE];
        allPage_mod1 = [S_USER_DEFAULTS integerForKey:UDK_ALL_POST_MOD1_LIST_PAGE];
        allPage_mod2 = [S_USER_DEFAULTS integerForKey:UDK_ALL_POST_MOD2_LIST_PAGE];
        allPage_mod3 = [S_USER_DEFAULTS integerForKey:UDK_ALL_POST_MOD3_LIST_PAGE];
    }
    return self;
}
/*
 * @brief 初始化
 */
+ (AllPostServer *)sharedInstance
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[AllPostServer alloc] init];
    });
    return instance;
}

- (void)archivePosts:(NSArray *)posts key:(NSString *)key
{
    dispatch_async(dispatch_get_global_queue(0, 0), ^(void){
        [[ArchiveServer defaultArchiver] archiveObject:posts key:key];
    });
}

/*
 * 4
 * @brief 筛选本地帖子
 */
- (void)loadCachePostListWithType:(NSInteger)type delegate:(id<AllPostServerDelegate>)delegate
{
    NSInteger count = 0;
    if (1 == type) {
        NSArray *array = [[ArchiveServer defaultArchiver] unarchiveWithKey:C_FILE_POSTS_MOD0];
        if (array.count) {
            [allPostListMod1 removeAllObjects];
            [allPostListMod1 addObjectsFromArray:array];
        }
        count = allPostListMod1.count;
    }
    else if (2 == type) {
        NSArray *array = [[ArchiveServer defaultArchiver] unarchiveWithKey:C_FILE_POSTS_MOD1];
        if (array.count) {
            [allPostListMod2 removeAllObjects];
            [allPostListMod2 addObjectsFromArray:array];
        }
        count = allPostListMod2.count;
    }
    else if (3 == type) {
        NSArray *array = [[ArchiveServer defaultArchiver] unarchiveWithKey:C_FILE_POSTS_MOD2];
        if (array.count) {
            [allPostListMod3 removeAllObjects];
            [allPostListMod3 addObjectsFromArray:array];
        }
        count = allPostListMod3.count;
    }
    else if (4 == type) {
        NSArray *array = [[ArchiveServer defaultArchiver] unarchiveWithKey:C_FILE_POSTS_MOD3];
        if (array.count) {
            [allPostListMod4 removeAllObjects];
            [allPostListMod4 addObjectsFromArray:array];
        }
        count = allPostListMod4.count;
    }
    if (delegate && [delegate respondsToSelector:@selector(didLoadCachePostListFinished:type:count:)]) {
        [delegate didLoadCachePostListFinished:self type:type count:count];//回掉已加载本地完成
    }
}
/*
 *5
 *重新请求帖子（刷新）
 */
- (void)reloadAllPostListWithType:(NSInteger)type delegate:(id<AllPostServerDelegate>)delegate{
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params setObject:@"1" forKey:@"page"];
    [params setObject:@(C_API_LIST_NUM) forKey:@"count"];
    [params setObject:@(type) forKey:@"mod_id"];//版块
    [[JRRequestManager shareInstance]
     startRequestWithCmd:API_CMD_ALLPOST_LIST
     method:JRRequestMethodPOST
     params:params
     key:API_CMD_ALLPOST_LIST
     failed:^(JRRequest *request,NSError *error){
         NSInteger code = error.code;
         NSString *msg = [ErrorHelper messageWithCode:!code];
         if (delegate && [delegate respondsToSelector:@selector(didReloadAllPostListFailed:type:errorCode:message:)]) {
             [delegate didReloadAllPostListFailed:self type:type errorCode:code message:msg];
         }
     }
     finished:^(JRRequest *request,JRResponse *response){
         if (!response.code) {
             if (delegate && [delegate respondsToSelector:@selector(didReloadAllPostListFailed:type:errorCode:message:)]) {
                 [delegate didReloadAllPostListFailed:self type:type errorCode:!response.code message:response.msg];
             }
         }
         else{
             NSArray *array = [response.data valueForKey:@"list"];
            if (1 == type) {
                 [self handleReloadAllPostMod0WithPosts:array delegate:delegate];
             }
             if (2 == type) {
                 [self handleReloadAllPostMod1WithPosts:array delegate:delegate];
             }
             if (3 == type) {
                 [self handleReloadAllPostMod2WithPosts:array delegate:delegate];
             }
             if (4 == type) {
                 [self handleReloadAllPostMod3WithPosts:array delegate:delegate];
             }
         }
     }];
    
}

//重新加载版块0的所有帖子并存储
- (void)handleReloadAllPostMod0WithPosts:(NSArray *)posts delegate:(id<AllPostServerDelegate>)delegate
{
    NSInteger updateCount = 0;
    NSMutableArray *array = [[NSMutableArray alloc] init];
    if (posts.count > 0) {
        for (NSDictionary *dict in posts) {
            Post *post = [[Post alloc] init];
            [post loadData:dict];
            [array addObject:post];
//            if (![allPostListMod1 containsObject:post]) {
//                updateCount++;//更新帖子数量
//            }
        }
    }
        //保存数据到本地
        [allPostListMod1 removeAllObjects];
        [allPostListMod1 addObjectsFromArray:array];
        allPage_mod1 = 1;
        [S_USER_DEFAULTS setInteger:allPage_mod0 forKey:UDK_ALL_POST_MOD0_LIST_PAGE];//归档帖子列表页数
        [S_USER_DEFAULTS synchronize];
        [self archivePosts:allPostListMod1 key:C_FILE_POSTS_MOD0];//归档所有的帖子

    if (delegate && [delegate respondsToSelector:@selector(didReloadAllPostListFinished:type:updateCount:)]) {
        [delegate didReloadAllPostListFinished:self type:1 updateCount:updateCount];
    }
}
//重新加载版块1的所有帖子并存储
- (void)handleReloadAllPostMod1WithPosts:(NSArray *)posts delegate:(id<AllPostServerDelegate>)delegate
{
    NSInteger updateCount = 0;
    NSMutableArray *array = [[NSMutableArray alloc] init];
    if (posts.count > 0) {
        for (NSDictionary *dict in posts) {
            Post *post = [[Post alloc] init];
            [post loadData:dict];
            [array addObject:post];
//            if (![allPostListMod2 containsObject:post]) {
//                updateCount++;//更新帖子数量
//            }
        }
    }
        //保存数据到本地
        [allPostListMod2 removeAllObjects];
        [allPostListMod2 addObjectsFromArray:array];
        allPage_mod2 = 1;
        [S_USER_DEFAULTS setInteger:allPage_mod1 forKey:UDK_ALL_POST_MOD1_LIST_PAGE];//归档帖子列表页数
        [S_USER_DEFAULTS synchronize];
        [self archivePosts:allPostListMod2 key:C_FILE_POSTS_MOD1];//归档所有的帖子

    if (delegate && [delegate respondsToSelector:@selector(didReloadAllPostListFinished:type:updateCount:)]) {
        [delegate didReloadAllPostListFinished:self type:2 updateCount:updateCount];
    }
}
//重新加载版块2的所有帖子并存储
- (void)handleReloadAllPostMod2WithPosts:(NSArray *)posts delegate:(id<AllPostServerDelegate>)delegate
{
    NSInteger updateCount = 0;
    NSMutableArray *array = [[NSMutableArray alloc] init];
    if (posts.count > 0) {
        for (NSDictionary *dict in posts) {
            Post *post = [[Post alloc] init];
            [post loadData:dict];
            [array addObject:post];
//            if (![allPostListMod3 containsObject:post]) {
//                updateCount++;//更新帖子数量
//            }
        }
    }
        //保存数据到本地
        [allPostListMod3 removeAllObjects];
        [allPostListMod3 addObjectsFromArray:array];
        allPage_mod3 = 1;
        [S_USER_DEFAULTS setInteger:allPage_mod2 forKey:UDK_ALL_POST_MOD2_LIST_PAGE];//归档帖子列表页数
        [S_USER_DEFAULTS synchronize];
        [self archivePosts:allPostListMod3 key:C_FILE_POSTS_MOD2];//归档所有的帖子

    if (delegate && [delegate respondsToSelector:@selector(didReloadAllPostListFinished:type:updateCount:)]) {
        [delegate didReloadAllPostListFinished:self type:3 updateCount:updateCount];
    }
}
//重新加载版块3的所有帖子并存储
- (void)handleReloadAllPostMod3WithPosts:(NSArray *)posts delegate:(id<AllPostServerDelegate>)delegate
{
    NSInteger updateCount = 0;
    NSMutableArray *array = [[NSMutableArray alloc] init];
    if (posts.count > 0) {
        for (NSDictionary *dict in posts) {
            Post *post = [[Post alloc] init];
            [post loadData:dict];
            [array addObject:post];
//            if (![allPostListMod4 containsObject:post]) {
//                updateCount++;//更新帖子数量
//            }
        }
    }
        //保存数据到本地
        [allPostListMod4 removeAllObjects];
        [allPostListMod4 addObjectsFromArray:array];
        allPage_mod1 = 1;
        [S_USER_DEFAULTS setInteger:allPage_mod3 forKey:UDK_ALL_POST_MOD3_LIST_PAGE];//归档帖子列表页数
        [S_USER_DEFAULTS synchronize];
        [self archivePosts:allPostListMod4 key:C_FILE_POSTS_MOD3];//归档所有的帖子

    if (delegate && [delegate respondsToSelector:@selector(didReloadAllPostListFinished:type:updateCount:)]) {
        [delegate didReloadAllPostListFinished:self type:4 updateCount:updateCount];
    }
}
/*
 * 7
 * @brief 加载下一页运单
 */
- (void)loadNextPostListWithType:(NSInteger)type delegate:(id<AllPostServerDelegate>)delegate
{
    if (1 == type) {
        [self loadNextAllPostMod0ListWithDelegate:delegate];
    }
    else if (2 == type){
        [self loadNextAllPostMod1ListWithDelegate:delegate];
    }
    else if (3 == type){
        [self loadNextAllPostMod2ListWithDelegate:delegate];
    }
    else if (4 == type){
        [self loadNextAllPostMod3ListWithDelegate:delegate];
    }
}
//加载0版块的下一页
- (void)loadNextAllPostMod0ListWithDelegate:(id<AllPostServerDelegate>)delegate
{
    allPage_mod0++;
    [[JRRequestManager shareInstance]
     startRequestWithCmd:API_CMD_ALLPOST_LIST
     method:JRRequestMethodPOST
     params:@{@"page":@(allPage_mod0),
              @"count":@(C_API_LIST_NUM),
              @"mod_id":@(1)//版块
              }
     key:API_CMD_ALLPOST_LIST
     failed:^(JRRequest *request,NSError *error){
         NSInteger code = error.code;
         NSString *msg = [ErrorHelper messageWithCode:code];
         if (delegate && [delegate respondsToSelector:@selector(didLoadNextAllPostListFailed:type:errorCode:message:)]) {
             [delegate didLoadNextAllPostListFailed:self type:1 errorCode:code message:msg];
         }
     }
     finished:^(JRRequest *request,JRResponse *response){
         if (!response.code) {
             if (delegate && [delegate respondsToSelector:@selector(didLoadNextAllPostListFailed:type:errorCode:message:)]) {
                 [delegate didLoadNextAllPostListFailed:self type:1 errorCode:!response.code message:response.msg];
             }
         }
         else{
             NSArray *array = [response.data valueForKey:@"list"];
             NSMutableArray *posts = [[NSMutableArray alloc] init];
             if (array.count > 0) {
                 for (NSDictionary *dict in array) {
                     Post *post = [[Post alloc] init];
                     [post loadData:dict];
                     [posts addObject:post];
                 }
                 //保存数据
                 [allPostListMod1 removeAllObjects];
                 [allPostListMod1 addObjectsFromArray:posts];
                 [S_USER_DEFAULTS setInteger:allPage_mod0 forKey:UDK_ALL_POST_MOD0_LIST_PAGE];
                 [S_USER_DEFAULTS synchronize];
                 [self archivePosts:allPostListMod1 key:C_FILE_POSTS_MOD0];
             }
             //看帖子是否都添加正确
             if (delegate && [delegate respondsToSelector:@selector(didLoadNextAllPostListFinished:type:isLoadAll:)]) {
                 [delegate didLoadNextAllPostListFinished:self type:1 isLoadAll:YES];
             }
         }
     }];
}
//加载2版块的下一页
- (void)loadNextAllPostMod1ListWithDelegate:(id<AllPostServerDelegate>)delegate
{
    allPage_mod1++;
    [[JRRequestManager shareInstance]
     startRequestWithCmd:API_CMD_ALLPOST_LIST
     method:JRRequestMethodPOST
     params:@{@"page":@(allPage_mod1),
              @"count":@(C_API_LIST_NUM),
              @"mod_id":@(2)//版块
              }
     key:API_CMD_ALLPOST_LIST
     failed:^(JRRequest *request,NSError *error){
         NSInteger code = error.code;
         NSString *msg = [ErrorHelper messageWithCode:code];
         if (delegate && [delegate respondsToSelector:@selector(didLoadNextAllPostListFailed:type:errorCode:message:)]) {
             [delegate didLoadNextAllPostListFailed:self type:2 errorCode:code message:msg];
         }
     }
     finished:^(JRRequest *request,JRResponse *response){
         if (!response.code) {
             if (delegate && [delegate respondsToSelector:@selector(didLoadNextAllPostListFailed:type:errorCode:message:)]) {
                 [delegate didLoadNextAllPostListFailed:self type:2 errorCode:!response.code message:response.msg];
             }
         }
         else{
             NSArray *array = [response.data valueForKey:@"list"];
             NSMutableArray *posts = [[NSMutableArray alloc] init];
             if (array.count > 0) {
                 for (NSDictionary *dict in array) {
                     Post *post = [[Post alloc] init];
                     [post loadData:dict];
                     [posts addObject:post];
                 }
                 //保存数据
                 [allPostListMod2 removeAllObjects];
                 [allPostListMod2 addObjectsFromArray:posts];
                 [S_USER_DEFAULTS setInteger:allPage_mod1 forKey:UDK_ALL_POST_MOD1_LIST_PAGE];
                 [S_USER_DEFAULTS synchronize];
                 [self archivePosts:allPostListMod2 key:C_FILE_POSTS_MOD1];
             }
             //看帖子是否都添加正确
             if (delegate && [delegate respondsToSelector:@selector(didLoadNextAllPostListFinished:type:isLoadAll:)]) {
                 [delegate didLoadNextAllPostListFinished:self type:2 isLoadAll:YES];
             }
         }
     }];
}
//加载3版块的下一页
- (void)loadNextAllPostMod2ListWithDelegate:(id<AllPostServerDelegate>)delegate
{
    allPage_mod2++;
    [[JRRequestManager shareInstance]
     startRequestWithCmd:API_CMD_ALLPOST_LIST
     method:JRRequestMethodPOST
     params:@{@"page":@(allPage_mod3),
              @"count":@(C_API_LIST_NUM),
              @"mod_id":@(3)//版块
              }
     key:API_CMD_ALLPOST_LIST
     failed:^(JRRequest *request,NSError *error){
         NSInteger code = error.code;
         NSString *msg = [ErrorHelper messageWithCode:code];
         if (delegate && [delegate respondsToSelector:@selector(didLoadNextAllPostListFailed:type:errorCode:message:)]) {
             [delegate didLoadNextAllPostListFailed:self type:3 errorCode:code message:msg];
         }
     }
     finished:^(JRRequest *request,JRResponse *response){
         if (!response.code) {
             if (delegate && [delegate respondsToSelector:@selector(didLoadNextAllPostListFailed:type:errorCode:message:)]) {
                 [delegate didLoadNextAllPostListFailed:self type:3 errorCode:!response.code message:response.msg];
             }
         }
         else{
             NSArray *array = [response.data valueForKey:@"list"];
             NSMutableArray *posts = [[NSMutableArray alloc] init];
             if (array.count > 0) {
                 for (NSDictionary *dict in array) {
                     Post *post = [[Post alloc] init];
                     [post loadData:dict];
                     [posts addObject:post];
                 }
                 //保存数据
                 [allPostListMod3 removeAllObjects];
                 [allPostListMod3 addObjectsFromArray:posts];
                 [S_USER_DEFAULTS setInteger:allPage_mod2 forKey:UDK_ALL_POST_MOD2_LIST_PAGE];
                 [S_USER_DEFAULTS synchronize];
                 [self archivePosts:allPostListMod3 key:C_FILE_POSTS_MOD2];
             }
             //看帖子是否都添加正确
             if (delegate && [delegate respondsToSelector:@selector(didLoadNextAllPostListFinished:type:isLoadAll:)]) {
                 [delegate didLoadNextAllPostListFinished:self type:3 isLoadAll:YES];
             }
         }
     }];
}
//加载4版块的下一页
- (void)loadNextAllPostMod3ListWithDelegate:(id<AllPostServerDelegate>)delegate
{
    allPage_mod3++;
    [[JRRequestManager shareInstance]
     startRequestWithCmd:API_CMD_ALLPOST_LIST
     method:JRRequestMethodPOST
     params:@{@"page":@(allPage_mod3),
              @"count":@(C_API_LIST_NUM),
              @"mod_id":@(4)//版块
              }
     key:API_CMD_ALLPOST_LIST
     failed:^(JRRequest *request,NSError *error){
         NSInteger code = error.code;
         NSString *msg = [ErrorHelper messageWithCode:code];
         if (delegate && [delegate respondsToSelector:@selector(didLoadNextAllPostListFailed:type:errorCode:message:)]) {
             [delegate didLoadNextAllPostListFailed:self type:4 errorCode:code message:msg];
         }
     }
     finished:^(JRRequest *request,JRResponse *response){
         if (!response.code) {
             if (delegate && [delegate respondsToSelector:@selector(didLoadNextAllPostListFailed:type:errorCode:message:)]) {
                 [delegate didLoadNextAllPostListFailed:self type:4 errorCode:!response.code message:response.msg];
             }
         }
         else{
             NSArray *array = [response.data valueForKey:@"list"];
             NSMutableArray *posts = [[NSMutableArray alloc] init];
             if (array.count > 0) {
                 for (NSDictionary *dict in array) {
                     Post *post = [[Post alloc] init];
                     [post loadData:dict];
                     [posts addObject:post];
                 }
                 //保存数据
                 [allPostListMod4 removeAllObjects];
                 [allPostListMod4 addObjectsFromArray:posts];
                 [S_USER_DEFAULTS setInteger:allPage_mod3 forKey:UDK_ALL_POST_MOD3_LIST_PAGE];
                 [S_USER_DEFAULTS synchronize];
                 [self archivePosts:allPostListMod4 key:C_FILE_POSTS_MOD3];
             }
             //看帖子是否都添加正确
             if (delegate && [delegate respondsToSelector:@selector(didLoadNextAllPostListFinished:type:isLoadAll:)]) {
                 [delegate didLoadNextAllPostListFinished:self type:4 isLoadAll:YES];
             }
         }
     }];
}
/*
 * 7
 * @brief 添加帖子,发送给服务器后保存本地
 */
- (void)addPost:(Post *)post
         failed:(void(^)(NSInteger code,NSString *msg))failed
       finished:(void(^)(JRRequest *request,JRResponse *response))finished
{
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    
    if (post.subTitle) {
        [params setObject:post.subTitle forKey:@"sub_title"];
    }
    if (post.subContent) {
        [params setObject:post.subContent forKey:@"sub_content"];
    }
    if (post.modID) {
        [params setObject:@(post.modID) forKey:@"mod_id"];//板块id
    }
    if (post.customerID) {
        [params setObject:@(post.customerID) forKey:@"customer_id"];//发帖人的id
    }
    [params setObject:post.beginTime forKey:@"begin_tm"];
    
    [[JRRequestManager shareInstance]
     startRequestWithCmd:API_CMD_POST_CREATE
     method:JRRequestMethodPOST
     params:params
     key:API_CMD_POST_CREATE
     failed:^(JRRequest *request,NSError *error){
         NSInteger code = error.code;
         NSString *msg = [ErrorHelper messageWithCode:code];
         failed(code,msg);//添加失败返回
     }
     finished:^(JRRequest *request,JRResponse *response){
         if (!response.code) {
             finished(request,response);//添加失败返回
         }
         else{
             post.subID = [[response.data valueForKey:@"sub_id"] intValue];
             //插入新创建的帖子
//             [self insertPost:post];
             finished(request,response);//返回
        }
     }];
}

//添加帖子到本地
- (void)insertPost:(Post *)post
{
    if (1 == post.modID) {
        [allPostListMod1 insertObject:post atIndex:0];
        [self archivePosts:allPostListMod1 key:C_FILE_POSTS_MOD0];
    }
    if (2 == post.modID) {
        [allPostListMod2 insertObject:post atIndex:0];
        [self archivePosts:allPostListMod2 key:C_FILE_POSTS_MOD1];
    }
    if (3 == post.modID) {
        [allPostListMod3 insertObject:post atIndex:0];
        [self archivePosts:allPostListMod3 key:C_FILE_POSTS_MOD2];
    }
    if (4 == post.modID) {
        [allPostListMod4 insertObject:post atIndex:0];
        [self archivePosts:allPostListMod4 key:C_FILE_POSTS_MOD3];
    }
    
}
//删除帖子
- (void)deletePost:(Post *)post
{
    if ([self.allPostListMod1 containsObject:post]) {
        [self.allPostListMod1 removeObject:post];
        [self archivePosts:self.allPostListMod1 key:C_FILE_POSTS_MOD0];
    }
    else if ([self.allPostListMod2 containsObject:post]) {
        [self.allPostListMod2 removeObject:post];
        [self archivePosts:self.allPostListMod2 key:C_FILE_POSTS_MOD1];
    }
    else if ([self.allPostListMod3 containsObject:post]) {
        [self.allPostListMod3 removeObject:post];
        [self archivePosts:self.allPostListMod3 key:C_FILE_POSTS_MOD2];
    }
    else if ([self.allPostListMod4 containsObject:post]) {
        [self.allPostListMod4 removeObject:post];
        [self archivePosts:self.allPostListMod4 key:C_FILE_POSTS_MOD3];
    }
}

@end
