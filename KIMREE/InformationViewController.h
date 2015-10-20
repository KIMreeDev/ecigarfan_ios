//
//  InformationViewController.h
//  ECIGARFAN
//
//  Created by renchunyu on 14-8-15.
//  Copyright (c) 2014年 renchunyu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EScrollerView.h"
#import "InformationCell.h"

@interface InformationViewController : UIViewController<UICollectionViewDelegateFlowLayout,EScrollerViewDelegate,UIActionSheetDelegate,InformationCellDelegate>
@property (weak, nonatomic) IBOutlet UICollectionView *contentCollectionView;
@property (strong,nonatomic) NSMutableArray *dataList;
- (void)getInformationFromNetwork:(NSString *)strUrl;
@end
