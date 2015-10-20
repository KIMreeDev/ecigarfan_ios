//
//  Post.m
//  ECIGARFAN
//
//  Created by JIRUI on 14-4-28.
//  Copyright (c) 2014年 ___FULLUSERNAME___. All rights reserved.
//

#import "Post.h"
@implementation Post
@synthesize subID,subTitle,customerID,lastID,modID,subContent,replyCount,beginTime,lastTime,subImage,customerImage,customer;
//载入帖子
- (void)loadData:(NSDictionary *)dict{
    self.subID = [[dict valueForKey:@"sub_id"]integerValue];
    self.subTitle = [dict valueForKey:@"sub_title"];
    self.customerID = [[dict valueForKey:@"customer_id"]integerValue];
    self.lastID = [[dict valueForKey:@"last_id"]integerValue];
    self.modID = [[dict valueForKey:@"mod_id"]integerValue];
    self.subContent = [dict valueForKey:@"sub_content"];
    if (self.subContent) {
        self.subContent = [NSString stringFromHexString:self.subContent];//把十六进制转成正常文字
    }
    self.replyCount = [[dict valueForKey:@"reply_count"]integerValue];
    self.beginTime = [dict valueForKey:@"begin_tm"];
    self.lastTime = [dict valueForKey:@"last_tm"];
    self.subImage = [dict valueForKey:@"image_url"];
    self.imageSmall = [dict valueForKey:@"image_small"];
    self.customerImage = [dict valueForKey:@"customer_head"];
    self.customer = [dict valueForKey:@"customer_name"];
}
@end