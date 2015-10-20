//
//  RepositoryCell.m
//  ECIGARFAN
//
//  Created by renchunyu on 14-8-15.
//  Copyright (c) 2014年 renchunyu. All rights reserved.
//

#import "RepositoryCell.h"

@implementation RepositoryCell

- (void)awakeFromNib
{
    
    [_selectedBtn addTarget:self action:@selector(clickSelectedBtn:) forControlEvents:UIControlEventTouchUpInside];
}


-(void)clickSelectedBtn:(id)sender
{
    
    if (_isSelected) {
        [_selectedBtn setImage:[UIImage imageNamed:@"radiobox_0"] forState:UIControlStateNormal];
        _isSelected=NO;
    }else
    {
        [_selectedBtn setImage:[UIImage imageNamed:@"radiobox_1"] forState:UIControlStateNormal];
        _isSelected=YES;
    
    }

    UIButton *button=(id)sender;
    [self changeSelectedStatus:button.tag];

}


//改变列表是否选中状态,并更新选中表
-(void)changeSelectedStatus:(NSInteger)index
{
    

    NSMutableArray *data = [[LocalStroge sharedInstance] getObjectAtKey:F_WEBSITE filePath:NSCachesDirectory];
    
    //改变状态
    [[data objectAtIndex:index] setObject:[NSString stringWithFormat:@"%d",_isSelected] forKey:@"status"];
    [[LocalStroge sharedInstance] addObject:data forKey:F_WEBSITE filePath:NSCachesDirectory];
    

 //更新选中表
    NSMutableArray *array=[[NSMutableArray alloc] init];
    for (int i=0; i<[data count]; i++) {
        if ([[[data objectAtIndex:i] objectForKey:@"status"] isEqualToString:@"1"]) {
            
            [array addObject:[data objectAtIndex:i]];
        }
    }
    [[LocalStroge sharedInstance] addObject:array forKey:F_WEBSITE_SELECTED filePath:NSCachesDirectory];
    
    
    //发送通知,重载列表
    [[NSNotificationCenter defaultCenter] postNotificationName:@"reloadContent" object:nil];
}




- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
