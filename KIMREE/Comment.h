//
//  Comment.h
//  ECIGARFAN
//
//  Created by JIRUI on 14-4-16.
//  Copyright (c) 2014年 ___FULLUSERNAME___. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JRModel.h"
/**
 * @brief 评论
 */
@interface Comment : JRModel
@property (nonatomic, assign) NSInteger modID;              //版块id
@property (nonatomic, assign) NSInteger subID;              //帖子id
@property (nonatomic, assign) NSInteger customerID;         //评论人
@property (nonatomic, strong) NSString *content;            //回复内容
@property (nonatomic, assign) NSInteger replyID;            //回复id值，楼层
@property (nonatomic, assign) NSInteger repRepID;           //追评
@property (nonatomic, strong) NSString *replyTime;          //回复时间
@property (nonatomic, strong) NSString *customerImage;      //用户照片
@property (nonatomic, strong) NSString *customerName;       //评论人的用户兼昵称
@property (nonatomic, assign) NSInteger moreRepCount;       //更多的回复数量
@property (nonatomic, assign) NSInteger repCustomerID;      //被回复人的ID
@property (nonatomic, strong) NSString *repCustomerName;    //被回复人的名称
- (void)loadData:(NSDictionary *)dict;

@end
