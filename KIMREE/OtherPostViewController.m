//
//  OtherViewController.m
//  ECIGARFAN
//
//  Created by JIRUI on 14-6-12.
//  Copyright (c) 2014年 JIRUI. All rights reserved.
//

#import "OtherPostViewController.h"
#import "SubPostBarCell.h"
#import "PostDetailViewController.h"
#import "PostImageViewController.h"
#import "TableView.h"
#import "UIView+Frame.h"
#import "UIView+Nib.h"
#import "OtherPostServer.h"
@interface OtherPostViewController ()<UITableViewDataSource,UITableViewDelegate,SubPostBarCellDelegate,TableViewLoadMoreDelegate,TableViewRefreshDelegate,UIScrollViewDelegate>
{
    OtherPostServer *otherPostServer;//贴吧版块实例，存所有帖子
    BOOL showTipDidReload;
}
@property (nonatomic,strong) TableView *dataTableView;

@end

@implementation OtherPostViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.view = [UIView n_loadFromNibName:@"SubPostListView"];
    self.view.backgroundColor = COLOR_BACKGROUND;
    [self loadData];
    //数据列表
    self.dataTableView = (TableView *)[self.view viewWithTag:1000];
    self.dataTableView.key = [NSString stringWithFormat:@"OtherPostList%@",[AppHelper sharedInstance].uid];
    self.dataTableView.delegate = (id)self;
    self.dataTableView.dataSource = (id)self;
    self.dataTableView.refreshDelegate = self;
    self.dataTableView.loadMoreDelegate = self;
    self.dataTableView.refreshView = [[RefreshHeaderView alloc] initWithFrame:CGRectMake(0, self.dataTableView.top, self.dataTableView.width, 0)];
    
    //设置背景，去掉表格的中间线条·
    UIView *view =[ [UIView alloc]init];
    view.backgroundColor = [UIColor clearColor];
    [self.dataTableView setTableFooterView:view];
    UIBarButtonItem *backButtonItem = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemReply target:self action:@selector(backButtonClicked)];
    [self.navigationItem setRightBarButtonItem:backButtonItem];
}
//跳出键
- (void)backButtonClicked
{
    [self.navigationController popToViewController:[self.navigationController.viewControllers objectAtIndex:1] animated:YES];
}
//下拉刷新
- (void)reloadPost:(BOOL)showed
{
    showTipDidReload = showed;
    [otherPostServer reloadOtherPostListWithID:self.otherID delegate:(id)self];//实体请求数据
}
//加载更多
- (void)loadMore{
    [otherPostServer loadNextOtherPostListWithID:self.otherID delegate:(id)self];//加载更多
}
//数据
- (NSMutableArray *)allPostList
{
    return otherPostServer.allPostList                                                                                                                                                                                                          ;
}
- (void)loadData{
    //完成更新，显示提示信息
    otherPostServer = [OtherPostServer sharedInstance];
    [self reloadPost:NO];//实体请求数据
}
#pragma mark - Scroll
//刷新数据成功后回调
- (void)didReloadOtherPostListFinished:(OtherPostServer *)server type:(NSString *)type updateCount:(NSInteger)count{
    if ([self allPostList].count > 0) {
       self.title = ((Post *)[[self allPostList] objectAtIndex:0]).customer;
    }
    [self.dataTableView refreshFinished:self.dataTableView];
    [self.dataTableView reloadData];
    NSInteger rows = [self allPostList].count;
    if (rows >= C_API_LIST_NUM) {
        self.dataTableView.loadMoreView = [[LoadFooterView alloc] initWithFrame:CGRectMake(0, 0, self.dataTableView.width-60, 60) textColor:[UIColor grayColor]];
    }
    else{
        self.dataTableView.loadMoreView = nil;
    }
}
//刷新数据失败后回调
- (void)didReloadOtherPostListFailed:(OtherPostServer *)server type:(NSString *)type errorCode:(NSInteger)code message:(NSString *)msg{
    [self.dataTableView refreshFinished:self.dataTableView];
    [JDStatusBarNotification showWithStatus:msg dismissAfter:1.0f];
}
//加载成功回调
- (void)didLoadNextOtherPostListFinished:(OtherPostServer *)server type:(NSString *)type isLoadAll:(BOOL)isLoadAll{
    [self.dataTableView loadMoreFinished:self.dataTableView];
    [self.dataTableView reloadData];
    if (isLoadAll) {
        [self.dataTableView loadAllData];
    }
}
//加载失败回调
- (void)didLoadNextOtherPostListFailed:(OtherPostServer *)server type:(NSString *)type errorCode:(NSInteger)code message:(NSString *)msg{
    [self.dataTableView loadMoreFinished:self.dataTableView];
    [JDStatusBarNotification showWithStatus:msg dismissAfter:1.0f];
}
#pragma mark - Table view data source
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    PostDetailViewController *postDetail = [[PostDetailViewController alloc]initWithNibName:@"PostDetailViewController" bundle:nil];
    postDetail.post = [[self allPostList] objectAtIndex:indexPath.row];
    [self.navigationController pushViewController:postDetail animated:YES];

}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [self allPostList].count;//实例中下载存储的帖子
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [SubPostBarCell postCellHeight:[[self allPostList] objectAtIndex:indexPath.row]];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //设置重用标识
    static NSString *CellIdentifier = @"PostBarCell";
    UITableViewCell *cell = (SubPostBarCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    //cell为空，初始化一个cell
    if (cell == nil){
        NSArray *nibArray = [[NSBundle mainBundle] loadNibNamed:@"SubPostBarCell" owner:self options:nil];
        cell = (SubPostBarCell *)[nibArray objectAtIndex:0];
        ((SubPostBarCell *)cell).delegate = self;
    }
    //如果帖子数组不为空，就初始化对应的帖子
    if ([self allPostList].count) {
        [((SubPostBarCell *)cell) configPostCellWithPost:[[self allPostList] objectAtIndex:indexPath.row]];
        [((SubPostBarCell *)cell).customerLabel setTitleColor:[UIColor brownColor] forState:UIControlStateNormal];
    }
    return cell;
}
#pragma mark UIScrollViewDelegate
//点击图片
- (void)didTapedSubPostBarCellImage:(NSString *)subImage
{
    PostImageViewController *postImageVC = [[PostImageViewController alloc] initWithNibName:@"PostImageViewController" bundle:nil];
    [postImageVC sePostImageURL:subImage];
    postImageVC.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [self presentViewController:postImageVC animated:YES completion:nil];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    //上滑隐藏工具栏，下滑显示工具栏
    if (scrollView.contentOffset.y-beginPoint.y>44) {
        [UIView animateWithDuration:0.7 animations:^{
            self.tabBarController.tabBar.alpha = 0.0;
        } completion:nil];
    }
    if (scrollView.contentOffset.y-beginPoint.y<-44){
        [UIView animateWithDuration:0.7 animations:^{
            self.tabBarController.tabBar.alpha = 1.0;
        } completion:nil];
    }
    [self.dataTableView scrollViewDidScroll:scrollView];
}

//用户手动滑动tableview时调用下面的方法,保存初始的触摸点的位置
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView;
{
    beginPoint = scrollView.contentOffset;
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (scrollView.contentOffset.y-beginPoint.y>0) {
        [UIView animateWithDuration:0.6 animations:^{
            self.tabBarController.tabBar.alpha = 0.0;
        } completion:nil];
    }else{
        [UIView animateWithDuration:0.6 animations:^{
            self.tabBarController.tabBar.alpha = 1.0;
        } completion:nil];
    }
    [self.dataTableView scrollViewDidEndDragging:scrollView];
}

#pragma mark TableViewRefreshDelegate & TableViewLoadMoreDelegate

//下拉触发刷新列表数据
- (void)refreshData:(TableView *)tableView
{
    THLog(@"------------刷新-------------");
    self.dataTableView.isLoading = YES;
    [self reloadPost:YES];
}
//上拉触发加载下一页数据
- (void)loadMoreData:(TableView *)tableView
{
    THLog(@"------------加载-------------");
    self.dataTableView.isLoading = YES;
    [self loadMore];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
