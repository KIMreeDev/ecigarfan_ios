//
//  postMessageViewController.h
//  RFKeyboardToolbarDemo
//
//  Created by JIRUI on 14-5-9.
//  Copyright (c) 2014年 Rex Finn. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EmojiView.h"
@interface PostMessageViewController : UIViewController<UIImagePickerControllerDelegate,UINavigationControllerDelegate,UIScrollViewDelegate,UITextViewDelegate,EmojiViewDelegate>{
    BOOL isFullScreen;
    BOOL isFirstShowKeyboard;
    BOOL isButtonClicked;
    BOOL isKeyboardShowing;
    BOOL isSystemBoardShow;
//    EmojiView *_emojiView;
    CGFloat keyboardHeight;
    //表情
    IBOutlet UIButton *keyboardButton;
}
@property (strong, nonatomic) IBOutlet UITextView *subTitle;
@property (strong, nonatomic) IBOutlet UIView *centerView;
@property (strong, nonatomic) IBOutlet UITextView *postContent;
@property (strong, nonatomic) IBOutlet UIView *mainView;
@property (strong, nonatomic) IBOutlet UIView *toolView;
@property (strong, nonatomic) IBOutlet UIImageView *imageView;
    //版块
@property (nonatomic) NSInteger modID;
    //发帖用户的ID
@property (nonatomic) NSInteger customerID;
@end
