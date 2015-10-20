//
//  SubPostViewController.m
//  ECIGARFAN
//
//  Created by JIRUI on 14-6-5.
//  Copyright (c) 2014年 JIRUI. All rights reserved.
//

#import "SubPostViewController.h"
#import "PostDetailViewController.h"
#import "SubPostBarCell.h"
#import "MyPostViewController.h"
#import "AllPostServer.h"
#import "PostImageViewController.h"
#import "PostMessageViewController.h"
#import "OtherPostViewController.h"
#import "NewsViewController.h"
#import "TableView.h"
#import "UIView+Frame.h"
#import "UIView+Nib.h"
#import "MyPostServer.h"
#import "LoginViewController.h"



@interface SubPostViewController ()<UITableViewDataSource,UITableViewDelegate,SubPostBarCellDelegate,TableViewLoadMoreDelegate,TableViewRefreshDelegate,UIScrollViewDelegate>
{
    AllPostServer *allPostServer;//贴吧版块实例，存所有帖子
    BOOL showTipDidReload;
}
@property (nonatomic,strong) TableView *dataTableView;
@property (nonatomic,strong) MyPostViewController *myPost;
@property (nonatomic,strong) OtherPostViewController *otherPost;
@end

@implementation SubPostViewController
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [SVProgressHUD dismiss];
    self.view.userInteractionEnabled = YES;//界面
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceivePostChanged:) name:NOTIFICATION_POST_CHANGED object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceivePostChanged:) name:NOTIFICATION_USER_LOGIN object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceivePostChanged:) name:NOTIFICATION_USER_LOGOUT object:nil];
    // Do any additional setup after loading the view.
    [self loadData];
    self.view = [UIView n_loadFromNibName:@"SubPostListView"];
    self.view.backgroundColor = COLOR_BACKGROUND;

    //数据列表
    self.dataTableView = (TableView *)[self.view viewWithTag:1000];
    self.dataTableView.key = [NSString stringWithFormat:@"SubPostList%@",[AppHelper sharedInstance].uid];
    self.dataTableView.delegate = (id)self;
    self.dataTableView.dataSource = (id)self;
    self.dataTableView.refreshDelegate = self;
    self.dataTableView.loadMoreDelegate = self;
    self.dataTableView.refreshView = [[RefreshHeaderView alloc] initWithFrame:CGRectMake(0, self.dataTableView.top, self.dataTableView.width, 0)];
    
    //设置背景，去掉表格的中间线条·
    UIView *view =[ [UIView alloc]init];
    view.backgroundColor = [UIColor clearColor];
    [self.dataTableView setTableFooterView:view];
    //导航栏右边第一个按钮，设置图片
    UIBarButtonItem *postButton = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemCompose target:self action:@selector(clickPostButton)];
    //导航栏右边第二个按钮（消息）
    UIBarButtonItem *newsButton = [[UIBarButtonItem alloc] initWithTitle:@" "
                                                                   style:UIBarButtonItemStylePlain
                                                                  target:self
                                                                  action:@selector(clickNewsButton)];
    [newsButton setImage:[UIImage imageNamed:@"mypostNavi"]];
    NSArray *rightArr = [NSArray arrayWithObjects:postButton ,newsButton, nil];
    [self.navigationItem setRightBarButtonItems:rightArr animated:YES];

}
//收到帖子变动的通知
- (void)didReceivePostChanged:(NSNotification *)notification
{
    [self reloadPost:NO];
}

//在所有帖子界面，让自己的帖子显示删除
- (void)deleteMyPost:(NSInteger)needDeletePost
{
    NSString *userSid = [S_USER_DEFAULTS stringForKey:API_LOGIN_SID];
    if (userSid) {
        [SVProgressHUD showWithStatus:@"Submitting..."];
        Post *delPost = [[self allPostList] objectAtIndex:needDeletePost];
        self.view.userInteractionEnabled=NO;//界面
        [[MyPostServer sharedInstance]
         deletePost:delPost
         failed:^(NSInteger code,NSString *msg){
             [SVProgressHUD dismiss];
             self.view.userInteractionEnabled = YES;//界面
            [JDStatusBarNotification showWithStatus:msg dismissAfter:2.0];
             [self.dataTableView reloadData];
         }
         finished:^(JRRequest *request,JRResponse *response){
            [SVProgressHUD dismiss];
             if (!response.code) {
                 [self.dataTableView reloadData];
                [JDStatusBarNotification showWithStatus:response.msg dismissAfter:1.0];
             }
             else{
                [self reloadPost:NO];
//                NSIndexPath *indexPath = [NSIndexPath indexPathForRow:needDeletePost inSection:0];
//                [self.dataTableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationTop];
                 //如果删除后数据为空，那么试着加载下一页
                 if ([self allPostList].count == 0) {
                     [self loadMore];
                 }
                [JDStatusBarNotification showWithStatus:[NSString stringWithFormat:NSLocalizedString(@"Deleted successfully", nil)] dismissAfter:1.0];
             }
            self.view.userInteractionEnabled = YES;//界面
         }];
    }
}
////刷新
//- (void)quikRelod
//{
//    [self.dataTableView reloadData];
//    NSLog(@"本地帖子数： %i ", [self allPostList].count);
//}
//点击用户名触发
- (void)postsOfElse:(NSInteger)selectedPost
{
    NSString *userSid = [S_USER_DEFAULTS stringForKey:API_LOGIN_SID];
    if (userSid) {
        NSDictionary *dic=[[LocalStroge sharedInstance] getObjectAtKey:F_USER_INFORMATION filePath:NSDocumentDirectory];
        NSInteger customerID = [[dic objectForKey:@"customer_id"]integerValue];
        if (customerID == selectedPost) {
            _myPost = nil;
            _myPost = [[MyPostViewController alloc]init];
            [self.navigationController pushViewController:_myPost animated:YES];
            return;
        }
    }
    _otherPost = nil;
    _otherPost = [[OtherPostViewController alloc]init];
    _otherPost.otherID = selectedPost;//获取其他用户的ID
    [self.navigationController pushViewController:_otherPost animated:YES];
}
//进入消息
-(void)clickNewsButton{
    NSString *userSid = [S_USER_DEFAULTS stringForKey:API_LOGIN_SID];
    if (userSid) {//在登录的情况下
//        NewsViewController *news = [[NewsViewController alloc]init];
//        [self.navigationController pushViewController:news animated:YES];
        MyPostViewController *myPost = [[MyPostViewController alloc]init];
        [self.navigationController pushViewController:myPost animated:YES];
    }else{
        LoginViewController *loginVC = [[LoginViewController alloc]init];
        loginVC.isFromPostbar=YES;
        [self.navigationController pushViewController:loginVC animated:YES];
    }
}

//进入发帖
-(void)clickPostButton{
    NSString *userSid = [S_USER_DEFAULTS stringForKey:API_LOGIN_SID];
    if (userSid) {//在登录的情况下
        PostMessageViewController *postMessage = [[PostMessageViewController alloc]initWithNibName:@"PostMessageViewController" bundle:nil];
        //设置版块
        postMessage.modID = self.modID;
        [self.navigationController pushViewController:postMessage animated:YES];
    }else{//在没有登录的情况下，要求登录
        LoginViewController *loginVC = [[LoginViewController alloc]init];
        loginVC.isFromPostbar=YES;
        [self.navigationController pushViewController:loginVC animated:YES];
    }
}
//下拉刷新
- (void)reloadPost:(BOOL)showed
{
    showTipDidReload = showed;
    [allPostServer reloadAllPostListWithType:self.modID delegate:(id)self];//实体请求数据
}
//加载更多
- (void)loadMore{
    [allPostServer loadNextPostListWithType:self.modID delegate:(id)self];//加载更多
}
//数组
- (NSMutableArray *)allPostList
{
    if (1==self.modID) {
        return allPostServer.allPostListMod1;
    }
    else if (2==self.modID){
        return allPostServer.allPostListMod2;
    }
    else if (3==self.modID){
        return allPostServer.allPostListMod3;
    }
    else{
        return allPostServer.allPostListMod4;
    }
}

- (void)loadData{
    //完成更新，显示提示信息
    allPostServer = [AllPostServer sharedInstance];
    [allPostServer loadCachePostListWithType:self.modID delegate:(id)self];//载入数据
}
#pragma mark - Scroll
//加载本地数据，再去服务器拉一次
- (void)didLoadCachePostListFinished:(AllPostServer *)server type:(NSInteger)type count:(NSInteger)count{
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
- (void)didReloadAllPostListFinished:(AllPostServer *)server type:(NSInteger)type updateCount:(NSInteger)count{
    [self.dataTableView refreshFinished:self.dataTableView];
    [self.dataTableView reloadData];
    if (showTipDidReload) {
        if (count) {//提示更新数量
            if (count==1) {
                [JDStatusBarNotification showWithStatus:[NSString stringWithFormat:@"%ld post has updated",(long)count] dismissAfter:1.0f];
            }
            if (count>=2) {
                [JDStatusBarNotification showWithStatus:[NSString stringWithFormat:@"%ld posts have updated",(long)count] dismissAfter:1.0f];
            }
        }
    }
    NSInteger rows = [self allPostList].count;
    if (rows >= C_API_LIST_NUM) {
        self.dataTableView.loadMoreView = [[LoadFooterView alloc] initWithFrame:CGRectMake(0, 0, self.dataTableView.width-60, 60) textColor:[UIColor grayColor]];
    }
    else{
        self.dataTableView.loadMoreView = nil;
    }
    
}
//刷新数据失败后回调
- (void)didReloadAllPostListFailed:(AllPostServer *)server type:(NSInteger)type errorCode:(NSInteger)code message:(NSString *)msg{
    [self.dataTableView refreshFinished:self.dataTableView];
    [JDStatusBarNotification showWithStatus:msg dismissAfter:1.0f];
    
}
//加载成功回调
- (void)didLoadNextAllPostListFinished:(AllPostServer *)server type:(NSInteger)type isLoadAll:(BOOL)isLoadAll{
    [self.dataTableView loadMoreFinished:self.dataTableView];
    [self.dataTableView reloadData];
    if (isLoadAll) {
        [self.dataTableView loadAllData];
    }
}
//加载失败回调
- (void)didLoadNextAllPostListFailed:(AllPostServer *)server type:(NSInteger)type errorCode:(NSInteger)code message:(NSString *)msg{
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
        if (!((indexPath.row)>=[self allPostList].count)) {
            Post *enumPost = [[self allPostList] objectAtIndex:indexPath.row];
            if (enumPost) {
                ((SubPostBarCell *)cell).deletePost.hidden = YES;
                [((SubPostBarCell *)cell).deletePost setFrame:CGRectMake(294, 8, 14, 14)];
                ((SubPostBarCell *)cell).needDeletedPostID = indexPath.row;//记录选择项
                ((SubPostBarCell *)cell).subpostDel.hidden = YES;
                NSString *userSid = [S_USER_DEFAULTS stringForKey:API_LOGIN_SID];//是否登录
                NSDictionary *dic=[[LocalStroge sharedInstance] getObjectAtKey:F_USER_INFORMATION filePath:NSDocumentDirectory];
                if (userSid) {
                    NSInteger customerID = [[dic objectForKey:@"customer_id"]integerValue];//提取本地用户
                    if (customerID==enumPost.customerID||[[dic objectForKey:@"customer_name"] isEqualToString:@"Administrator"]) {
                        //自己的帖子就显示删除
//                        [((SubPostBarCell *)cell).subpostDel setBackgroundImage:[UIImage imageNamed:@"delet"] forState:UIControlStateNormal];
                        [((SubPostBarCell *)cell).subpostDel setTitle:NSLocalizedString(@"Delete", nil) forState:UIControlStateNormal];
                        ((SubPostBarCell *)cell).subpostDel.hidden = NO;
                    }
                }
                ((SubPostBarCell *)cell).delegate = self;
                [((SubPostBarCell *)cell) configPostCellWithPost:enumPost];
            }
        }
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
//用户手动滑动tableview时调用下面的方法,保存初始的触摸点的位置
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView;
{
    beginPoint = scrollView.contentOffset;
}
//当tableview 停止滑动时会调用该代理方法,在此判断,tableview是向上还是向下滑动,进行相应设置
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
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    [self.dataTableView scrollViewDidEndDragging:scrollView];
}
#pragma mark THTableViewRefreshDelegate & THTableViewLoadMoreDelegate
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
