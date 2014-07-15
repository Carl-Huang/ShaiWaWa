//
//  BabyHomePageViewController.h
//  ShaiWaWa
//
//  Created by 祥 on 14-7-9.
//  Copyright (c) 2014年 helloworld. All rights reserved.
//

#import "CommonViewController.h"
#import "HMSegmentedControl.h"

@interface BabyHomePageViewController : CommonViewController<UIScrollViewDelegate,UITableViewDataSource,UITableViewDelegate>
{
    HMSegmentedControl *segMentedControl;
    NSMutableDictionary *summaryDic;
    NSArray *summaryKey;
    NSArray *summaryValue;
    BOOL isRightBtnSelected;
}
@property (strong, nonatomic) IBOutlet UIView *tabSelectionBar;

@property (strong, nonatomic) IBOutlet UIScrollView *segScrollView;
@property (strong, nonatomic) IBOutlet UIView *summaryView;
@property (strong, nonatomic) IBOutlet UITableView *summaryTableView;
@property (strong, nonatomic) IBOutlet UIButton *monButton;
@property (strong, nonatomic) IBOutlet UIButton *dadButton;
- (IBAction)isYaoQing:(id)sender;

@property (strong, nonatomic) IBOutlet UIView *yaoQingbgView;
- (IBAction)msgYaoQingButton:(id)sender;

- (IBAction)weiXinYaoQingButton:(id)sender;
- (IBAction)hideCurView:(id)sender;

@end
