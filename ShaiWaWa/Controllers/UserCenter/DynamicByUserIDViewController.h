//
//  DynamicByUserIDViewController.h
//  ShaiWaWa
//
//  Created by Carl_Huang on 14-8-14.
//  Copyright (c) 2014年 helloworld. All rights reserved.
//

#import "CommonViewController.h"

@interface DynamicByUserIDViewController : CommonViewController<UITableViewDataSource,UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *dyTableView;

@end
