//
//  ContentTableViewController.m
//  ECIGARFAN
//
//  Created by renchunyu on 14-8-15.
//  Copyright (c) 2014年 renchunyu. All rights reserved.
//

#import "ContentTableViewController.h"
#import "RepositoryCell.h"

@interface ContentTableViewController ()

@end

@implementation ContentTableViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title=NSLocalizedString(@"Repository", nil);
    
   
    if ([[LocalStroge sharedInstance] getObjectAtKey:F_WEBSITE filePath:NSCachesDirectory]==nil) {
          _dataList=[[NSMutableArray alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"webSite.plist" ofType:nil]];
        [[LocalStroge sharedInstance] addObject:_dataList forKey:F_WEBSITE filePath:NSCachesDirectory];
    }else{
        _dataList=[[LocalStroge sharedInstance] getObjectAtKey:F_WEBSITE filePath:NSCachesDirectory];
    }
  
    //接收重载界面通知
    [[NSNotificationCenter defaultCenter]  addObserver:self  selector:@selector(reloadTableView)  name:@"reloadContent" object:nil];

}

-(void)reloadTableView
{
    _dataList=[[LocalStroge sharedInstance] getObjectAtKey:F_WEBSITE filePath:NSCachesDirectory];
    [self.tableView reloadData];
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{

    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{

    return [_dataList count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 80;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString * CellIdentifier = @"webpage";
    
    RepositoryCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[NSBundle mainBundle] loadNibNamed:@"RepositoryCell" owner:self options:nil] lastObject];
        cell.selectionStyle=UITableViewCellSelectionStyleNone;
        
    }
    
  
   if ([[[NSLocale preferredLanguages] objectAtIndex:0] isEqualToString:@"zh-Hans"]) {
        cell.webSiteTitle.text=[[_dataList objectAtIndex:indexPath.row] objectForKey:@"titleCn"];
   }else {
    cell.webSiteTitle.text=[[_dataList objectAtIndex:indexPath.row] objectForKey:@"titleEn"];
   }
   
    
    UIImage *image=[UIImage imageNamed:[NSString stringWithFormat:@"%@",[[_dataList objectAtIndex:indexPath.row] objectForKey:@"image"]]];
  
    
    cell.webSiteImageView.image=[self cutImage:image];
    
 
    if ([[[_dataList objectAtIndex:indexPath.row] objectForKey:@"status"] isEqualToString:@"1"]) {
        
        cell.isSelected=YES;
        [cell.selectedBtn setImage:[UIImage imageNamed:@"remove"] forState:UIControlStateNormal];
    }else
    {
       cell.isSelected=NO;
        [cell.selectedBtn setImage:[UIImage imageNamed:@"add"] forState:UIControlStateNormal];
    }
    cell.selectedBtn.tag=indexPath.row;
    
    
    return cell;
}



//剪切图片，是按具体分辨率剪切

#pragma mark - 截取图片
- (UIImage*)cutImage:(UIImage*)image
{
    
    CGRect rect1 = CGRectMake(46, 46, 120, 120);
    //对图片进行截取
    UIImage * imageNew = [UIImage imageWithCGImage:CGImageCreateWithImageInRect([image CGImage], rect1)];
 
    return imageNew;
}







/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

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
