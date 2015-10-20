//
//  CommentAddViewController.h
//  ECIGARFAN
//
//  Created by JIRUI on 14-7-8.
//  Copyright (c) 2014年 JIRUI. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CommentCell.h"
#import "CommentAddCell.h"
@interface CommentAddViewController : UIViewController
{
    //手势滑动的位置
    CGPoint beginPoint;
}
- (IBAction)dissSelf:(id)sender;
@property (strong, nonatomic) IBOutlet UIButton *dissButton;
@property (strong, nonatomic) IBOutlet UIImageView *lineSperator;
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet UILabel *placeHodle;
@property (strong, nonatomic) Comment *comment;
@end
