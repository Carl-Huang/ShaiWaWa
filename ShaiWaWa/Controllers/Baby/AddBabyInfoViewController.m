//
//  AddBabyInfoViewController.m
//  ShaiWaWa
//
//  Created by 祥 on 14-7-7.
//  Copyright (c) 2014年 helloworld. All rights reserved.
//

#import "AddBabyInfoViewController.h"
#import "UIViewController+BarItemAdapt.h"

#import "HttpService.h"
#import "SVProgressHUD.h"
#import "UserDefault.h"
#import "UserInfo.h"
#import "Friend.h"
#import "BabyInfo.h"
@interface AddBabyInfoViewController ()
{
    BabyInfo *baby;
    TSLocateView *locateView;
    TSLocation *location;
    NSString *imageFullUrlStr;
}
@end

@implementation AddBabyInfoViewController

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
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Private Methods
- (void)initUI
{
    self.title = @"添加宝宝";
    [self setLeftCusBarItem:@"square_back" action:nil];
    isBoy = YES;
    isMon = YES;
    isGirl = NO;
    isDad = NO;
    _scrollView.contentSize = CGSizeMake(_addView.bounds.size.width, _addView.bounds.size.height);
    [_scrollView addSubview:_addView];
    
    UIButton *addButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [addButton setTitle:@"添加" forState:UIControlStateNormal];
    addButton.frame = CGRectMake(0, 0, 40, 30);
    [addButton.titleLabel setFont:[UIFont systemFontOfSize:15]];
    [addButton addTarget:self action:@selector(addBaby) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *right_add = [[UIBarButtonItem alloc] initWithCustomView:addButton];
    self.navigationItem.rightBarButtonItem = right_add;
    
    UIImage *imageJianTou = [UIImage imageNamed:@"main_jiantou.png"];
    UIImageView *jianTou = [[UIImageView alloc] initWithImage:imageJianTou];
    jianTou.frame = CGRectMake(_cityButton.bounds.size.width-18, 15, 7, 11);
    [_cityButton addSubview:jianTou];
    
    [self createFolder];
    
    baby = [[BabyInfo alloc] init];
    

}

- (void)addBaby
{
    UserInfo *user = [[UserDefault sharedInstance] userInfo];
    if (_babyNameField.text.length > 0 && _birthDayField.text.length > 0 && _babyNicknameField.text.length > 0 && _birthStatureField.text.length > 0 &&_birthWeightField.text.length > 0 ) {
      
        [[HttpService sharedInstance] addBaby:@{@"uid":user.uid,
                                                @"fid":isDad ? user.uid : @"",
                                                @"mid":isMon ? user.uid : @"",
                                                @"baby_name":_babyNameField.text,
                                                @"avatar":![imageFullUrlStr isEqual:[NSNull null]] ? imageFullUrlStr : @"",
                                                @"sex":isBoy ? @"1" : @"0",
                                                @"birthday":_birthDayField.text,
                                                @"nickname":_babyNicknameField.text,
                                                @"birth_height":_birthStatureField.text,
                                                @"birth_weight":_birthWeightField.text,
                                                @"country":@"中国",
                                                @"province":location.state,
                                                @"city":location.city} completionBlock:^(id object) {
                                                    [SVProgressHUD showSuccessWithStatus:@"添加成功"];
                                                    [self clearTextField];
                                                    [self resetStatus];
                                                } failureBlock:^(NSError *error, NSString *responseString) {
                                                    NSString * msg = responseString;
                                                    if (error) {
                                                        msg = @"加载失败";
                                                    }
                                                    [SVProgressHUD showErrorWithStatus:msg];
                                                }];

    }
    else
    [SVProgressHUD showErrorWithStatus:@"不允许为空"];
   }

- (IBAction)boySelected:(id)sender
{
    isBoy = YES;
    [_boyRadioButton setImage:[UIImage imageNamed:@"main_dian.png"] forState:UIControlStateNormal];
    isGirl = NO;
    [_girlRadioButton setImage:[UIImage imageNamed:@"main_dian-.png"] forState:UIControlStateNormal];
}

- (IBAction)girlSelected:(id)sender
{
    isBoy = NO;
    [_boyRadioButton setImage:[UIImage imageNamed:@"main_dian-.png"] forState:UIControlStateNormal];
    isGirl = YES;
    [_girlRadioButton setImage:[UIImage imageNamed:@"main_dian.png"] forState:UIControlStateNormal];
}

- (IBAction)monSelected:(id)sender
{
    isMon = YES;
    [_monRadioButton setImage:[UIImage imageNamed:@"main_dian.png"] forState:UIControlStateNormal];
    isDad = NO;
    [_dadRadioButton setImage:[UIImage imageNamed:@"main_dian-.png"] forState:UIControlStateNormal];
}

- (IBAction)dadSelected:(id)sender
{
    isMon = NO;
    [_monRadioButton setImage:[UIImage imageNamed:@"main_dian-.png"] forState:UIControlStateNormal];
    isDad = YES;
    [_dadRadioButton setImage:[UIImage imageNamed:@"main_dian.png"] forState:UIControlStateNormal];
}

- (IBAction)openCitiesSelectView:(id)sender
{
    
    locateView = [[TSLocateView alloc] initWithTitle:@"定位城市" delegate:self];
    locateView.tag = 11111;
    [locateView showInView:self.view];
}

- (IBAction)touXiangSelectEvent:(id)sender
{
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:@"拍照" otherButtonTitles:@"相册", nil];
    [actionSheet showFromRect:CGRectMake(0, 0, 320, 100) inView:self.view animated:YES];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (actionSheet.tag == 11111)
    {
       locateView  = (TSLocateView *)actionSheet;
        location = locateView.locate;
        
        _cityValueTextField.text = [[location.state stringByAppendingString:@" "] stringByAppendingString:location.city];
        NSLog(@"city:%@ lat:%f lon:%f", location.city, location.latitude, location.longitude);
        
        //You can uses location to your application.
        if(buttonIndex == 0) {
            NSLog(@"Cancel");
        }else {
            NSLog(@"Select");
        }
    }
    else
    {
    // 判断是否支持相机
    //先设定sourceType为相机，然后判断相机是否可用（ipod）没相机，不可用将sourceType设定为相片库
    UIImagePickerControllerSourceType sourceType = UIImagePickerControllerSourceTypeCamera;
    
    switch (buttonIndex) {
        case 0:
            // 相机
            sourceType = UIImagePickerControllerSourceTypeCamera;
            break;
        case 1:
            // 相册
            sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            break;
        case 2:
            // 取消
            return;
    }
    UIImagePickerController *imagePickerController =[[UIImagePickerController alloc] init];
    
    imagePickerController.delegate = self;
    
    imagePickerController.allowsEditing = YES;
    
    imagePickerController.sourceType = sourceType;
    
    [self presentViewController:imagePickerController animated:YES completion:^{}];
    }
}

//点击相册中的图片 货照相机照完后点击use  后触发的方法
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [picker dismissViewControllerAnimated:YES completion:^{}];
    UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
    
    
    // 保存图片至本地，方法见下文
    [self saveImage:image withName:@"Baby_avatar_NumPic"];
  
    [_touXiangButton setImage:image forState:UIControlStateNormal];
}
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissViewControllerAnimated:YES completion:^{}];
}

#pragma mark - 保存图片至沙盒
- (void) saveImage:(UIImage *)currentImage withName:(NSString *)imageName
{
    NSData *imageData = UIImageJPEGRepresentation(currentImage, 0.5);
    
    
    NSDate *  senddate=[NSDate date];
    NSDateFormatter  *dateformatter=[[NSDateFormatter alloc] init];
    //    [dateformatter setDateFormat:@"HH:mm"];
    //    NSString *  locationString=[dateformatter stringFromDate:senddate];
    [dateformatter setDateFormat:@"YYYY-MM-dd-HH-mm-ss"];
    NSString *morelocationString=[dateformatter stringFromDate:senddate];
    
    // 获取沙盒目录
    imageFullUrlStr = [[[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"] stringByAppendingPathComponent:@"/Avatar"] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@_%@.png",imageName,morelocationString]];
    // 将图片写入文件
    [imageData writeToFile:imageFullUrlStr atomically:NO];
}
//NSData * UIImageJPEGRepresentation ( UIImage *image, CGFloat compressionQuality
//创建沙盒下文件夹
- (void)createFolder
{
    NSString *dirName = @"Avatar";
    NSString *fullPath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    NSString *imageDir = [NSString stringWithFormat:@"%@/%@", fullPath,dirName];
    BOOL isDir = NO;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL existed = [fileManager fileExistsAtPath:imageDir isDirectory:&isDir];
    if ( !(isDir == YES && existed == YES) )
    {
        [fileManager createDirectoryAtPath:imageDir withIntermediateDirectories:YES attributes:nil error:nil];
    }
}
//删除文件夹及文件级内的文件：
//NSString *imageDir = [NSString stringWithFormat:@"%@/Caches/%@", NSHomeDirectory(), dirName];
//NSFileManager *fileManager = [NSFileManager defaultManager];
//[fileManager removeItemAtPath:imageDir error:nil];
#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField == _babyNicknameField) {
    [_birthDayField becomeFirstResponder];
        return NO;
    }
    if (textField == _babyNameField) {
        [_birthStatureField becomeFirstResponder];
        return NO;
    }
    if (textField == _birthStatureField) {
        [_birthWeightField becomeFirstResponder];
        return NO;
    }
    [textField resignFirstResponder];
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    if (textField == _birthWeightField) {
        _scrollView.contentOffset = CGPointMake(0, 296);
    }
    if (textField == _birthStatureField) {
         _scrollView.contentOffset = CGPointMake(0, 246);
    }
    if (textField == _babyNameField) {
        _scrollView.contentOffset = CGPointMake(0, 246);
    }
}
- (void)textFieldDidEndEditing:(UITextField *)textField
{
    if (textField == _birthWeightField) {
        _scrollView.contentOffset = CGPointMake(0, 58);
    }
    else
    {
        _scrollView.contentOffset = CGPointMake(0, 0);
    }
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView
{
    [_babyNicknameField resignFirstResponder];
    [_birthDayField resignFirstResponder];
    [_babyNameField resignFirstResponder];
    [_birthStatureField resignFirstResponder];
    [_birthWeightField resignFirstResponder];
}

- (void)clearTextField
{
    _babyNameField.text = nil;
    _birthDayField.text = nil;
    _babyNicknameField.text = nil;
    _birthStatureField.text = nil;
    _birthWeightField.text = nil;
    _cityValueTextField.text = nil;
}

- (void)resetStatus
{
    [self boySelected:nil];
    [self monSelected:nil];
    [_touXiangButton setImage:[UIImage imageNamed:@"main_baobaotouxiang.png"] forState:UIControlStateNormal];
}
@end
