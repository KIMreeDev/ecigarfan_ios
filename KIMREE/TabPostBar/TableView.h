//
//  TableView.h
//  ECIGARFAN
//
//  Created by JIRUI on 14-6-5.
//  Copyright (c) 2014年 JIRUI. All rights reserved.
//
#import <UIKit/UIKit.h>
#import "RefreshHeaderView.h"
#import "LoadFooterView.h"

/*
 * @brief TableView
 */
@protocol TableViewRefreshDelegate;
@protocol TableViewLoadMoreDelegate;

@interface TableView : UITableView
//key
@property(nonatomic,strong) NSString *key;
//是否正在请求数据
@property(nonatomic) BOOL isLoading;
//刷新头部
@property(nonatomic,strong) RefreshHeaderView *refreshView;
//加载更多
@property(nonatomic,strong) LoadFooterView *loadMoreView;
//刷新代理
@property(nonatomic,weak) id<TableViewRefreshDelegate> refreshDelegate;
//加载更多代理
@property(nonatomic,weak) id<TableViewLoadMoreDelegate> loadMoreDelegate;
/*
 * @brief 刷新数据结束
 */
- (void)refreshFinished:(UIScrollView *)view;

/*
 * @brief 加载更多结束
 */
- (void)loadMoreFinished:(UIScrollView *)view;

/*
 * @brief 加载完所有数据
 */
- (void)loadAllData;

//滚动
- (void)scrollViewDidScroll:(UIScrollView *)view;
- (void)scrollViewDidEndDragging:(UIScrollView *)view;
@end

/*
 * @brief TableViewRefreshDelegate
 */
@protocol TableViewRefreshDelegate <NSObject>
//刷新数据
- (void)refreshData:(TableView *)tableView;
@end

/*
 * @brief TableViewLoadMoreDelegate
 */
@protocol TableViewLoadMoreDelegate <NSObject>
//刷新数据
- (void)loadMoreData:(TableView *)tableView;
@end



















