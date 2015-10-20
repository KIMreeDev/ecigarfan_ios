//
//  NewInformationViewController.m
//  ECIGARFAN
//
//  Created by renchunyu on 14-8-13.
//  Copyright (c) 2014年 renchunyu. All rights reserved.


#import "NewInformationViewController.h"

@interface NewInformationViewController ()
{
    UIActivityIndicatorView  *activityIndicator;
}
@property (nonatomic, strong) UISwipeGestureRecognizer *leftSwipeGestureRecognizer;
@property (nonatomic, strong) UISwipeGestureRecognizer *rightSwipeGestureRecognizer;
@property (nonatomic,strong) UIWebView *webView;
@property (nonatomic,strong) UIButton *reloadBtn;
@property (nonatomic,strong) UIButton *stopBtn;
@property (strong,nonatomic)UIBarButtonItem *gobackBtn;
@property (strong,nonatomic)UIBarButtonItem *goforwardBtn;
@end

@implementation NewInformationViewController

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
    self.title = NSLocalizedString(@"News", nil);
    
    _webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, 320, 568)];
    _webView.delegate=self;
    NSURLRequest *request =[NSURLRequest requestWithURL:[NSURL URLWithString:@"http://www.ecigarfan.com"]];
    [self.view addSubview: _webView];
    [_webView loadRequest:request];
    
    
    _reloadBtn=[UIButton buttonWithType:UIButtonTypeCustom];
    _reloadBtn.frame=CGRectMake(10, kScreen_Height-105, 50, 50);
    [_reloadBtn setImage:[UIImage imageNamed:@"reload"] forState:UIControlStateNormal];
    [_reloadBtn addTarget:self action:@selector(reloadWebPage) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_reloadBtn];
    
    
    _stopBtn=[UIButton buttonWithType:UIButtonTypeCustom];
    _stopBtn.frame=CGRectMake(10, kScreen_Height-105, 50, 50);
    [_stopBtn setImage:[UIImage imageNamed:@"loadingStop"] forState:UIControlStateNormal];
    [_stopBtn addTarget:self action:@selector(stopWebPage) forControlEvents:UIControlEventTouchUpInside];
    
    //增加左右滑动手势
    self.leftSwipeGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipes:)];
    self.rightSwipeGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipes:)];
    
    self.leftSwipeGestureRecognizer.direction = UISwipeGestureRecognizerDirectionLeft;
    self.rightSwipeGestureRecognizer.direction = UISwipeGestureRecognizerDirectionRight;
    
    [self.view addGestureRecognizer:self.leftSwipeGestureRecognizer];
    [self.view addGestureRecognizer:self.rightSwipeGestureRecognizer];

    //接收通知
    [[NSNotificationCenter defaultCenter]  addObserver:self  selector:@selector(reloadOrStop)  name:@"isLoading" object:nil];
   
    _gobackBtn=[[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"goback"] style:UIBarButtonItemStylePlain target:self action:@selector(goBack)];
    self.navigationItem.leftBarButtonItem =_gobackBtn;
    _goforwardBtn.enabled=NO;
    
    
    _goforwardBtn=[[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"goforward"] style:UIBarButtonItemStylePlain target:self action:@selector(goForward)];
    self.navigationItem.rightBarButtonItem =_goforwardBtn;
    _goforwardBtn.enabled=NO;

}


-(void)goForward
{
    [_webView goForward];


}

-(void)goBack
{
    [_webView goBack];


    
}



//滑动方法

- (void)handleSwipes:(UISwipeGestureRecognizer *)sender
{
    if (sender.direction == UISwipeGestureRecognizerDirectionLeft) {
      
       

    }
    
    if (sender.direction == UISwipeGestureRecognizerDirectionRight) {
     
        [_webView goBack];

    }
}

//重载方法
-(void)reloadOrStop
{
    if (_webView.isLoading) {
        [_reloadBtn removeFromSuperview];
        [self.view addSubview:_stopBtn];
    }else
    {
        [_stopBtn removeFromSuperview];
        [self.view addSubview:_reloadBtn];
    }
    
}

-(void)reloadWebPage
{
    [_webView reload];

}

-(void)stopWebPage
{
    [_webView stopLoading];
    [self refreshButtonState];
}


#pragma mark
#pragma mark webView method

- (void) webViewDidStartLoad:(UIWebView *)webView
{
    //发送通知
    [[NSNotificationCenter defaultCenter] postNotificationName:@"isLoading" object:nil];
    
//    //创建UIActivityIndicatorView背底半透明View
//    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 568)];
//    [view setTag:108];
//    [view setBackgroundColor:[UIColor blackColor]];
//    [view setAlpha:0.5];
//    [self.view addSubview:view];
//    
//    activityIndicator = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 32.0f, 32.0f)];
//    [activityIndicator setCenter:view.center];
//    [activityIndicator setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleWhite];
//    [view addSubview:activityIndicator];
//    
//    [activityIndicator startAnimating];
    
}



- (void) webViewDidFinishLoad:(UIWebView *)webView
{
    //发送通知
    [[NSNotificationCenter defaultCenter] postNotificationName:@"isLoading" object:nil];
    
//    [activityIndicator stopAnimating];
//    
//    UIView *view = (UIView*)[self.view viewWithTag:108];
//    [view removeFromSuperview];
//    NSLog(@"webViewDidFinishLoad");
    
    [self refreshButtonState];
    
}
- (void) webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    //发送通知
    [[NSNotificationCenter defaultCenter] postNotificationName:@"isLoading" object:nil];
//    [activityIndicator stopAnimating];
//    UIView *view = (UIView*)[self.view viewWithTag:108];
//    [view removeFromSuperview];
//    NSLog(@"didFailLoadWithError:%@", error);
    
    [self refreshButtonState];
}


-(void) refreshButtonState
{
    if (_webView.canGoBack==YES) {
        _gobackBtn.enabled=YES;
    }else
    {
        
        _gobackBtn.enabled=NO;
    }
    
    if (_webView.canGoForward==YES) {
        _goforwardBtn.enabled=YES;
    }else
    {
        
        _goforwardBtn.enabled=NO;
    }

}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
