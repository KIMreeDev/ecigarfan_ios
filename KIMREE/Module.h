//
//  Module.h
//  ECIGARFAN
//
//  Created by JIRUI on 14-6-17.
//  Copyright (c) 2014年 JIRUI. All rights reserved.
//

#import "JRModel.h"
#import <Foundation/Foundation.h>

@interface Module : JRModel
@property (nonatomic, assign) NSInteger modID;              //帖子id
@property (nonatomic, strong) NSString *modTitle;            //回复内容
@property (nonatomic, assign) NSInteger postCount;            //回复id值，楼层
@property (nonatomic, strong) NSString *modContent;          //回复时间
@property (nonatomic, strong) NSString *modImage;       //评论人的用户兼昵称
- (void)loadData:(NSDictionary *)dict;
@end
