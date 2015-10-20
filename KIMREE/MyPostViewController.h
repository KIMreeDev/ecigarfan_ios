//
//  MyPostViewController.h
//  ECIGARFAN
//
//  Created by JIRUI on 14-6-6.
//  Copyright (c) 2014年 JIRUI. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MyPostViewController : UIViewController
{
    //帖子数组
    NSMutableArray *_postArray;
    //手势滑动的位置
    CGPoint beginPoint;
}
@property (nonatomic,assign) NSInteger modID;
@end
