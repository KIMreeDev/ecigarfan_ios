//
//  CommentCell.m
//
//  Created by JIRUI on 14-5-8.
//  Copyright (c) 2014年 JIRUI. All rights reserved.
//

#import "CommentCell.h"

#import "NSString+extended.h"
@implementation CommentCell

- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
//评论
- (void)configCommentCellWithComment:(Comment *)comment
{
    _customerID = comment.customerID;
    //单击的 Recognizer
    UITapGestureRecognizer *singleRecognizer, *nameRecognizer;
    singleRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTapFrom)];
    singleRecognizer.numberOfTapsRequired = 1; // 单击
    [_customerImage addGestureRecognizer:singleRecognizer];//设置头像手势
    
    nameRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTapFrom)];
    nameRecognizer.numberOfTapsRequired = 1; // 单击
    [_customerNameLabel addGestureRecognizer:nameRecognizer];//设置名字手势

    //将图层的边框设置为圆脚
    _customerImage.layer.cornerRadius = 14;
    _customerImage.layer.masksToBounds = YES;
    //给图层添加一个有色边框
    _customerImage.layer.borderWidth = 0;
    _customerImage.layer.borderColor = [[UIColor colorWithRed:0.52 green:0.09 blue:0.07 alpha:1] CGColor];
    [_customerImage setImageWithURL:[NSURL URLWithString:comment.customerImage] placeholderImage:[UIImage imageNamed:@"thumb_avatar.png"]];
    //设置评论用户的昵称
    _customerNameLabel.text = comment.customerName;
    //设置楼层
    _floorLabel.text = [NSString stringWithFormat:@"%li", (long)comment.replyID];
    //设置回复时间
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString *strDate = [DateTimeHelper getLocalDateFormateUTCDate:comment.replyTime];
    NSDate *dateNow = [formatter dateFromString:strDate];
    strDate = [DateTimeHelper formatStringWithDate:dateNow];
    _beginTime.text = strDate;
    
    NSInteger commentHeight = 0;

    commentHeight = [comment.content boundingRectWithSize:CGSizeMake(257, 0) withTextFont:[UIFont systemFontOfSize:13] withLineSpacing:0].height;
    
    //设置内容
    [self.content setText:comment.content];
    //设置高度
    CGRect rect = self.content.frame;
    rect.size.height = commentHeight+8;
    self.content.frame = rect;
    //设置更多回复按钮
 
#if COMMENT
//    if (comment.moreRepCount > 0) {
    
    
        rect = self.moreReply.frame;
        rect.origin.y = self.content.frame.origin.y+commentHeight+8;
        rect.size.height = 15;
        self.moreReply.frame = rect;
        NSString *strRep = [NSString stringWithFormat:NSLocalizedString(@"See article %i reply", nil) ,comment.moreRepCount];
        [self.moreReply setTitle:strRep forState:UIControlStateNormal];
        self.moreReply.hidden = NO;
//    }
#endif
    if ([comment.customerName isEqualToString:@"Administrator"]) {
        [self.customerNameLabel setTextColor:[UIColor redColor]];
        [self.content setTextColor:[UIColor redColor]];
    }
}
//追评
- (void)configCommentAddCellWithComment:(Comment *)comment
{
    _customerID = comment.customerID;
    //单击的 Recognizer
    UITapGestureRecognizer *singleRecognizer, *nameRecognizer;
    singleRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTapFrom)];
    singleRecognizer.numberOfTapsRequired = 1; // 单击
    [_customerImage addGestureRecognizer:singleRecognizer];//设置头像手势
    
    nameRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTapFrom)];
    nameRecognizer.numberOfTapsRequired = 1; // 单击
    [_customerNameLabel addGestureRecognizer:nameRecognizer];//设置名字手势
//    //将图层的边框设置为圆脚
//    _customerImage.layer.cornerRadius = 14;
//    _customerImage.layer.masksToBounds = YES;
//    //给图层添加一个有色边框
//    _customerImage.layer.borderWidth = 0;
    _customerImage.layer.borderColor = [[UIColor colorWithRed:0.52 green:0.09 blue:0.07 alpha:1] CGColor];
    [_customerImage setImageWithURL:[NSURL URLWithString:comment.customerImage] placeholderImage:[UIImage imageNamed:@"thumb_avatar.png"]];
    //设置评论用户的昵称
    _customerNameLabel.text = comment.customerName;
    CGRect rect = self.customerNameLabel.frame;
    rect.origin.y = self.customerNameLabel.frame.origin.y - 3.5;
    self.customerNameLabel.frame = rect;
    //设置楼层
    _floorLabel.text = [NSString stringWithFormat:@"%li", (long)comment.replyID];
    //设置回复时间
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString *strDate = [DateTimeHelper getLocalDateFormateUTCDate:comment.replyTime];
    NSDate *dateNow = [formatter dateFromString:strDate];
    strDate = [DateTimeHelper formatStringWithDate:dateNow];
    _beginTime.text = strDate;
    
    NSInteger commentHeight = 0;
    commentHeight = [comment.content boundingRectWithSize:CGSizeMake(257, 0) withTextFont:[UIFont systemFontOfSize:14] withLineSpacing:0].height;
    
    //设置内容
    self.content.font = [UIFont boldSystemFontOfSize:14.0f]; //UILabel的字体大小;
    [self.content setText:comment.content];
    //设置高度
    rect = self.content.frame;
    rect.size.height = commentHeight+8;
    self.content.frame = rect;
    //分割线
    rect = self.speratorImg.frame;
    rect.origin.y = self.content.frame.origin.y + commentHeight + 12;
    self.speratorImg.frame = rect;
    self.speratorImg.hidden = NO;
}
//点击用户的头像
- (void)handleSingleTapFrom{
    if (_customerID) {
        if ([_delegate respondsToSelector:@selector(didTapedCustomerImage:)]) {
            [_delegate didTapedCustomerImage:_customerID];
        }
    }
}
//点击更多追回(参数为评论ID)
- (IBAction)tapMoreRep:(id)sender
{
    if ([_delegate respondsToSelector:@selector(loadMoreReply:)]) {
        [_delegate loadMoreReply:_repIndex];
    }
}

+ (CGFloat)getCellHeight:(Comment *)comment
{
    CGFloat height = 43;
    if (comment.content) {
        //获取高度
        NSInteger commentHeight = 0;
        commentHeight = [comment.content boundingRectWithSize:CGSizeMake(257, 0) withTextFont:[UIFont systemFontOfSize:13] withLineSpacing:0].height;
        height += (commentHeight+5+8);
    }
//    if (comment.moreRepCount > 0) {
        //更多回复
        height += 23;
//    }
    return height;
}
//追评
+ (CGFloat)getAddCellHeight:(Comment *)comment
{
    CGFloat height = 43;
    if (comment.content) {
        //获取高度
        NSInteger commentHeight = 0;
        commentHeight = [comment.content boundingRectWithSize:CGSizeMake(257, 0) withTextFont:[UIFont systemFontOfSize:14] withLineSpacing:0].height;
        height += (commentHeight+5+12);
    }
    return height;
}

@end
