//
//  RefreshHeaderView.m
//  ECIGARFAN
//
//  Created by JIRUI on 14-6-5.
//  Copyright (c) 2014年 JIRUI. All rights reserved.
//
#import "RefreshHeaderView.h"
#import "UIView+Frame.h"
#define TEXT_COLOR [UIColor grayColor]
#define FLIP_ANIMATION_DURATION 0.18f

@interface RefreshHeaderView ()
@property(nonatomic) NSInteger index;
@property(nonatomic,strong) NSTimer *timer;
@property(nonatomic,strong) NSArray *images;
- (void)setState:(RefreshState)aState;
@end

@implementation RefreshHeaderView
@synthesize delegate;

- (id)initWithFrame:(CGRect)frame
{
  NSArray *images = [NSArray arrayWithObjects:@"icon_load_0.png", @"icon_load_1.png", @"icon_load_2.png", @"icon_load_3.png", @"icon_load_4.png", @"icon_load_5.png", @"icon_load_6.png", @"icon_load_7.png", @"icon_load_8.png", @"icon_load_9.png", @"icon_load_10.png", @"icon_load_11.png", nil];
  return [self initWithFrame:frame images:images textColor:[UIColor grayColor]];
}

- (id)initWithFrame:(CGRect)frame images:(NSArray *)images textColor:(UIColor *)textColor
{
  if((self = [super initWithFrame:frame])) {
    self.clipsToBounds = YES;
    self.images = images;
		self.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    
    //状态
		UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 10, 150, 20.0f)];
    label.centerX = self.center.x+50;
		label.autoresizingMask = UIViewAutoresizingFlexibleWidth;
		label.font = [UIFont systemFontOfSize:12.0f];
		label.textColor = textColor;
		label.backgroundColor = [UIColor clearColor];
		[self addSubview:label];
		_stateLabel=label;
    
    //更新时间
		label = [[UILabel alloc] initWithFrame:CGRectMake(0, 30, 150, 20.0f)];
    label.centerX = self.center.x+50;
		label.autoresizingMask = UIViewAutoresizingFlexibleWidth;
		label.font = [UIFont systemFontOfSize:10.0f];
		label.textColor = textColor;
		label.backgroundColor = [UIColor clearColor];
		[self addSubview:label];
		_updateLabel=label;
		
    //图标箭头
		_imageView = [[UIImageView alloc] initWithFrame:CGRectMake(label.frame.origin.x-40, 20, 20.0f, 20.0f)];
        _imageView.contentMode = UIViewContentModeScaleAspectFit;
		[self addSubview:_imageView];
    
    //设置默认状态
		[self setState:RefreshStateNormal];
  }
  return self;
}

//刷新停止
- (void)refreshScrollViewDataSourceDidFinishedLoading:(UIScrollView *)scrollView
{
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:0.3f];
	[scrollView setContentInset:UIEdgeInsetsMake(0.0f, 0.0f, 0.0f, 0.0f)];
	[UIView commitAnimations];
    [self refreshLastUpdatedDate];
	[self setState:RefreshStateNormal];
    [self stopLoadingAnimation];
}

//开始播放加载动画
- (void)startLoadingAnimation
{
  [self stopLoadingAnimation];
  _imageView.image = [UIImage imageNamed:[self.images lastObject]];
  self.index = 0;
  self.timer = [NSTimer scheduledTimerWithTimeInterval:0.05f target:self selector:@selector(playLoadingAnimation) userInfo:nil repeats:YES];
}
//播放加载动画
- (void)playLoadingAnimation
{
  self.index ++;
  CGFloat rotation = ((self.index*30)/180.0f)*M_PI;
    _imageView.transform = CGAffineTransformMakeRotation(rotation);
}
//停止播放加载动画
- (void)stopLoadingAnimation
{
  if (self.timer) {
    [self.timer invalidate];
    self.timer = nil;
  }
  _imageView.image = nil;
  _imageView.transform = CGAffineTransformIdentity;
}

- (NSString *)getUpdateDateKey
{
  return [NSString stringWithFormat:@"%@_RefreshHeaderView_LastRefreshDate",self.key];
}

#pragma mark -
#pragma mark Setters
//更新时间
- (void)refreshLastUpdatedDate {
	if ([self.delegate respondsToSelector:@selector(refreshTableHeaderDataSourceLastUpdated:)]) {
		NSDate *date = [self.delegate refreshTableHeaderDataSourceLastUpdated:self];
		
		[NSDateFormatter setDefaultFormatterBehavior:NSDateFormatterBehaviorDefault];
		NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
		[dateFormatter setDateStyle:NSDateFormatterShortStyle];
		[dateFormatter setTimeStyle:NSDateFormatterShortStyle];
    
		_updateLabel.text = NSLocalizedString(@"Last updated: just", nil);
		[[NSUserDefaults standardUserDefaults] setDouble:[date timeIntervalSince1970] forKey:[self getUpdateDateKey]];
		[[NSUserDefaults standardUserDefaults] synchronize];
	}
  else {
		_updateLabel.text = nil;
	}
}

//设置状态
- (void)setState:(RefreshState)aState{
	switch (aState) {
		case RefreshStatePulling:
    {
    _stateLabel.text = NSLocalizedString(@"Release to refresh", nil);
    }
			break;
		case RefreshStateNormal:
    {
    _stateLabel.text = NSLocalizedString(@"Pull down to refresh", nil);
    }
			break;
		case RefreshStateLoading:
    {
    _stateLabel.text = NSLocalizedString(@"Loading Status", nil);
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
- (void)refreshScrollViewDidScroll:(UIScrollView *)scrollView
{
  CGFloat height = scrollView.contentOffset.y * -1;
  if (height < 5) {
    height = 5;
  }
  
  self.height = height;
  
  NSTimeInterval interval = [[NSUserDefaults standardUserDefaults] doubleForKey:[self getUpdateDateKey]];
  if (interval > 0) {
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:interval];
    _updateLabel.text = [NSString stringWithFormat:NSLocalizedString(@"Last updated: %@", nil),[DateTimeHelper formatStringWithDate:date]];
  }
  else{
    _updateLabel.text = NSLocalizedString(@"Last updated: no refresh", nil);
  }
  
	if (_state == RefreshStateLoading) {
		CGFloat offset = MAX(scrollView.contentOffset.y * -1, 0);
		offset = MIN(offset, 60);
		scrollView.contentInset = UIEdgeInsetsMake(offset, 0.0f, 0.0f, 0.0f);
	}
  else if (scrollView.isDragging) {
		BOOL _loading = NO;
		if ([self.delegate respondsToSelector:@selector(refreshTableHeaderDataSourceIsLoading:)]) {
			_loading = [self.delegate refreshTableHeaderDataSourceIsLoading:self];
		}
		
		if (_state == RefreshStatePulling && scrollView.contentOffset.y > -65.0f && scrollView.contentOffset.y < 0.0f && !_loading) {
			[self setState:RefreshStateNormal];
		}
    else if (_state == RefreshStateNormal && scrollView.contentOffset.y < -65.0f && !_loading) {
			[self setState:RefreshStatePulling];
		}
    
    if (!_loading) {
      NSUInteger dy = 60/self.images.count;
      NSUInteger index = -(scrollView.contentOffset.y+20) / dy;
      if (index >= self.images.count) {
        index = self.images.count-1;
      }
      _imageView.image = [UIImage imageNamed:[self.images objectAtIndex:index]];
    }
		
		if (scrollView.contentInset.top != 0) {
			scrollView.contentInset = UIEdgeInsetsZero;
		}
		
	}
	
}
//停止拖拽
- (void)refreshScrollViewDidEndDragging:(UIScrollView *)scrollView
{
	BOOL _loading = NO;
	if ([self.delegate respondsToSelector:@selector(refreshTableHeaderDataSourceIsLoading:)]) {
		_loading = [self.delegate refreshTableHeaderDataSourceIsLoading:self];
	}
	if (scrollView.contentOffset.y <= - 65.0f && !_loading) {
		if ([self.delegate respondsToSelector:@selector(refreshTableHeaderDidTriggerRefresh:)]) {
			[self.delegate refreshTableHeaderDidTriggerRefresh:self];
		}
		[self setState:RefreshStateLoading];
        [self startLoadingAnimation];
		[UIView beginAnimations:nil context:NULL];
		[UIView setAnimationDuration:0.2];
		scrollView.contentInset = UIEdgeInsetsMake(60.0f, 0.0f, 0.0f, 0.0f);
		[UIView commitAnimations];
	}
}

@end




