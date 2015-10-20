//
//  MainViewController.m
//  ECIGARFAN
//
//  Created by renchunyu on 14-8-13.
//  Copyright (c) 2014年 renchunyu. All rights reserved.
//

#import "MainViewController.h"
#import "NavigationAnimation.h"
//#import "PostBarViewController.h"
#import "CigAndWineViewController.h"
#import "NearbyViewController.h"

#import "MemberSettingViewController.h"
#import "LoginViewController.h"
#if TESTVERSION
#include "InformationViewController.h"
#else
#import "NewInformationViewController.h"
#endif

#import "JRWebViewController.h"


@interface MainViewController ()<UITabBarControllerDelegate,UINavigationControllerDelegate>

@property (strong,nonatomic) NavigationAnimation *navAnimation;
//@property (strong,nonatomic) PostBarViewController *postVC;
@property (strong,nonatomic) CigAndWineViewController *wineVC;

@property (strong,nonatomic) NearbyViewController *nearbyVC;
@property (strong,nonatomic) MemberSettingViewController *memberSettingVC;
@property (strong,nonatomic) UINavigationController *userNav;
@property (strong,nonatomic) UINavigationController *informationNav;
@property (strong,nonatomic) UINavigationController *wineNav;
@property (strong,nonatomic) UINavigationController *nearbyNav;
@property (strong,nonatomic)  LoginViewController *loginVC;
#if TESTVERSION
@property (strong,nonatomic) InformationViewController *informationV;
#else
@property (strong,nonatomic) NewInformationViewController *informationVC;
#endif

@end

@implementation MainViewController

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
    
    self.delegate=self;
    //视图初始化
    [self viewInit];
}

#pragma mark
#pragma mark view init method


-(void)viewInit
{
    
    _navAnimation=[NavigationAnimation new];
    
    //资讯
    
#if TESTVERSION
    _informationV=[[InformationViewController alloc] init];
    _informationNav=[self UINavigationControllerWithRootVC:_informationV image:@"information" title:@"News"];
#else
//    _informationVC=[[NewInformationViewController alloc] init];
//    _informationNav=[self UINavigationControllerWithRootVC:_informationVC image:@"information" title:@"News"];
    
    
    JRWebViewController *webVC=[[JRWebViewController alloc] init];
    webVC.URL=[NSURL URLWithString:@"http://www.ecigarfan.com/"];
    webVC.mode=WebBrowserModeModal;
    _informationNav=[self UINavigationControllerWithRootVC:webVC image:@"information" title:@"News"];
    _informationNav.delegate=self;
    
#endif
    
    //自动登录
    _loginVC=[[LoginViewController alloc] init];
    
    if ([[LocalStroge sharedInstance] getObjectAtKey:F_USER_INFORMATION filePath:NSDocumentDirectory]) {
        [_loginVC LinkNetWork:API_LOGIN_URL];
    }
//    
//    //烟酒
//    _wineVC = [[CigAndWineViewController alloc] init] ;
//    _wineNav=[self UINavigationControllerWithRootVC:_wineVC image:@"wine" title:@"Cigarettes and Wine"];
//    _wineNav.delegate=self;
    
    //附近
    _nearbyVC=[[NearbyViewController alloc] init];
    _nearbyNav=[self UINavigationControllerWithRootVC:_nearbyVC image:@"circum" title:@"E-cigarette"];
    _nearbyNav.delegate=self;

     //用户
    _memberSettingVC=[[MemberSettingViewController alloc] init];
    _userNav=[self UINavigationControllerWithRootVC:_memberSettingVC image:@"Me" title:@"Account"];
    _userNav.delegate=self;

    self.viewControllers = [NSArray arrayWithObjects:_informationNav/*,_wineNav*/,_nearbyNav,_userNav,nil];
    self.tabBar.barStyle=UIBarStyleDefault;
    //选中颜色
    self.tabBar.tintColor=COLOR_LIGHT_BLUE_THEME;
    
    
}


-(UINavigationController*)UINavigationControllerWithRootVC:(UIViewController*)VC image:(NSString*)image title:(NSString*) title
{
    UINavigationController *nav=[[UINavigationController alloc] initWithRootViewController:VC];
    VC.tabBarItem.image=[UIImage imageNamed:image];
    VC.title=NSLocalizedString(title, nil);
    nav.navigationBar.tintColor=COLOR_WHITE_NEW;
    return nav;
}



#pragma mark
#pragma mark UITabBarControllerDelegate

- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController{
    
    self.navigationController.navigationBarHidden=NO;
    
    if (self.selectedIndex==0) {
        #if TESTVERSION
        //清除缓存后重新获取广告内容
        if ([[LocalStroge sharedInstance] getObjectAtKey:F_ADVERTISEMENT filePath:NSCachesDirectory]==nil) {
        
            //获取广告信息
            [_informationV getInformationFromNetwork:API_GETADVERTISEMENT_URL];
        }
        #endif
    }
    
    
#if TESTVERSION
#else
[[[self.viewControllers objectAtIndex:0] tabBarItem] setTitle:NSLocalizedString(@"News", nil)];
 
#endif

    

}


- (id <UIViewControllerAnimatedTransitioning>)navigationController:(UINavigationController *)navigationController
                                   animationControllerForOperation:(UINavigationControllerOperation)operation
                                                fromViewController:(UIViewController *)fromVC
                                                  toViewController:(UIViewController *)toVC
{
    
    
    return _navAnimation;
    
    
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
