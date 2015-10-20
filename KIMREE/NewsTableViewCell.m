//
//  NewsTableViewCell.m
//  RFKeyboardToolbarDemo
//
//  Created by JIRUI on 14-5-16.
//  Copyright (c) 2014年 Rex Finn. All rights reserved.
//

#import "NewsTableViewCell.h"
#import "NSString+extended.h"
#import "UIImageView+WebCache.h"
@implementation NewsTableViewCell

- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
//回复新信息
- (IBAction)replyNews:(id)sender {
    if ([self.delegate respondsToSelector:@selector(newsReply)]) {
        [self.delegate newsReply];
    }
}
//查看其他人的帖子
- (IBAction)replyManPosts:(id)sender {
    if ([self.delegate respondsToSelector:@selector(postsOfElseMan:)]) {
        [self.delegate postsOfElseMan:self.customerID];
    }
}

- (void)configNewsCellWithNews:(NewsModel *)news{
    CGRect rect = CGRectZero;
    CGFloat y = 48.0;
    if (news.replyManImage) {
        //从网上取得用户的头像
        NSData * data = [NSData dataWithContentsOfURL:[NSURL URLWithString:news.replyManImage]];
        [self.replyManImage setBackgroundImage:[UIImage imageWithData:data] forState:UIControlStateNormal];
    }
    //回复人的昵称
    self.replyManNick.text = news.replyMan;
    self.customerID = news.customerID;//记录customerID
    //回复的内容
    self.replyTime.text = news.replyTime;
    if (news.reply) {
        //获得请求数据中内容的高度
        CGFloat contentHeight = [news.reply boundingRectWithSize:CGSizeMake(257, 0) withTextFont:[UIFont systemFontOfSize:14] withLineSpacing:0].height;
        //取得cell中内容label的大小
        rect = self.replyContent.frame;
        //根据请求内容的大小来改变内容的显示高度
        rect.size.height = contentHeight;
        //设置纵坐标
        rect.origin.y = y;
        //更新原内容显示的坐标及尺寸
        self.replyContent.frame = rect;
        //更新文本内容
        self.replyContent.text = news.reply;
        //取得内容的尾坐标，以供后面图片显示的坐标定位
        y += CGRectGetHeight(self.replyContent.frame) + 9;
    }else{
        self.replyContent.hidden = YES;
    }
    //设置垫底view
    rect = self.myPostView.frame;
    rect.origin.y = y;
    self.myPostView.frame = rect;
    y += CGRectGetHeight(self.myPostView.frame)+8;
    //设置被回复体
    if (news.contentImage) {//回复帖子
        self.myPostImage.hidden = NO;
        [self.myPostImage setImageWithURL:[NSURL URLWithString:news.contentImage]];
        //设置被回复的帖子内容
        NSString *postStr = [NSString stringWithFormat:@"%@：%@",news.myName, news.subTitle];
        self.myPost.text = postStr;
    } else {//回复没有图片的帖子或回复楼层
        //隐藏图片，
        self.myPostImage.hidden = YES;
        if (news.subTitle) {//
            rect = self.myPost.frame;
            rect.origin.x = rect.origin.x-50;
            rect.size.width = rect.size.width+50;
            self.myPost.frame = rect;
            NSString *replyStr = [NSString stringWithFormat:@"%@：%@",news.myName, news.subTitle];
            self.myPost.text = replyStr;

        } else {//回复楼层
            //更改myPost的位置
            rect = self.myPost.frame;
            rect.origin.x = rect.origin.x-50;
            rect.size.width = rect.size.width+50;
            self.myPost.frame = rect;
            NSString *replyStr = [NSString stringWithFormat:@"%@：%@",news.myName, news.myReply];
            self.myPost.text = replyStr;
        }

    }
    //更新cell的frame
    rect = self.frame;
    rect.size.height = y;
    self.frame = rect;
}

//获得cell的高度
+ (CGFloat)getCellHeight:(NewsModel *)news
{
    CGFloat height = 48.0;
    //获得请求数据中内容的高度
    CGFloat contentHeight = [news.reply boundingRectWithSize:CGSizeMake(257, 0) withTextFont:[UIFont systemFontOfSize:14] withLineSpacing:0].height;
    height += contentHeight+9;
    height += 50+8;
    return height;
}
@end
