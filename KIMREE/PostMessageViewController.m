//
//  postMessageViewController.m
//  RFKeyboardToolbarDemo
//
//  Created by JIRUI on 14-5-9.
//  Copyright (c) 2014年 Rex Finn. All rights reserved.
//

#import "PostMessageViewController.h"
#import "Post.h"
#import "AllPostServer.h"
@interface PostMessageViewController ()
{
}
@end

@implementation PostMessageViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization

    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated{
    [UIView animateWithDuration:0.5 animations:^{
        self.tabBarController.tabBar.alpha = 0.0;
    } completion:nil];
    [super viewWillAppear:animated];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    _subTitle.text = NSLocalizedString(@"Subject", nil);
    _postContent.text = NSLocalizedString(@"Content", nil);
    // Do any additional setup after loading the view from its nib.
    [self initView];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [[AppHelper sharedInstance] clearImgPost];//清除沙盒中保存的图片
}

- (IBAction)chooseImage:(id)sender {
    UIActionSheet *sheet;
	// 判断是否支持相机
	if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
    {
        sheet= [[UIActionSheet alloc] initWithTitle:@"" delegate:(id)self cancelButtonTitle:nil destructiveButtonTitle:NSLocalizedString(@"Cancel", nil) otherButtonTitles:NSLocalizedString(@"TakingPictures", nil), NSLocalizedString(@"FromTheAlbumToChoose", nil), nil];
    } else {
        
        sheet = [[UIActionSheet alloc] initWithTitle:@"" delegate:(id)self cancelButtonTitle:nil destructiveButtonTitle:NSLocalizedString(@"Cancel", nil) otherButtonTitles:NSLocalizedString(@"FromTheAlbumToChoose", nil), nil];
    }
	
	sheet.tag = 255;
    
    [sheet showInView:self.view];
    
}
#pragma mark - UITableView datasource methods
//actionsheet对话框
-(void) actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
	if (actionSheet.tag == 255) {

     NSUInteger sourceType = 0;

        // 判断是否支持相机
        if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
                switch (buttonIndex) {
                    case 0:
                    // 取消
                        return;
                    case 1:
                    // 相机
                        sourceType = UIImagePickerControllerSourceTypeCamera;
                        break;

                    case 2:
                    // 相册
                        sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
                        break;
               }
            }
        else {
                if (buttonIndex == 0) {
      
                    return;
                } else {
                    sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
                }
            }
      // 跳转到相机或相册页面
        UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
        imagePickerController.delegate = self;

        imagePickerController.allowsEditing = YES;
  
        imagePickerController.sourceType = sourceType;
     
        imagePickerController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
        [self presentViewController:imagePickerController animated:YES completion:^{}];

      }
}
#pragma mark - image picker delegte
//完成相片选择
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
    {
        [picker dismissViewControllerAnimated:YES completion:^{}];
        picker = nil;
        UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
	/* 此处info 有六个值
             UIImagePickerControllerMediaType; // an NSString UTTypeImage)
             UIImagePickerControllerOriginalImage;  // a UIImage 原始图片
             UIImagePickerControllerEditedImage;    // a UIImage 裁剪后图片
             UIImagePickerControllerCropRect;       // an NSValue (CGRect)
             UIImagePickerControllerMediaURL;       // an NSURL
             UIImagePickerControllerReferenceURL    // an NSURL that references an asset in the AssetsLibrary framework
             UIImagePickerControllerMediaMetadata    // an NSDictionary containing metadata from a captured photo
    */
	 // 保存图片至本地，方法见下文
        [self saveImage:image withName:@"selectedImage.png"];

        NSString *fullPath = [[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"] stringByAppendingPathComponent:@"selectedImage.png"];
        //记录沙盒图片地址
        UIImage *savedImage = [[UIImage alloc] initWithContentsOfFile:fullPath];
        isFullScreen = NO;
        [self.imageView setImage:savedImage];
	}

//点击了相册选择中的取消
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    [self dismissViewControllerAnimated:YES completion:^{
    }];
    picker=nil;
}
#pragma mark - 保存图片至沙盒
  //启用图片保存功能
- (void) saveImage:(UIImage *)currentImage withName:(NSString *)imageName{

    UIImage *upOrientation = [self fixOrientation:currentImage];
    NSData *imageData = UIImageJPEGRepresentation(upOrientation, 0.5);
	// 获取沙盒目录

	 NSString *fullPath = [[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"] stringByAppendingPathComponent:imageName];
	// 将图片写入文件

	[imageData writeToFile:fullPath atomically:NO];
}
//修改方向为上
- (UIImage *)fixOrientation:(UIImage *)srcImg {
    if (srcImg.imageOrientation == UIImageOrientationUp)
        return srcImg;
    CGAffineTransform transform = CGAffineTransformIdentity;
    switch (srcImg.imageOrientation) {
        case UIImageOrientationDown:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, srcImg.size.width, srcImg.size.height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;
            
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
            transform = CGAffineTransformTranslate(transform, srcImg.size.width, 0);
            transform = CGAffineTransformRotate(transform, M_PI_2);
            break;
            
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, 0, srcImg.size.height);
            transform = CGAffineTransformRotate(transform, -M_PI_2);
            break;
        case UIImageOrientationUp:
        case UIImageOrientationUpMirrored:
            break;
    }
    
    switch (srcImg.imageOrientation) {
        case UIImageOrientationUpMirrored:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, srcImg.size.width, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
            
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, srcImg.size.height, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
        case UIImageOrientationUp:
        case UIImageOrientationDown:
        case UIImageOrientationLeft:
        case UIImageOrientationRight:
            break;
    }
    
    CGContextRef ctx = CGBitmapContextCreate(NULL, srcImg.size.width, srcImg.size.height,
                                             CGImageGetBitsPerComponent(srcImg.CGImage), 0,
                                             CGImageGetColorSpace(srcImg.CGImage),
                                             CGImageGetBitmapInfo(srcImg.CGImage));
    CGContextConcatCTM(ctx, transform);
    switch (srcImg.imageOrientation) {
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            CGContextDrawImage(ctx, CGRectMake(0,0,srcImg.size.height,srcImg.size.width), srcImg.CGImage);
            break;
            
        default:
            CGContextDrawImage(ctx, CGRectMake(0,0,srcImg.size.width,srcImg.size.height), srcImg.CGImage);
            break;
    }
    
    CGImageRef cgimg = CGBitmapContextCreateImage(ctx);
    UIImage *img = [UIImage imageWithCGImage:cgimg];
    CGContextRelease(ctx);
    CGImageRelease(cgimg);
    return img;
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    //从相册点击一个图片，判断是否全屏
    isFullScreen = !isFullScreen;
    UITouch *touch = [touches anyObject];
	CGPoint touchPoint = [touch locationInView:self.view];
	CGPoint imagePoint = self.imageView.frame.origin;
	//touchPoint.x ，touchPoint.y 就是触点的坐标
	// 触点在imageView内，点击imageView时 放大,再次点击时缩小
	if(imagePoint.x <= touchPoint.x && imagePoint.x +self.imageView.frame.size.width >=touchPoint.x && imagePoint.y <=touchPoint.y && imagePoint.y+self.imageView.frame.size.height >= touchPoint.y)
       {
            // 设置图片放大动画
            [UIView beginAnimations:nil context:nil];
            // 动画时间
            [UIView setAnimationDuration:1];
           
            if (isFullScreen) {
                // 放大尺寸
                
                self.imageView.frame = CGRectMake(0, 0, 320, 480);
                }
            else {
                // 缩小尺寸
                self.imageView.frame = CGRectMake(50, 65, 90, 115);
               }

            // commit动画
            [UIView commitAnimations];
           
        }

}

- (void)textViewDidBeginEditing:(UITextView *)textView{

    //标题不允许输入表情
    if ([self.subTitle isFirstResponder]) {
        keyboardButton.enabled = NO;
        if ([self.subTitle.text isEqualToString:NSLocalizedString(@"Subject", nil)]) {//如果标题栏为Subject,就将其置空
            self.subTitle.text = @"";
        }
        if ([self.postContent.text isEqualToString:@""]) {//判断内容栏为空，则为其赋值Content
            self.postContent.text = NSLocalizedString(@"Content", nil);
        }
    }
    if ([self.postContent isFirstResponder]) {
        keyboardButton.enabled = YES;
        if ([self.postContent.text isEqualToString:NSLocalizedString(@"Content", nil)]) {
            self.postContent.text = @"";
        }
        if ([self.subTitle.text isEqualToString:@""]) {
            self.subTitle.text = NSLocalizedString(@"Subject", nil);
        }
    }
}

//点击表情按钮
//- (IBAction)faceBoardClick:(id)sender {
//    
//    isButtonClicked = YES;
//    
//    if ( isKeyboardShowing ) {
//        
//        [self.postContent resignFirstResponder];
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
//            self.postContent.inputView = _emojiView;
//        }
    
//        [self.postContent becomeFirstResponder];
//    }
//}

//文本框输入表情和文本
- (void)didTouchEmojiView:(EmojiView*)emojiView touchedEmoji:(NSString*)str
{
    NSString *content = self.postContent.text;
    NSInteger location = self.postContent.selectedRange.location;//取得光标位置
    NSString *beforText = [content substringToIndex:location];//取得光标之前的内容
    NSInteger centerRange = self.postContent.selectedRange.length;//取得光标选中的内容
    NSString *laterText = [content substringFromIndex:location+centerRange];//光标后面的内容，不包括光标选中的内容
    self.postContent.text = [NSString stringWithFormat:@"%@%@%@",beforText,str,laterText];//重组textView的内容
    self.postContent.selectedRange = NSMakeRange(beforText.length+str.length, 0);//设置光标位置
}

//注册的通知事件
- (void)keyboardWillShow:(NSNotification *)notification {
    //设置postContent的自适应高度
    CGRect rect = self.postContent.frame;
    rect.size.height = [UIScreen mainScreen].bounds.size.height-64-50-290;
    self.postContent.frame = rect;
    
    //
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
                         CGRect frame = self.toolView.frame;
                         frame.origin.y += keyboardHeight;
                         frame.origin.y -= keyboardRect.size.height;
                         self.toolView.frame = frame;
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
                         CGRect frame = self.toolView.frame;
                         frame.origin.y += keyboardHeight;
                         self.toolView.frame = frame;
                         keyboardHeight = 0;
                     }];
}

- (void)keyboardDidHide:(NSNotification *)notification {
    CGRect rect = self.postContent.frame;
    rect.size.height = [UIScreen mainScreen].bounds.size.height-64-50-44;
    self.postContent.frame = rect;
    
    isKeyboardShowing = NO;
    
//    if ( isButtonClicked ) {
//        
//        isButtonClicked = NO;
//        
//        if ( ![self.postContent.inputView isEqual:_emojiView] ) {
//            
//            isSystemBoardShow = NO;
//            
//            self.postContent.inputView = _emojiView;
//        }
//        else {
//            
//            isSystemBoardShow = YES;
//            
//            self.postContent.inputView = nil;
//        }
//        
//        [self.postContent becomeFirstResponder];
//    }
}


//点击表情页的删除按钮触发的事件
//- (void)selectedDel:(NSArray *)_symbolArr{
//    NSString *newBeforText = @"";
//    NSString *content = self.postContent.text;
//    NSInteger location = self.postContent.selectedRange.location;//取得光标位置
//    NSString *beforText = [content substringToIndex:location];//取得光标之前的内容
//    NSInteger centerRange = self.postContent.selectedRange.length;//取得光标选中的内容
//    NSString *laterText = [content substringFromIndex:location+centerRange];//光标后面的内容，不包括光标选中的内容
//    if (self.postContent.selectedRange.length > 0) {//在多选的情况下，要求多个字符串删除
//        self.postContent.text = [NSString stringWithFormat:@"%@%@",beforText,laterText];//重组textView的内容
//        self.postContent.selectedRange = NSMakeRange(beforText.length, 0);//设置光标位置
//        return;
//    }
//    if ([beforText isEqual:@""]) {//删除到textView的初始位置时，直接返回
//            self.postContent.text = laterText;
//            self.postContent.selectedRange = NSMakeRange(0, 0);//设置光标位置
//        return;
//    }
//    
//    if (content.length > 0) {//在帖子中间删除某个字符
//        
//        if ((beforText.length >= 2)&&[_symbolArr containsObject:[beforText substringFromIndex:beforText.length-2]]) {
//                newBeforText = [content substringToIndex:beforText.length-2];
//        }else{
//                newBeforText = [content substringToIndex:beforText.length-1];
//        }
//        self.postContent.text= [self.postContent.text stringByReplacingOccurrencesOfString:beforText withString:newBeforText];
//        self.postContent.selectedRange = NSMakeRange(newBeforText.length, 0);
//    }
//}

//发送消息
- (void)sendMessage{
    //确定有用户写的内容，保证发帖不为空
    if ([self.subTitle.text isEqualToString:NSLocalizedString(@"Subject", nil)]&&[self.postContent.text isEqualToString:NSLocalizedString(@"Content", nil)]) {
        return ;
    }

    if (![self.subTitle.text isEqualToString:@""]&&![self.postContent.text isEqualToString:@""]) {
        self.navigationItem.rightBarButtonItem.enabled = NO;
        [self initComment];
    }
}

- (void)initComment{
    NSDateFormatter *dateFormatter=[[NSDateFormatter alloc]init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSDate *now = [NSDate date];
    NSString *dateString=[dateFormatter stringFromDate:now];//得到字符串时间
    dateString = [DateTimeHelper getUTCFormateLocalDate:dateString];//转换成UTC标准时间
    
    Post *post = [[Post alloc]init];
    post.subTitle = self.subTitle.text;
    post.subContent = self.postContent.text;
    post.modID = self.modID;
    post.customerID = self.customerID;
    post.beginTime = dateString;
    self.view.userInteractionEnabled=NO;//界面
    [[AllPostServer sharedInstance]
     addPost:post
     failed:^(NSInteger code, NSString *msg) {
         self.view.userInteractionEnabled = YES;//界面
         [JDStatusBarNotification showWithStatus:msg dismissAfter:2.0];
         self.navigationItem.rightBarButtonItem.enabled = YES;
        } finished:^(JRRequest *request,JRResponse *response) {
            if (!response.code) {
                THLog(@"msg = %@", response.msg);
                [JDStatusBarNotification showWithStatus:response.msg dismissAfter:2.0];
            }
            else{

                [self.navigationController popViewControllerAnimated:YES];
                [JDStatusBarNotification showWithStatus:NSLocalizedString(@"Post success", nil) dismissAfter:1.0];
                [self.postContent resignFirstResponder];
                [self.subTitle resignFirstResponder];
                [self.postContent setText:@""];
                [self.subTitle setText:@""];
                self.imageView.image = nil;
                //加入通知,发帖后主界面要进行刷新
                [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_POST_CHANGED object:nil];
                //清除图片
                [[AppHelper sharedInstance]clearImgPost];
            }
            self.navigationItem.rightBarButtonItem.enabled = YES;
            self.view.userInteractionEnabled = YES;//界面
    }];
}
//初始化视图
- (void)initView{
    NSDictionary *dic=[[LocalStroge sharedInstance] getObjectAtKey:F_USER_INFORMATION filePath:NSDocumentDirectory];
    NSInteger customerID = [[dic objectForKey:@"customer_id"]integerValue];
    self.customerID = customerID;
    //给图片设置手势
    UITapGestureRecognizer* singleRecognizer;
    singleRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imageSingleTap:)];
    //点击的次数
    singleRecognizer.numberOfTouchesRequired = 1; //手指
    singleRecognizer.numberOfTapsRequired = 1; // 单击
    [self.imageView setUserInteractionEnabled:YES];
    [self.imageView addGestureRecognizer:singleRecognizer];//添加手势
    
    //初始化自定义的工具栏
    CGRect rect = self.toolView.frame;
    rect.origin.y = [UIScreen mainScreen].bounds.size.height-44;
    self.toolView.frame = rect;
    
    //设置导航栏右按钮发送
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:NSLocalizedString(@"Posting", nil) style:UIBarButtonItemStylePlain target:self action:@selector(sendMessage)];
    //初始化标题与内容所在的视图
    rect = self.mainView.frame;
    rect.origin.y = 64;
    rect.size.height = [UIScreen mainScreen].bounds.size.height-44-64;
    self.mainView.frame = rect;
    //代理
    self.postContent.delegate = self;
    self.subTitle.delegate = self;
    //初始化表情
//    _emojiView = [[EmojiView alloc] initWithFrame:CGRectMake(0, [UIScreen mainScreen].bounds.size.height, 320, 216)];
//    _emojiView.delegate = self;
//    [self.view addSubview:_emojiView];
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

//图片单击
- (void)imageSingleTap:(UITapGestureRecognizer *)gesture{
    if (!self.imageView.image) {//如果图片为空就直接返回
        return;
    }
    self.imageView.image = nil;
    [[AppHelper sharedInstance] clearImgPost];//清除沙盒中保存的图片

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated
    
}

@end
