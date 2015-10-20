//
//  NewsController.h
//  ECIGARFAN
//
//  Created by JIRUI on 14-6-12.
//  Copyright (c) 2014年 JIRUI. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EmojiView.h"
#import "NewsTableViewCell.h"
@interface NewsViewController : UIViewController
{
    //推送消息
    NSMutableArray *_newsArr;
    //toolview
    IBOutlet UIView *toolBar;
    //文本域
    IBOutlet UITextView *textView;
    //表情
    IBOutlet UIButton *keyboardButton;
    //发送
    IBOutlet UIButton *sendButton;
    NSMutableString *templyMessage;
    EmojiView *_emojiView;
    BOOL isFirstShowKeyboard;
    BOOL isButtonClicked;
    BOOL isKeyboardShowing;
    BOOL isSystemBoardShow;
    CGFloat keyboardHeight;
}

@end
