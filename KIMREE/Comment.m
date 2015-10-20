//
//  Comment.m
//  ECIGARFAN
//
//  Created by JIRUI on 14-4-16.
//  Copyright (c) 2014年 ___FULLUSERNAME___. All rights reserved.
//

#import "Comment.h"
@implementation Comment

- (void)loadData:(NSDictionary *)dict
{
    self.modID = [[dict objectForKey:@"mod_id"] integerValue];
    self.replyID = [[dict objectForKey:@"rep_id"] integerValue];
    self.subID = [[dict objectForKey:@"sub_id"]integerValue];
    self.customerID = [[dict objectForKey:@"customer_id"]integerValue];
    self.repRepID = [[dict objectForKey:@"rep_rep_id"]integerValue];
    self.content = [dict objectForKey:@"rep_content"];
    self.customerImage = [dict objectForKey:@"customer_head"];
    //把十六进制转成正常文字
    self.content = [NSString stringFromHexString:self.content];
    self.replyTime = [dict objectForKey:@"rep_tm"];
    self.customerName = [dict objectForKey:@"customer_name"];
    self.moreRepCount = [[dict objectForKey:@"more_rep"] integerValue];
    //新增加的被回复人数据
    self.repCustomerID = [[dict objectForKey:@"rep_customer_id"]integerValue];
	self.repCustomerName = [dict objectForKey:@"rep_customer_name"];
    
}
@end
