//
//  TableView.m
//  ECIGARFAN
//
//  Created by JIRUI on 14-6-5.
//  Copyright (c) 2014年 JIRUI. All rights reserved.
//
#import "TableView.h"

@interface TableView ()<RefreshHeaderViewDelegate,LoadFooterViewDelegate>
{
}
@end

@implementation TableView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
    }
    return self;
}

- (void)setRefreshView:(RefreshHeaderView *)refreshView
{
  if (_refreshView == refreshView) {
    return;
  }
  if (_refreshView) {
    [_refreshView removeFromSuperview];
    _refreshView = nil;
  }
  if (refreshView) {
    _refreshView = refreshView;
    _refreshView.key = self.key;
    _refreshView.delegate = self;
    [self.superview insertSubview:_refreshView belowSubview:self];
  }
}

- (void)setLoadMoreView:(LoadFooterView *)loadMoreView
{
  if (_loadMoreView == loadMoreView) {
    return;
  }
  if (_loadMoreView) {
    self.tableFooterView = nil;
    _loadMoreView = nil;
  }
  _loadMoreView = loadMoreView;
  _loadMoreView.delegate = self;
  self.tableFooterView = _loadMoreView;
}

/*
 * @brief 刷新数据结束
 */
- (void)refreshFinished:(UIScrollView *)view
{
  [self.refreshView refreshScrollViewDataSourceDidFinishedLoading:view];
  self.isLoading = NO;
}

/*
 * @brief 加载更多结束
 */
- (void)loadMoreFinished:(UIScrollView *)view
{
  [self.loadMoreView loadScrollViewDataSourceDidFinishedLoading:view];
  self.isLoading = NO;
}

/*
 * @brief 加载完所有数据
 */
- (void)loadAllData
{
  [self.loadMoreView loadAllData];
}

#pragma mark-
#pragma mark THRefreshHeaderViewDelegate
- (void)refreshTableHeaderDidTriggerRefresh:(RefreshHeaderView *)view
{
  if ([self.refreshDelegate respondsToSelector:@selector(refreshData:)]) {
    [self.refreshDelegate refreshData:self];
  }
}
- (BOOL)refreshTableHeaderDataSourceIsLoading:(RefreshHeaderView *)view
{
  return self.isLoading;
}
- (NSDate *)refreshTableHeaderDataSourceLastUpdated:(RefreshHeaderView *)view
{
  return [NSDate date];
}

#pragma mark-
#pragma mark THLoadFooterViewDelegate
- (void)loadFooterViewDidTriggerLoad:(LoadFooterView *)view
{
  if ([self.loadMoreDelegate respondsToSelector:@selector(loadMoreData:)]) {
    [self.loadMoreDelegate loadMoreData:self];
  }
}
- (BOOL)loadFooterViewDataSourceIsLoading:(LoadFooterView *)view
{
  return self.isLoading;
}

#pragma mark-
#pragma mark- UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{   
  if (self.refreshView) {
    [self.refreshView refreshScrollViewDidScroll:scrollView];
  }
  if (self.loadMoreView) {
    [self.loadMoreView loadScrollViewDidScroll:scrollView];
  }
}
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView
{

  if (self.refreshView) {

    [self.refreshView refreshScrollViewDidEndDragging:scrollView];
  }
    
  if (self.loadMoreView) {
    [self.loadMoreView loadScrollViewDidEndDragging:scrollView];
  }
}

@end




















































