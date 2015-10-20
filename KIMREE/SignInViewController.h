//
//  SignInViewController.h
//  ECIGARFAN
//
//  Created by renchunyu on 14-4-15.
//  Copyright (c) 2014年 renchunyu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Public.h"
#import "LoginViewController.h"


@protocol SignInDelegate <NSObject>

-(void)setNameAndPwd:(NSArray*)array;

@end


@interface SignInViewController : UIViewController

{
    UIButton *submitBtn,*serviceBtn;
    UILabel  *agreeInLabel;
    UITextField *nickname,*email,*passwordbox,*comfirmpasswordbox;
    UIView  *serveProtocolView;
}
@property (strong,nonatomic) id<SignInDelegate>delegate;
@end
