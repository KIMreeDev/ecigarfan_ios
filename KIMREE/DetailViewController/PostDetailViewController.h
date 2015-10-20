//
//  PostDetailViewController
//  ECIGARFAN
//
//  Created by JIRUI on 14-4-7.
//  Copyright (c) 2014年 JIRUI. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Post.h"
#import "EmojiView.h"
#import <Social/Social.h>
#import "TableView.h"
/**
 * @brief 详细帖子（评论）
 */
@interface PostDetailViewController : UIViewController <UITableViewDataSource,UITableViewDelegate,TableViewLoadMoreDelegate, UIScrollViewDelegate,UITextViewDelegate,EmojiViewDelegate>
{
    BOOL isFirstShowKeyboard;
    BOOL isButtonClicked;
    BOOL isKeyboardShowing;
    BOOL isSystemBoardShow;
//    EmojiView *_emojiView;
    CGFloat keyboardHeight;
    //系统分享类库
    SLComposeViewController *slComposerSheet;
    //截屏
    UIImage *image;
    //toolview
    IBOutlet UIView *toolBar;
    //文本域
    IBOutlet UITextView *textView;
//    //表情
//    IBOutlet UIButton *keyboardButton;
    //发送
    IBOutlet UIButton *sendButton;
    //手势滑动的位置
    CGPoint beginPoint;
}
@property (strong, nonatomic) NSString *superTitle;
//帖子
@property (strong, nonatomic) Post *post;
//表视图
@property (strong, nonatomic) TableView *detailTableView;
//返回按钮
@property (strong, nonatomic) IBOutlet UIButton *backButton;
//分享按钮
@property (strong, nonatomic) IBOutlet UIButton *shareButton;
@property (strong, nonatomic) IBOutlet UILabel *placeHodle;
- (void)initViews;
@end
