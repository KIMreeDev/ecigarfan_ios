//
//  CommentAddCell.h
//  ECIGARFAN
//
//  Created by JIRUI on 14-7-9.
//  Copyright (c) 2014年 JIRUI. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Comment.h"
@protocol CommentAddCellDelegate <NSObject>
//点击用户名触发
- (void)didTapedCustomerName:(NSInteger)customerID;
@end

@interface CommentAddCell : UITableViewCell
@property (strong, nonatomic) id<CommentAddCellDelegate> delegate;
@property (strong, nonatomic) IBOutlet UILabel *customerName;//回复者名称
@property (strong, nonatomic) IBOutlet UILabel *reply;         //回复label
@property (strong, nonatomic) IBOutlet UILabel *colon;         //冒号
@property (strong, nonatomic) IBOutlet UILabel *repedCustomerName;//被回复者名称
@property (strong, nonatomic) IBOutlet UILabel *repTime;          //回复时间
@property (strong, nonatomic) IBOutlet UILabel *repContent;       //回复内容
@property (strong, nonatomic) Comment *comm;
//@property (strong, nonatomic) IBOutlet UIView *backgroundView;
//配置cell
- (void)configCommentCellWithComment:(Comment *)comment;
//得到cell的高度
+ (CGFloat)getCellHeight:(Comment *)comment;
@end
