//
//  NewsController.m
//  ECIGARFAN
//
//  Created by JIRUI on 14-6-12.
//  Copyright (c) 2014年 JIRUI. All rights reserved.
//

#import "NewsViewController.h"
#import "NewsModel.h"
#import "PostDetailViewController.h"
#import "Post.h"
#import "PostImageViewController.h"
#import "MyPostViewController.h"
#import "OtherPostViewController.h"
#import "NewsServer.h"
#import "TableView.h"
#import "RefreshHeaderView.h"
#import "UIView+Frame.h"
#import "UIView+Nib.h"
#import "MyPostServer.h"
#import "SubPostBarCell.h"
@interface NewsViewController ()<UITableViewDataSource,UITableViewDelegate,SubPostBarCellDelegate,TableViewLoadMoreDelegate,TableViewRefreshDelegate,UIScrollViewDelegate>
{
    NewsServer *newsServer;//贴吧版块实例，存所有帖子
    BOOL showTipDidReload;
}
@property (nonatomic,strong) TableView *dataTableView;

@end

@implementation NewsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    //信息回复框
    CGRect frame = toolBar.frame;
    frame.origin.y = self.view.frame.size.height - 44;
    toolBar.frame = frame;
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.g
    textView.editable = YES;
    //获取基本信息
    [self loadData];
    // Do any additional setup after loading the view.
    self.view = [UIView n_loadFromNibName:@"NewsController"];
    self.view.backgroundColor = COLOR_BACKGROUND;
    
    self.dataTableView = (TableView *)[self.view viewWithTag:1000];
    toolBar = (UIView *)[self.view viewWithTag:1001];
    keyboardButton = (UIButton *)[self.view viewWithTag:1002];
    textView = (UITextView *)[self.view viewWithTag:1003];
    sendButton = (UIButton *)[self.view viewWithTag:1004];
//    self.dataTableView.key = strKey;
    self.dataTableView.delegate = (id)self;
    self.dataTableView.dataSource = (id)self;
//    self.dataTableView.refreshDelegate = self;
//    self.dataTableView.loadMoreDelegate = self;
//    self.dataTableView.refreshView = [[RefreshHeaderView alloc] initWithFrame:CGRectMake(0, self.dataTableView.top, self.dataTableView.width, 0)];
    
    //设置背景，去掉表格的中间线条·
    UIView *view =[ [UIView alloc]init];
    view.backgroundColor = [UIColor clearColor];
    [self.dataTableView setTableFooterView:view];
    [self initViews];
}
- (void)refreshData:(TableView *)tableView{}
- (void)loadMoreData:(TableView *)tableView{}
//下拉刷新
- (void)reloadPost:(BOOL)showed
{
    showTipDidReload = showed;
    [newsServer reloadNewsListWithType:NULL delegate:(id)self];//实体请求数据
}
//数组
- (NSMutableArray *)allPostList
{
    return  newsServer.newsList;
}
//初始始化请求
- (void)loadData{
    //完成更新，显示提示信息
    newsServer = [NewsServer sharedInstance];
    [newsServer loadCacheNewsListWithType:NULL delegate:(id)self];//载入数据
}
- (void)newsReply{
    if (toolBar.hidden==NO) {//隐藏回复栏
        toolBar.hidden = YES;
        [textView resignFirstResponder];
    }else{
        toolBar.hidden = NO;
        if (![templyMessage isEqualToString:@""]) {
            textView.text = templyMessage;//将编辑中而保存的信息还原
        }
        [textView becomeFirstResponder];
    }
}
//点击其他用户头像查看该用户的帖子
- (void)postsOfElseMan:(NSInteger)sender{
    OtherPostViewController *otherPost = [[OtherPostViewController alloc]init];
    otherPost.otherID = sender;//获取其他用户的ID
    [self.navigationController pushViewController:otherPost animated:YES];
}
#pragma mark - Scroll
- (void)myPost
{
    MyPostViewController *myPost = [[MyPostViewController alloc]init];
    [self.navigationController pushViewController:myPost animated:YES];
}
//点击表情按钮
- (IBAction)faceBoardClick:(id)sender {
    
    isButtonClicked = YES;
    
    if ( isKeyboardShowing ) {
        
        [textView resignFirstResponder];
    }
    else {
        
        if ( isFirstShowKeyboard ) {
            
            isFirstShowKeyboard = NO;
            
            isSystemBoardShow = NO;
        }
        
        if ( !isSystemBoardShow ) {
            
            textView.inputView = _emojiView;
        }
        
        [textView becomeFirstResponder];
    }
}
//点击发送
- (IBAction)faceBoardHide:(id)sender {
    
    textView.text = NULL;
    [self textViewDidChange:textView];
    [textView resignFirstResponder];
    isFirstShowKeyboard = YES;
    
    isButtonClicked = NO;
    
    textView.inputView = nil;
    
    [keyboardButton setImage:[UIImage imageNamed:@"board_emoji"]
                    forState:UIControlStateNormal];
    //将临时信息清空
    [templyMessage setString:@""];
    [toolBar setHidden:YES];
}

#pragma Server
//加载本地数据，再去服务器拉一次
- (void)didLoadCacheNewsListFinished:(NewsServer*)server type:(NSString *)type count:(NSInteger)count{
    [self.dataTableView reloadData];
    //从本地获取数据后，去服务器拉一次新的数据
    [self reloadPost:NO];
}

//刷新数据成功后回调
- (void)didReloadNewsListFinished:(NewsServer *)server type:(NSString *)type updateCount:(NSInteger)count{
//    [self.dataTableView refreshFinished:self.dataTableView];
    [self.dataTableView reloadData];
}
//刷新数据失败后回调
- (void)didReloadNewsListFailed:(NewsServer *)server type:(NSString *)type errorCode:(NSInteger)code message:(NSString *)msg{
    [self.dataTableView refreshFinished:self.dataTableView];
    [JDStatusBarNotification showWithStatus:msg dismissAfter:1.0f];
    
}
#pragma mark - Table view data source
//有多少分区
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
//每个区有多少单元
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self allPostList].count;
}
//自定义单元格的高度
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [NewsTableViewCell getCellHeight:[[self allPostList] objectAtIndex:indexPath.row]];
}
//重构单元格
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = nil;
    static NSString *CellIdentifier = @"NewsCell";
    cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell) {
        NSArray *nibArray = [[NSBundle mainBundle] loadNibNamed:@"NewsTableViewCell" owner:self options:nil] ;
        cell = (NewsTableViewCell *)[nibArray objectAtIndex:0];
    }
    if ([[self allPostList] count]) {
        [(NewsTableViewCell *)cell configNewsCellWithNews:[[self allPostList] objectAtIndex:indexPath.row]];
        ((NewsTableViewCell *)cell).delegate = (id)self;
    }
    return cell;
}
//点击表格
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [textView resignFirstResponder];
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    NewsModel *news = (NewsModel *)[[self allPostList] objectAtIndex:indexPath.row];
    [self initPost:news.modID Sub:news.subID];//网络请求消息中的帖子内容
}
- (void)initPost:(NSInteger)mod Sub:(NSInteger)sub
{
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params setObject:@(mod) forKey:@"mod_id"];//
    [params setObject:@(sub) forKey:@"sub_id"];//
    [[JRRequestManager shareInstance]
     startRequestWithCmd:API_CMD_COMMENT_LIST
     method:JRRequestMethodPOST
     params:params
     key:API_CMD_COMMENT_LIST
     failed:^(JRRequest *request,NSError *error){
     }
     finished:^(JRRequest *request,JRResponse *response){
         if (!response.code) {
             [JDStatusBarNotification showWithStatus:response.msg dismissAfter:2.0];
         }
         else{
             NSMutableArray *array = [response.data valueForKey:@"list"];
             [self performSelector:@selector(pushPostDetail:) withObject:array];
         }
     }];
}
//请求详细帖子后，推出视图
- (void)pushPostDetail:(NSMutableArray *)arr
{
    if (arr.count) {
        PostDetailViewController *postDetail = [[PostDetailViewController alloc]initWithNibName:@"PostDetailViewController" bundle:nil];
        postDetail.post = (Post *)[arr lastObject];
        [self.navigationController pushViewController:postDetail animated:YES];
    }
}

//点击图片
- (void)didTapedSubPostBarCellImage:(NSString *)subImage
{
    PostImageViewController *postImageVC = [[PostImageViewController alloc] initWithNibName:@"PostImageViewController" bundle:nil];
    [postImageVC sePostImageURL:subImage];
    postImageVC.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [self presentViewController:postImageVC animated:YES completion:nil];
}

//#pragma mark UIScrollViewDelegate
//- (void)scrollViewDidScroll:(UIScrollView *)scrollView
//{
//    [self.dataTableView scrollViewDidScroll:scrollView];
//}
//- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
//{
//    [self.dataTableView scrollViewDidEndDragging:scrollView];
//}
//#pragma mark TableViewRefreshDelegate & TableViewLoadMoreDelegate
////下拉触发刷新列表数据
//- (void)refreshData:(TableView *)tableView
//{
//    THLog(@"------------刷新-------------");
//    self.dataTableView.isLoading = YES;
//    [self reloadPost:YES];
//}
//初始化背景
- (void)initViews
{
    UIBarButtonItem *myPost = [[UIBarButtonItem alloc]initWithTitle:@"post" style:UIBarButtonItemStylePlain target:self action:@selector(myPost)];
    [myPost setImage:[UIImage imageNamed:@"ico_people.png"]];
    [self.navigationItem setRightBarButtonItem:myPost];
    //去掉表格的中间线条
    UIView *view =[ [UIView alloc]init];
    view.backgroundColor = [UIColor clearColor];
    [self.dataTableView setTableFooterView:view];
    
    // 隐藏信息回复框
    toolBar.hidden = YES;
    //初始化表情
    _emojiView = [[EmojiView alloc] initWithFrame:CGRectMake(0, [UIScreen mainScreen].bounds.size.height, 320, 216)];
    _emojiView.delegate = (id)self;
    [self.view addSubview:_emojiView];
    textView.delegate = (id)self;
    [textView.layer setCornerRadius:6];
    [textView.layer setMasksToBounds:YES];
    isFirstShowKeyboard = YES;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardDidHide:)
                                                 name:UIKeyboardDidHideNotification
                                               object:nil];
    
}
#pragma mark keyBoard
//文本框输入表情和文本
- (void)didTouchEmojiView:(EmojiView*)emojiView touchedEmoji:(NSString*)str
{
    textView.text = [NSString stringWithFormat:@"%@%@", textView.text, str];
    //储存临时信息
    [templyMessage setString:textView.text];
}
//点击表情页的删除按钮触发的事件
- (void)selectedDel:(NSArray *)_symbolArr
{
    NSString *newStr;
    if (textView.text.length>0) {
        if ([_symbolArr containsObject:[textView.text substringFromIndex:textView.text.length-2]]) {
            newStr=[textView.text substringToIndex:textView.text.length-2];
        }else{
            newStr=[textView.text substringToIndex:textView.text.length-1];
        }
        textView.text=newStr;
    }
    //储存临时信息
    [templyMessage setString:textView.text];
}

//注册的通知事件
- (void)keyboardWillShow:(NSNotification *)notification
{
    
    isKeyboardShowing = YES;
    
    NSDictionary *userInfo = [notification userInfo];
    NSValue *aValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    
    CGRect keyboardRect = [aValue CGRectValue];
    keyboardRect = [self.view convertRect:keyboardRect fromView:nil];
    
    NSValue *animationDurationValue = [userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSTimeInterval animationDuration;
    [animationDurationValue getValue:&animationDuration];
    
    [UIView animateWithDuration:animationDuration
                     animations:^{
                         CGRect frame = toolBar.frame;
                         frame.origin.y += keyboardHeight;
                         frame.origin.y -= keyboardRect.size.height;
                         toolBar.frame = frame;
                         keyboardHeight = keyboardRect.size.height;
                     }];
    
    if ( isFirstShowKeyboard ) {
        
        isFirstShowKeyboard = NO;
        
        isSystemBoardShow = !isButtonClicked;
    }
    
    if ( isSystemBoardShow ) {
        
        [keyboardButton setImage:[UIImage imageNamed:@"board_emoji"]
                        forState:UIControlStateNormal];
    }
    else {
        
        [keyboardButton setImage:[UIImage imageNamed:@"board_system"]
                        forState:UIControlStateNormal];
    }
}

- (void)keyboardWillHide:(NSNotification *)notification
{
    
    NSDictionary *userInfo = [notification userInfo];
    
    NSValue *animationDurationValue = [userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSTimeInterval animationDuration;
    [animationDurationValue getValue:&animationDuration];
    
    [UIView animateWithDuration:animationDuration
                     animations:^{
                         CGRect frame = toolBar.frame;
                         frame.origin.y += keyboardHeight;
                         toolBar.frame = frame;
                         keyboardHeight = 0;
                     }];
}

- (void)keyboardDidHide:(NSNotification *)notification
{
    
    isKeyboardShowing = NO;
    
    if ( isButtonClicked ) {
        
        isButtonClicked = NO;
        
        if ( ![textView.inputView isEqual:_emojiView] ) {
            
            isSystemBoardShow = NO;
            
            textView.inputView = _emojiView;
        }
        else {
            
            isSystemBoardShow = YES;
            
            textView.inputView = nil;
        }
        
        [textView becomeFirstResponder];
    }
    [self textViewDidChange:textView];
}

- (void)textViewDidChange:(UITextView *)_textView
{
    //取得textview的contentsize
    CGSize size = textView.contentSize;
    size.height -= 2;
    if ( size.height >= 68 ) {
        
        size.height = 68;
    }
    else if ( size.height <= 32 ) {
        
        size.height = 32;
    }
    
    if ( size.height != textView.frame.size.height ) {
        
        CGFloat span = size.height - textView.frame.size.height;
        
        CGRect frame = toolBar.frame;
        frame.origin.y -= span;
        frame.size.height += span;
        toolBar.frame = frame;
        //
        CGFloat centerY = frame.size.height / 2;
        
        frame = textView.frame;
        frame.size = size;
        textView.frame = frame;
        
        CGPoint center = textView.center;
        center.y = centerY;
        textView.center = center;
        
        center = keyboardButton.center;
        center.y = centerY;
        keyboardButton.center = center;
        
        center = sendButton.center;
        center.y = centerY;
        sendButton.center = center;
    }
    //储存临时信息
    [templyMessage setString:textView.text];
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
