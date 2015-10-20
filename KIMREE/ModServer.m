//
//  ModServer.m
//  ECIGARFAN
//
//  Created by JIRUI on 14-6-17.
//  Copyright (c) 2014年 JIRUI. All rights reserved.
//

#import "ModServer.h"
#import "Module.h"
#import "ArchiveServer.h"
#import "ErrorHelper.h"
#import "SystemHelper.h"
static ModServer *instance;
@interface ModServer (){
    
}
@end

@implementation ModServer
@synthesize modList;

- (id)init
{
    self = [super init];
    if (self) {
        modList = [[NSMutableArray alloc] init];//所有帖子
    }
    return self;
}
/*
 * @brief 初始化
 */
+ (ModServer *)sharedInstance
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[ModServer alloc] init];
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
- (void)loadCacheModListWithType:(NSString *)type delegate:(id<ModServerDelegate>)delegate{
    NSInteger count = 0;
    NSString *myFile = [NSString stringWithFormat:@"%@",C_FILE_MOD_MY];
    
    NSArray *array = [[ArchiveServer defaultArchiver] unarchiveWithKey:myFile];
    if (array.count) {
        [modList removeAllObjects];
        [modList addObjectsFromArray:array];
    }
    count = modList.count;
    if (delegate && [delegate respondsToSelector:@selector(didLoadCacheModListFinished:type:count:)]) {
        [delegate didLoadCacheModListFinished:self type:NULL count:count];//回掉已加载本地完成
    }
}
/*
 *重新请求消息（刷新）
 */
- (void)reloadModListWithType:(NSString *)type delegate:(id<ModServerDelegate>)delegate{
    [[JRRequestManager shareInstance]
     startRequestWithCmd:API_CMD_MOD_LIST
     method:JRRequestMethodPOST
     params:nil
     key:API_CMD_MOD_LIST
     failed:^(JRRequest *request,NSError *error){
         NSInteger code = error.code;
         NSString *msg = [ErrorHelper messageWithCode:!code];
         if (delegate && [delegate respondsToSelector:@selector(didReloadModListFailed:type:errorCode:message:)]) {
             [delegate didReloadModListFailed:self type:NULL errorCode:code message:msg];
         }
     }
     finished:^(JRRequest *request,JRResponse *response){
         if (!response.code) {
             if (delegate && [delegate respondsToSelector:@selector(didReloadModListFailed:type:errorCode:message:)]) {
                 [delegate didReloadModListFailed:self type:NULL errorCode:!response.code message:response.msg];
             }
         }
         else{
             NSArray *array = [response.data valueForKey:@"list"];
             [self handleReloadMod:array delegate:delegate];
         }
     }];
    
}

//重新刷新消息并存储
- (void)handleReloadMod:(NSArray *)mods delegate:(id<ModServerDelegate>)delegate
{
    NSInteger updateCount = 0;
    NSMutableArray *array = [[NSMutableArray alloc]init];
    if (mods.count > 0) {
        for (NSDictionary *dict in mods) {
            Module *model = [[Module alloc] init];
            [model loadData:dict];
            [array addObject:model];
        }
        [modList removeAllObjects];
        [modList addObjectsFromArray:array];

        //保存数据到本地
        NSString *myFile = [NSString stringWithFormat:@"%@",C_FILE_MOD_MY];
        
        [self archiveNews:modList key:myFile];
    }
    if (delegate && [delegate respondsToSelector:@selector(didReloadModListFinished:type:updateCount:)]) {
        [delegate didReloadModListFinished:self type:NULL updateCount:updateCount];
    }
}

@end
