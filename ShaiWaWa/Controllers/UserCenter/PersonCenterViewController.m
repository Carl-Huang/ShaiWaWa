//
//  PersonCenterViewController.m
//  ShaiWaWa
//
//  Created by Carl on 14-7-6.
//  Copyright (c) 2014年 helloworld. All rights reserved.
//

#import "PersonCenterViewController.h"
#import "UIViewController+BarItemAdapt.h"
#import "ControlCenter.h"
#import "PlatformBindViewController.h"
#import "MyGoodFriendsListViewController.h"
#import "MybabyListViewController.h"
#import "QRCodeCardViewController.h"
#import "DynamicByUserIDViewController.h"
#import "MyCollectionViewController.h"
#import "UserDefault.h"
#import "HttpService.h"
#import "SVProgressHUD.h"
#import "UserInfo.h"
#import "AppMacros.h"
#import "QNUploadHelper.h"
#import "UIImageView+WebCache.h"
@interface PersonCenterViewController ()
{

}
@end

@implementation PersonCenterViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        users = [[UserDefault sharedInstance] userInfo];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:YES];
    users = [[UserDefault sharedInstance] userInfo];
    self.title = users.username;
    //[self topViewData];
    
    if(users.sina_openId == nil)
    {
        _xinlanButton.selected = YES;
    }
    else
    {
        _xinlanButton.selected = NO;
    }
    
    if(users.tecent_openId == nil)
    {
        _qqButton.selected = YES;
    }
    else
    {
        _qqButton.selected = NO;
    }
    
    if(users.phone == nil)
    {
        _addressbookButton.selected = YES;
    }
    else
    {
        _addressbookButton.selected = NO;
    }
    
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];

}

#pragma mark - Private Methods
- (void)initUI
{

    [self setLeftCusBarItem:@"square_back" action:nil];

    [self getUserInfo];
}

- (void)getUserInfo
{
    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeGradient];
    [[HttpService sharedInstance] getUserInfo:@{@"uid":users.uid} completionBlock:^(id object) {
        [SVProgressHUD dismiss];
        users = (UserInfo *)object;
        [[UserDefault sharedInstance] setUserInfo:users];
        
        [self babyCell];
        [self dynamicCell];
        [self goodFriendCell];
        [self twoDimensionCodeCell];
        [self myCollectionCell];
        [self socialPlatformBindCell];
        [self topViewData];
        
    } failureBlock:^(NSError *error, NSString *responseString) {
        
        NSString * msg = responseString;
        if(error)
        {
            msg = @"加载失败.";
        }
        
        [SVProgressHUD showErrorWithStatus:msg];
    }];
}


- (void)topViewData
{
    _acountName.text = users.username;
    _wawaNum.text = users.sww_number;
    UITapGestureRecognizer *touXiangImgViewTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showActionSheetView)];
    [_touXiangView addGestureRecognizer:touXiangImgViewTap];
    
    
    UIImage * image = Unkown_Avatar;
    if([users.sex isEqualToString:@"1"])
    {
        image = Man_Avatar;
    }
    else if([users.sex isEqualToString:@"2"])
    {
        image = Woman_Avatar;
    }
    
    [_touXiangView sd_setImageWithURL:[NSURL URLWithString:users.avatar] placeholderImage:image];
}

- (void)showActionSheetView
{
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:@"拍照" otherButtonTitles:@"相册", nil];
    [actionSheet showFromRect:CGRectMake(0, 0, 320, 100) inView:self.view animated:YES];
}

//宝宝数量
- (void)babyCell
{
    UILabel *babyLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 5, 120, _babyButton.bounds.size.height-10)];
    babyLabel.backgroundColor = [UIColor clearColor];
    babyLabel.font = [UIFont systemFontOfSize:15];
    babyLabel.textColor = [UIColor darkGrayColor];
    [_babyButton addSubview:babyLabel];
    babyLabel.text = [NSString stringWithFormat:@"宝宝 (%i)",[users.baby_count intValue]];
    UIImage *imageJianTou = [UIImage imageNamed:@"main_jiantou.png"];
    UIImageView *jianTou = [[UIImageView alloc] initWithImage:imageJianTou];
    jianTou.frame = CGRectMake(_babyButton.bounds.size.width-18, 15, 7, 11);
    [_babyButton addSubview:jianTou];
}

//动态数量
- (void)dynamicCell
{
    UILabel *dynamicLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 5, 120, _dynamicButton.bounds.size.height-10)];
    dynamicLabel.backgroundColor = [UIColor clearColor];
    
    dynamicLabel.font = [UIFont systemFontOfSize:15];
    dynamicLabel.textColor = [UIColor darkGrayColor];
    [_dynamicButton addSubview:dynamicLabel];
    
    dynamicLabel.text = [NSString stringWithFormat:@"动态 (%i)",[users.record_count intValue]];
    
    UIImage *imageJianTou = [UIImage imageNamed:@"main_jiantou.png"];
    UIImageView *jianTou = [[UIImageView alloc] initWithImage:imageJianTou];
    jianTou.frame = CGRectMake(_dynamicButton.bounds.size.width-18, 15, 7, 11);
    [_dynamicButton addSubview:jianTou];
}

//好友数量
- (void)goodFriendCell
{
    UILabel *goodFriendLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 5, 120, _goodFriendButton.bounds.size.height-10)];
    goodFriendLabel.backgroundColor = [UIColor clearColor];
    goodFriendLabel.font = [UIFont systemFontOfSize:15];
    goodFriendLabel.textColor = [UIColor darkGrayColor];
    [_goodFriendButton addSubview:goodFriendLabel];
    goodFriendLabel.text = [NSString stringWithFormat:@"好友 (%i)",[users.friend_count intValue]];
    UIImage *imageJianTou = [UIImage imageNamed:@"main_jiantou.png"];
    UIImageView *jianTou = [[UIImageView alloc] initWithImage:imageJianTou];
    jianTou.frame = CGRectMake(_goodFriendButton.bounds.size.width-18, 15, 7, 11);
    [_goodFriendButton addSubview:jianTou];
}


//二维码
- (void)twoDimensionCodeCell
{
    UILabel *twoDimensionCodeLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 5, 120, _twoDimensionCodeButton.bounds.size.height-10)];
    twoDimensionCodeLabel.backgroundColor = [UIColor clearColor];
    twoDimensionCodeLabel.text = [NSString stringWithFormat:@"二维码名片"];
    twoDimensionCodeLabel.font = [UIFont systemFontOfSize:15];
    twoDimensionCodeLabel.textColor = [UIColor darkGrayColor];
    [_twoDimensionCodeButton addSubview:twoDimensionCodeLabel];
    
    UIImage *imageJianTou = [UIImage imageNamed:@"main_jiantou.png"];
    UIImageView *jianTou = [[UIImageView alloc] initWithImage:imageJianTou];
    jianTou.frame = CGRectMake(_twoDimensionCodeButton.bounds.size.width-18, 15, 7, 11);
    [_twoDimensionCodeButton addSubview:jianTou];
}

//收藏数量
- (void)myCollectionCell
{
    UILabel *myCollectionLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 5, 120, _myCollectionButton.bounds.size.height-10)];
    myCollectionLabel.backgroundColor = [UIColor clearColor];
    myCollectionLabel.text = [NSString stringWithFormat:@"我的收藏 (%i)",[users.favorite_count intValue]];
    myCollectionLabel.font = [UIFont systemFontOfSize:15];
    myCollectionLabel.textColor = [UIColor darkGrayColor];
    [_myCollectionButton addSubview:myCollectionLabel];
    UIImage *imageJianTou = [UIImage imageNamed:@"main_jiantou"];
    UIImageView *jianTou = [[UIImageView alloc] initWithImage:imageJianTou];
    jianTou.frame = CGRectMake(_myCollectionButton.bounds.size.width-18, 15, 7, 11);
    [_myCollectionButton addSubview:jianTou];
}

//社交平台
- (void)socialPlatformBindCell
{
    UILabel *socialPlatformBindLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 5, 120, _sheJianBar.bounds.size.height-10)];
    socialPlatformBindLabel.backgroundColor = [UIColor clearColor];
    socialPlatformBindLabel.text = [NSString stringWithFormat:@"社交平台绑定"];
    socialPlatformBindLabel.font = [UIFont systemFontOfSize:15];
    socialPlatformBindLabel.textColor = [UIColor darkGrayColor];
    [_sheJianBar addSubview:socialPlatformBindLabel];
    
    UIImage *imageJianTou = [UIImage imageNamed:@"main_jiantou"];
    UIImageView *jianTou = [[UIImageView alloc] initWithImage:imageJianTou];
    jianTou.frame = CGRectMake(_sheJianBar.bounds.size.width-18, 15, 7, 11);
    [_sheJianBar addSubview:jianTou];
}


#pragma mark - Action Methods
//显示用户信息
- (IBAction)showUserInfoPageVC:(id)sender
{
    [ControlCenter pushToUserInfoPageVC];
}

- (IBAction)showPlatformBind:(id)sender
{
    PlatformBindViewController *platformVC = [[PlatformBindViewController alloc] init];
    [self.navigationController pushViewController:platformVC animated:YES];
}

//显示好友列表
- (IBAction)showGoodFriendListVC:(id)sender
{
    MyGoodFriendsListViewController *myGoodFriendListVC = [[MyGoodFriendsListViewController alloc] init];
    [self.navigationController pushViewController:myGoodFriendListVC animated:YES];
}

//显示我的宝宝列表
- (IBAction)showMyBabyListVC:(id)sender
{
    MybabyListViewController *myBabyListVC = [[MybabyListViewController alloc] init];
    [self.navigationController pushViewController:myBabyListVC animated:YES];
}

//显示二维码
- (IBAction)showMyQRCardVC:(id)sender
{
    QRCodeCardViewController *qrCodeCardVC = [[QRCodeCardViewController alloc] init];
    [self.navigationController pushViewController:qrCodeCardVC animated:YES];
}

//显示我的收藏
- (IBAction)showMyCollectionVC:(id)sender
{
    MyCollectionViewController * vc = [[MyCollectionViewController alloc] initWithNibName:nil bundle:nil];
    [self.navigationController pushViewController:vc animated:YES];
    vc = nil;
}

- (IBAction)dyPageShowEvent:(id)sender
{
    DynamicByUserIDViewController *dynamicVC = [[DynamicByUserIDViewController alloc] initWithNibName:nil bundle:nil];
    [self.navigationController pushViewController:dynamicVC animated:YES];
    dynamicVC = nil;
}


#pragma mark - UIImagePickerControllerDelegate
//点击相册中的图片 货照相机照完后点击use  后触发的方法
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [picker dismissViewControllerAnimated:YES completion:^{}];
    UIImage *image = [info objectForKey:UIImagePickerControllerEditedImage];
    // 保存图片至本地，方法见下文
    NSString * fileName = [[IO generateRndString] stringByAppendingPathExtension:@"png"];
    NSString *fullPath = [IO pathForResource:fileName inDirectory:Avatar_Folder];
    if(![IO writeFileToPath:fullPath withData:UIImagePNGRepresentation(image)])
    {
        [SVProgressHUD showErrorWithStatus:@"保存失败."];
        return ;
    }
    _touXiangView.image = image;
    // 开始上传
    QNUploadHelper * uploadHelper = [QNUploadHelper sharedHelper];
    [uploadHelper uploadFileData:UIImageJPEGRepresentation(image, 1.0) withKey:fileName];
    //设置头像
    uploadHelper.uploadSuccess = ^(NSString * str){
        
        NSString * qq = users.qq == NULL ? @"" : users.qq;
        NSString * wechat = users.wechat == NULL ? @"" : users.wechat;
        NSString * weibo = users.weibo == NULL ? @"" : users.weibo;
        NSString * sex = users.sex == NULL ? @"" : users.sex;
        [[HttpService sharedInstance] updateUserInfo:@{@"user_id":users.uid,@"username":users.username,@"avatar":[QN_URL stringByAppendingString:fileName],@"sex":sex,@"qq":qq,@"weibo":weibo,@"wechat":wechat} completionBlock:^(id object) {
            users.avatar = [QN_URL stringByAppendingString:fileName];
            [[UserDefault sharedInstance] setUserInfo:users];
            [SVProgressHUD showSuccessWithStatus:@"上传成功."];
            
            [_touXiangView sd_setImageWithURL:[NSURL URLWithString:users.avatar] placeholderImage:image];
        } failureBlock:^(NSError *error, NSString *responseString) {
            NSString * msg = responseString;
            if(error)
            {
                msg = @"上传失败.";
            }
            [SVProgressHUD showErrorWithStatus:msg];
        }];
    };
    
    uploadHelper.uploadFailure = ^(NSString * str){
        [SVProgressHUD showErrorWithStatus:@"上传失败."];
    };

    
    
}


- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissViewControllerAnimated:YES completion:^{}];
}


#pragma mark - UIActionSheetDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    // 判断是否支持相机
    //先设定sourceType为相机，然后判断相机是否可用（ipod）没相机，不可用将sourceType设定为相片库
    UIImagePickerControllerSourceType sourceType = UIImagePickerControllerSourceTypeCamera;
    
    switch (buttonIndex) {
        case 0:
            //相机
            sourceType = UIImagePickerControllerSourceTypeCamera;
            break;
        case 1:
            //相册
            sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            break;
        case 2:
            //取消
            return;
    }
    UIImagePickerController *imagePickerController =[[UIImagePickerController alloc] init];
    imagePickerController.delegate = self;
    imagePickerController.allowsEditing = YES;
    imagePickerController.sourceType = sourceType;
    [self presentViewController:imagePickerController animated:YES completion:^{}];
}


@end
