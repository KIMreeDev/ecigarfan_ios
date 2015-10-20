//
//  EmojiView.h
//
//  Created by JIRUI on 14-5-8.
//  Copyright (c) 2014年 JIRUI. All rights reserved.
//
#import <QuartzCore/QuartzCore.h>

@protocol EmojiViewDelegate;
@interface EmojiView : UIView 

@property (strong, nonatomic) id<EmojiViewDelegate> delegate;

@end

@protocol EmojiViewDelegate<NSObject>
@optional
- (void)didTouchEmojiView:(EmojiView*)emojiView touchedEmoji:(NSString*)string;
- (void)selectedDel:(NSArray *)_symbolArr;
@end
