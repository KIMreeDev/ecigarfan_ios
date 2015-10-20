//
//  Post.h
//  ECIGARFAN
//
//  Created by JIRUI on 14-4-28.
//  Copyright (c) 2014年 ___FULLUSERNAME___. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JRModel.h"
#import "Post.h"
/**
 * @brief 帖子
 */
@interface Post : JRModel
@property (nonatomic,assign) NSInteger subID;                    //帖子ID
@property (nonatomic,strong) NSString *subTitle;                 //标题名
@property (nonatomic,assign) NSInteger customerID;               //发帖人ID
@property (nonatomic,assign) NSInteger lastID;                   //最后回复人ID
@property (nonatomic,assign) NSInteger modID;                    //所属模块
@property (nonatomic,strong) NSString *subContent;               //帖子内容
@property (nonatomic,assign) NSInteger replyCount;               //评论数量
@property (nonatomic,strong) NSString *beginTime;                //发布时间
@property (nonatomic,strong) NSString *lastTime;                 //最后回复时间
@property (nonatomic,strong) NSString *subImage;                 //帖子图片地址
@property (nonatomic,strong) NSString *imageSmall;               //压缩后的帖子图片
@property (nonatomic,strong) NSString *customerImage;            //发帖人头像地址
@property (nonatomic,strong) NSString *customer;                 //发帖人

@end
