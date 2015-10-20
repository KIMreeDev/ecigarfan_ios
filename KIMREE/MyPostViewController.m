//
//  MyPostViewController.m
//  ECIGARFAN
//
//  Created by JIRUI on 14-6-6.
//  Copyright (c) 2014年 JIRUI. All rights reserved.
//

#import "MyPostViewController.h"
#import "SubPostBarCell.h"
#import "PostDetailViewController.h"
#import "PostImageViewController.h"
#import "TableView.h"
#import "UIView+Frame.h"
#import "UIView+Nib.h"
#import "MyPostServer.h"
@interface MyPostViewController ()<UITableViewDataSource,UITableViewDelegate,SubPostBarCellDelegate,TableViewLoadMoreDelegate,TableViewRefreshDelegate,UIScrollViewDelegate>
{
    MyPostServer *myPostServer;//贴吧版块实例，存所有帖子
    BOOL showTipDidReload;
    Post *post; //本地的信息
    NSString *userSid;
}
@property (nonatomic,strong) TableView *dataTableView;

@end

@implementation MyPostViewController

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
    // Do any additional setup after loading the view.g
    self.title = NSLocalizedString(@"Me", nil);
    //获取基本信息
    userSid = [S_USER_DEFAULTS stringForKey:API_LOGIN_SID];
    NSDictionary *dic=[[LocalStroge sharedInstance] getObjectAtKey:F_USER_INFORMATION filePath:NSDocumentDirectory];
    post = [[Post alloc]init];
    post.customerID = [[dic objectForKey:@"customer_id"]integerValue];
    [self loadData];
    // Do any additional setup after loading the view.
    self.view = [UIView n_loadFromNibName:@"SubPostListView"];
    self.view.backgroundColor = COLOR_BACKGROUND;
    //数据列表
    self.dataTableView = (TableView *)[self.view viewWithTag:1000];
    self.dataTableView.key = [NSString stringWithFormat:@"MyPostList%@",[AppHelper sharedInstance].uid];
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
- (void)backButtonClicked
{
    [self.navigationController popToViewController:[self.navigationController.viewControllers objectAtIndex:1] animated:YES];
}
//下拉刷新
- (void)reloadPost:(BOOL)showed
{
    showTipDidReload = showed;
    [myPostServer reloadPostListWithType:post delegate:(id)self];//实体请求数据
}
//加载更多
- (void)loadMore{
    [myPostServer loadNextPostListWithType:post delegate:(id)self];//加载更多
}
//数组
- (NSMutableArray *)allPostList
{
    return  myPostServer.allPostList                                                                                                                                                                                                          ;
}
- (void)loadData{
    //完成更新，显示提示信息
    myPostServer = [MyPostServer sharedInstance];
    [myPostServer loadCachePostListWithType:post delegate:(id)self];//载入数据
}
#pragma mark - Scroll
//加载本地数据，再去服务器拉一次
- (void)didLoadCacheMyPostListFinished:(MyPostServer*)server type:(NSString *)type count:(NSInteger)count{
    [self.dataTableView reloadData];
    
    if (count >= C_API_LIST_NUM) {
        self.dataTableView.loadMoreView = [[LoadFooterView alloc] initWithFrame:CGRectMake(0, 0, self.dataTableView.width-60, 60) textColor:[UIColor grayColor]];
    }
    else{
        self.dataTableView.loadMoreView = nil;
    }
    //从本地获取数据后，去服务器拉一次新的数据
    [self reloadPost:NO];
}

//刷新数据成功后回调
- (void)didReloadMyPostListFinished:(MyPostServer *)server type:(NSString *)type updateCount:(NSInteger)count{
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
- (void)didReloadMyPostListFailed:(MyPostServer *)server type:(NSString *)type errorCode:(NSInteger)code message:(NSString *)msg{
    [self.dataTableView refreshFinished:self.dataTableView];
    [JDStatusBarNotification showWithStatus:msg dismissAfter:1.0f];
    
}
//加载成功回调
- (void)didLoadNextMyPostListFinished:(MyPostServer *)server type:(NSString *)type isLoadAll:(BOOL)isLoadAll{
    [self.dataTableView loadMoreFinished:self.dataTableView];
    [self.dataTableView reloadData];
    if (isLoadAll) {
        [self.dataTableView loadAllData];
    }
}
//加载失败回调
- (void)didLoadNextMyPostListFailed:(MyPostServer *)server type:(NSString *)type errorCode:(NSInteger)code message:(NSString *)msg{
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
    }
    //如果帖子数组不为空，就初始化对应的帖子
    if ([self allPostList].count) {
        ((SubPostBarCell *)cell).needDeletedPostID = indexPath.row;
        [((SubPostBarCell *)cell).deletePost setTitle:NSLocalizedString(@"Delete", nil) forState:UIControlStateNormal];
        ((SubPostBarCell *)cell).deletePost.hidden = NO;
        ((SubPostBarCell *)cell).delegate = self;
        [((SubPostBarCell *)cell) configPostCellWithPost:[[self allPostList] objectAtIndex:indexPath.row]];
        [((SubPostBarCell *)cell).customerLabel setTitleColor:[UIColor brownColor] forState:UIControlStateNormal];
    }
    return cell;
}
//点击图片
- (void)didTapedSubPostBarCellImage:(NSString *)subImage
{
    PostImageViewController *postImageVC = [[PostImageViewController alloc] initWithNibName:@"PostImageViewController" bundle:nil];
    [postImageVC sePostImageURL:subImage];
    postImageVC.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [self presentViewController:postImageVC animated:YES completion:nil];
}

#pragma mark UIScrollViewDelegate
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
#pragma mark UIScrollViewDelegate
//用户手动滑动tableview时调用下面的方法,保存初始的触摸点的位置
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView;
{
    beginPoint = scrollView.contentOffset;
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    //上滑隐藏工具栏，下滑显示工具栏
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
#pragma subPostBarCellDelegate
- (void)deleteMyPost:(NSInteger)needDeletePost
{
    Post *delPost = [[self allPostList] objectAtIndex:needDeletePost];
    self.view.userInteractionEnabled=NO;//界面
    [SVProgressHUD showWithStatus:NSLocalizedString(@"Submitting...", nil)];
    [[MyPostServer sharedInstance]
     deletePost:delPost
     failed:^(NSInteger code,NSString *msg){
         [SVProgressHUD dismiss];
         self.view.userInteractionEnabled = YES;//界面
         [JDStatusBarNotification showWithStatus:msg dismissAfter:2.0];
     }
     finished:^(JRRequest *request,JRResponse *response){
        [SVProgressHUD dismiss];
         if (!response.code) {
             [JDStatusBarNotification showWithStatus:response.msg dismissAfter:2.0];
         }
         else{
             NSIndexPath *indexPath = [NSIndexPath indexPathForRow:needDeletePost inSection:0];
             [self.dataTableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationTop];
             [self performSelector:@selector(quikRelod) withObject:nil afterDelay:0.5];
             //如果删除后数据为空，那么试着加载下一页
             if ([self allPostList].count == 0) {
                 [self loadMore];
             }
             [JDStatusBarNotification showWithStatus:[NSString stringWithFormat:NSLocalizedString(@"Deleted successfully", nil)] dismissAfter:1.0];
             //加入通知,发帖后主界面要进行刷新
             [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_POST_CHANGED object:nil];
         }
        self.view.userInteractionEnabled = YES;//界面
     }];
}

- (void)quikRelod
{
    [self.dataTableView reloadData];
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
