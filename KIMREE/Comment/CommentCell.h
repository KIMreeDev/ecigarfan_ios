//
//  CommentCell.h
//
//  Created by JIRUI on 14-5-8.
//  Copyright (c) 2014年 JIRUI. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Comment.h"
@protocol CommentCellDelegate <NSObject>
//点击用户名触发
- (void)didTapedCustomerImage:(NSInteger)coustomerID;
//点击加载更多
- (void)loadMoreReply:(NSInteger)repIndex;
@end

@interface CommentCell : UITableViewCell
@property (strong, nonatomic) id<CommentCellDelegate> delegate;
@property (strong, nonatomic) IBOutlet UILabel *customerNameLabel;
@property (strong, nonatomic) IBOutlet UILabel *floorLabel;
@property (strong, nonatomic) IBOutlet UILabel *content;
@property (strong, nonatomic) IBOutlet UILabel *beginTime;
@property (strong, nonatomic) IBOutlet UIImageView *customerImage;
@property (strong, nonatomic) IBOutlet UIButton *moreReply;
@property (strong, nonatomic) IBOutlet UIImageView *speratorImg;
@property (nonatomic, assign) NSInteger customerID;
@property (nonatomic, assign) NSInteger repIndex;
- (void)configCommentCellWithComment:(Comment *)comment;
- (void)configCommentAddCellWithComment:(Comment *)comment;
+ (CGFloat)getCellHeight:(Comment *)comment;
+ (CGFloat)getAddCellHeight:(Comment *)comment;
- (IBAction)tapMoreRep:(id)sender;
@end
