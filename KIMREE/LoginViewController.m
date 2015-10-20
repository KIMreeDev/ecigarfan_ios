//
//  LoginViewController.m
//  ECIGARFAN
//
//  Created by renchunyu on 14-5-20.
//  Copyright (c) 2014年 renchunyu. All rights reserved.
//

#import "LoginViewController.h"
#import "JRKeyChainHelper.h"
#import "NSString+JiRui.h"
#import "MemberSettingViewController.h"
#import "UserModel.h"


@interface LoginViewController () <UITextFieldDelegate,SignInDelegate>
{
    UIButton *forgotpsswordBtn,*logInBtn,*RememberPassword;
    UILabel  *autoLonInLabel;
    UIImageView *headImageView,*backgroundImage,*accountHintImage,*passwordHintImage;
}
@property (nonatomic,assign) BOOL  isRead;
@property (strong,nonatomic) ASIFormDataRequest *request;
@end

@implementation LoginViewController
@synthesize Remember=_Remember;

NSString * const KEY_USERNAME = @"com.private.username";
NSString * const KEY_PASSWORD = @"com.private.password";



- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self viewInit];
    _isInLoginVC=YES;
    
}

-(void)viewWillAppear:(BOOL)animated
{

    self.navigationController.navigationBarHidden=NO;

}


-(void)viewDidDisappear:(BOOL)animated
{
    _isInLoginVC=NO;
  
    
}





//界面初始化
-(void)viewInit
{
    
   
    self.view.backgroundColor = COLOR_BACKGROUND;
    self.title =NSLocalizedString(@"Login", @"");
    //从贴吧登陆是需要改变
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"SIGN IN", nil) style:UIBarButtonItemStylePlain target:self action:@selector(signIn:)];

    
    float value;
    if (_isFromPostbar==YES) {
        value=60.0;
    }else{
    
        value=0;
    }
    
    backgroundImage=[[UIImageView alloc] initWithFrame:CGRectMake(0, value, kScreen_Width, 140)];
    backgroundImage.image=[UIImage imageNamed:@"accountBg"];
    [self.view addSubview:backgroundImage];
    
    //头像
    headImageView=[[UIImageView alloc] initWithFrame:CGRectMake(110, 20, 100, 100)];
    headImageView.image=[UIImage imageNamed:@"accountHeader"];
    headImageView.layer.cornerRadius = 50;
    headImageView.layer.masksToBounds = YES;
    headImageView.layer.borderWidth=4;
    headImageView.layer.borderColor=COLOR_WHITE_NEW.CGColor;
    headImageView.contentMode = UIViewContentModeScaleAspectFit;
    [backgroundImage addSubview:headImageView];
    
    
    //提示图片
    accountHintImage=[[UIImageView alloc] initWithFrame:CGRectMake(10, 155+value, 40, 40)];
    accountHintImage.image=[UIImage imageNamed:@"accountHint"];
    [self.view addSubview:accountHintImage];
    passwordHintImage=[[UIImageView alloc] initWithFrame:CGRectMake(10, 205+value, 40, 40)];
    passwordHintImage.image=[UIImage imageNamed:@"passwordHint"];
    [self.view addSubview:passwordHintImage];
    
    
    
    //用户名
    _userbox=[self textFieldInit:_userbox placeholder:NSLocalizedString(@"NAME", nil) Frame:CGRectMake(50, 155+value, 260, 40) Tag:Tag_AccountTextField];
    _userbox.text = [JRKeyChainHelper getUserNameWithService:KEY_USERNAME];
    
    //密码
    _passwordbox=[self textFieldInit:_passwordbox placeholder:NSLocalizedString(@"PASSWORD", nil) Frame:CGRectMake(50, 205+value, 260, 40) Tag:Tag_TempPasswordTextField];
    [_passwordbox setSecureTextEntry:YES];
    _passwordbox.text = [JRKeyChainHelper getPasswordWithService:KEY_PASSWORD];
   
    
    //记住密码选择框
    NSUserDefaults *passwordObject = [NSUserDefaults standardUserDefaults];
    _Remember = [passwordObject boolForKey:@"rememberPassword"];
    
    RememberPassword = [UIButton buttonWithType:UIButtonTypeCustom];
    [RememberPassword setFrame:CGRectMake(12, 266+value, 28, 28)];
    RememberPassword.layer.cornerRadius = 6;
    [RememberPassword setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"radiobox_0"]]];
    if (_Remember == NO) {
        [RememberPassword setImage:nil forState:UIControlStateNormal];
    }else{
        [RememberPassword setImage:[UIImage imageNamed:@"checkbox_1"] forState:UIControlStateNormal];
    }
    [RememberPassword addTarget:self action:@selector(RememberPassword:) forControlEvents:UIControlEventTouchUpInside];
    //记住密码提示框
    autoLonInLabel=[self labelInit:autoLonInLabel name:@"Remember the password" frame:CGRectMake(44, 264+value, 200, 30) fontsize:14.0];
    
    //忘记密码
    forgotpsswordBtn=[self buttonInit:forgotpsswordBtn setTitle:@"FORGOT?" action:@selector(getPassword:) size:CGRectMake(160,264+value,150,30) withFontSize:14.0 color:COLOR_LIGHT_BLUE_THEME];
    [forgotpsswordBtn setContentHorizontalAlignment:UIControlContentHorizontalAlignmentRight];
    

    //登陆
    logInBtn=[self buttonInit:logInBtn setTitle:@"LOGIN" action:@selector(logIn:) size:CGRectMake(10,310+value,300,40) withFontSize:18.0 color:COLOR_BACKGROUND];
    logInBtn.backgroundColor=COLOR_LIGHT_BLUE_THEME;
    logInBtn.layer.cornerRadius=4;
    logInBtn.layer.masksToBounds=YES;
    logInBtn.titleLabel.font = [UIFont boldSystemFontOfSize: 18.0];
    

    [self.view addSubview:_userbox];
    [self.view addSubview:_passwordbox];
    [self.view addSubview:RememberPassword];
    [self.view addSubview:forgotpsswordBtn];
    [self.view addSubview:autoLonInLabel];
    [self.view addSubview:logInBtn];
    

    //添加键盘通知
    //注册键盘出现与隐藏时候的通知
         [[NSNotificationCenter defaultCenter] addObserver:self
                                                          selector:@selector(keyboadWillShow:)
                                                          name:UIKeyboardWillShowNotification
                                                          object:nil];
         [[NSNotificationCenter defaultCenter] addObserver:self
            selector:@selector(keyboardWillHide:)
                                                       name:UIKeyboardWillHideNotification
                                                       object:nil];
         //添加手势，点击屏幕其他区域关闭键盘的操作
         UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboard)];
         gesture.numberOfTapsRequired = 1;//手势敲击的次数
         [self.view addGestureRecognizer:gesture];
    

    
}







 //键盘出现时候调用的事件
 -(void) keyboadWillShow:(NSNotification *)note{
     
     float value;
     if (_isFromPostbar==YES) {
         value=60.0;
     }else{
         
         value=0;
     }
     
         [UIView beginAnimations:nil context:NULL];
         [UIView setAnimationDuration:0.3];
         self.view.frame = CGRectMake(0, -80-value, kScreen_Width, kScreen_Height);
         [UIView commitAnimations];
    
     }
 //键盘消失时候调用的事件
 -(void)keyboardWillHide:(NSNotification *)note{

     float value;
     if (_isFromPostbar==YES) {
         value=60.0;
     }else{
         
         value=0;
     }
         [UIView beginAnimations:nil context:NULL];//此处添加动画，使之变化平滑一点
         [UIView setAnimationDuration:0.3];
         self.view.frame = CGRectMake(0, 64-value, kScreen_Width, kScreen_Height);
         [UIView commitAnimations];
     }


//隐藏键盘方法
 -(void)hideKeyboard{
         [_userbox resignFirstResponder];
     }





-(NSDictionary*) returnUserNameAndPassword
{
    NSDictionary *dic=[[NSDictionary alloc] initWithObjectsAndKeys:[JRKeyChainHelper getUserNameWithService:KEY_USERNAME],@"username",[JRKeyChainHelper getPasswordWithService:KEY_PASSWORD],@"userpassword" ,nil];
    
    return dic;
    
}






#pragma mark---------------------------init method

-(UIButton*) buttonInit:(UIButton*)button setTitle:(NSString*)name action:(SEL)action size:(CGRect)frame withFontSize:(float)size color:(UIColor*)color{
    
    button=[UIButton buttonWithType:UIButtonTypeRoundedRect];
    button.titleLabel.font = [UIFont systemFontOfSize: size];
    [button setTitle:NSLocalizedString(name, @"") forState:UIControlStateNormal];
    [button setTitleColor:color forState:UIControlStateNormal];
    [button addTarget:self action:action forControlEvents:UIControlEventTouchUpInside];
    button.backgroundColor=[UIColor clearColor];
    button.frame = frame;
    return button;
    
}

-(UILabel*) labelInit:(UILabel*)label name:(NSString*)string frame:(CGRect)frame fontsize:(float)size{
    
    label=[[UILabel alloc] init];
    label.text=NSLocalizedString(string, @"");
    label.backgroundColor=[UIColor clearColor];
    label.textColor=COLOR_LIGHT_BLUE_THEME;
    label.font = [UIFont systemFontOfSize:size];
    label.frame = frame;
    return label;
}


-(UITextField*) textFieldInit:(UITextField*)textfield placeholder:(NSString*)string Frame:(CGRect)frame Tag:(NSInteger)tag
{
    textfield=[[UITextField alloc] initWithFrame:frame];
    [textfield setBorderStyle:UITextBorderStyleRoundedRect];
    textfield.placeholder = NSLocalizedString(string, @"");
    textfield.tag = tag;
    textfield.delegate =self;
    textfield.autocorrectionType = UITextAutocorrectionTypeNo;
    textfield.autocapitalizationType = UITextAutocapitalizationTypeNone;
    textfield.returnKeyType = UIReturnKeyDone;
    textfield.clearButtonMode = UITextFieldViewModeWhileEditing;
    return textfield;
}



#pragma mark ----------------------- RegisterBtnClicked Method
- (void)logIn:(id)sender{
    
    NSString* userName = _userbox.text;
    NSString* pwd = _passwordbox.text;
    if (_Remember)
    {
        [JRKeyChainHelper saveUserName:userName userNameService:KEY_USERNAME psaaword:pwd psaawordService:KEY_PASSWORD];
    }
    
    if ([self checkValidityTextField]) {
        if (NO) {
            [Utils alertTitle:nil message:@"Wrong username or password" delegate:self cancelBtn:@"Fill again" otherBtnName:nil];
        }else {
            logInBtn.enabled=NO;
            [self LinkNetWork:API_LOGIN_URL];
        }
    }
}


- (void)RememberPassword:(id)sender{
    
    if (_Remember==YES) {
        
        [JRKeyChainHelper deleteWithUserNameService:KEY_USERNAME psaawordService:KEY_PASSWORD];
        [RememberPassword setImage:nil forState:UIControlStateNormal];
        _Remember = NO;
        
        
        
    }else if(_Remember==NO){
        [RememberPassword setImage:[UIImage imageNamed:@"checkbox_1"] forState:UIControlStateNormal];
        _Remember = YES;
        
        
    }
    
    //存储按钮状态
    NSUserDefaults *passwordObject = [NSUserDefaults standardUserDefaults];
    [passwordObject setBool:_Remember forKey:@"rememberPassword"];
    [passwordObject synchronize];
    
    
}




#pragma mark checkValidityTextField Null

- (BOOL)checkValidityTextField
{
    
    
    if ([(UITextField *)[self.view viewWithTag:Tag_AccountTextField] text] == nil || [[(UITextField *)[self.view viewWithTag:Tag_AccountTextField] text] isEqualToString:@""]) {
        
        [Utils alertTitle:nil message:NSLocalizedString(@"NO user name", "") delegate:self cancelBtn:NSLocalizedString(@"Cancel", "") otherBtnName:nil];
        
        return NO;
    }
    if ([(UITextField *)[self.view viewWithTag:Tag_TempPasswordTextField] text] == nil || [[(UITextField *)[self.view viewWithTag:Tag_TempPasswordTextField] text] isEqualToString:@""]) {
        
        [Utils alertTitle:nil message:NSLocalizedString(@"NO password", "") delegate:self cancelBtn:NSLocalizedString(@"Cancel", "") otherBtnName:nil];
        
        return NO;
    }
    
    if ([[(UITextField *)[self.view viewWithTag:Tag_TempPasswordTextField] text] length] < 6) {
        
        [Utils alertTitle:nil message:NSLocalizedString(@"Password lengh must be over 6 numbers including letters!", "") delegate:nil cancelBtn:NSLocalizedString(@"Cancel", "") otherBtnName:nil];
        return NO;
    }
    
    
    return YES;
    
}


-(void)getPassword:(UIButton *)btn
{
    self.navigationController.navigationBar.hidden = NO;
    GetPasswordViewController *getPasswordView =[[GetPasswordViewController alloc] init];
    [self.navigationController pushViewController:getPasswordView animated:YES];
}

-(void)signIn:(UIButton *)btn
{
    self.navigationController.navigationBar.hidden = NO;
    SignInViewController *signInVC = [[SignInViewController alloc] init];
    signInVC.delegate=self;
    [self.navigationController pushViewController:signInVC animated:YES];
    
}


#pragma -mark signInDelegate
-(void)setNameAndPwd:(NSArray*)array
{
    _userbox.text=[array objectAtIndex:0];
    _passwordbox.text=[array objectAtIndex:1];
  
}


- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    
    [textField resignFirstResponder];
    
    return YES;
}

#pragma mark - touchMethod
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    
    [super touchesBegan:touches withEvent:event];
    
    [self allEditActionsResignFirstResponder];
}

#pragma mark - PrivateMethod
- (void)allEditActionsResignFirstResponder{
    
    //用户名
    [[self.view viewWithTag:Tag_AccountTextField] resignFirstResponder];
    //temp密码
    [[self.view viewWithTag:Tag_TempPasswordTextField] resignFirstResponder];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void)dealloc
{
    
    [_request cancel];
    [_request clearDelegatesAndCancel];
    [[NSNotificationCenter defaultCenter] removeObserver:self];//移除观察者
    
}


#pragma -mark UITextFieldDelegate

//开始编辑：
 - (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
 {
         return YES;
 }



- (void)LinkNetWork:(NSString *)strUrl
{
        _request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:strUrl]];
        [_request setDelegate:self];
        [_request setShouldAttemptPersistentConnection:NO];
        [_request setTimeOutSeconds:10];
        
        if ([strUrl isEqualToString:API_GETUSERINFO_URL]) {
            _request.tag=102;
        }else {
            
            [_request setRequestMethod:@"POST"];
            
            if (_isInLoginVC==YES) {
                [_request setPostValue:_userbox.text forKey:@"username"];
                [_request setPostValue:_passwordbox.text forKey:@"userpassword"];
            }else{
                
                [_request setPostValue:[[self returnUserNameAndPassword] objectForKey:@"username"] forKey:@"username"];
                [_request setPostValue:[[self returnUserNameAndPassword] objectForKey:@"userpassword"] forKey:@"userpassword"];
            }
            
            
            if (_isInLoginVC==YES) {
                [MMProgressHUD showWithTitle:nil status:NSLocalizedString(@"Loading...", @"")];
            }
            
          
        }
        
        [_request startAsynchronous];
}


- (void)requestFailed:(ASIFormDataRequest *)request
{
    [MMProgressHUD dismissWithError:NSLocalizedString(@"Failed to connect link to server!", "")];
     logInBtn.enabled=YES;
}

- (void)requestFinished:(ASIFormDataRequest *)request
{
    NSData *jsonData = [request.responseString dataUsingEncoding:NSUTF8StringEncoding];
    NSError *error;
    NSMutableDictionary *rootDic = [[CJSONDeserializer deserializer] deserialize:jsonData error:&error];
    int status=[[rootDic objectForKey:@"code"] intValue];
    if (request.tag==102) {
        if (status==1) {
            logInBtn.enabled=YES;
            
            NSDictionary *dic=[[NSDictionary alloc] initWithDictionary:[rootDic objectForKey:@"data"]];
            
            [[LocalStroge sharedInstance] addObject:dic forKey:F_USER_INFORMATION filePath:NSDocumentDirectory];
            
            if (self.navigationController.viewControllers.count==1) {
                
                MemberSettingViewController *secVC = [[MemberSettingViewController alloc] init];
                [self.navigationController pushViewController:secVC animated:YES];
                
                if ([[dic objectForKey:@"customer_headimage"] isEqualToString:@""]) {
                    
                    [secVC.headView setImage:[UIImage imageNamed:@"accountHeader.png"]];
                }else{
                    
                    [secVC.headView setImageWithURL:[dic objectForKey:@"customer_headimage"]];
                    
                }
                secVC.userName =[NSString stringWithFormat:@"Name:%@",[dic objectForKey:@"customer_name"]];
                secVC.userNickname =[NSString stringWithFormat:@"Nickname:%@",[dic objectForKey:@"customer_nickname"]];
                secVC.userLevel=[NSString stringWithFormat:@"Level:%@",[dic objectForKey:@"customer_degree"]];
                
                
                [secVC.memberTableView reloadData];
                
                
            }else
            {
            //加入通知,登录后主界面要进行刷新
            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_USER_LOGOUT object:nil];
                [self.navigationController popViewControllerAnimated:YES];
            }
            
        }
        else{
            if (_isInLoginVC==YES) {
                [MMProgressHUD showWithTitle:nil status:NSLocalizedString(@"Get user information...", "")];
                [MMProgressHUD dismissWithError:[rootDic objectForKey:@"data"]];
            }
        }
        
        
    }else{
        
        if (status==1) {
    
        
        [MMProgressHUD dismissWithSuccess:nil];
        
        
        NSDictionary *userDic=[rootDic objectForKey:@"data"];
        
        NSUserDefaults *userSid=[NSUserDefaults standardUserDefaults];
        [userSid setObject:[userDic objectForKey:@"sid"] forKey:API_LOGIN_SID];
        [userSid synchronize];
        
        
        [self LinkNetWork:API_GETUSERINFO_URL];
        
        
    }
    else{
        
        if ([rootDic objectForKey:@"data"]==NULL) {
            [MMProgressHUD dismissWithError:NSLocalizedString(@"error", @"")];
        }
        [MMProgressHUD dismissWithError:[rootDic objectForKey:@"data"]];
        logInBtn.enabled=YES;
    }
    }
}



@end
