//
//  InformationViewController.m
//  ECIGARFAN
//
//  Created by renchunyu on 14-8-15.
//  Copyright (c) 2014年 renchunyu. All rights reserved.
//

#import "InformationViewController.h"
#import "JRWebViewController.h"
#import "ContentTableViewController.h"



@interface InformationViewController ()
{
    NSMutableArray *imagesArray,*titleArray,*urlArray;
    
}
@property (strong,nonatomic)  ASIHTTPRequest *request;
@property (strong, nonatomic)  EScrollerView *newsView;
@end

@implementation InformationViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}


-(void)viewWillAppear:(BOOL)animated
{

    //初始启动获取本地默认列表
    if ([[[LocalStroge sharedInstance] getObjectAtKey:F_WEBSITE_SELECTED filePath:NSCachesDirectory] count]==0) {
        //更新选中表
        NSMutableArray *data = [[NSMutableArray alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"webSite.plist" ofType:nil]];
        NSMutableArray *array=[[NSMutableArray alloc] init];
        for (int i=0; i<[data count]; i++) {
            if ([[[data objectAtIndex:i] objectForKey:@"status"] isEqualToString:@"1"]) {
                
                [array addObject:[data objectAtIndex:i]];
            }
        }
        [[LocalStroge sharedInstance] addObject:array forKey:F_WEBSITE_SELECTED filePath:NSCachesDirectory];
    }
    
    
     _dataList=[[LocalStroge sharedInstance] getObjectAtKey:F_WEBSITE_SELECTED filePath:NSCachesDirectory];
     [_contentCollectionView reloadData];

}


- (void)viewDidLoad
{
    [super viewDidLoad];
    _contentCollectionView.backgroundColor=COLOR_WHITE_NEW;

    
    //注册cell
    [_contentCollectionView  registerClass:[InformationCell class] forCellWithReuseIdentifier:@"InformationCell"];
    //注册表头
    [_contentCollectionView registerNib:[UINib nibWithNibName:@"PhotoSupplementaryView" bundle:nil] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"PhotoSupplementaryView"];
    
    
    //获取广告信息
    [self getInformationFromNetwork:API_GETADVERTISEMENT_URL];
    
}



//设置新闻栏
-(UIView*)creatNews
{
    
    [self initAdvertisementArray];
    _newsView =[[EScrollerView alloc]
                initWithFrameRect:CGRectMake(0,0,kScreen_Width,200)
                ImageArray:[NSArray arrayWithArray:imagesArray]
                TitleArray:[NSArray arrayWithArray:titleArray]];
    _newsView.backgroundColor=COLOR_DARK_GRAY;
    _newsView.delegate = self;
    return _newsView;
}

//初始化广告数组
- (void) initAdvertisementArray {
    

    if ([[LocalStroge sharedInstance] getObjectAtKey:F_ADVERTISEMENT filePath:NSCachesDirectory]!=nil) {
        NSArray *array=[[LocalStroge sharedInstance] getObjectAtKey:F_ADVERTISEMENT filePath:NSCachesDirectory];
        imagesArray =[[NSMutableArray alloc] init];
        titleArray =[[NSMutableArray alloc] init];
        urlArray =[[NSMutableArray alloc] init];
        
        for (int i=0; i<[array count]; i++) {
            
            [imagesArray addObject:[[array objectAtIndex:i] objectForKey:@"adimage"]];
            [titleArray addObject:[[array objectAtIndex:i] objectForKey:@"adalt"]];
            [urlArray addObject:[[array objectAtIndex:i] objectForKey:@"adurl"]];
        }
        
    }else {
        
        imagesArray =[[NSMutableArray alloc] initWithObjects:@"advertisement.jpg", nil];
        titleArray =[[NSMutableArray alloc] initWithObjects:@"", nil];
        urlArray =[[NSMutableArray alloc] initWithObjects:@"http://www.ecigarfan.com/", nil];
    }
    
    
    //NSLog(@"%@",titleArray);
    
    
}

//点击新闻图片触发的事件
#pragma EScrollerViewDelegate--
-(void)EScrollerViewDidClicked:(NSUInteger)index
{
    
    
    
    if ([urlArray count]!=0) {
        JRWebViewController *JRwebView=[[JRWebViewController alloc] init];
        JRwebView.mode=WebBrowserModeModal;
        
        if ([[urlArray objectAtIndex:index-1] isEqualToString:@""]) {
            
        }else{
            JRwebView.URL=[NSURL URLWithString:[urlArray objectAtIndex:index-1]];
            [self presentViewController:JRwebView animated:YES completion:nil];
        }
        
    }
    
    
}




#pragma mark
#pragma mark UICollectionViewDatasource


//定义展示的Section的个数
-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

//每个section的item个数
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [_dataList count]+1;
}


//表头文件
- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath{
    
    
    UICollectionReusableView *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader  withReuseIdentifier:@"PhotoSupplementaryView" forIndexPath:indexPath];
    //加入广告表头
    [headerView addSubview:[self creatNews]];
    return headerView;;
}







//每个UICollectionView展示的内容
-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString * CellIdentifier = @"InformationCell";
    
    InformationCell * cell = (InformationCell *)[collectionView dequeueReusableCellWithReuseIdentifier:CellIdentifier forIndexPath:indexPath];
    [cell sizeToFit];
    //[cell.layer setBorderWidth:1];
    //[cell.layer setBorderColor:COLOR_MIDDLE_GRAY.CGColor];
    
    cell.tag=indexPath.item;
    cell.delegate=self;
    
    if (indexPath.item==[_dataList count]) {
        cell.testString.text=NSLocalizedString(@"Add content", nil);
        cell.contentImage.image=[UIImage imageNamed:@"addToDefault"];
        
    }else{
        
        cell.testString.text=@"";
        cell.contentImage.image=[UIImage imageNamed:[[_dataList objectAtIndex:indexPath.item] objectForKey:@"image"]];
    }
    

    return cell;
}



#pragma mark
#pragma mark

-(void)deleteAction:(NSInteger)index
{
    if (index!=[_dataList count]) {
        UIActionSheet *actionSheet = [[UIActionSheet alloc]
                                      initWithTitle:NSLocalizedString(@"Delete the channel?", nil)
                                      delegate:self
                                      cancelButtonTitle:NSLocalizedString(@"Cancel", nil)
                                      destructiveButtonTitle:NSLocalizedString(@"Delete", nil)
                                      otherButtonTitles:nil];
        actionSheet.actionSheetStyle = UIActionSheetStyleBlackOpaque;
        [actionSheet showInView:self.view];
        actionSheet.tag=index;
    }
    
  
    
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex==0) {
        
        NSMutableArray *array=[[LocalStroge sharedInstance] getObjectAtKey:F_WEBSITE filePath:NSCachesDirectory];
        NSInteger index=[array indexOfObject:[_dataList objectAtIndex:actionSheet.tag]];
       
        //改变网页链接总表状态
        [[array objectAtIndex:index] setObject:@"0" forKey:@"status"];
        [[LocalStroge sharedInstance] addObject:array forKey:F_WEBSITE filePath:NSCachesDirectory];
        
        //改变选中网页状态
        [_dataList removeObjectAtIndex:actionSheet.tag];
        [[LocalStroge sharedInstance] addObject:_dataList forKey:F_WEBSITE_SELECTED filePath:NSCachesDirectory];
        
        [_contentCollectionView reloadData];
        
    }

}


#pragma mark
#pragma mark --UICollectionViewDelegateFlowLayout

//定义每个UICollectionView 的大小
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(106, 106);
}


//定义每个UICollectionView 的 margin
-(UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    UIEdgeInsets top = {0,0,0,0};
    return top;
}

#pragma mark
#pragma mark --UICollectionViewDelegate

//UICollectionView被选中时调用的方法
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.item==[_dataList count]) {
        ContentTableViewController *contentVC=[[ContentTableViewController alloc] init];
        [self.navigationController pushViewController:contentVC animated:YES];
        
    }else{
        
        JRWebViewController *webVC=[[JRWebViewController alloc] init];
        NSString *urlString=[[_dataList objectAtIndex:indexPath.item] objectForKey:@"website"];
        webVC.URL=[NSURL URLWithString:urlString];
        webVC.mode=WebBrowserModeModal;
        [self presentViewController:webVC animated:YES completion:nil];
    }
    

    
}
//返回这个UICollectionView是否可以被选择
-(BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (void)collectionView:(UICollectionView *)collectionView didHighlightItemAtIndexPath:(NSIndexPath *)indexPath
{
    
}

#pragma mark
#pragma mark 获取版头新闻
- (void)getInformationFromNetwork:(NSString *)strUrl
{
    _request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:strUrl]];
    [_request setDelegate:self];
    [_request setDownloadCache:[ASIDownloadCache sharedCache]];
    [_request setCachePolicy:ASIAskServerIfModifiedWhenStaleCachePolicy];
    [_request setShouldAttemptPersistentConnection:NO];
    [_request setTimeOutSeconds:10];
    [_request startAsynchronous];
    
}

- (void)requestFailed:(ASIHTTPRequest *)request
{
    [self creatNews];
    [_contentCollectionView reloadData];
    
}

- (void)requestFinished:(ASIHTTPRequest *)request
{
    NSData *jsonData = [request.responseString dataUsingEncoding:NSUTF8StringEncoding];
    
    NSError *error;
    
    NSMutableDictionary *rootDic = [[CJSONDeserializer deserializer] deserialize:jsonData error:&error];
    
    int status=[[rootDic objectForKey:@"code"] intValue];
    
    if (status==1) {
        
        //存储
        NSArray *array=[[NSArray alloc] initWithArray:[[LocalStroge sharedInstance] getObjectAtKey:F_ADVERTISEMENT filePath:NSCachesDirectory]];
        if (![array count]==0) {
            
            for (id object in [rootDic objectForKey:@"data"]) {
                if (![array containsObject:object]) {
                    [[LocalStroge sharedInstance] deleteFileforKey:F_ADVERTISEMENT filePath:NSCachesDirectory];
                    [[LocalStroge sharedInstance] addObject:[rootDic objectForKey:@"data"] forKey:F_ADVERTISEMENT filePath:NSCachesDirectory];                    }
                
            }
            
            
        }
        if ([array count]==0) {
            [[LocalStroge sharedInstance] addObject:[rootDic objectForKey:@"data"] forKey:F_ADVERTISEMENT filePath:NSCachesDirectory];
        }
        
        
        [self creatNews];
        [_contentCollectionView reloadData];
        
    }else{
        //[MMProgressHUD dismissWithError:[rootDic objectForKey:@"data"]];
        
    }
    
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
