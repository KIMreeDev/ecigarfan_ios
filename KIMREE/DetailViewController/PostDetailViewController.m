//
//  PostDetailViewController
//  ECIGARFAN
//
//  Created by JIRUI on 14-4-7.
//  Copyright (c) 2014年 JIRUI. All rights reserved.
//

#import "PostDetailViewController.h"
#import "SubPostBarCell.h"
#import "PostImageViewController.h"
#import "OtherPostViewController.h"
#import "MyPostViewController.h"
#import "CommentAddViewController.h"
#import "Comment.h"
#import "CommentCell.h"
#import "ZS_Share.h"
#import "ErrorHelper.h"
#import "LoginViewController.h"
#import "UIView+Frame.h"

@interface PostDetailViewController ()<SubPostBarCellDelegate>
{
    UIViewController * shareController;
    NSInteger _currentCommentPage;//评论页
    NSInteger _totalCommentCount;//所有评论数
    BOOL _moreLoading;//是否加载更多标识
    NSMutableString *templyMessage;//临时信息
    NSInteger sec;//分区
    NSInteger repID;//单元
    NSInteger customerID;
}
@property (nonatomic,strong) NSMutableArray *commentArray;
@property (nonatomic,strong) NSIndexPath *selIndex;
@property (nonatomic,strong) UITextView *information;
@property (nonatomic,strong) NSString *textOfReport;
@property (nonatomic,strong) ASIFormDataRequest *request;
@property (nonatomic) BOOL loading;

@end

@implementation PostDetailViewController

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
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = _post.subTitle;
    textView.editable = YES;
    _currentCommentPage = 1;
    _loading = NO;
    self.commentArray = [NSMutableArray arrayWithCapacity:0];
    CGRect frame = toolBar.frame;

    if (IS_INCH4) {
        frame.origin.y = self.view.frame.size.height + 44;
    } else {
        frame.origin.y = self.view.frame.size.height - 44;
    }
    toolBar.frame = frame;
    //加载数据的线程
    [self initComment];
    // Do any additional setup after loading the view from its nib.
    //临时消息存储
    templyMessage = [[NSMutableString alloc]init];

    //取得本地登录用户的ID
    NSDictionary *dic=[[LocalStroge sharedInstance] getObjectAtKey:F_USER_INFORMATION filePath:NSDocumentDirectory];
    customerID = [[dic objectForKey:@"customer_id"]integerValue];
    
    //数据列表
//    self.detailTableView = (TableView *)[self.view viewWithTag:2000];
    CGRect rect = [self.view viewWithTag:2000].frame;
    self.detailTableView = [[TableView alloc]initWithFrame:rect];
    if (self.detailTableView) {
        self.detailTableView.key = [NSString stringWithFormat:@"PostDetailList%@",[AppHelper sharedInstance].uid];
        self.detailTableView.delegate = (id)self;
        self.detailTableView.dataSource = self;
        self.detailTableView.loadMoreDelegate = self;
    }
    [self.view addSubview:self.detailTableView];
    [self.view addSubview:toolBar];
    //初始化视图
    [self initViews];
    //匹配屏幕的显示问题
    if (IS_INCH4) {
        rect.size.height += 70;
    } else {
        rect.size.height -= 20;
    }
    self.detailTableView.frame = rect;
}

- (void)initComment{
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params setObject:@(_currentCommentPage) forKey:@"page"];
    [params setObject:@(C_API_LIST_NUM) forKey:@"count"];
    [params setObject:@(self.post.modID) forKey:@"mod_id"];//
    [params setObject:@(self.post.subID) forKey:@"sub_id"];//
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
             self.detailTableView.isLoading = NO;
         }
     }];
}

//取得数据，并刷新列表
- (void)configComment:(NSArray *)arr{
    NSMutableArray *array = [[NSMutableArray alloc] init];
    if (arr.count > 0) {
        for (NSDictionary *dict in arr) {
            Comment *comm = [[Comment alloc] init];
            [comm loadData:dict];
            [array addObject:comm];
        }
        [self.commentArray removeAllObjects];
        [self.commentArray addObjectsFromArray:array];
        _currentCommentPage++;
        [self.detailTableView reloadData];//刷新列表
        _loading = NO;
    }
    //初始化加载更多
    NSInteger rows = [self commentArray].count;
    if (rows >= C_API_LIST_NUM) {
        self.detailTableView.loadMoreView = [[LoadFooterView alloc] initWithFrame:CGRectMake(0, 0, self.detailTableView.width-50, 60) textColor:[UIColor grayColor]];
    }
    else{
        self.detailTableView.loadMoreView = nil;
    }
}

////点击表情按钮
//- (IBAction)faceBoardClick:(id)sender {
//    isButtonClicked = YES;
//    if ( isKeyboardShowing ) {
//        [textView resignFirstResponder];
//    }
//    else {
//        
//        if ( isFirstShowKeyboard ) {
//            
//            isFirstShowKeyboard = NO;
//            
//            isSystemBoardShow = NO;
//        }
//        
//        if ( !isSystemBoardShow ) {
//            
//            textView.inputView = _emojiView;
//        }
//        
//        [textView becomeFirstResponder];
//    }
//}
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
    if (sec) {//对评论追评

        NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
        [params setObject:textView.text forKey:@"rep_content"];//内容
        [params setObject:dateString forKey:@"rep_tm"];//时间
        [params setObject:@(customerID) forKey:@"customer_id"];//发帖人的ID
        [params setObject:@(self.post.modID) forKey:@"mod_id"];//模块
        [params setObject:@(self.post.subID) forKey:@"sub_id"];//主题ID
        [params setObject:@(repID) forKey:@"rep_id"];//楼层
        [[JRRequestManager shareInstance]
         startRequestWithCmd:API_CMD_COMMENT_REPLY
         method:JRRequestMethodPOST
         params:params
         key:API_CMD_COMMENT_REPLY
         failed:^(JRRequest *request,NSError *error){
             [JDStatusBarNotification showWithStatus:NSLocalizedString(@"Failure", nil) dismissAfter:1.0];
             sendButton.enabled = YES;

         }
         finished:^(JRRequest *request,JRResponse *response){
             if (!response.code) {

                 [JDStatusBarNotification showWithStatus:response.msg dismissAfter:1.0];
                 sendButton.enabled = YES;
             }
             else{
                 self.post.replyCount++;
                 [self performSelector:@selector(quitText) withObject:nil];
                 [JDStatusBarNotification showWithStatus:NSLocalizedString(@"Comment on success", nil) dismissAfter:1.0];

             }
         }];
    }
    else {//对帖子评论
        NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
        [params setObject:textView.text forKey:@"rep_content"];//内容
        [params setObject:dateString forKey:@"rep_tm"];//时间
        [params setObject:@(customerID) forKey:@"customer_id"];//发帖人的ID
        [params setObject:@(self.post.modID) forKey:@"mod_id"];//模块
        [params setObject:@(self.post.subID) forKey:@"sub_id"];//主题ID
        [[JRRequestManager shareInstance]
         startRequestWithCmd:API_CMD_POST_REPLY
         method:JRRequestMethodPOST
         params:params
         key:API_CMD_POST_REPLY
         failed:^(JRRequest *request,NSError *error){
             [JDStatusBarNotification showWithStatus:NSLocalizedString(@"Failure", nil) dismissAfter:1.0];
             sendButton.enabled = YES;
         }
         finished:^(JRRequest *request,JRResponse *response){
             if (!response.code) {
                 [JDStatusBarNotification showWithStatus:response.msg dismissAfter:1.0];
                 sendButton.enabled = YES;
             }
             else{
                 self.post.replyCount++;
                 [self performSelector:@selector(quitText) withObject:nil];
                 [JDStatusBarNotification showWithStatus:NSLocalizedString(@"Comment on success", nil) dismissAfter:1.0];

             }
         }];
    }
    
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
//    [keyboardButton setImage:[UIImage imageNamed:@"board_emoji"]
//                    forState:UIControlStateNormal];
    //将临时信息清空
    [templyMessage setString:@""];
    [toolBar setHidden:YES];
}

- (void)textViewDidChange:(UITextView *)_textView {
    //设置placeHodle
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
        
//        center = keyboardButton.center;
//        center.y = centerY;
//        keyboardButton.center = center;
        
        center = sendButton.center;
        center.y = centerY;
        sendButton.center = center;
    }
    //储存临时信息
    [templyMessage setString:textView.text];
}

#pragma mark - UITableView datasource methods
////文本框输入表情和文本
//- (void)didTouchEmojiView:(EmojiView*)emojiView touchedEmoji:(NSString*)str
//{
//    NSString *content = textView.text;
//    NSInteger location = textView.selectedRange.location;//取得光标位置
//    NSString *beforText = [content substringToIndex:location];//取得光标之前的内容
//    NSInteger centerRange = textView.selectedRange.length;//取得光标选中的内容
//    NSString *laterText = [content substringFromIndex:location+centerRange];//光标后面的内容，不包括光标选中的内容
//    textView.text = [NSString stringWithFormat:@"%@%@%@",beforText,str,laterText];//重组textView的内容
//    textView.selectedRange = NSMakeRange(beforText.length+str.length, 0);//设置光标位置
//    //储存临时信息
//    [templyMessage setString:textView.text];
//    if (textView.text.length == 0) {
//        self.placeHodle.hidden = NO;
//    }
//    else{
//        self.placeHodle.hidden = YES;
//    }
//}

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
    
//    if ( isFirstShowKeyboard ) {
//        
//        isFirstShowKeyboard = NO;
//        
//        isSystemBoardShow = !isButtonClicked;
//    }
//    
//    if ( isSystemBoardShow ) {
//        
//        [keyboardButton setImage:[UIImage imageNamed:@"board_emoji"]
//                        forState:UIControlStateNormal];
//    }
//    else {
//        
//        [keyboardButton setImage:[UIImage imageNamed:@"board_system"]
//                        forState:UIControlStateNormal];
//    }
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
    
//    if ( isButtonClicked ) {
//        
//        isButtonClicked = NO;
//        
//        if ( ![textView.inputView isEqual:_emojiView] ) {
//            
//            isSystemBoardShow = NO;
//            
//            textView.inputView = _emojiView;
//        }
//        else {
//            
//            isSystemBoardShow = YES;
//            
//            textView.inputView = nil;
//        }
//        
//        [textView becomeFirstResponder];
//    }
    [self textViewDidChange:textView];
}

//点击表情页的删除按钮触发的事件
//- (void)selectedDel:(NSArray *)_symbolArr{
//    NSString *newBeforText = @"";
//    NSString *content = textView.text;
//    NSInteger location = textView.selectedRange.location;//取得光标位置
//    NSString *beforText = [content substringToIndex:location];//取得光标之前的内容
//    NSInteger centerRange = textView.selectedRange.length;//取得光标选中的内容
//    NSString *laterText = [content substringFromIndex:location+centerRange];//光标后面的内容，不包括光标选中的内容
//    if (textView.selectedRange.length > 0) {//在多选的情况下，要求多个字符串删除
//        textView.text = [NSString stringWithFormat:@"%@%@",beforText,laterText];//重组textView的内容
//        textView.selectedRange = NSMakeRange(beforText.length, 0);//设置光标位置
//        return;
//    }
//    if ([beforText isEqual:@""]) {//删除到textView的初始位置时，直接返回
//        textView.text = laterText;
//        textView.selectedRange = NSMakeRange(0, 0);//设置光标位置
//        return;
//    }
//    
//    if (content.length > 0) {//在帖子中间删除某个字符
//        
//        if ((beforText.length >= 2)&&[_symbolArr containsObject:[beforText substringFromIndex:beforText.length-2]]) {
//            newBeforText = [content substringToIndex:beforText.length-2];
//        }else{
//            newBeforText = [content substringToIndex:beforText.length-1];
//        }
//        textView.text= [textView.text stringByReplacingOccurrencesOfString:beforText withString:newBeforText];
//        textView.selectedRange = NSMakeRange(newBeforText.length, 0);
//    }
//
//    //储存临时信息
//    [templyMessage setString:textView.text];
//    if (textView.text.length == 0) {
//        self.placeHodle.hidden = NO;
//    }
//    else{
//        self.placeHodle.hidden = YES;
//    }
//}

//点击帖子中的图片
- (void)didTapedSubPostBarCellImage:(NSString *)subImage
{
    PostImageViewController *postImageVC = [[PostImageViewController alloc] initWithNibName:@"PostImageViewController" bundle:nil];
    [postImageVC sePostImageURL:subImage];
    postImageVC.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [self presentViewController:postImageVC animated:YES completion:nil];
}
#pragma table source data
//有多少分区
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}
//每个区有多少单元    
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section) {
        return [self.commentArray count];
    }
    else{
        return 1;
    }
}
//自定义单元格的高度
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat height = 0;
    //第一个分区
    if (indexPath.section == 0) {
        height = [SubPostBarCell detailCellHeight:_post];
    }
    //第二个分区
    else {
        height = [CommentCell getCellHeight:[self.commentArray objectAtIndex:indexPath.row]];
    }
    return height;
}

//点击评论表格头部分
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    sec = indexPath.section;//记录分区与行，后面发送信息需要
    //设置placeHold
    if (textView.text.length==0) {
        self.placeHodle.hidden = NO;
        if (!indexPath.section) {
            self.placeHodle.text = NSLocalizedString(@"Comment:", nil);
        }
        else{
            self.placeHodle.text = [NSString stringWithFormat:NSLocalizedString(@"Reply %i floor:", nil),((Comment *)[self.commentArray objectAtIndex:indexPath.row]).replyID];
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
    
        repID = ((Comment *)[self.commentArray objectAtIndex:indexPath.row]).replyID;
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

//重构单元格
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *COMMENTCELL = @"comment";
    UITableViewCell *cell = nil;
    //第一个分区的单元构造
    if (indexPath.section == 0) {
        cell = (SubPostBarCell *)[[[NSBundle mainBundle] loadNibNamed:@"SubPostBarCell" owner:self options:nil] lastObject];
        //设置图片点击触发的方法
        ((SubPostBarCell *)cell).delegate = self;
        //构造帖子信息
        [((SubPostBarCell *)cell) configDetailPostCellWithPost:self.post];

    }
    //第二个单元格的构造
    else{
        if ((indexPath.row==[self.commentArray count])&&([self.commentArray count]%10==0)) {
            static NSString* ENDCELL = @"end";
            cell = [tableView dequeueReusableCellWithIdentifier:ENDCELL];//重用标识
            if (!cell) {//初始
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ENDCELL];
            }
            cell.textLabel.textAlignment = NSTextAlignmentCenter;
            cell.textLabel.textColor = [UIColor brownColor];
            cell.textLabel.text = NSLocalizedString(@"More", nil);
            return cell;
        }
        cell = (CommentCell *)[tableView dequeueReusableCellWithIdentifier:COMMENTCELL];
        if (!cell) {
            cell = [[[NSBundle mainBundle] loadNibNamed:@"CommentCell" owner:self options:nil] lastObject];
        }
        ((CommentCell *)cell).repIndex = indexPath.row;
        ((CommentCell *)cell).delegate = (id)self;
        [(CommentCell *)cell configCommentCellWithComment:[self.commentArray objectAtIndex:indexPath.row]];
        cell.backgroundColor = COLOR_BACKGROUND;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
//    UILongPressGestureRecognizer *recognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPress:)];
//    recognizer.minimumPressDuration = 1.0;
//    [((SubPostBarCell *)cell) addGestureRecognizer:recognizer];
    return cell;
}
//点击分享按钮的回调，平台的为实现
//actionsheet对话框
-(void) actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
	if (actionSheet.tag == 355) {
        //初始化邮件、短信
        ZS_Share *share = [[ZS_Share alloc] init];
        ZS_ShareResult *result;
        //判断按钮
        switch (buttonIndex) {
            case 0:{
                //facebook分享
                slComposerSheet = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeFacebook];
                [slComposerSheet setInitialText:[NSString stringWithFormat:@"%@\n\nFrom Ecigarfan\nwww.ecigarfan.com", _post.subTitle]];
                [slComposerSheet addImage:image];
                [self presentViewController:slComposerSheet animated:YES completion:nil];
                [slComposerSheet setCompletionHandler:^(SLComposeViewControllerResult result) {
                    NSString *output;
                    switch (result) {
                        case SLComposeViewControllerResultCancelled:
                            output = @"Action Cancelled";
                            break;
                        case SLComposeViewControllerResultDone:
                            output = @"Post Successfull";
                            break;
                        default:
                            break;
                    }
                }];
            }
                break;
            case 1:{
                //twitter分享
                slComposerSheet = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
                [slComposerSheet setInitialText:[NSString stringWithFormat:@"%@\n\nFrom Ecigarfan\nwww.ecigarfan.com", _post.subTitle]];
                [slComposerSheet addImage:image];
                [self presentViewController:slComposerSheet animated:YES completion:nil];
                [slComposerSheet setCompletionHandler:^(SLComposeViewControllerResult result) {
                    NSString *output;
                    switch (result) {
                        case SLComposeViewControllerResultCancelled:
                            output = @"Action Cancelled";
                            break;
                        case SLComposeViewControllerResultDone:
                            output = @"Post Successfull";
                            break;
                        default:
                            break;
                    }
                }];
            }
                break;
            case 2:{
                    // 邮件
                result = [share shareContent:(id)[NSString stringWithFormat:@"%@\n\nFrom Ecigarfan\nwww.ecigarfan.com", _post.subTitle]
                        withShareBy:NSClassFromString(@"ZS_ShareByMail") withShareDelegate:(id)self];
            }
                    break;
            case 3:{
                    // 短信
                    result = [share shareContent:(id)[NSString stringWithFormat:@"%@\n\nFrom Ecigarfan\nwww.ecigarfan.com", _post.subTitle]                 withShareBy:NSClassFromString(@"ZS_ShareByMessage") withShareDelegate:(id)self];
                    break;
            }
        }
    }
}
#pragma mark - CommentCellDelegate
//载入更多追回
- (void)loadMoreReply:(NSInteger)repIndex
{
    CommentAddViewController *commentAdd = [[CommentAddViewController alloc]initWithNibName:@"CommentAddViewController" bundle:nil];
    commentAdd.comment = [_commentArray objectAtIndex:repIndex];
    [self.navigationController pushViewController:commentAdd animated:YES];
}
//点击用户的头像或用户名
- (void)didTapedCustomerImage:(NSInteger)userID
{
    NSString *userSid = [S_USER_DEFAULTS stringForKey:API_LOGIN_SID];
    if (userSid) {
        NSDictionary *dic=[[LocalStroge sharedInstance] getObjectAtKey:F_USER_INFORMATION filePath:NSDocumentDirectory];
        NSInteger myID = [[dic objectForKey:@"customer_id"]integerValue];
        if (myID == userID) {
                MyPostViewController *myPost = [[MyPostViewController alloc]init];
                [self.navigationController pushViewController:myPost animated:YES];
            return;
        }
    }
    
    OtherPostViewController *otherPost = [[OtherPostViewController alloc]init];
    otherPost.otherID = userID;//获取其他用户的ID
    [self.navigationController pushViewController:otherPost animated:YES];
}

#pragma mark - UIAction methods
//分享按钮
- (void)shareButtonClicked{
    //截屏
    UIWindow *screenWindow = [[UIApplication sharedApplication] keyWindow];
    UIGraphicsBeginImageContext(screenWindow.frame.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    [screenWindow.layer renderInContext:context];
    image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    //选择控件
    UIActionSheet *sheet= [[UIActionSheet alloc] initWithTitle:@"" delegate:(id)self cancelButtonTitle:NSLocalizedString(@"Cancel", nil) destructiveButtonTitle:nil otherButtonTitles:NSLocalizedString(@"Facebook", nil), NSLocalizedString(@"Twitter", nil),NSLocalizedString(@"Mail", nil), NSLocalizedString(@"SMS", nil), nil];
    sheet.tag = 355;
    [sheet showInView:self.view];
}

#pragma mark - ZS_Share

-(void) shareBy:(ZS_ShareBy *) shareBy withResult:(ZS_ShareResult *) result
{
    NSLog(@"%@", result.shRetInfo);
    
    NSDictionary * dic = (NSDictionary *) result.shRetInfo;
    
    for (NSString * key in [dic allKeys])
    {
        NSLog(@"%@", [dic  objectForKey:key]);
        
    }
    [shareController dismissViewControllerAnimated:YES completion:^{
        
        //      [self performSelector:@selector(circleTest) withObject:nil afterDelay:1];
        
        shareController = nil;
        
    }];
}

-(void) shareBy:(ZS_ShareBy *)shareBy withRootOject:(id)controller
{
    shareController = controller;
    [self presentViewController:controller animated:YES completion:^{
        
    }];
}

#pragma mark - Private methods
- (void)backButtonClicked
{
    [self.navigationController popToViewController:[self.navigationController.viewControllers objectAtIndex:1] animated:YES];
}
//初始化背景
- (void)initViews{
    //设置背景图
    [self.view setBackgroundColor:COLOR_BACKGROUND];
    //设置导航栏右按钮
    UIBarButtonItem *shareButtonItem = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(shareButtonClicked)];
    UIBarButtonItem *backButtonItem = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemReply target:self action:@selector(backButtonClicked)];
    NSArray *arr = [NSArray arrayWithObjects:shareButtonItem, backButtonItem, nil];
    [self.navigationItem setRightBarButtonItems:arr];
    
    //设置一下分隔线条
    [_detailTableView setSeparatorColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"block_line.png"]]];
    UIView *view =[ [UIView alloc]init];
    view.backgroundColor = [UIColor clearColor];
    [_detailTableView setTableFooterView:view];
    
    // 隐藏信息回复框
    toolBar.hidden = YES;
    //初始化表情
//    _emojiView = [[EmojiView alloc] initWithFrame:CGRectMake(0, [UIScreen mainScreen].bounds.size.height, 320, 216)];
//    _emojiView.delegate = self;
//    [self.view addSubview:_emojiView];
    textView.delegate = self;
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

#pragma mark - 长按浮现菜单，
//-(BOOL) canBecomeFirstResponder{
//    return YES;
//}
//长按浮现菜单项（复制、举报）
//- (void)longPress:(UILongPressGestureRecognizer *)recognizer {
//
//    if (recognizer.state == UIGestureRecognizerStateBegan) {
//        CGPoint point = [recognizer locationInView:_detailTableView];
//        NSIndexPath * indexPath = [_detailTableView indexPathForRowAtPoint:point];
//        _selIndex = indexPath;
//        if(indexPath == nil) return ;
//        //add your code here
//        UIMenuController *menu = [UIMenuController sharedMenuController];
//        if (!indexPath.section) {
//            SubPostBarCell *cell = (SubPostBarCell *)recognizer.view;
//            [cell becomeFirstResponder];
//            UIMenuItem *copy = [[UIMenuItem alloc] initWithTitle:@"copy" action:@selector(copyContent:)];
//            UIMenuItem *report = [[UIMenuItem alloc] initWithTitle:@"report" action:@selector(report:)];
//            [menu setMenuItems:[NSArray arrayWithObjects:copy, report, nil]];
//            [menu setTargetRect:cell.frame inView:cell.superview];
//        }else{
//            CommentCell *cell = (CommentCell *)recognizer.view;
//            [cell becomeFirstResponder];
//            UIMenuItem *copy = [[UIMenuItem alloc] initWithTitle:@"copy" action:@selector(copyContent:)];
//            [menu setMenuItems:[NSArray arrayWithObjects:copy, nil]];
//            [menu setTargetRect:cell.frame inView:cell.superview];
//        }
//        [menu setMenuVisible:YES animated:YES];
//    }
//}
////拷贝
//- (void)copyContent:(id)sender {
//    CommentCell *comCell = nil;
//    SubPostBarCell *subCell = nil;
//    //拷贝帖子内容
//    if (!_selIndex.section) {
//        subCell = (SubPostBarCell *)[_detailTableView cellForRowAtIndexPath:_selIndex];
//        [UIPasteboard generalPasteboard].string = subCell.contentLabel.text;
//        return;
//    }
//    //拷贝评论内容
//    comCell = (CommentCell *)[_detailTableView cellForRowAtIndexPath:_selIndex];
//    [UIPasteboard generalPasteboard].string = comCell.content.text;
//}
//举报
- (void)report:(id)sender {
    [self reportView];
}
#pragma mark - 举报页面
- (void)reportPosts{
    //组织举报内容
    _textOfReport = [NSString stringWithFormat:NSLocalizedString(@"Reporting: %@ \nReason: Individual companies/spam \n", nil) , _post.subTitle];
    [self reportView];
}
//feedback view
-(void)reportView
{
    UIViewController *feedbackVC=[[UIViewController  alloc] init];
    feedbackVC.view.backgroundColor=COLOR_WHITE_NEW;
    feedbackVC.title=NSLocalizedString(@"Report", nil);
    
    UILabel *firsthint =[[UILabel alloc] init];
    [self labelInit:firsthint name:@"Please fill in your questions" size:CGRectMake(10, 75, 310, 40) numerOfLines:2 fontSize:14];
    firsthint.textColor=COLOR_DARK_GRAY;
    [feedbackVC.view addSubview:firsthint];
    
    _information = [[UITextView alloc] initWithFrame:CGRectMake(10, 115, 300, 130)];
    _information.layer.cornerRadius = 6;
    _information.layer.masksToBounds = YES;
    _information.backgroundColor =COLOR_BACKGROUND;
    _information.autocorrectionType = UITextAutocorrectionTypeNo;
    _information.autocapitalizationType = UITextAutocapitalizationTypeNone;
    _information.returnKeyType = UIReturnKeyDone;
    _information.font = [UIFont systemFontOfSize:14];
    _information.delegate=self;
    //赋值
    _information.text = _textOfReport;
    [feedbackVC.view addSubview:_information];
    
    UIButton *submit = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [self buttonInit:submit action:@selector(sendFeedback) size:CGRectMake(10.0, 260, 300.0, 40.0) name:NSLocalizedString(@"Submit", @"")];
    submit.backgroundColor=COLOR_LIGHT_BLUE_THEME;
    submit.layer.masksToBounds=YES;
    submit.layer.cornerRadius=4;
    [feedbackVC.view addSubview:submit];
    
    UITapGestureRecognizer *tapGr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(viewTapped:)];
    tapGr.cancelsTouchesInView = NO;
    [feedbackVC.view addGestureRecognizer:tapGr];
    
    
    [self.navigationController pushViewController:feedbackVC animated:YES];
    
}

//初始化方法
-(void)labelInit:(UILabel*)label name:(NSString*)string size:(CGRect)frame numerOfLines:(int)num fontSize:(int)size{
    label.text=NSLocalizedString(string, @"");
    label.textColor=COLOR_DARK_GRAY;
    label.backgroundColor=[UIColor clearColor];
    label.textAlignment=NSTextAlignmentLeft;
    label.frame = frame;
    label.numberOfLines=num;
    //  label.font = [UIFont fontWithName:@"Helvetica" size:size];
    label.font =[UIFont boldSystemFontOfSize:size];
}
-(void) buttonInit:(UIButton*)button action:(SEL)action size:(CGRect)frame name:(NSString*)name{
    
    [button addTarget:self action:action forControlEvents:UIControlEventTouchUpInside];
    button.backgroundColor=[UIColor clearColor];
    button.frame = frame;
    [button setTitleColor:COLOR_WHITE_NEW forState:UIControlStateNormal];
    [button setTitle:name forState:UIControlStateNormal];
}

-(void)viewTapped:(UITapGestureRecognizer*)tapGr
{
    [_information resignFirstResponder];
}
//发送举报
#pragma mark  ----------send email
-(void)sendFeedback
{
    if ([_information.text isEqualToString:@""]) {
        UIAlertView *alertView=[[UIAlertView alloc] initWithTitle:nil message:NSLocalizedString(@"No content submit", @"") delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", @"") otherButtonTitles: nil];
        alertView.tag=100;
        [alertView show];
    }else
    {
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            //加入多线程耗时操作
            [self LinkNetWork:API_FEEDBACK_URL];
        });
    }
}
#pragma -mark 网络请求

- (void)LinkNetWork:(NSString *)strUrl
{
    _request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:strUrl]];
    
    [_request setDelegate:self];
    [_request setShouldAttemptPersistentConnection:NO];
    [_request setTimeOutSeconds:10];
    [_request setPostValue:[NSString stringWithFormat:@" \n%@ 举报者id：%li",_information.text, (long)_post.customerID] forKey:@"question_content"];
    // [MMProgressHUD showWithTitle:nil status:NSLocalizedString(@"submit...", "")];
    [_request startAsynchronous];
}

- (void)requestFailed:(ASIFormDataRequest *)request
{
    [JDStatusBarNotification showWithStatus:NSLocalizedString(@"Failed to connect link to server!", "") dismissAfter:1.0f];
}

- (void)requestFinished:(ASIFormDataRequest *)request
{
    NSData *jsonData = [request.responseString dataUsingEncoding:NSUTF8StringEncoding];
    NSError *error;
    NSMutableDictionary *rootDic = [[CJSONDeserializer deserializer] deserialize:jsonData error:&error];
    int status=[[rootDic objectForKey:@"code"] intValue];
    if (status==1) {
        //[MMProgressHUD dismissWithSuccess:[rootDic objectForKey:@"msg"]];
        [JDStatusBarNotification showWithStatus:NSLocalizedString(@"Successful submission!", "") dismissAfter:1.0f];
        
        [self.navigationController popViewControllerAnimated:YES];
        
    }
    else
    {
        // [MMProgressHUD dismissWithError:[rootDic objectForKey:@"data"]];
        [JDStatusBarNotification showWithStatus:[rootDic objectForKey:@"data"] dismissAfter:1.0f];
        
        [JDStatusBarNotification showWithStatus:NSLocalizedString(@"Failed to connect link to server!", "") dismissAfter:1.0f];
    }
    
}

#pragma mark - UIMenucontroller 显示复制菜单
-(BOOL)tableView:(UITableView *)tableView shouldShowMenuForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return YES;
}

-(BOOL)tableView:(UITableView *)tableView canPerformAction:(SEL)action forRowAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender{
    if (action == @selector(copy:)) {
        return YES;
    }
    return NO;
}

-(void)tableView:(UITableView *)tableView performAction:(SEL)action forRowAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender{
    CommentCell *comCell = nil;
    SubPostBarCell *subCell = nil;
    //获取对应的节
    if (indexPath.section) {
        comCell = (CommentCell *)[tableView cellForRowAtIndexPath:indexPath];
    }
    else{
        subCell = (SubPostBarCell *)[tableView cellForRowAtIndexPath:indexPath];
    }
    //拷贝不同单元的内容
    if (action == @selector(copy:)) {
        if (indexPath.section) {
            [UIPasteboard generalPasteboard].string = comCell.content.text;
        }
        else{
            [UIPasteboard generalPasteboard].string = subCell.contentLabel.text;
        }
    }
}
#pragma mark UIScrollViewDelegate
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
    [self.detailTableView scrollViewDidScroll:scrollView];
}

//用户手动滑动tableview时调用下面的方法,保存初始的触摸点的位置
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView;
{
    beginPoint = scrollView.contentOffset;
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    [self.detailTableView scrollViewDidEndDragging:scrollView];
}
#pragma mark -TableViewLoadMoreDelegate
//上拉触发加载下一页回复
- (void)loadMoreData:(TableView *)tableView
{
    THLog(@"------------加载-------------");
    self.detailTableView.isLoading = YES;
    [self initComment];//请求回复
}
@end
