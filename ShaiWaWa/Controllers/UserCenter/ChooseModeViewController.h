//
//  ChooseModeViewController.h
//  ShaiWaWa
//
//  Created by 祥 on 14-7-5.
//  Copyright (c) 2014年 helloworld. All rights reserved.
//

#import "CommonViewController.h"

@interface ChooseModeViewController : CommonViewController
{
    BOOL isMenuShown;
}
- (IBAction)showSearchFriendsVC:(id)sender;

- (IBAction)showAddBabyVC:(id)sender;
@property (strong, nonatomic) IBOutlet UIView *menuGray;
- (IBAction)hideMenuGray:(id)sender;
@property (strong, nonatomic) IBOutlet UITapGestureRecognizer *userViewTap;
- (IBAction)userViewTouchEvent:(id)sender;
@end
