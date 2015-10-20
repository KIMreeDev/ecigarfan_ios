//
//  SubPostBarCell.h
//  ECIGARFAN
//
//  Created by JIRUI on 14-4-29.
//  Copyright (c) 2014年 JIRUI. All rights reserved.
//
#import <UIKit/UIKit.h>
#import "Post.h"
/**
 * @brief帖子
 */
//帖子协议
@protocol SubPostBarCellDelegate <NSObject>

@optional
//点击帖子中的图片触发
- (void)didTapedSubPostBarCellImage:(NSString *)subImage;
//点击用户名触发
- (void)postsOfElse:(NSInteger)selectedPost;
//点击删除，则删除用户的帖子
- (void)deleteMyPost:(NSInteger)needDeletePost;
//帖子举报
- (void)reportPosts;
@end

@interface SubPostBarCell : UITableViewCell
{
    NSString *_imageURL;//图片地址
    NSInteger subID;//帖子id
    NSInteger replyCount;//回复数
    NSInteger isCellXY;
}
@property (strong, nonatomic) IBOutlet UIButton *reportBut;
@property (strong, nonatomic) id<SubPostBarCellDelegate> delegate;
//标题名
@property (nonatomic,strong) IBOutlet UILabel *subTitle;
//发布时间
@property (nonatomic,strong) IBOutlet UILabel *beginTime;
//内容
@property (strong, nonatomic) IBOutlet UILabel *contentLabel;
//内容图片
@property (strong, nonatomic) IBOutlet UIImageView *subImageView;
//评论图标
@property (strong, nonatomic) IBOutlet UIImageView *replyIcon;
//评论数量
@property (nonatomic,strong) IBOutlet UIButton *replyLabel;
//各个版块帖子中的删除按钮
@property (nonatomic,strong) IBOutlet UIButton *subpostDel;
//用户头像
@property (strong, nonatomic) IBOutlet UIImageView *customerImageView;
//用户名
@property (strong, nonatomic) IBOutlet UIButton *customerLabel;
//个人页面的删除按钮
@property (strong, nonatomic) IBOutlet UIButton *deletePost;

@property (nonatomic) NSInteger customerID;
@property (nonatomic) NSInteger needDeletedPostID;
@property (strong, nonatomic) Post *postOfCell;
//根据帖子内容来获取帖子高度
+ (CGFloat)detailCellHeight:(Post *)post;
+ (CGFloat)postCellHeight:(Post *)post;
//根据参数来设置帖子内容
- (void)configDetailPostCellWithPost:(Post *)post;
- (void)configPostCellWithPost:(Post *)post;
@end
