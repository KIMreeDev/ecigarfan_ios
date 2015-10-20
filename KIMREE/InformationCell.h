//
//  InformationCell.h
//  ECIGARFAN
//
//  Created by renchunyu on 14-8-15.
//  Copyright (c) 2014年 renchunyu. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol InformationCellDelegate <NSObject>

-(void)deleteAction:(NSInteger)index;

@end

@interface InformationCell : UICollectionViewCell
@property (weak, nonatomic) IBOutlet UIImageView *contentImage;
@property (weak, nonatomic) IBOutlet UILabel *testString;
@property(strong,nonatomic) id<InformationCellDelegate>delegate;
@end
