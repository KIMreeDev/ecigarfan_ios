//
//  SubPostBarCell.m
//  ECIGARFAN
//
//  Created by JIRUI on 14-4-14.
//  Copyright (c) 2014年 JIRUI. All rights reserved.
//

#import "SubPostBarCell.h"
#import "UIImageView+WebCache.h"
#import "PostImageViewController.h"
#import "NSString+extended.h"
@implementation SubPostBarCell
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
- (IBAction)deletePost:(id)sender {
    if ([self.delegate respondsToSelector:@selector(deleteMyPost:)]) {
        [self.delegate deleteMyPost:_needDeletedPostID];
    }
}
- (IBAction)reportPost:(id)sender {
    if ([self.delegate respondsToSelector:@selector(reportPosts)]) {
        [self.delegate reportPosts];
    }
}

//点击用户名获取该用户的所有帖子
- (IBAction)manPosts:(NSInteger)sender {
    if ([self.delegate respondsToSelector:@selector(postsOfElse:)]) {
        [self.delegate postsOfElse:self.customerID];
    }
}
//点击用户头像
- (void)handleSingleTapFrom
{
    if ([self.delegate respondsToSelector:@selector(postsOfElse:)]) {
        [self.delegate postsOfElse:self.customerID];
    }
}
//配置帖子内容
- (void)configPostCellWithPost:(Post *)post{
    _reportBut.hidden = YES;
    //设置帖子ID
    subID = post.subID;
    //设置发帖时间
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString *strDate = [DateTimeHelper getLocalDateFormateUTCDate:post.beginTime];
    NSDate *dateNow = [formatter dateFromString:strDate];
    strDate = [DateTimeHelper formatStringWithDate:dateNow];
    self.beginTime.text = strDate;
    
    self.customerID = post.customerID;
    CGRect rect = CGRectZero;
    CGFloat y = 28;
    //设置帖子主题
    if (post.subTitle) {
        //获得请求数据中内容的高度
        CGFloat contentHeight = [post.subTitle boundingRectWithSize:CGSizeMake(279, 0) withTextFont:[UIFont systemFontOfSize:14] withLineSpacing:0].height;
        contentHeight += 1;
        //取得cell中内容label的大小
        rect = _subTitle.frame;
        rect.size.height = contentHeight;
        rect.origin.y = y;
        _subTitle.frame = rect;
        _subTitle.text = post.subTitle;
        //取得内容的尾坐标，以供后面图片显示的坐标定位
        y += CGRectGetHeight(_subTitle.frame)+4;
    }
    //设置内容
    if (post.subContent) {
        //获得请求数据中内容的高度, 如果高度超过4行就固定在4行
        CGFloat contentHeight = [post.subContent boundingRectWithSize:CGSizeMake(279, 0) withTextFont:[UIFont systemFontOfSize:13] withLineSpacing:0].height;
        if (contentHeight >= 100.0) {
                contentHeight = 100.0;
        }
 
        //取得cell中内容label的大小
        rect = _contentLabel.frame;
        rect.size.height = contentHeight;
        rect.origin.y = y;
        _contentLabel.frame = rect;
        _contentLabel.text = post.subContent;
        //取得内容的尾坐标，以供后面图片显示的坐标定位
        y += CGRectGetHeight(_contentLabel.frame) + 8;
    }
    //设置图片
    if (![post.imageSmall isEqualToString:@""]) {
        //隐藏图片
        self.subImageView.hidden = NO;
        //取得cell中图片的坐标大小
        rect = self.subImageView.frame;
        rect.origin.y = y;
        self.subImageView.frame = rect;
        //通过UIImageView+WebCache类别设置图片、并设置背景图片
        [self.subImageView setImageWithURL:[NSURL URLWithString:post.imageSmall] placeholderImage:[UIImage imageNamed:@"thumb_pic.png"]];
        //给图片设置点击手势
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleImageTap:)];
        [self.subImageView addGestureRecognizer:tap];
        //取得总坐标以供后面的控件的正确显示
        y += CGRectGetHeight(self.subImageView.frame) + 20;
        
        //设置点击图片将要显示大图的地址
        _imageURL = post.subImage;
    }
    else {//如果没有图片，就隐藏cell中的图片
        self.subImageView.hidden = YES;
        y += 12;
    }
    
    //评论图标
    rect = self.replyIcon.frame;
    rect.origin.y = y-1.2;
    self.replyIcon.frame = rect;
    //评论标签
    rect = self.replyLabel.frame;
    rect.origin.y = y;
    self.replyLabel.frame = rect;
    [self.replyLabel setTitle:[NSString stringWithFormat:@"%li",(long)post.replyCount] forState:UIControlStateNormal];
    //赞图标(＊＊＊＊)
    rect = self.subpostDel.frame;
    rect.origin.y = y+1;
    self.subpostDel.frame = rect;
//    self.subpostDel.hidden = YES;
//    self.subpostDel.selected = NO;
    //用户头像
    //将图层的边框设置为圆脚
    self.customerImageView.layer.cornerRadius = 14;
    self.customerImageView.layer.masksToBounds = YES;
    //给图层添加一个有色边框
    self.customerImageView.layer.borderWidth = 0;
    self.customerImageView.layer.borderColor = [[UIColor colorWithRed:0.52 green:0.09 blue:0.07 alpha:1] CGColor];
    rect = self.customerImageView.frame;
    rect.origin.y = y-7.5;
    self.customerImageView.frame = rect;
    if ((NSNull *)post.customerImage != [NSNull null]) {
        [self.customerImageView setImageWithURL:[NSURL URLWithString:post.customerImage] placeholderImage:[UIImage imageNamed:@"thumb_avatar.png"]];
    }
    //用户名
    rect = self.customerLabel.frame;
    rect.origin.y = y;
    self.customerLabel.frame = rect;
    [self.customerLabel setTitle:post.customer forState:UIControlStateNormal];
    y += CGRectGetHeight(self.customerImageView.frame)+8;
    
    rect = self.frame;
    rect.size.height = y;
    self.frame = rect;
    // 单击的 Recognizer
    UITapGestureRecognizer *singleRecognizer;
    singleRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTapFrom)];
    singleRecognizer.numberOfTapsRequired = 1; // 单击
    [_customerImageView setUserInteractionEnabled:YES];
    [_customerImageView addGestureRecognizer:singleRecognizer];//设置头像手势
    [self.subTitle setTextColor:[UIColor brownColor]];
    [self.contentLabel setTextColor:COLOR_ECIGARFAN_GRAY];
    [self.customerLabel setTitleColor:COLOR_BLUE_LABEL forState:UIControlStateNormal];
    [self.subpostDel setTitleColor:COLOR_BLUE_LABEL forState:UIControlStateNormal];
    if ([post.customer isEqualToString:@"Administrator"]) {
        [self.subTitle setTextColor:[UIColor redColor]];
        [self.contentLabel setTextColor:[UIColor redColor]];
        [self.customerLabel setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
        [self.subpostDel setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    }
}

- (void)configDetailPostCellWithPost:(Post *)post{
    _reportBut.hidden = NO;
    [_reportBut setTitle:NSLocalizedString(@"Report", nil) forState:UIControlStateNormal];
    //设置帖子ID
    subID = post.subID;
    NSString *beginStr = [DateTimeHelper getLocalDateFormateUTCDate:post.beginTime];
    //设置发帖时间
    self.beginTime.text = beginStr;
    
    CGRect rect = CGRectZero;
    CGFloat y = 28;
    //设置帖子主题
    if (post.subTitle) {
        
        //获得请求数据中内容的高度
        CGFloat contentHeight = [post.subTitle boundingRectWithSize:CGSizeMake(279, 0) withTextFont:[UIFont systemFontOfSize:14] withLineSpacing:0].height;
        //取得cell中内容label的大小
        rect = _subTitle.frame;
        rect.size.height = contentHeight;
        rect.origin.y = y;
        _subTitle.frame = rect;
        _subTitle.text = post.subTitle;
        //取得内容的尾坐标，以供后面图片显示的坐标定位
        y += CGRectGetHeight(_subTitle.frame)+4;
    }
    //设置内容
    if (post.subContent) {
        //获得请求数据中内容的高度, 如果高度超过4行就固定在4行
        CGFloat contentHeight = [post.subContent boundingRectWithSize:CGSizeMake(279, 0) withTextFont:[UIFont systemFontOfSize:13] withLineSpacing:0].height;
        contentHeight += 20;
        //取得cell中内容label的大小
        rect = _contentLabel.frame;
        rect.size.height = contentHeight;
        rect.origin.y = y;
        _contentLabel.frame = rect;
        _contentLabel.text = post.subContent;
        //取得内容的尾坐标，以供后面图片显示的坐标定位

        y += CGRectGetHeight(_contentLabel.frame) + 8;
    }
    //设置图片
    if (![post.imageSmall isEqualToString:@""]) {
        //隐藏图片
        self.subImageView.hidden = NO;
        //取得cell中图片的坐标大小
        rect = self.subImageView.frame;
        rect.origin.y = y;
        self.subImageView.frame = rect;
        //通过UIImageView+WebCache类别设置图片、并设置背景图片
        [self.subImageView setImageWithURL:[NSURL URLWithString:post.imageSmall] placeholderImage:[UIImage imageNamed:@"thumb_pic.png"]];
        //给图片设置点击手势
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleImageTap:)];
        [self.subImageView addGestureRecognizer:tap];
        //取得总坐标以供后面的控件的正确显示
        y += CGRectGetHeight(self.subImageView.frame) + 20;
        
        //设置点击图片将要显示大图的地址
        _imageURL = post.subImage;
    }
    else {//如果没有图片，就隐藏cell中的图片
        self.subImageView.hidden = YES;
        y += 12;
    }
    
    //评论图标
    rect = self.replyIcon.frame;
    rect.origin.y = y-1.2;
    self.replyIcon.frame = rect;
    //评论标签
    rect = self.replyLabel.frame;
    rect.origin.y = y;
    self.replyLabel.frame = rect;
    [self.replyLabel setTitle:[NSString stringWithFormat:@"%li",(long)post.replyCount] forState:UIControlStateNormal];
    //版块帖子中的删除图标（识别出自己的帖子则显示）
    rect = self.subpostDel.frame;
    rect.origin.y = y;
    self.subpostDel.frame = rect;
    self.subpostDel.hidden = YES;
    self.subpostDel.selected = NO;
    //用户头像
    rect = self.customerImageView.frame;
    rect.origin.y = y-7.5;
    self.customerImageView.frame = rect;
    if ((NSNull *)post.customerImage != [NSNull null]) {
        [self.customerImageView setImageWithURL:[NSURL URLWithString:post.customerImage] placeholderImage:[UIImage imageNamed:@"thumb_avatar.png"]];
    }
    //用户名
    rect = self.customerLabel.frame;
    rect.origin.y = y;
    self.customerLabel.frame = rect;
    [self.customerLabel setTitle:post.customer forState:UIControlStateNormal];
    [self.customerLabel setTitleColor:[UIColor brownColor] forState:UIControlStateNormal];
    y += CGRectGetHeight(self.customerImageView.frame)+8;
    
    rect = self.frame;
    rect.size.height = y;
    self.frame = rect;
    
    if ([post.customer isEqualToString:@"Administrator"]) {
        [self.subTitle setTextColor:[UIColor redColor]];
    }
}

//详细帖子视图的高度获取
+ (CGFloat)detailCellHeight:(Post *)post
{
    CGFloat height = 28;
    if (post.subTitle) {
        CGFloat contentHeight = [post.subTitle boundingRectWithSize:CGSizeMake(279, 0) withTextFont:[UIFont systemFontOfSize:14] withLineSpacing:0].height;
        height += contentHeight;
    }
    if (post.subContent) {
        CGFloat contentHeight = [post.subContent boundingRectWithSize:CGSizeMake(279, 0) withTextFont:[UIFont systemFontOfSize:13] withLineSpacing:0].height;
        height += (contentHeight + 20);
    }
    height += ![post.imageSmall isEqual: @""] ? (125 + 8) : 0;
    height += 52;
    return height;
}
//所有帖子列表的高度获取
+ (CGFloat)postCellHeight:(Post *)post{
    CGFloat height = 28;
    if (post.subTitle) {
        CGFloat contentHeight = [post.subTitle boundingRectWithSize:CGSizeMake(279, 0) withTextFont:[UIFont systemFontOfSize:14] withLineSpacing:0].height;
        height += contentHeight;
    }
    if (post.subContent) {
        CGFloat contentHeight = [post.subContent boundingRectWithSize:CGSizeMake(279, 0) withTextFont:[UIFont systemFontOfSize:13] withLineSpacing:0].height;
        if (contentHeight >= 100.0) {
            contentHeight = 100.0;
        }
        height += (contentHeight + 8);
    }
    height += ![post.imageSmall  isEqual: @""] ? (125 + 8) : 0;
    height += 52;

    return height;
}

#pragma mark - Private methods

//点击图片
- (void)handleImageTap:(UITapGestureRecognizer *)gesture
{
    if (_delegate && [_delegate respondsToSelector:@selector(didTapedSubPostBarCellImage:)]) {
        [_delegate didTapedSubPostBarCellImage:_imageURL];
    }
}



@end
