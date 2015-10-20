//
//  PostBarViewController.m
//  ECIGARFAN
//
//  Created by JIRUI on 14-4-9.
//  Copyright (c) 2014年 JIRUI. All rights reserved.
//
#import "PostBarViewController.h"
#import "PostMessageViewController.h"
#import "MyPostViewController.h"
#import "LoginViewController.h"
#import "SubPostViewController.h"
#import "UIImageView+WebCache.h"
#import "ModServer.h"
#import "Module.h"
@interface PostBarViewController () {
    //版块
    ModServer *modServer;
}

@property (nonatomic, strong) IBOutlet UITableView *tableView;
@property (strong, nonatomic) SubPostViewController *tabMainController;

@end

@implementation PostBarViewController
@synthesize tableView = _tableView;
@synthesize tabMainController = _tabMainController;

- (void)viewDidLoad{
    [super viewDidLoad];
    self.title=NSLocalizedString(@"Postbar", nil);
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.rowHeight = 90;
    self.tableView.allowsSelection = NO; // We essentially implement our own   12selection
    self.tableView.separatorInset = UIEdgeInsetsMake(0, 0, 0, 0); // Makes the horizontal row seperator stretch the entire length of the table view
    [self loadData];
    
}

- (void)viewWillAppear:(BOOL)animated{
    self.navigationController.navigationBarHidden=NO;
    [UIView animateWithDuration:0.5 animations:^{
        self.tabBarController.tabBar.alpha = 1.0;
    } completion:nil];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
}

- (void)didReceiveMemoryWarning{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark UITableViewDataSource
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 90;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self allModList].count;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //隐藏所有划开的cell
    for (id everyCell in _tableView.visibleCells) {
        [everyCell hideUtilityButtonsAnimated:NO];
    }
    Module *module = [[self allModList] objectAtIndex:indexPath.row];
    self.tabMainController = [[SubPostViewController alloc]init];
    self.tabMainController.modID = module.modID;//设置版块
    self.tabMainController.title = module.modTitle;
    [self.navigationController pushViewController:_tabMainController animated:YES];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"Cell";
    
    JRTableViewCell *cell = (JRTableViewCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (cell == nil) {
        NSMutableArray *leftUtilityButtons = [NSMutableArray new];
 //       NSMutableArray *rightUtilityButtons = [NSMutableArray new];
        [leftUtilityButtons addUtilityButtonWithColor:COLOR_MIDDLE_GRAY icon:[UIImage imageNamed:@"posting"]];
        [leftUtilityButtons addUtilityButtonWithColor:COLOR_MIDDLE_GRAY icon:[UIImage imageNamed:@"mypost"]];
//        [rightUtilityButtons addUtilityButtonWithColor:COLOR_LIGHT_BLUE_THEME icon:[UIImage imageNamed:@"mypost"]];
//        [rightUtilityButtons addUtilityButtonWithColor:COLOR_LIGHT_BLUE_THEME icon:[UIImage imageNamed:@"posting"]];
        
        cell = [[JRTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle
                                      reuseIdentifier:cellIdentifier
                                  containingTableView:_tableView // Used for row height and selection
                                   leftUtilityButtons:leftUtilityButtons
                                  rightUtilityButtons:nil];

        cell.textLabel.textColor=COLOR_LIGHT_BLUE_THEME;
        cell.detailTextLabel.textColor=COLOR_DARK_GRAY;
        cell.delegate = self;
    }
    Module *module = [[self allModList] objectAtIndex:indexPath.row];
    cell.textLabel.text = module.modTitle;//文本题
    cell.detailTextLabel.text = module.modContent;//内容
    cell.detailTextLabel.font = [UIFont fontWithName:@"Arial-BoldItalicMT" size:14];
    [cell.imageView setImageWithURL:[NSURL URLWithString:module.modImage] placeholderImage:[UIImage imageNamed:@"thumb_pic.png"]];//图片
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Set background color of cell here if you don't want white

}

#pragma mark - SWTableViewDelegate
//从左往右滑后点击
- (void)swippableTableViewCell:(JRTableViewCell *)cell didTriggerLeftUtilityButtonWithIndex:(NSInteger)index
{
        NSIndexPath *cellIndexPath = [self.tableView indexPathForCell:cell];
        Module *module = [[self allModList] objectAtIndex:cellIndexPath.row];
            if (!index) {//发帖界面
                [cell hideUtilityButtonsAnimated:YES];
                NSString *userSid = [S_USER_DEFAULTS stringForKey:API_LOGIN_SID];
                if (userSid) {//在登录的情况下
                    PostMessageViewController *postMessage = [[PostMessageViewController alloc]initWithNibName:@"PostMessageViewController" bundle:nil];
                    //设置版块
                    postMessage.modID = module.modID;
                    [self.navigationController pushViewController:postMessage animated:YES];
                }else{//在没有登录的情况下，要求登录
                    LoginViewController *login = [[LoginViewController alloc]init];
                    login.isFromPostbar=YES;
                    [self.navigationController pushViewController:login animated:YES];
                }
                
            } else {//我的帖子
                [cell hideUtilityButtonsAnimated:YES];
                NSString *userSid = [S_USER_DEFAULTS stringForKey:API_LOGIN_SID];
                if (userSid) {//在登录的情况下
                    MyPostViewController *myPost = [[MyPostViewController alloc]init];
                    [self.navigationController pushViewController:myPost animated:YES];
                }else{
                    LoginViewController *login = [[LoginViewController alloc]init];
                    login.isFromPostbar=YES;
                    [self.navigationController pushViewController:login animated:YES];
                }
            }
}

//从右往左滑后点击
- (void)swippableTableViewCell:(JRTableViewCell *)cell didTriggerRightUtilityButtonWithIndex:(NSInteger)index
{
    NSIndexPath *cellIndexPath = [self.tableView indexPathForCell:cell];
    Module *module = [[self allModList] objectAtIndex:cellIndexPath.row];
    if (index) {//发帖界面
        [cell hideUtilityButtonsAnimated:YES];
        NSString *userSid = [S_USER_DEFAULTS stringForKey:API_LOGIN_SID];
        if (userSid) {//在登录的情况下
            PostMessageViewController *postMessage = [[PostMessageViewController alloc]initWithNibName:@"PostMessageViewController" bundle:nil];
            //设置版块
            postMessage.modID = module.modID;
            [self.navigationController pushViewController:postMessage animated:YES];
        }
        else{
            LoginViewController *login = [[LoginViewController alloc]init];
            login.isFromPostbar=YES;
            [self.navigationController pushViewController:login animated:YES];
        }
    } else {//我的帖子界面
        [cell hideUtilityButtonsAnimated:YES];
        NSString *userSid = [S_USER_DEFAULTS stringForKey:API_LOGIN_SID];
        if (userSid) {//在登录的情况下
            MyPostViewController *myPost = [[MyPostViewController alloc]init];
            [self.navigationController pushViewController:myPost animated:YES];
        }
        else{
            LoginViewController *login = [[LoginViewController alloc]init];
            login.isFromPostbar=YES;
            [self.navigationController pushViewController:login animated:YES];
        }
    }
}

- (void)swippableTableViewCell:(JRTableViewCell *)cell scrollingToState:(SWCellState)state
{
    for (id everyCell in _tableView.visibleCells) {
        [everyCell hideUtilityButtonsAnimated:YES];
    }
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
        return YES;
}
//数据源
- (NSMutableArray *)allModList
{
    return modServer.modList;//单例的数组
}
//初始化版块单例
- (void)loadData
{
    //完成更新，显示提示信息
    modServer = [ModServer sharedInstance];
    [modServer loadCacheModListWithType:NULL delegate:(id)self];//载入数据
}
//刷新数据
- (void)reloadMod
{
    [modServer reloadModListWithType:NULL delegate:(id)self];//实体请求数据
}
#pragma ModServerDelegate
//加载本地数据，再去服务器拉一次
- (void)didLoadCacheModListFinished:(ModServer*)server type:(NSString *)type count:(NSInteger)count
{
    [self.tableView reloadData];
    //从本地获取数据后，去服务器拉一次新的数据
    [self reloadMod];
}

//刷新数据成功后回调
- (void)didReloadModListFinished:(ModServer *)server type:(NSString *)type updateCount:(NSInteger)count
{
    [self.tableView reloadData];
}
//刷新数据失败后回调
- (void)didReloadModListFailed:(ModServer *)server type:(NSString *)type errorCode:(NSInteger)code message:(NSString *)msg
{
    [JDStatusBarNotification showWithStatus:msg dismissAfter:1.0f];
}
@end
