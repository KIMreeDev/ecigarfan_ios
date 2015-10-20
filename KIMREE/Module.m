//
//  Module.m
//  ECIGARFAN
//
//  Created by JIRUI on 14-6-17.
//  Copyright (c) 2014年 JIRUI. All rights reserved.
///Users/jirui/Desktop/kimree_cigarette/ECIGARFAN/en.lproj/InfoPlist.strings

#import "Module.h"

@implementation Module

- (void)loadData:(NSDictionary *)dict{
    NSString *language = [SystemHelper currentLanguage];//获取当前系统语言
    self.modID = [[dict valueForKey:@"mod_id"]integerValue]; //版块ID
    self.modTitle = [dict valueForKey:@"mod_title"];	       //版块主题
    self.modContent = [dict valueForKey:@"mod_content"];    //版块内容
    if ([language isEqualToString:@"en"]) {
        self.modTitle = [dict valueForKey:@"mod_title_en"];//为英文
        self.modContent = [dict valueForKey:@"mod_content_en"];
    }
    self.postCount = [[dict valueForKey:@"post_count"] integerValue]; //版块帖子数
    self.modImage = [dict valueForKey:@"mod_image"];			//版块图片
}
@end
