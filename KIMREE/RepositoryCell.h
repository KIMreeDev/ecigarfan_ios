//
//  RepositoryCell.h
//  ECIGARFAN
//
//  Created by renchunyu on 14-8-15.
//  Copyright (c) 2014年 renchunyu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RepositoryCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *webSiteImageView;
@property (weak, nonatomic) IBOutlet UILabel *webSiteTitle;
@property (weak, nonatomic) IBOutlet UIButton *selectedBtn;
@property (assign,nonatomic) BOOL isSelected;
@end
