//
//  LoadFooterView.h
//  ECIGARFAN
//
//  Created by JIRUI on 14-6-5.
//  Copyright (c) 2014年 JIRUI. All rights reserved.
//
#import <UIKit/UIKit.h>

typedef enum{
  LoadStateNormal,
  LoadStatePulling,
  LoadStateLoading,
  LoadStateFinished
} LoadState;

@protocol LoadFooterViewDelegate;
@interface LoadFooterView : UIView
{
  UIActivityIndicatorView *_activityView;
  UILabel *_stateLabel;
  LoadState _state;
}
@property(nonatomic,weak) id<LoadFooterViewDelegate> delegate;

//初始化
- (id)initWithFrame:(CGRect)frame textColor:(UIColor *)textColor;
//开始滚动
- (void)loadScrollViewDidScroll:(UIScrollView *)scrollView;
//停止拖拽
- (void)loadScrollViewDidEndDragging:(UIScrollView *)scrollView;
//刷新结束
- (void)loadScrollViewDataSourceDidFinishedLoading:(UIScrollView *)scrollView;
//加载完全部数据
- (void)loadAllData;
//设置状态
- (void)setState:(LoadState)aState;
@end

@protocol LoadFooterViewDelegate <NSObject>

//触发刷新
- (void)loadFooterViewDidTriggerLoad:(LoadFooterView *)view;
//判断是否正在刷新
- (BOOL)loadFooterViewDataSourceIsLoading:(LoadFooterView *)view;

@end












