//
//  NewsModel.m
//  RFKeyboardToolbarDemo
//
//  Created by JIRUI on 14-5-16.
//  Copyright (c) 2014年 Rex Finn. All rights reserved.
//

#import "NewsModel.h"

@implementation NewsModel
- (void)loadData:(NSDictionary *)dict
{
    //
    self.newsID = [[dict objectForKey:@"news_id"] integerValue];
    self.modID = [[dict objectForKey:@"mod_id"] integerValue];
    self.subID = [[dict objectForKey:@"sub_id"]integerValue];
    self.customerID = [[dict objectForKey:@"customer_id"]integerValue];
    self.replyId = [[dict objectForKey:@"rep_id"]integerValue];
    self.replyManImage = [dict objectForKey:@"customer_head"];//回复人的头像
    self.replyMan = [dict objectForKey:@"reply_customer_name"];//追评人的名称
    self.myReply = [dict objectForKey:@"customer_reply"];//我对帖子的评论，或我的追评
    //所有评论数
    self.subTitle = [dict objectForKey:@"sub_title"];
    self.reply = [dict objectForKey:@"rep_content"];//回复我的内容
    self.replyTime = [dict objectForKey:@"rep_tm"];
    self.contentImage = [dict objectForKey:@"image_url"];
    //赋值名称
    self.myName = [dict objectForKey:@"customer_name"];
}

@end
