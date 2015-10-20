//
//  CommentAddViewController.m
//  ECIGARFAN
//
//  Created by JIRUI on 14-7-8.
//  Copyright (c) 2014年 JIRUI. All rights reserved.
//

#import "CommentAddViewController.h"
#import "EmojiView.h"
#import "MyPostViewController.h"
#import "OtherPostViewController.h"
#import "LoginViewController.h"

@interface CommentAddViewController ()<UITableViewDataSource,UITableViewDelegate,UIScrollViewDelegate,UITextViewDelegate,EmojiViewDelegate>
{
    BOOL isFirstShowKeyboard;
    BOOL isButtonClicked;
    BOOL isKeyboardShowing;
    BOOL isSystemBoardShow;
    NSInteger _currentCommentPage;//评论页
    NSInteger sec;//分区
    NSInteger row;//行
    NSInteger repID;
    NSInteger customerID;
    EmojiView *_emojiView;
    CGFloat keyboardHeight;
    //toolview
    IBOutlet UIView *toolBar;
    //文本域
    IBOutlet UITextView *textView;
    //表情
    IBOutlet UIButton *keyboardButton;
    //发送
    IBOutlet UIButton *sendButton;
    //追评数组
    NSMutableArray *comAddArr;
    //临时信息
    NSMutableString *templyMessage;
    
}
@property (nonatomic) BOOL loading;
@end

@implementation CommentAddViewController

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
    [[self navigationController] setNavigationBarHidden:YES animated:YES];
    CGRect rect = _tableView.frame;
    //初始化表格的坐标
    rect.origin.y = 0;
    rect.size.height = self.view.frame.size.height;
    _tableView.frame = rect;
    [self initializeDissView];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title=NSLocalizedString(@"more reply", nil);
    // Do any additional setup after loading the view from its nib.
    _loading = NO;
    [_dissButton setTitle:NSLocalizedString(@"Pack up reply all", nil) forState:UIControlStateNormal];
    [self.view setBackgroundColor:COLOR_BACKGROUND];
    //临时消息存储
    templyMessage = [[NSMutableString alloc]init];
//    comAddArr = [[NSMutableArray alloc]init];
    //加载数据的线程
//    [self initComment];
    //取得本地登录用户的ID
    NSDictionary *dic=[[LocalStroge sharedInstance] getObjectAtKey:F_USER_INFORMATION filePath:NSDocumentDirectory];
    customerID = [[dic objectForKey:@"customer_id"]integerValue];
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
    [textView setEditable:YES];
    [keyboardButton setEnabled:YES];
    [sendButton setEnabled:YES];
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
- (void)initComment{
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params setObject:@(_currentCommentPage) forKey:@"page"];
    [params setObject:@(C_API_LIST_NUM) forKey:@"count"];
    [params setObject:@(_comment.modID) forKey:@"mod_id"];//
    [params setObject:@(_comment.subID) forKey:@"sub_id"];//
    [params setObject:@(_comment.replyID) forKey:@"rep_id"];//评论ID
    [[JRRequestManager shareInstance]
     startRequestWithCmd:API_CMD_COMMENT_LIST
     method:JRRequestMethodPOST
     params:params
     key:API_CMD_COMMENT_LIST
     failed:^(JRRequest *request,NSError *error){
     }
     finished:^(JRRequest *request,JRResponse *response){
         if (!response.code) {
             [JDStatusBarNotification showWithStatus:response.msg dismissAfter:1.0];
         }
         else{
             NSMutableArray *array = [response.data valueForKey:@"list"];
             [self performSelectorOnMainThread:@selector(configComment:) withObject:array waitUntilDone:NO];
         }
     }];
}
- (void)configComment:(NSArray *)arr{//取得数据，并刷新列表
    NSMutableArray *array = [[NSMutableArray alloc] init];
    if (arr.count > 0) {
        for (NSDictionary *dict in arr) {
            Comment *comm = [[Comment alloc] init];
            [comm loadData:dict];
            [array addObject:comm];
        }
        [comAddArr removeAllObjects];
        [comAddArr addObjectsFromArray:array];
        _currentCommentPage++;
        [_tableView reloadData];//刷新列表
        _loading = NO;
    }
}
//初始化退出本视图按钮
- (void)initializeDissView
{
    //设置布局
    CGRect frame = _lineSperator.frame;
    frame.origin.y = self.view.frame.size.height - 45.5;
    _lineSperator.frame = frame;
    
    frame = _dissButton.frame;
    frame.origin.y = self.view.frame.size.height - 44;
    _dissButton.frame = frame;
    //信息回复框
    frame = toolBar.frame;
    frame.origin.y = self.view.frame.size.height - 44;
    toolBar.frame = frame;
}
//退出本视图
- (IBAction)dissSelf:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}
#pragma mark - UITableView datasource methods
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
    NSString *userSid = [S_USER_DEFAULTS stringForKey:API_LOGIN_SID];
    if ([textView.text isEqualToString:@""]||(!userSid)) {
        if (!userSid) {//如果没登录
            LoginViewController *login = [[LoginViewController alloc]init];
            [self.navigationController pushViewController:login animated:YES];
        }
        return;
    }
    if (customerID==0) {
        //取得本地登录用户的ID
        NSDictionary *dic=[[LocalStroge sharedInstance] getObjectAtKey:F_USER_INFORMATION filePath:NSDocumentDirectory];
        customerID = [[dic objectForKey:@"customer_id"]integerValue];
    }
    sendButton.enabled = NO;//发送为不可点击
    NSDateFormatter *dateFormatter=[[NSDateFormatter alloc]init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSDate *now = [NSDate date];
    NSString *dateString=[dateFormatter stringFromDate:now];//记录时间
    dateString = [DateTimeHelper getUTCFormateLocalDate:dateString];
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    if (sec) {//对评论追评
        [params setObject:textView.text forKey:@"rep_content"];//内容
        [params setObject:dateString forKey:@"rep_tm"];//时间
        [params setObject:@(customerID) forKey:@"customer_id"];//发帖人的ID
        [params setObject:@(_comment.modID) forKey:@"mod_id"];//模块
        [params setObject:@(_comment.subID) forKey:@"sub_id"];//主题ID
        [params setObject:@(repID) forKey:@"rep_id"];//楼层
        [params setObject:@(((Comment *)[comAddArr objectAtIndex:row]).customerID) forKey:@"rep_customer_id"];//是否是追评的追评，判断依据
        ;
    }
    else {//对帖子评论
        NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
        [params setObject:textView.text forKey:@"rep_content"];//内容
        [params setObject:dateString forKey:@"rep_tm"];//时间
        [params setObject:@(customerID) forKey:@"customer_id"];//发帖人的ID
        [params setObject:@(_comment.modID) forKey:@"mod_id"];//模块
        [params setObject:@(_comment.subID) forKey:@"sub_id"];//主题ID
        [params setObject:@(repID) forKey:@"rep_id"];//楼层
    }
    //评论请求
    [[JRRequestManager shareInstance]
     startRequestWithCmd:API_CMD_COMMENT_REPLY
     method:JRRequestMethodPOST
     params:params
     key:API_CMD_COMMENT_REPLY
     failed:^(JRRequest *request,NSError *error){
         NSInteger code = error.code;
         NSString *msg = [ErrorHelper messageWithCode:code];
         [JDStatusBarNotification showWithStatus:msg dismissAfter:1.0];
         sendButton.enabled = YES;
     }
     finished:^(JRRequest *request,JRResponse *response){
         if (!response.code) {
             [JDStatusBarNotification showWithStatus:response.msg dismissAfter:1.0];
             sendButton.enabled = YES;
         }
         else{
             [self performSelector:@selector(quitText) withObject:nil];
             [JDStatusBarNotification showWithStatus:NSLocalizedString(@"Comment on success", nil) dismissAfter:1.0];
         }
     }];


}
- (void)quitText
{
    [self initComment];
    sendButton.enabled = YES;
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

//文本框输入表情和文本
- (void)didTouchEmojiView:(EmojiView*)emojiView touchedEmoji:(NSString*)str
{
    NSString *content = textView.text;
    NSInteger location = textView.selectedRange.location;//取得光标位置
    NSString *beforText = [content substringToIndex:location];//取得光标之前的内容
    NSInteger centerRange = textView.selectedRange.length;//取得光标选中的内容
    NSString *laterText = [content substringFromIndex:location+centerRange];//光标后面的内容，不包括光标选中的内容
    textView.text = [NSString stringWithFormat:@"%@%@%@",beforText,str,laterText];//重组textView的内容
    textView.selectedRange = NSMakeRange(beforText.length+str.length, 0);//设置光标位置
    //储存临时信息
    [templyMessage setString:textView.text];
    if (textView.text.length == 0) {
        self.placeHodle.hidden = NO;
    }
    else{
        self.placeHodle.hidden = YES;
    }
}

//注册的通知事件
- (void)keyboardWillShow:(NSNotification *)notification {
    
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

- (void)keyboardWillHide:(NSNotification *)notification {
    
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

- (void)keyboardDidHide:(NSNotification *)notification {
    
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
- (void)textViewDidChange:(UITextView *)_textView {
    if (textView.text.length == 0) {
        self.placeHodle.hidden = NO;
    }
    else{
        self.placeHodle.hidden = YES;
    }
    //取得textview的contentsize
    CGSize size = _textView.contentSize;
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
- (BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    return YES; //make sure the YES is returned.
}
//点击表情页的删除按钮触发的事件
- (void)selectedDel:(NSArray *)_symbolArr{
    NSString *newBeforText = @"";
    NSString *content = textView.text;
    NSInteger location = textView.selectedRange.location;//取得光标位置
    NSString *beforText = [content substringToIndex:location];//取得光标之前的内容
    NSInteger centerRange = textView.selectedRange.length;//取得光标选中的内容
    NSString *laterText = [content substringFromIndex:location+centerRange];//光标后面的内容，不包括光标选中的内容
    if (textView.selectedRange.length > 0) {//在多选的情况下，要求多个字符串删除
        textView.text = [NSString stringWithFormat:@"%@%@",beforText,laterText];//重组textView的内容
        textView.selectedRange = NSMakeRange(beforText.length, 0);//设置光标位置
        return;
    }
    if ([beforText isEqual:@""]) {//删除到textView的初始位置时，直接返回
        textView.text = laterText;
        textView.selectedRange = NSMakeRange(0, 0);//设置光标位置
        return;
    }
    
    if (content.length > 0) {//在帖子中间删除某个字符
        
        if ((beforText.length >= 2)&&[_symbolArr containsObject:[beforText substringFromIndex:beforText.length-2]]) {
            newBeforText = [content substringToIndex:beforText.length-2];
        }else{
            newBeforText = [content substringToIndex:beforText.length-1];
        }
        textView.text= [textView.text stringByReplacingOccurrencesOfString:beforText withString:newBeforText];
        textView.selectedRange = NSMakeRange(newBeforText.length, 0);
    }
    
    //储存临时信息
    [templyMessage setString:textView.text];
    if (textView.text.length == 0) {
        self.placeHodle.hidden = NO;
    }
    else{
        self.placeHodle.hidden = YES;
    }
}

#pragma Table 
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    sec = indexPath.section;//记录分区与行，后面发送信息需要
    row = indexPath.row;
    //判断是否有placeHold
    if (textView.text.length == 0) {
        self.placeHodle.hidden = NO;
        if (!indexPath.section) {
            self.placeHodle.text =[NSString stringWithFormat:NSLocalizedString(@"I also speaking a word", nil) ];
        }
        else{
            self.placeHodle.text = [NSString stringWithFormat:NSLocalizedString(@"Reply %@:", nil),((Comment *)[comAddArr objectAtIndex:indexPath.row]).customerName];
        }
    }
    else{
        self.placeHodle.hidden = YES;
    }
    
    if (indexPath.section==0) {
        if (toolBar.hidden==NO) {//点击屏幕剩余部分，隐藏回复栏
            toolBar.hidden = YES;
            [textView resignFirstResponder];
        }else{
            toolBar.hidden = NO;
            [textView becomeFirstResponder];
        }
    }
    
    if (indexPath.section>0) {
        
        if ((_loading==YES)&&(indexPath.row==[comAddArr count])) {//当在载入中并且点击了最后一项就撤除点击
            return;
        }
        if (indexPath.row==[comAddArr count]) {
            _loading = YES;
//            [self initComment];//请求回复
            return;
        }
        repID = ((Comment *)[comAddArr objectAtIndex:indexPath.row]).replyID;
        if (toolBar.hidden==YES) {//当回复框隐藏的时候才能弹出回复框
            toolBar.hidden = NO;
            if (![templyMessage isEqualToString:@""]) {
                textView.text = templyMessage;//将编辑中而保存的信息还原
            }
            [textView becomeFirstResponder];
        }else{
            //点击屏幕剩余部分，隐藏回复栏
            toolBar.hidden = YES;
            [textView resignFirstResponder];
        }
        
    }
}
//有多少分区
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    if (section) {
//        return [comAddArr count] >= 10 ? ([comAddArr count]+1) : [comAddArr count];
        return 10;
    }
    else{
        return 1;
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat height = 0;
    //第一个分区
    if (indexPath.section == 0) {
        height = [CommentCell getAddCellHeight:_comment];
    }
    //第二个分区
    else {
        //加载更多
        if ((indexPath.row==[comAddArr count])&&([comAddArr count]>=10)) {
            return 15;
        }
//        height = [CommentCell getCellHeight:[comAddArr objectAtIndex:indexPath.row]];
        height = 104;
    }
    return height;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *COMMENTADDCELL = @"commentadd";
    UITableViewCell *cell = nil;
    //第一个分区的单元构造
    if (indexPath.section == 0) {
        cell = (CommentCell *)[[[NSBundle mainBundle] loadNibNamed:@"CommentCell" owner:self options:nil] lastObject];
        //设置图片点击触发的方法
        ((CommentCell *)cell).delegate = (id)self;
        //构造帖子信息
        [((CommentCell *)cell) configCommentAddCellWithComment:self.comment];
    }
    //第二个单元格的构造
    //最后加载更多栏
    else{
        if ((indexPath.row==[comAddArr count])&&([comAddArr count]>=10)) {
            static NSString* ENDCELL = @"end";
            cell = [tableView dequeueReusableCellWithIdentifier:ENDCELL];//重用标识
            if (!cell) {//初始
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ENDCELL];
            }
            cell.textLabel.textAlignment = NSTextAlignmentRight;
            cell.textLabel.textColor = COLOR_THEME;
            cell.textLabel.text = [NSString stringWithFormat: NSLocalizedString(@"See more %i reply", nil),((Comment *)[comAddArr objectAtIndex:indexPath.row]).moreRepCount];
            cell.textLabel.font = [UIFont boldSystemFontOfSize:11.0];
            cell.backgroundColor = COLOR_BACKGROUND;
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            return cell;
        }
        cell = (CommentAddCell *)[tableView dequeueReusableCellWithIdentifier:COMMENTADDCELL];
        if (!cell) {
            cell = [[[NSBundle mainBundle] loadNibNamed:@"CommentAddCell" owner:self options:nil] lastObject];
        }
        ((CommentAddCell *)cell).delegate = (id)self;
        if ((indexPath.row<[comAddArr count]) && ([comAddArr count]>0)) {
            [(CommentAddCell *)cell configCommentCellWithComment:[comAddArr objectAtIndex:indexPath.row]];
        }
    }
    cell.backgroundColor = COLOR_BACKGROUND;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}
#pragma mark -CommentAddCell
//点击追评用户
- (void)didTapedCustomerName:(NSInteger)custID
{
    THLog(@"我进来了，亲");
}
//点击评论用户的头像或用户名
- (void)didTapedCustomerImage:(NSInteger)userID
{
    NSString *userSid = [S_USER_DEFAULTS stringForKey:API_LOGIN_SID];
    if (userSid) {
        NSDictionary *dic=[[LocalStroge sharedInstance] getObjectAtKey:F_USER_INFORMATION filePath:NSDocumentDirectory];
        NSInteger myID = [[dic objectForKey:@"customer_id"]integerValue];
        if (myID == userID) {
            MyPostViewController *myPost = [[MyPostViewController alloc]init];
            // 准备动画
            CATransition *animation = [CATransition animation];
            //动画播放持续时间
            [animation setDuration:0.8f];
            //动画速度,何时快、慢
            [animation setTimingFunction:[CAMediaTimingFunction
                                          functionWithName:kCAMediaTimingFunctionEaseIn]];
            [UIView setAnimationTransition: UIViewAnimationTransitionFlipFromLeft   forView:self.view  cache:YES];
            [animation setType:@"oglFlip"];
            //开始动画
            [self.view.layer addAnimation:animation forKey:@"oglFlip"];
            [self.navigationController pushViewController:myPost animated:YES];
            [UIView commitAnimations];

            return;
        }
    }
    OtherPostViewController *otherPost = [[OtherPostViewController alloc]init];
    otherPost.otherID = userID;//获取其他用户的ID
    // 准备动画
    CATransition *animation = [CATransition animation];
    //动画播放持续时间
    [animation setDuration:0.8f];
    //动画速度,何时快、慢
    [animation setTimingFunction:[CAMediaTimingFunction
                                  functionWithName:kCAMediaTimingFunctionEaseIn]];
    [UIView setAnimationTransition: UIViewAnimationTransitionFlipFromLeft   forView:self.view  cache:YES];

    [animation setType:@"oglFlip"];
    //开始动画
    [self.view.layer addAnimation:animation forKey:@"oglFlip"];
    [self.navigationController pushViewController:otherPost animated:YES];
    [UIView commitAnimations];
}
#pragma mark UIScrollViewDelegate
//用户手动滑动tableview时调用下面的方法,保存初始的触摸点的位置
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView;
{
    beginPoint = scrollView.contentOffset;
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
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
