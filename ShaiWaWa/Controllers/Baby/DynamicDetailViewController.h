//
//  DynamicDetailViewController.h
//  ShaiWaWa
//
//  Created by Carl_Huang on 14-7-17.
//  Copyright (c) 2014年 helloworld. All rights reserved.
//

#import "CommonViewController.h"
#import "BabyRecord.h"
@interface DynamicDetailViewController : CommonViewController<UITableViewDataSource,UITableViewDelegate,UITextFieldDelegate>
{
    BOOL isShareViewShown;
    UITextField *temp_txt;
    NSMutableArray *pinLunArray;
}
@property (strong, nonatomic) IBOutlet UITableView *pinLunListTableView;
@property (weak, nonatomic) IBOutlet UIView *grayShareView;
@property (weak, nonatomic) IBOutlet UIView *shareView;
@property (weak, nonatomic) IBOutlet UITextField *pinLunContextTextField;
@property (strong,nonatomic) BabyRecord * babyRecord;


- (IBAction)hideGrayShareV:(id)sender;
- (IBAction)pinLunEvent:(id)sender;

@end
