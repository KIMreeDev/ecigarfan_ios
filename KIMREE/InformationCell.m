//
//  InformationCell.m
//  ECIGARFAN
//
//  Created by renchunyu on 14-8-15.
//  Copyright (c) 2014年 renchunyu. All rights reserved.
//

#import "InformationCell.h"

@implementation InformationCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        NSArray *arrayOfViews = [[NSBundle mainBundle] loadNibNamed:@"InformationCell" owner:self options:nil];
        
        // 如果路径不存在，return nil
        if (arrayOfViews.count < 1)
        {
            return nil;
        }
        // 如果xib中view不属于UICollectionViewCell类，return nil
        if (![[arrayOfViews objectAtIndex:0] isKindOfClass:[UICollectionViewCell class]])
        {
            return nil;
        }
        // 加载nib
        self = [arrayOfViews objectAtIndex:0];
        
        //划分隔线
        UIImageView *lineImageView=[[UIImageView alloc] initWithFrame:self.bounds];
        [self addSubview:lineImageView];
        
        UIGraphicsBeginImageContext(lineImageView.bounds.size);
        [lineImageView.image drawInRect:CGRectMake(0, 0, lineImageView.frame.size.width, lineImageView.bounds.size.height)];
        CGContextSetLineCap(UIGraphicsGetCurrentContext(), kCGLineCapRound);
        CGContextSetLineWidth(UIGraphicsGetCurrentContext(), 1.0);  //线宽
        CGContextSetAllowsAntialiasing(UIGraphicsGetCurrentContext(), YES);
        CGContextSetRGBStrokeColor(UIGraphicsGetCurrentContext(), 180.0/255.0, 180.0/255.0, 180.0/255.0, 1.0);  //颜色
        
        CGContextBeginPath(UIGraphicsGetCurrentContext());
        CGContextMoveToPoint(UIGraphicsGetCurrentContext(), 0, self.bounds.size.height);  //起点坐标
        CGContextAddLineToPoint(UIGraphicsGetCurrentContext(), self.bounds.size.width, self.bounds.size.height);
        CGContextAddLineToPoint(UIGraphicsGetCurrentContext(), self.bounds.size.width, 0);//终点坐标
     
        CGContextStrokePath(UIGraphicsGetCurrentContext());
        lineImageView.image=UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        
        
        //增加长按删除手势
        UILongPressGestureRecognizer *longPressGestureRecognizer = [[UILongPressGestureRecognizer alloc] init];
        [longPressGestureRecognizer addTarget:self action:@selector(gestureRecognizerHandle:)];
        [longPressGestureRecognizer setMinimumPressDuration:0.3f];
        [longPressGestureRecognizer setAllowableMovement:50.0];
        [self addGestureRecognizer:longPressGestureRecognizer];
        

    }
    return self;
}


-(void)gestureRecognizerHandle:(UILongPressGestureRecognizer*)gesture
{
    if(UIGestureRecognizerStateBegan == gesture.state) {
    //放在判断条件外会重复执行
        if ([_delegate respondsToSelector:@selector(deleteAction:)]) {
            [_delegate deleteAction:self.tag];
        }
    }
    
    if(UIGestureRecognizerStateChanged == gesture.state) {
        // Do repeated work here (repeats continuously) while finger is down
   
    }
    
    if(UIGestureRecognizerStateEnded == gesture.state) {
        // Do end work here when finger is lifted
    }
    

}



@end
