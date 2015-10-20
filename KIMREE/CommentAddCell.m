//
//  CommentAddCell.m
//  ECIGARFAN
//
//  Created by JIRUI on 14-7-9.
//  Copyright (c) 2014年 JIRUI. All rights reserved.
//

#import "CommentAddCell.h"
#import "NSString+extended.h"
@implementation CommentAddCell

- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
//手势点击评论者
- (void)handleSingleTapFrom
{
    if ([_delegate respondsToSelector:@selector(didTapedCustomerName:)]) {
        [_delegate didTapedCustomerName:_comm.customerID];
    }
}
//手势点击被评论者
- (void)handleSingleTapFrom2
{
    if ([_delegate respondsToSelector:@selector(didTapedCustomerName:)]) {
        [_delegate didTapedCustomerName:_comm.repCustomerID];
    }
}
//配置cell
- (void)configCommentCellWithComment:(Comment *)comment
{
    //保存追评信息
    _comm = comment;
    //单击的 Recognizer
    UITapGestureRecognizer *singleRecognizer, *nameRecognizer;
    singleRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTapFrom)];
    singleRecognizer.numberOfTapsRequired = 1; // 单击
    [_customerName addGestureRecognizer:singleRecognizer];//设置头像手势
    
    nameRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTapFrom2)];
    nameRecognizer.numberOfTapsRequired = 1; // 单击
    [_repedCustomerName setUserInteractionEnabled:YES];
    [_repedCustomerName addGestureRecognizer:nameRecognizer];//设置名字手势

    CGRect rect = CGRectZero;
    CGFloat y = 23.0;
    //设置用户名
    rect = _customerName.frame;
    rect.size.width = [comment.customerName boundingRectWithSize:CGSizeMake(MAXFLOAT, 14) withTextFont:[UIFont systemFontOfSize:13] withLineSpacing:0].width;
    if (rect.size.width > 180) {
        rect.size.width = 180;
    }
    _customerName.frame = rect;
    [_customerName setText:comment.customerName];
    //设置回复时间
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString *strDate = [DateTimeHelper getLocalDateFormateUTCDate:comment.replyTime];
    NSDate *dateNow = [formatter dateFromString:strDate];
    strDate = [DateTimeHelper formatStringWithDate:dateNow];
    _repTime.text = strDate;
    //设置被回复人,是否有
    if (!comment.repCustomerName) {//没有
        _reply.hidden = YES;
        _customerName.hidden = YES;
        _colon.hidden = YES;
        //配置冒号
        rect.origin.x += 1;
        _colon.frame = rect;
    }
    else{//有
        rect = _repedCustomerName.frame;
        rect.size.width = [comment.repCustomerName boundingRectWithSize:CGSizeMake(MAXFLOAT, 14) withTextFont:[UIFont systemFontOfSize:13] withLineSpacing:0].width;
        if (rect.size.width > 180) {
            rect.size.width = 180;
            y += 14;
        }
        _repedCustomerName.frame = rect;
        [_repedCustomerName setText:comment.repCustomerName];
        //配置冒号
        rect.origin.x += 1;
        _colon.frame = rect;
    }
    //配置内容
    rect = _repContent.frame;
    rect.origin.y = y;
    rect.size.height = [comment.content boundingRectWithSize:CGSizeMake(264, 0) withTextFont:[UIFont systemFontOfSize:13] withLineSpacing:0].width;
    _repContent.frame = rect;
    [_repContent setText:comment.content];
    y += rect.size.height+2;
    //背景view
    rect = ((UIView *)[self viewWithTag:100]).frame;
    rect.origin.y = 2;
    rect.size.height = y-2;
    ((UIView *)[self viewWithTag:100]).frame = rect;
    
}

//得到cell的高度
+ (CGFloat)getCellHeight:(Comment *)comment
{
    CGFloat height = 23.0;
    if (comment.repCustomerName) {//有被评论人
        height += 14;
    }
    height += [comment.content boundingRectWithSize:CGSizeMake(264, 0) withTextFont:[UIFont systemFontOfSize:13] withLineSpacing:0].width;
    height += 4;
    return height;
}

@end
