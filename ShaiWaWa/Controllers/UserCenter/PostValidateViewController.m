//
//  PostValidateViewController.m
//  ShaiWaWa
//  提交验证码
//  Created by Carl on 14-7-5.
//  Copyright (c) 2014年 helloworld. All rights reserved.
//

#import "PostValidateViewController.h"
#import "ControlCenter.h"
#import "UIViewController+BarItemAdapt.h"
#import "SearchAddressListViewController.h"
#import "FinishRegisterViewController.h"
#import "HttpService.h"
#import "SVProgressHUD.h"
#import "InputHelper.h"
#import "UserDefault.h"
#import "UserInfo.h"
#import "PlatformBindViewController.h"
#import "SetPassStepTwoViewController.h"
@interface PostValidateViewController ()
@property (nonatomic,strong) NSTimer * countTimer;
@end

@implementation PostValidateViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        countBacki = 60;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [_validateCoreTextField addTarget:self action:@selector(textChange:) forControlEvents:UIControlEventEditingChanged];
    _nextBtn.enabled = NO;
    // Do any additional setup after loading the view from its nib.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self startTimer];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self stopTimer];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Private Methods
- (void)initUI
{
    self.title = NSLocalizedString(@"ValidateCodeVCTitle", nil);
    [self setLeftCusBarItem:@"square_back" action:nil];
    _phoneNumberLabel.text = _currentPhone;
}


- (void)startTimer
{
    
    if(_countTimer == nil)
    {
        NSBlockOperation * operation = [NSBlockOperation blockOperationWithBlock:^{
            
            _countTimer = [NSTimer timerWithTimeInterval:1 target:self selector:@selector(countBackwards) userInfo:nil repeats:YES];
            [[NSRunLoop currentRunLoop] addTimer:_countTimer forMode:NSRunLoopCommonModes];
            [_countTimer setFireDate:[NSDate date]];
            [_countTimer fire];
        }];
        [operation start];
        return ;
    }
    
    [_countTimer setFireDate:[NSDate date]];
    [_countTimer fire];
}

- (void)stopTimer
{
    if(_countTimer)
    {
        [_countTimer setFireDate:[NSDate distantFuture]];
    }
}

- (void)countBackwards
{
    countBacki--;
    [_getCoreAgainButton setEnabled:NO];
    [_getCoreAgainButton setBackgroundImage:[UIImage imageNamed:@"login_box-5.png"] forState:UIControlStateDisabled];
    [_getCoreAgainButton setTitle:[NSString stringWithFormat:@"重发(%d)",countBacki] forState:UIControlStateDisabled];
    if(countBacki <= 0)
    {
        [_getCoreAgainButton setEnabled:YES];
        [_getCoreAgainButton setTitle:[NSString stringWithFormat:@"重发"] forState:UIControlStateNormal];
        [_getCoreAgainButton setBackgroundImage:[UIImage imageNamed:@"login_box3.png"] forState:UIControlStateNormal];
        _getCoreAgainButton.enabled = YES;
        [self stopTimer];
        return ;
    }
    
}


- (IBAction)showFinishRegisterVC:(id)sender
{
    [_validateCoreTextField resignFirstResponder];
    //先判断验证码是否空
    NSString * code = [InputHelper trim:_validateCoreTextField.text];
    if([InputHelper isEmpty:code])
    {
        [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"CanNotEmpty", nil)];
        return ;
    }
    //判断长度是否是6
//#warning 注意
//    if(![InputHelper isLength:6 withString:code])
//    {
//        [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"InvalidateCode", nil)];
//        return ;
//    }
   
    if(_isBinding)
    {
        void (^BindBlock)(void) = ^(void){
            
            UserInfo * user = [[UserDefault sharedInstance] userInfo];
            
            [[HttpService sharedInstance] bindPhone:@{@"uid":user.uid,@"phone":_currentPhone} completionBlock:^(id object) {
                //保存到本地
                user.phone = _currentPhone;
                [[UserDefault sharedInstance] setUserInfo:user];
                [SVProgressHUD showSuccessWithStatus:@"绑定成功."];
                
                //查找通讯录
                if([_type isEqualToString:@"0"])
                {
                    SearchAddressListViewController * vc = [[SearchAddressListViewController alloc] initWithNibName:nil bundle:nil];
                    [self push:vc];
                    vc = nil;
                }
                else
                {
                    //绑定完成后返回
                    NSArray * vcs = self.navigationController.viewControllers;
                    for(UIViewController * vc in vcs)
                    {
                        if([vc isKindOfClass:[PlatformBindViewController class]])
                        {
                            [self.navigationController popToViewController:vc animated:YES];
                            break ;
                        }
                    }
                }
                
            } failureBlock:^(NSError *error, NSString *responseString) {
                NSString * msg = responseString;
                if(error)
                {
                    msg = @"绑定手机失败.";
                }
                [SVProgressHUD showErrorWithStatus:msg];

            }];
            
        };
        
        [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeGradient];
        [[HttpService sharedInstance] verifyValidateCode:@{@"phone":_currentPhone,@"validate_code":code} completionBlock:^(id object) {
            
            if([_type isEqualToString:@"2"])
            {
                [SVProgressHUD dismiss];
                //前去设置密码
                SetPassStepTwoViewController * vc = [[SetPassStepTwoViewController alloc] initWithNibName:nil bundle:nil];
                [self push:vc];
                vc = nil;
                return ;
            }

            BindBlock();
            
        } failureBlock:^(NSError *error, NSString *responseString) {
            NSString * msg = responseString;
            if(error)
            {
                msg = @"校验失败.";
            }
            [SVProgressHUD showErrorWithStatus:msg];
        }];
        
        return ;
    }
    
    
    
    //验证是否和服务端的一致,才跳转到下个页面
    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeGradient];
    [[HttpService sharedInstance] verifyValidateCode:@{@"phone":_currentPhone,@"validate_code":code} completionBlock:^(id object) {
        [SVProgressHUD dismiss];
        FinishRegisterViewController * vc = [[FinishRegisterViewController alloc] initWithNibName:nil bundle:nil];
        vc.currentPhone = _currentPhone;
        vc.validateCode = code;
        [self push:vc];
        vc = nil;

        
    } failureBlock:^(NSError *error, NSString *responseString) {
        NSString * msg = responseString;
        if(error)
        {
            msg = @"校验失败.";
        }
        [SVProgressHUD showErrorWithStatus:msg];
    }];

}
- (IBAction)getCoreAgainEvent:(id)sender
{
    
    if(countBacki > 0)
    {
        return ;
    }
    
    if(_currentPhone == nil)
    {
        DDLogError(@"The phone is nil.");
        return ;
    }
    
    [[HttpService sharedInstance] sendValidateCode:@{@"phone":_currentPhone} completionBlock:^(id object) {
        countBacki = 60;
        [self startTimer];
    } failureBlock:^(NSError *error, NSString *responseString) {
        NSString * msg = responseString;
        if(error)
        {
            msg = NSLocalizedString(@"LoadError", nil);
        }
        [SVProgressHUD showErrorWithStatus:msg];
    }];
}

#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    BOOL shouNext = range.location >= 4;
    return !shouNext;
}

- (void)textChange:(UITextField *)textField
{
    if (textField.text.length == 4) {
        _nextBtn.enabled = YES;
    }else{
        _nextBtn.enabled = NO;
    }
}

@end
