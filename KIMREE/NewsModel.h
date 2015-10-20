//
//  NewsModel.h
//  RFKeyboardToolbarDemo
//
//  Created by JIRUI on 14-5-16.
//  Copyright (c) 2014年 Rex Finn. All rights reserved.
//

#import "JRModel.h"
#import <Foundation/Foundation.h>

@interface NewsModel : JRModel
@property (nonatomic,assign) NSInteger newsID;                   //消息模块
@property (nonatomic,assign) NSInteger modID;                    //所属模块
@property (nonatomic,assign) NSInteger subID;                    //帖子ID
@property (nonatomic,assign) NSInteger customerID;               //回复人ID
@property (nonatomic,strong) NSString *replyManImage;            //回帖人头像地址
@property (nonatomic,strong) NSString *replyMan;                 //回帖人
@property (nonatomic,strong) NSString *reply;                    //回复内容
@property (nonatomic,assign) NSInteger replyId;                  //对帖子的回复的id,相当于楼层
@property (nonatomic,strong) NSString *myName;                   //我的昵称
@property (nonatomic,strong) NSString *subTitle;                 //我的帖子名
@property (nonatomic,strong) NSString *myReply;                  //我的回复
@property (nonatomic,strong) NSString *replyTime;                //回复时间
@property (nonatomic,strong) NSString *contentImage;             //帖子图片地址
- (void)loadData:(NSDictionary *)dict;
@end
