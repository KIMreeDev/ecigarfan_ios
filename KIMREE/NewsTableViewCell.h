//
//  NewsTableViewCell.h
//  RFKeyboardToolbarDemo
//
//  Created by JIRUI on 14-5-16.
//  Copyright (c) 2014年 Rex Finn. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NewsModel.h"
@protocol NewsTableViewCellDelegate<NSObject>
- (void)newsReply;
- (void)postsOfElseMan:(NSInteger)sender;
@end
@interface NewsTableViewCell : UITableViewCell
@property (strong, nonatomic) id<NewsTableViewCellDelegate> delegate;
//回复人图片
@property (strong, nonatomic) IBOutlet UIButton *replyManImage;
//回复人的名称
@property (strong, nonatomic) IBOutlet UILabel *replyManNick;
//回复时间
@property (strong, nonatomic) IBOutlet UILabel *replyTime;
//回复的内容
@property (strong, nonatomic) IBOutlet UILabel *replyContent;
//垫底视图
@property (strong, nonatomic) IBOutlet UIView *myPostView;
//我发的帖子图片
@property (strong, nonatomic) IBOutlet UIImageView *myPostImage;
//我发的帖子
@property (strong, nonatomic) IBOutlet UILabel *myPost;
@property (nonatomic) NSInteger customerID;
//根据帖子内容来获取帖子高度
+ (CGFloat)getCellHeight:(NewsModel *)news;
//根据参数来设置帖子内容
- (void)configNewsCellWithNews:(NewsModel *)news;
@end
