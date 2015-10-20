//
//  LoginViewController.h
//  ECIGARFAN
//
//  Created by renchunyu on 14-5-20.
//  Copyright (c) 2014年 renchunyu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"
#import "GetPasswordViewController.h"
#import "Public.h"
#import "ASIFormDataRequest.h"
#import "ApiDef.h"
#import "SignInViewController.h"


@interface LoginViewController : UIViewController

@property (nonatomic,strong) UITextField *userbox,*passwordbox;
@property (nonatomic,assign)BOOL Remember,isInLoginVC,isFromPostbar;
- (void)LinkNetWork:(NSString *)strUrl;

@end
