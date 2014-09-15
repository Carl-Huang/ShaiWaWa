//
//  PublishRecordViewController.m
//  ShaiWaWa
//
//  Created by Carl on 14-8-21.
//  Copyright (c) 2014年 helloworld. All rights reserved.
//

#import "PublishRecordViewController.h"
#import "UIViewController+BarItemAdapt.h"
#import "AddBabyInfoViewController.h"
#import "MybabyListViewController.h"
#import "LocationsViewController.h"
#import "UserInfo.h"
#import "UserDefault.h"
#import "HttpService.h"
#import "SVProgressHUD.h"
#import "BabyInfo.h"
#import "PublishImageView.h"
#import "UIImageView+WebCache.h"
#import "VideoConvertHelper.h"
#import "AppMacros.h"
#import "InputHelper.h"
#import "QNUploadHelper.h"
#import "TopicViewController.h"
#import "ChooseFriendViewController.h"
#import "NSStringUtil.h"
#import "ImageDisplayView.h"
#import "Setting.h"
@import MediaPlayer;
#define PlaceHolder @"关于宝宝的开心事情..."
@interface PublishRecordViewController ()<UITextViewDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate,UIAlertViewDelegate,UIActionSheetDelegate>
@property (nonatomic,strong) BabyInfo * babyInfo;
@property (nonatomic,strong) UserInfo * userInfo;
@property (nonatomic,strong) Setting * setting;
@property (nonatomic,strong) CLPlacemark * placemark; //位置
@property (nonatomic,strong) NSString * visibility; //可见性
@property (nonatomic,strong) NSMutableArray * images; //图片路径数组
@property (nonatomic,strong) NSMutableArray * imageViews;  //图片对应的imageview数组
@property (nonatomic,strong) NSMutableArray * uploadedImages;  //上传成功图片队列
@property (nonatomic,strong) NSMutableArray * uploadFailImages; //上传失败图片队列
@property (nonatomic,strong) NSString * videoPath;  //本地视频路径
@end

@implementation PublishRecordViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        _setting = [[UserDefault sharedInstance] set];
        _userInfo = [[UserDefault sharedInstance] userInfo];
        _images = [@[] mutableCopy];
        _imageViews = [@[] mutableCopy];
        _uploadedImages = [@[] mutableCopy];
        _uploadFailImages = [@[] mutableCopy];
        _visibility = @"2";
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
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardShow:) name:UIKeyboardWillChangeFrameNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardHide:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}


#pragma mark - Private Methods
- (void)initUI
{
    self.title = NSLocalizedString(@"PublishVCTitle", nil);
    [self setLeftCusBarItem:@"square_back" action:nil];
    self.navigationItem.rightBarButtonItem = [self customBarItem:@"pb_fabu" action:@selector(publishAction:) size:CGSizeMake(57, 27)];
    
    _textView.allowsEditingTextAttributes = YES;
    
    //添加按钮到视图中
    _button3View.frame = _scrollView.frame;
    [self.view addSubview:_button3View];
    
    //添加底部按钮到视图中
    _bottomView.frame = CGRectMake(0, CGRectGetHeight(self.view.frame) - CGRectGetHeight(_bottomView.frame), CGRectGetWidth(_bottomView.frame), CGRectGetHeight(_bottomView.frame));
    [self.view addSubview:_bottomView];
    
    [_textView setPlaceholder:PlaceHolder];
    _textView.inputAccessoryView = _toolbar;
    
    //获取宝宝列表
    [self getBabys];
}

//获取宝宝列表
- (void)getBabys
{
    UserInfo *user = [[UserDefault sharedInstance] userInfo];
    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeGradient];
    [[HttpService sharedInstance] getBabyList:@{@"offset":@"0",@"pagesize":@"10",@"uid":user.uid}completionBlock:^(id object) {
        [SVProgressHUD dismiss];
        if([object count] == 0)
        {
            _moreButton.hidden = YES;
            UIAlertView * alertView = [[UIAlertView alloc] initWithTitle:nil message:NSLocalizedString(@"HaveNotBaby", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"Back", nil) otherButtonTitles:NSLocalizedString(@"Add", nil),nil];
            alertView.tag = 1;
            [alertView show];
            alertView = nil;
            return ;
        }
        _babyInfo = object[0];
        [self updateBabyInfo:_babyInfo];
        if([object count] > 1)
        {
            _moreButton.hidden = NO;
        }
        else
        {
            _moreButton.hidden = YES;
        }
    } failureBlock:^(NSError *error, NSString *responseString) {
        [SVProgressHUD dismiss];
        UIAlertView * alertView = [[UIAlertView alloc] initWithTitle:nil message:NSLocalizedString(@"GetBabyError", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"Back", nil) otherButtonTitles:NSLocalizedString(@"TryAgain", nil),nil];
        alertView.tag = 2;
        [alertView show];
        alertView = nil;
        
        _moreButton.hidden = YES;
        
    }];
}


//更新当前宝宝的头像和名称
- (void)updateBabyInfo:(BabyInfo *)babyInfo
{
    [_avatarImageView sd_setImageWithURL:[NSURL URLWithString:babyInfo.avatar] placeholderImage:Default_Avatar];
    _babyNameLabel.text = babyInfo.nickname;
}


//提交方法
- (void)publishAction:(id)sender
{
    
    /**
     1.先检查是否有图片和视频
     2.检查内容是否为空
     3.如果是图片则循环上传；如果是视频则单个上传，不需要上传图片
     */
    
    [_textView resignFirstResponder];
    //判断是否有添加图片
    if([_images count] == 0 && _videoPath == nil)
    {
        [SVProgressHUD showErrorWithStatus:@"请添加图片或者视频."];
        return ;
    }
    
    //判断内容是否为空
    NSString * content = [InputHelper trim:_textView.text];
    if([InputHelper isEmpty:content] || [content isEqualToString:PlaceHolder])
    {
        [SVProgressHUD showErrorWithStatus:@"请输入内容."];
        return ;
    }
    

    
    [SVProgressHUD showWithStatus:@"提交中..." maskType:SVProgressHUDMaskTypeGradient];
    
    _uploadedImages = [@[] mutableCopy];
    _uploadFailImages = [@[] mutableCopy];
    //上传成功回调
    [[QNUploadHelper sharedHelper] setUploadSuccess:^(NSString * str){
        
        //判断是上传视频还是图片
        if([str hasSuffix:@"png"] || [str hasSuffix:@"jpg"])
        {
            //将上传成功的图片添加到数组中,用于记录上传成功的个数
            [_uploadedImages addObject:str];
            if([_uploadedImages count] == [_images count])
            {
                //检查是否图片全部上传完毕
                [self checkUploadIsComplete];
                return ;
                
            }
        }
        else if([str hasSuffix:@"mp4"] || [str hasSuffix:@"mov"])
        {
            //上传视频成功，将内容提交到服务器
            [self uploadVideoFinish];
        }
        
    }];
    //上传失败回调
    [[QNUploadHelper sharedHelper] setUploadFailure:^(NSString * str){

        //判断是上传视频还是图片
        if([str hasSuffix:@"png"] || [str hasSuffix:@"jpg"])
        {
            //将上传失败的图片添加到失败队列中
            [_uploadFailImages addObject:str];
            //检查是否全部上传完毕
            [self checkUploadIsComplete];

        }
        else if([str hasSuffix:@"mp4"] || [str hasSuffix:@"mov"])
        {
            UIAlertView * alertView = [[UIAlertView alloc] initWithTitle:@"" message:@"上传视频失败." delegate:self cancelButtonTitle:@"返回" otherButtonTitles:@"重试", nil];
            [alertView show];
            alertView = nil;
        }
        


    }];
    
    //如果有视频则上传,然后返回，不需要上传图片
    if(_videoPath != nil)
    {
        [[QNUploadHelper sharedHelper] uploadFile:_videoPath];
        return ;
    }
    
    for(NSString * path in _images)
    {
        [[QNUploadHelper sharedHelper] uploadFile:path];
    }
}


//检测是否上传完毕，以及是否上传出错
- (void)checkUploadIsComplete
{
    if([_uploadedImages count] + [_uploadFailImages count] != [_images count])
    {
        return ;
    }
    
    if([_uploadFailImages count] > 0)
    {
        DDLogCInfo(@"Some images upload failed.");
        [SVProgressHUD dismiss];
        NSString * msg = [NSString stringWithFormat:@"有%i张图片上传失败",[_uploadFailImages count]];
        UIAlertView * alertView = [[UIAlertView alloc] initWithTitle:nil message:msg delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"重新提交", nil];
        alertView.tag = 3;
        [alertView show];
        alertView = nil;
        return ;
    }
    
    DDLogCInfo(@"Upload images complete.");
    [SVProgressHUD showSuccessWithStatus:@"上传成功."];
    
    //上传图片完毕，提交到服务器
    NSMutableArray * tmpImageURLS = [@[] mutableCopy];
    for (NSString * path in _uploadedImages)
    {
        [tmpImageURLS addObject:[NSString stringWithFormat:@"%@%@",QN_URL,[path lastPathComponent]]];
    }
    [_uploadedImages removeAllObjects];
    NSString * content = [InputHelper trim:_textView.text];
    NSMutableDictionary * params = [@{} mutableCopy];
    params[@"baby_id"] = _babyInfo.baby_id;
    params[@"uid"] =  _userInfo.uid;
    params[@"visibility"] = _visibility;
    params[@"content"] = content;
    params[@"address"] = @"";
    params[@"longitude"] = @"";
    params[@"latitude"] = @"";
    if(_placemark != nil)
    {
        params[@"address"] = _placemark.name;
        params[@"longitude"] = [NSString stringWithFormat:@"%f",_placemark.location.coordinate.longitude];
        params[@"latitude"] = [NSString stringWithFormat:@"%f",_placemark.location.coordinate.latitude];
    }
    
    params[@"video"] = _videoPath != nil ? _videoPath : @"";
    params[@"audio"] = @"";
    params[@"images"] = tmpImageURLS;
    [[HttpService sharedInstance] publishRecord:params completionBlock:^(id object) {
        
        [SVProgressHUD showSuccessWithStatus:@"上传成功."];
        //清楚数据
        [self cleanUp];
        
        //返回上个页面
        [self popVIewController];
        
    } failureBlock:^(NSError *error, NSString *responseString) {
        NSString * msg = responseString;
        if (error) {
              msg = @"提交失败";
        }
        [SVProgressHUD showErrorWithStatus:msg];
    }];
}


//视频上传7牛后调用的函数
- (void)uploadVideoFinish
{
    NSString * content = [InputHelper trim:_textView.text];
    NSMutableDictionary * params = [@{} mutableCopy];
    params[@"baby_id"] = _babyInfo.baby_id;
    params[@"uid"] =  _userInfo.uid;
    params[@"visibility"] = _visibility;
    params[@"content"] = content;
    params[@"address"] = @"";
    params[@"longitude"] = @"";
    params[@"latitude"] = @"";
    if(_placemark != nil)
    {
        params[@"address"] = _placemark.name;
        params[@"longitude"] = [NSString stringWithFormat:@"%f",_placemark.location.coordinate.longitude];
        params[@"latitude"] = [NSString stringWithFormat:@"%f",_placemark.location.coordinate.latitude];
    }
    
    params[@"video"] = _videoPath != nil ? [NSString stringWithFormat:@"%@%@",QN_URL,[_videoPath lastPathComponent]] : @"";
    params[@"audio"] = @"";
    params[@"images"] = @"";
    [[HttpService sharedInstance] publishRecord:params completionBlock:^(id object) {
        
        [SVProgressHUD showSuccessWithStatus:@"上传成功."];
        //清楚数据
        [self cleanUp];
        
        //返回上个页面
        [self popVIewController];
        
    } failureBlock:^(NSError *error, NSString *responseString) {
        NSString * msg = responseString;
        if (error) {
            msg = @"提交失败";
        }
        [SVProgressHUD showErrorWithStatus:msg];
    }];
}



//清楚数据
- (void)cleanUp
{
    _videoPath = nil;
    _addressLabel.text = @"添加位置";
    _placemark = nil;
    _textView.text = PlaceHolder;
    [_images removeAllObjects];
    [_imageViews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [_imageViews removeAllObjects];
    [_uploadedImages removeAllObjects];
    [_uploadFailImages removeAllObjects];
    [self.view addSubview:_button3View];
    _addMoreButton.hidden = YES;
}

- (IBAction)showMoreBaby:(id)sender
{
    MybabyListViewController * vc = [[MybabyListViewController alloc] initWithNibName:nil bundle:nil];
    vc.didSelectBaby = ^(BabyInfo * babyInfo){
        _babyInfo = babyInfo;
        [self updateBabyInfo:_babyInfo];
    };
    [self push:vc];
    vc = nil;
}

- (IBAction)showButtonsAction:(id)sender
{
    _overlayView.frame = self.view.bounds;
    [self.view addSubview:_overlayView];
    
}

- (IBAction)hideOverlay:(id)sender
{
    [_overlayView removeFromSuperview];
}

- (IBAction)dismissKeyboard:(id)sender
{
    [_textView resignFirstResponder];
}


- (IBAction)openPictureAction:(id)sender
{
    [_overlayView removeFromSuperview];
    UIImagePickerController * picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    picker.allowsEditing = YES;
    [self presentViewController:picker animated:YES completion:nil];
    picker = nil;
}

//显示拍照控制器
- (IBAction)takePictureAction:(id)sender
{
    [_overlayView removeFromSuperview];
    UIImagePickerController * picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.sourceType = UIImagePickerControllerSourceTypeCamera;
    NSArray * avaibleSourcType = [UIImagePickerController availableMediaTypesForSourceType:UIImagePickerControllerSourceTypeCamera];
    picker.mediaTypes = [avaibleSourcType subarrayWithRange:NSMakeRange(0, 1)];
    picker.allowsEditing = YES;
    [self presentViewController:picker animated:YES completion:nil];
    picker = nil;
}

//显示录像控制器
- (IBAction)takeMovieAction:(id)sender
{
    UIImagePickerController * pickerCamerView = [[UIImagePickerController alloc] init];
    pickerCamerView.sourceType = UIImagePickerControllerSourceTypeCamera;
    NSArray* availableMedia = [UIImagePickerController availableMediaTypesForSourceType:UIImagePickerControllerSourceTypeCamera];
    pickerCamerView.mediaTypes = [NSArray arrayWithObject:availableMedia[1]];
    pickerCamerView.videoMaximumDuration = 15;
    pickerCamerView.videoQuality = UIImagePickerControllerQualityTypeMedium;
    pickerCamerView.delegate = self;
    [pickerCamerView setShowsCameraControls:YES];
    [self presentViewController:pickerCamerView animated:YES completion:^{}];
    pickerCamerView = nil;

}

//显示定位
- (IBAction)showAddressAction:(id)sender
{
    //__weak PublishRecordViewController *rself = self;
    LocationsViewController *locationVC = [[LocationsViewController alloc] init];
    locationVC.didSelectPlacemark = ^(CLPlacemark * placemark){
        _placemark = placemark;
        if(_placemark != nil)
        {
            _addressLabel.text = placemark.name;
        }
    };
    [self.navigationController pushViewController:locationVC animated:YES];
}

//选择可见性
- (IBAction)setVisibilityAction:(id)sender
{
    NSString *strOne = @"所有都可见";
    NSString *strTwo = @"仅好友可见";
    NSString *strThree = @"仅父母可见";
    UIActionSheet * actionSheet = [[UIActionSheet alloc] initWithTitle:@"" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:strOne,strTwo,strThree, nil];
    [actionSheet showInView:self.view];
    actionSheet = nil;
}

//选择话题页面
- (IBAction)showTopicAction:(id)sender
{
    TopicViewController * topicVC = [[TopicViewController alloc] initWithNibName:nil bundle:nil];
    topicVC.didSelectTopic = ^(NSString * topic){
        
        if([_textView.text isEqualToString:PlaceHolder])
        {
            _textView.text = @"";
        }
        
        NSMutableAttributedString * text = [[NSMutableAttributedString alloc] initWithAttributedString:_textView.attributedText];
        [text appendAttributedString:[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"#%@#",topic] attributes:@{NSForegroundColorAttributeName:[UIColor colorWithRed:131.0/255.0f green:169.0/255.0f blue:88.0/255.0f alpha:1.0]}]];
        
        if([text length] > 140)
        {
            [SVProgressHUD showErrorWithStatus:@"不能超出140个字."];
            return ;
        }
        
        _textView.attributedText = text;

        
    };
    [self.navigationController pushViewController:topicVC animated:YES];
    topicVC = nil;
}

//选择好友页面
- (IBAction)showFriendAction:(id)sender
{
    ChooseFriendViewController *chooseFriendsVC = [[ChooseFriendViewController alloc] initWithNibName:nil bundle:nil];
    [self.navigationController pushViewController:chooseFriendsVC animated:YES];
    chooseFriendsVC = nil;
}

//显示添加宝宝页面
- (void)showAddBaby
{
    AddBabyInfoViewController * vc = [[AddBabyInfoViewController alloc] initWithNibName:nil bundle:nil];
    [self push:vc];
    vc = nil;
}

//选择图片后的处理
- (void)pickPictureProcess:(UIImage *)image
{
    //先保存
    NSString * fileName = [[IO generateRndString] stringByAppendingPathExtension:@"png"];
    NSString * path = [IO pathForResource:fileName inDirectory:Publish_Image_Folder];
    if(![IO writeFileToPath:path withData:UIImageJPEGRepresentation(image, 0.5)])
    {
        [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"SaveError", nil)];
        return ;
    }
    
    int offx = 5;
    __weak PublishImageView * imageView = [self generateImageViewWithPath:path];
    imageView.frame = CGRectMake(offx * ([_images count] + 1) + [_images count] * CGRectGetWidth(imageView.frame), 0, CGRectGetWidth(imageView.frame), CGRectGetHeight(imageView.frame));
    imageView.deleteBlock = ^(NSString * path){
        [_images removeObject:path];
        [_imageViews removeObject:imageView];
        if([_imageViews count] > 0)
        {
            [self reRangeImageView];
        }
        [_scrollView setContentSize:CGSizeMake(([_images count] + 1) * offx + [_images count] * CGRectGetWidth(_scrollView.frame), CGRectGetHeight(_scrollView.frame))];
        [_addMoreButton setTitle:[NSString stringWithFormat:@"添加更多(%i/9)",[_images count]] forState:UIControlStateNormal];
        if([_images count] == 0)
        {
            _addMoreButton.hidden = YES;
            [self.view addSubview:_button3View];
            
        }
    };
    [_images addObject:path];
    [_imageViews addObject:imageView];
    [_scrollView addSubview:imageView];
    [_scrollView setContentSize:CGSizeMake(([_images count] + 1) * offx + [_images count] * CGRectGetWidth(imageView.frame), CGRectGetHeight(_scrollView.frame))];
    //隐藏按钮
    [_button3View removeFromSuperview];
    
    if([_images count] < 9)
    {
        //显示添加按钮，设置标题
        _addMoreButton.hidden = NO;
        [_addMoreButton setTitle:[NSString stringWithFormat:@"添加更多(%i/9)",[_images count]] forState:UIControlStateNormal];
    }
    else
    {
        //9个图片，隐藏按钮
        _addMoreButton.hidden = YES;
    }

}

//选择视频后的处理
- (void)pickVideoProcess:(NSURL *)videoURL
{
    if(videoURL == nil)
    {
        DDLogWarn(@"The video url is nil.");
        return ;
    }
    
    //文件名和保存路径
    NSString * fileName = [[[NSProcessInfo processInfo] globallyUniqueString] stringByAppendingPathExtension:@"mov"];
    NSString * path = [IO pathForResource:fileName inDirectory:Publish_Video_Folder];
    //保存
    NSData * videoData = [NSData dataWithContentsOfURL:videoURL];
    if(![IO writeFileToPath:path withData:videoData])
    {
        [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"SaveError", nil)];
        return ;
    }
    NSString * mp4Name = [[[NSProcessInfo processInfo] globallyUniqueString] stringByAppendingPathExtension:@"mp4"];
    [SVProgressHUD showWithStatus:@"处理中..." maskType:SVProgressHUDMaskTypeGradient];
    NSString * mp4Path = [IO pathForResource:mp4Name inDirectory:Publish_Video_Folder];
    [[VideoConvertHelper sharedHelper] setFinishBlock:^(){
        
        _videoPath = mp4Path;
        [SVProgressHUD dismiss];
        
        PublishImageView * imageView = [self generateImageViewWithPath:mp4Path];
        imageView.frame = CGRectMake(5,5,CGRectGetWidth(_scrollView.frame) - 10,CGRectGetHeight(_scrollView.frame) - 10);
        __weak PublishImageView * weakImageView = imageView;
        imageView.deleteBlock = ^(NSString * path){
            _videoPath = nil;
            [_imageViews removeObject:weakImageView];
            _addMoreButton.hidden = YES;
            [self.view addSubview:_button3View];
        };

        [_imageViews addObject:imageView];
        [_scrollView addSubview:imageView];
        [_scrollView setContentSize:CGSizeMake(CGRectGetWidth(_scrollView.frame),CGRectGetHeight(_scrollView.frame))];
        //隐藏按钮
        [_button3View removeFromSuperview];
        _addMoreButton.hidden = YES;
        
        
        
    }];
    [[VideoConvertHelper sharedHelper] convertMov:path toMP4:mp4Path];
    
    
}

//生成imageview
- (PublishImageView *)generateImageViewWithPath:(NSString *)path
{
    PublishImageView * imageView = [[PublishImageView alloc] initWithFrame:CGRectMake(0, 0, 108, 108) withPath:path];
    imageView.tapBlock = ^(NSString * path){
        
        if([path hasSuffix:@"png"] || [path hasSuffix:@"jpg"])
        {
            ImageDisplayView * displayView = [[ImageDisplayView alloc] initWithFrame:self.navigationController.view.bounds withPath:path];
            [self.navigationController.view addSubview:displayView];
            [displayView show];
        }
        else if([path hasSuffix:@"mp4"] || [path hasSuffix:@"mov"])
        {
            MPMoviePlayerViewController * player = [[MPMoviePlayerViewController alloc] initWithContentURL:[NSURL fileURLWithPath:path]];
            player.moviePlayer.shouldAutoplay = YES;
            [player.moviePlayer prepareToPlay];
            [player.moviePlayer setControlStyle:MPMovieControlStyleFullscreen];
            [self presentViewController:player animated:YES completion:nil];
        }
    };
    return imageView;
}

//重新排列图片
- (void)reRangeImageView
{
    int offx = 5;
    for (int i = 0; i < [_imageViews count]; i++) {
        PublishImageView * imageView = _imageViews[i];
        imageView.frame = CGRectMake((i + 1) * offx + i * CGRectGetWidth(imageView.frame), 0, CGRectGetWidth(imageView.frame), CGRectGetHeight(imageView.frame));
    }
}

- (void)keyboardShow:(NSNotification *)notification
{
    float duration = [[[notification userInfo] objectForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue];
    //NSLog(@"%@",[[notification userInfo] objectForKey:UIKeyboardFrameBeginUserInfoKey]);
    CGRect beginRect = [[[notification userInfo] objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue];
    CGRect endRect = [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    
    //NSLog(@"%f",self.view.frame.origin.y);
    
    [UIView animateWithDuration:duration animations:^{
        
        float offset ;
        if(beginRect.size.height == endRect.size.height)
        {
            offset = - beginRect.size.height + 65;
        }
        else
        {
            offset = beginRect.size.height - endRect.size.height;
        }
        self.view.frame = CGRectOffset(self.view.frame, 0,offset);
    }];
    
}

- (void)keyboardHide:(NSNotification *)notification
{
    float duration = [[[notification userInfo] objectForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue];
    [UIView animateWithDuration:duration animations:^{
        self.view.frame = CGRectMake(0,  [OSHelper iOS7]?64:0, CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame));
    }];

}




#pragma mark - UIImagePickerControllerDelegate Methods
//点击相册中的图片 或照相机照完后点击use  后触发的方法
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [picker dismissViewControllerAnimated:YES completion:^{
        NSString * mediaType = [info objectForKey:UIImagePickerControllerMediaType];
        if ([mediaType isEqualToString:@"public.image"])
        {
            UIImage *image = [info objectForKey:UIImagePickerControllerEditedImage];
            [self pickPictureProcess:image];
        }
        else if([mediaType isEqualToString:@"public.movie"])
        {
            NSURL *videoURL = [info objectForKey:UIImagePickerControllerMediaURL];
            //DDLogVerbose(@"%@",videoURL);
            [self pickVideoProcess:videoURL];
        }

    }];
    
}


- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:^{}];
}


#pragma mark - UIActionSheetDelegate Methods
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 3) {
        return ;
    }
    
    if(buttonIndex == 0)
    {
        self.visibility = @"1";
    }
    else if(buttonIndex == 1)
    {
        self.visibility = @"2";
    }
    else if(buttonIndex == 2)
    {
        self.visibility = @"3";
    }
    
    _visibilityLabel.text = [actionSheet buttonTitleAtIndex:buttonIndex];
}

#pragma mark - UITextViewDelegate Methods
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if(range.location > 140)
    {
        return NO;
    }
    
    //判断是否删除字符
    if([text isEqualToString:@""])
    {
        //匹配话题字符串#...#
        NSString * regex = @"#([^\\#|.]+)#";
        NSRegularExpression * regularExpress = [NSRegularExpression regularExpressionWithPattern:regex options:NSRegularExpressionCaseInsensitive error:nil];
        //获取正则匹配的结果
        NSArray * arr = [regularExpress matchesInString:textView.text options:0 range:NSMakeRange(0, [textView.text length])];
        //如果匹配结果个数大于0，则计算当前删除的是不是话题
        if([arr count] > 0)
        {
            NSTextCheckingResult * last = [arr lastObject];
            NSRange lastRange = last.range;
            if(lastRange.location + lastRange.length >= range.location)
            {
                NSString * text = [textView.text substringToIndex:lastRange.location];
                textView.attributedText = [NSStringUtil makeTopicString:text];
                return NO;
            }
        }
    }
    
    return YES;
}

- (void)textViewDidChange:(UITextView *)textView
{
    textView.attributedText = [NSStringUtil makeTopicString:textView.text];
}


#pragma mark - UIAlertViewDelegate Methods
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    [alertView dismissWithClickedButtonIndex:alertView.cancelButtonIndex animated:YES];
    if(buttonIndex == 0)
    {
        [self popVIewController];
        return ;
    }
    
    
    if(buttonIndex == 1)
    {
        if(alertView.tag == 1)
        {
            [self showAddBaby];
        }
        else if(alertView.tag == 2)
        {
            [self getBabys];
        }
        else if (alertView.tag == 3)
        {
            //将上传失败的图片重新上传
            if([_uploadFailImages count] > 0)
            {
                NSArray * tmp = [_uploadFailImages copy];
                for(NSString * path in tmp)
                {
                    [[QNUploadHelper sharedHelper] uploadFile:path];
                    [_uploadFailImages removeObject:path];
                }
                tmp = nil;
            }
        }
    }
}

@end
