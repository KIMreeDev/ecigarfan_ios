//
//  RefreshHeaderView.h
//  ECIGARFAN
//
//  Created by JIRUI on 14-6-5.
//  Copyright (c) 2014年 JIRUI. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum{
  RefreshStateNormal,
  RefreshStatePulling,
  RefreshStateLoading
} RefreshState;

/*
 * @brief refresh header view
 */
@protocol RefreshHeaderViewDelegate;
@interface RefreshHeaderView : UIView
{
  UIImageView *_imageView;
  UILabel *_stateLabel;
  UILabel *_updateLabel;
  RefreshState _state;
}
@property(nonatomic,strong) NSString *key;
@property(nonatomic,weak) id<RefreshHeaderViewDelegate> delegate;

//初始化
- (id)initWithFrame:(CGRect)frame images:(NSArray *)images textColor:(UIColor *)textColor;
//刷新时间
- (void)refreshLastUpdatedDate;
//开始滚动
- (void)refreshScrollViewDidScroll:(UIScrollView *)scrollView;
//停止拖拽
- (void)refreshScrollViewDidEndDragging:(UIScrollView *)scrollView;
//刷新结束
- (void)refreshScrollViewDataSourceDidFinishedLoading:(UIScrollView *)scrollView;
@end

@protocol RefreshHeaderViewDelegate<NSObject>
//触发刷新
- (void)refreshTableHeaderDidTriggerRefresh:(RefreshHeaderView *)view;
//判断是否正在刷新
- (BOOL)refreshTableHeaderDataSourceIsLoading:(RefreshHeaderView *)view;
@optional
//最后更新时间
- (NSDate*)refreshTableHeaderDataSourceLastUpdated:(RefreshHeaderView *)view;
@end










