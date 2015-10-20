//
//  SubPostViewController.h
//  ECIGARFAN
//
//  Created by JIRUI on 14-6-5.
//  Copyright (c) 2014年 JIRUI. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SubPostViewController : UIViewController
{
    //帖子数组
    NSMutableArray *_postArray;
    //开始拖的点
    CGPoint beginPoint;
}
@property (nonatomic,assign) NSInteger modID;
@end
