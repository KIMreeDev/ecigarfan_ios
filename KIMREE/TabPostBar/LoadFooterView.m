//
//  LoadFooterView.m
//  ECIGARFAN
//
//  Created by JIRUI on 14-6-5.
//  Copyright (c) 2014年 JIRUI. All rights reserved.
//
#import "LoadFooterView.h"

#define TEXT_COLOR [UIColor grayColor]
#define FLIP_ANIMATION_DURATION 0.18f
#define FOOTER_HEIGHT 60

@interface LoadFooterView ()
- (void)setState:(LoadState)aState;
@end

@implementation LoadFooterView
@synthesize delegate;


- (id)initWithFrame:(CGRect)frame textColor:(UIColor *)textColor
{
  if((self = [super initWithFrame:frame])) {
		self.autoresizingMask = UIViewAutoresizingFlexibleWidth;
		
    //状态
		UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake((frame.size.width - 100.0f)/2,0, 100, frame.size.height)];
		label.autoresizingMask = UIViewAutoresizingFlexibleWidth;
		label.font = [UIFont systemFontOfSize:14.0f];
		label.textColor = textColor;
		label.backgroundColor = [UIColor clearColor];
		label.textAlignment = NSTextAlignmentCenter;
		[self addSubview:label];
		_stateLabel=label;
    
    //添加点击事件
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(loadMore)];
    _stateLabel.userInteractionEnabled = YES;
    [_stateLabel addGestureRecognizer:tap];
		
    //加载指示器
		_activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
		_activityView.frame = CGRectMake(_stateLabel.frame.origin.x-30, (frame.size.height-20)/2, 20.0f, 20.0f);
		[self addSubview:_activityView];
    if ([textColor isEqual:[UIColor whiteColor]]) {
      _activityView.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhite;
    }
    
    //设置默认状态
		[self setState:LoadStateNormal];
  }
  return self;
}

- (id)initWithFrame:(CGRect)frame {
  return [self initWithFrame:frame textColor:TEXT_COLOR];
}

#pragma mark -
#pragma mark Setters

//设置状态
- (void)setState:(LoadState)aState{
	switch (aState) {
		case LoadStatePulling:
    {
    _stateLabel.text = NSLocalizedString(@"Release to refresh", nil);
    }
			break;
		case LoadStateNormal:
    {
    _stateLabel.text = NSLocalizedString(@"Pull load more", nil);
    [_activityView stopAnimating];
    }
			break;
		case LoadStateLoading:
    {
    _stateLabel.text = NSLocalizedString(@"Loading Status", nil);
    [_activityView startAnimating];
    }
			break;
      case LoadStateFinished:
    {
    _stateLabel.text = NSLocalizedString(@"Finished Status", nil);
    [_activityView stopAnimating];
    }
      break;
		default:
			break;
	}
	
	_state = aState;
}

#pragma mark -
#pragma mark ScrollView Methods
//开始滚动
- (void)loadScrollViewDidScroll:(UIScrollView *)scrollView
{
  if (_state == LoadStateFinished) {
    return;
  }
  if(_state == LoadStateLoading){
    scrollView.contentInset = UIEdgeInsetsMake(0.0, 0.0f, 0.0f, 0.0f);
  }
  else if(scrollView.isDragging){
    if (_state == LoadStatePulling && (scrollView.contentOffset.y + scrollView.frame.size.height < scrollView.contentSize.height + FOOTER_HEIGHT) && scrollView.contentOffset.y > 0.0f) {
      [self setState:LoadStateNormal];
    }
    else if (_state == LoadStateNormal && (scrollView.contentOffset.y + scrollView.frame.size.height > scrollView.contentSize.height + FOOTER_HEIGHT)) {
      [self setState:LoadStatePulling];
    }
    if (scrollView.contentInset.bottom != 0) {
      scrollView.contentInset = UIEdgeInsetsZero;
    }
  }
}
//当用户停止拖动，并且手指从屏幕中拿开的的时候调用此方法
- (void)loadScrollViewDidEndDragging:(UIScrollView *)scrollView
{
    
  if (_state == LoadStateFinished) {
    return;
  }
  BOOL isLoading = NO;
  if ([self.delegate respondsToSelector:@selector(loadFooterViewDataSourceIsLoading:)]) {
    isLoading = [self.delegate loadFooterViewDataSourceIsLoading:self];
  }
  if (!isLoading && (scrollView.contentOffset.y + scrollView.frame.size.height) > scrollView.contentSize.height+FOOTER_HEIGHT) {
    [self loadMore];
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:FLIP_ANIMATION_DURATION];
    scrollView.contentInset = UIEdgeInsetsMake(0.0f, 0.0f, 0.0f, 0.0f);
    [UIView commitAnimations];
  }
}

//刷新结束
- (void)loadScrollViewDataSourceDidFinishedLoading:(UIScrollView *)scrollView; {
  _stateLabel.userInteractionEnabled = YES;
  [self setState:LoadStateNormal];
//  [UIView animateWithDuration:0.3f animations:^(void){
//    [scrollView setContentInset:UIEdgeInsetsMake(0.0f, 0.0f, 0.0f, 0.0f)];
//  }];
}

//加载完全部数据
- (void)loadAllData
{
  [self setState:LoadStateFinished];
}

//触发加载更多
- (void)loadMore
{
  if (_state == LoadStateFinished) {
    return;
  }
  _stateLabel.userInteractionEnabled = NO;
  if ([self.delegate respondsToSelector:@selector(loadFooterViewDidTriggerLoad:)]) {
    [self.delegate loadFooterViewDidTriggerLoad:self];
    [self setState:LoadStateLoading];
  }
}

@end
