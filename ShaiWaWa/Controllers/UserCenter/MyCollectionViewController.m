//
//  MyCollectionViewController.m
//  ShaiWaWa
//
//  Created by Carl_Huang on 14-8-11.
//  Copyright (c) 2014年 helloworld. All rights reserved.
//

#import "MyCollectionViewController.h"
#import "UIViewController+BarItemAdapt.h"
#import "DynamicCell.h"

#import "HttpService.h"
#import "SVProgressHUD.h"
#import "UserDefault.h"
#import "UserInfo.h"
#import "Friend.h"
#import "BabyInfo.h"

#import "MJRefreshHeaderView.h"
#import "MJRefreshFooterView.h"
#import "MJRefresh.h"
#import "AppMacros.h"

#import "BabyRecord.h"
@import MediaPlayer;

#import "PublishImageView.h"
#import "ImageDisplayView.h"
#import "UIImageView+WebCache.h"
#import "UIButton+WebCache.h"
#import "NSStringUtil.h"
#import "PraiseViewController.h"
#import "TopicListOfDynamic.h"
#import "BabyHomePageViewController.h"
@interface MyCollectionViewController ()
{
     NSMutableArray *dyArray;
}
@property (nonatomic,assign) int currentOffset;
@end

@implementation MyCollectionViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        dyArray = [@[] mutableCopy];
        _currentOffset = 0;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}


- (void)initUI
{
    self.title = @"我的收藏";
    [self setLeftCusBarItem:@"square_back" action:nil];
    [_myFavoriveList clearSeperateLine];
    [_myFavoriveList registerNibWithName:@"DynamicCell" reuseIdentifier:@"Cell"];
    
    [_myFavoriveList addHeaderWithCallback:^{
        [self refresh];
    }];
    
    [_myFavoriveList addFooterWithCallback:^{
        [self loadMore];
    }];
    
    [_myFavoriveList headerBeginRefreshing];
    
}

- (void)refresh
{
    _currentOffset = 0;
    [self getMyFavorite];
}

- (void)loadMore
{
    _currentOffset = [dyArray count];
    [self getMyFavorite];
}

- (void)getMyFavorite
{
    //获取收藏的宝宝动态
    UserInfo *users = [[UserDefault sharedInstance] userInfo];
    [[HttpService sharedInstance] getFavorite:@{@"uid":users.uid,@"offset":[NSString stringWithFormat:@"%i",_currentOffset],@"pagesize":[NSString stringWithFormat:@"%i",CommonPageSize]} completionBlock:^(id object) {
        [_myFavoriveList headerEndRefreshing];
        [_myFavoriveList footerEndRefreshing];
        if(_currentOffset == 0)
        {
            if(object == nil || [object count] == 0)
            {
                [SVProgressHUD showErrorWithStatus:@"暂时没有收藏."];
                return ;
            }
            dyArray = (NSMutableArray *)object;
        }
        else
        {
            [dyArray addObjectsFromArray:object];
        }
        
        [_myFavoriveList reloadData];
        
    } failureBlock:^(NSError *error, NSString *responseString) {
        [_myFavoriveList headerEndRefreshing];
        [_myFavoriveList footerEndRefreshing];
        
        NSString * msg = responseString;
        if (error)
        {
            msg = NSLocalizedString(@"LoadError", nil);
        }
        [SVProgressHUD showErrorWithStatus:msg];
    }];
}

- (void)showPraiseListVC:(UIButton *)sender
{
    
    UIButton * btn = (UIButton *)sender;
    DynamicCell * cell;
    
    if([btn.superview.superview.superview.superview.superview isKindOfClass:[DynamicCell class]])
    {
        cell = (DynamicCell *)btn.superview.superview.superview.superview.superview;
    }
    else if([btn.superview.superview.superview.superview isKindOfClass:[DynamicCell class]])
    {
        cell = (DynamicCell *)btn.superview.superview.superview.superview;
    }
    else
    {
        cell = (DynamicCell *)btn.superview.superview.superview;
    }
    NSIndexPath * indexPath = [_myFavoriveList indexPathForCell:cell];
    BabyRecord * record = dyArray[indexPath.row];
    
    
    PraiseViewController *praiseListVC = [[PraiseViewController alloc] init];
    praiseListVC.record = record;
    [self.navigationController pushViewController:praiseListVC animated:YES];
}

- (void)showTopicDynamic:(UIButton *)sender
{
    NSString * topic = [sender titleForState:UIControlStateNormal];
    TopicListOfDynamic * vc = [[TopicListOfDynamic alloc] initWithNibName:nil bundle:nil];
    vc.topic = topic;
    [self push:vc];
    vc = nil;
}

- (void)likeAction:(id)sender
{
    UIButton * btn = (UIButton *)sender;
    DynamicCell * cell;
    
    if([btn.superview.superview.superview.superview isKindOfClass:[DynamicCell class]])
    {
        cell = (DynamicCell *)btn.superview.superview.superview.superview;
    }
    else if([btn.superview.superview.superview isKindOfClass:[DynamicCell class]])
    {
        cell = (DynamicCell *)btn.superview.superview.superview;
    }
    else
    {
        cell = (DynamicCell *)btn.superview.superview;
    }
    
    
    NSIndexPath * indexPath = [_myFavoriveList indexPathForCell:cell];
    BabyRecord * record = dyArray[indexPath.row];
    UserInfo * users = [[UserDefault sharedInstance] userInfo];
    if([record.is_like isEqualToString:@"1"])
    {
        //取消赞
        [[HttpService sharedInstance] cancelLike:@{@"rid":record.rid,@"uid":users.uid} completionBlock:^(id object) {
            
            [SVProgressHUD showSuccessWithStatus:@"取消赞成功."];
            record.is_like = @"0";
            record.like_count = [NSString stringWithFormat:@"%i",[record.like_count intValue] - 1];
            [_myFavoriveList reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
        } failureBlock:^(NSError *error, NSString *responseString) {
            NSString * msg = responseString;
            if(error)
            {
                msg = @"请求失败";
            }
            [SVProgressHUD showErrorWithStatus:msg];
        }];
        
    }
    else
    {
        [[HttpService sharedInstance] addLike:@{@"rid":record.rid,@"uid":users.uid} completionBlock:^(id object) {
            
            [SVProgressHUD showSuccessWithStatus:@"谢谢您的参与."];
            record.is_like = @"1";
            record.like_count = [NSString stringWithFormat:@"%i",[record.like_count intValue] + 1];
            [_myFavoriveList reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
        } failureBlock:^(NSError *error, NSString *responseString) {
            NSString * msg = responseString;
            if(error)
            {
                msg = @"请求失败";
            }
            [SVProgressHUD showErrorWithStatus:msg];
        }];
        
    }
    
}


- (void)showBabyHomePage:(UITapGestureRecognizer *)gesture
{
    if(![gesture.view isKindOfClass:[UIImageView class]])
    {
        return ;
    }
    
    UIImageView * imageView = (UIImageView *)gesture.view;
    DynamicCell * cell ;
    if([imageView.superview.superview.superview.superview isKindOfClass:[DynamicCell class]])
    {
        cell = (DynamicCell *)imageView.superview.superview.superview.superview;
    }
    else if ([imageView.superview.superview.superview isKindOfClass:[DynamicCell class]])
    {
        cell = (DynamicCell *)imageView.superview.superview.superview;
    }
    else
    {
        cell = (DynamicCell *)imageView.superview.superview;
    }
    
    NSIndexPath * indexPath = [_myFavoriveList indexPathForCell:cell];
    BabyRecord * record = [dyArray objectAtIndex:indexPath.row];
    
    [SVProgressHUD showWithStatus:@"加载中..."];
    [[HttpService sharedInstance] getBabyInfo:@{@"baby_id":record.baby_id} completionBlock:^(id object) {
        [SVProgressHUD dismiss];
        BabyHomePageViewController * vc = [[BabyHomePageViewController alloc] initWithNibName:nil bundle:nil];
        vc.babyInfo = object;
        [self push:vc];
        vc = nil;
        
    } failureBlock:^(NSError *error, NSString *responseString) {
        NSString * msg = responseString;
        if(error)
        {
            msg = @"加载失败.";
        }
        [SVProgressHUD showErrorWithStatus:msg];
    }];
}

#pragma mark - UITableView DataSources and Delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}


-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [dyArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    DynamicCell * dynamicCell = (DynamicCell *)[tableView dequeueReusableCellWithIdentifier:@"Cell"];
    dynamicCell.selectionStyle = UITableViewCellSelectionStyleNone;
    BabyRecord * recrod = [dyArray objectAtIndex:indexPath.row];
    dynamicCell.addressLabel.text = recrod.address;
    //dynamicCell.dyContentTextView.text = recrod.content;
    dynamicCell.dyContentTextView.attributedText = [NSStringUtil makeTopicString:recrod.content];
    [dynamicCell.babyAvatarImageView sd_setImageWithURL:[NSURL URLWithString:recrod.avatar] placeholderImage:Default_Avatar];
    
    NSString * who = recrod.username;
    if([recrod.sex isEqualToString:@"1"])
    {
        who = [NSString stringWithFormat:@"%@(爸爸)",who];
    }
    else if ([recrod.sex isEqualToString:@"2"])
    {
        who = [NSString stringWithFormat:@"%@(妈妈)",who];
    }
    dynamicCell.whoLabel.text = who;
    
    //添加头像点击手势
    UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showBabyHomePage:)];
    dynamicCell.babyAvatarImageView.userInteractionEnabled = YES;
    [dynamicCell.babyAvatarImageView addGestureRecognizer:tap];
    tap = nil;
    
    dynamicCell.babyNameLabel.text = recrod.baby_nickname;
    [dynamicCell.zanButton setTitle:recrod.like_count forState:UIControlStateNormal];
    [dynamicCell.commentBtn setTitle:recrod.comment_count forState:UIControlStateNormal];
    [dynamicCell.zanButton addTarget:self action:@selector(likeAction:) forControlEvents:UIControlEventTouchUpInside];
    
    //[dynamicCell.moreBtn addTarget:self action:@selector(showShareGrayView:) forControlEvents:UIControlEventTouchUpInside];
    dynamicCell.moreBtn.hidden = YES;
    //显示话题
    NSArray * topics = [NSStringUtil getTopicStringArray:recrod.content];
    if([topics count] > 0)
    {
        dynamicCell.topicView.hidden = NO;
        [[dynamicCell.topicView subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
        for (int i = 0; i < [topics count]; i++) {
            if(i >= 2)
            {
                break ;
            }
            
            NSString * topic = topics[i];
            CGSize size = [topic sizeWithFont:[UIFont systemFontOfSize:12] constrainedToSize:CGSizeMake(MAXFLOAT, 0.0)];
            //DDLogInfo(@"%f,%f",size.width,size.height);
            size.width += 10;
            if(size.width >= 65)
            {
                size.width = 65;
            }
            
            UIButton * btn = [UIButton buttonWithType:UIButtonTypeCustom];
            btn.backgroundColor = [UIColor colorWithRed:247.0f/255.0f green:249.0/255.0f blue:248.0/255.0 alpha:1.0];
            btn.frame = CGRectMake(i * 65, 0, size.width, 16);
            [btn setTitle:topic forState:UIControlStateNormal];
            btn.titleLabel.font = [UIFont systemFontOfSize:12];
            [btn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
            btn.layer.cornerRadius = 3.0f;
            [btn addTarget:self action:@selector(showTopicDynamic:) forControlEvents:UIControlEventTouchUpInside];
            [dynamicCell.topicView addSubview:btn];
            btn = nil;
        }
    }
    else
    {
        dynamicCell.topicView.hidden = YES;
    }
    
    
    //显示赞用户头像
    if([recrod.top_3_likes count] > 0)
    {
        dynamicCell.likeUserView.hidden = NO;
        NSDictionary * userDic = recrod.top_3_likes[0];
        [dynamicCell.praiseUserFirstBtn sd_setImageWithURL:[NSURL URLWithString:userDic[@"avatar"] == [NSNull null] ? @"":userDic[@"avatar"]] forState:UIControlStateNormal placeholderImage:Default_Avatar];
        [dynamicCell.praiseUserFirstBtn addTarget:self action:@selector(showPraiseListVC:) forControlEvents:UIControlEventTouchUpInside];
        
        if([recrod.top_3_likes count] == 1)
        {
            dynamicCell.praiseUserSecondBtn.hidden = YES;
            dynamicCell.praiseUserThirdBtn.hidden = YES;
        }
        
        if([recrod.top_3_likes count] > 1)
        {
            userDic = recrod.top_3_likes[1];
            [dynamicCell.praiseUserSecondBtn sd_setImageWithURL:[NSURL URLWithString:userDic[@"avatar"] == [NSNull null] ? @"":userDic[@"avatar"]] forState:UIControlStateNormal placeholderImage:Default_Avatar];
            [dynamicCell.praiseUserSecondBtn addTarget:self action:@selector(showPraiseListVC:) forControlEvents:UIControlEventTouchUpInside];
        }
        
        if([recrod.top_3_likes count] > 2)
        {
            userDic = recrod.top_3_likes[2];
            [dynamicCell.praiseUserThirdBtn sd_setImageWithURL:[NSURL URLWithString:userDic[@"avatar"] == [NSNull null] ? @"":userDic[@"avatar"]] forState:UIControlStateNormal placeholderImage:Default_Avatar];
            [dynamicCell.praiseUserThirdBtn addTarget:self action:@selector(showPraiseListVC:) forControlEvents:UIControlEventTouchUpInside];
        }
    }
    else
    {
        dynamicCell.likeUserView.hidden = YES;
    }
    
    
    //删除重用cell原来的图片
    NSArray * scrollSubviews = [dynamicCell.scrollView subviews];
    for(UIView * view in scrollSubviews)
    {
        if([view isKindOfClass:[PublishImageView class]])
        {
            [view removeFromSuperview];
        }
    }
    
    //显示动态图片或者视频
    if(recrod.video != nil && [recrod.video length] != 0)
    {
        PublishImageView * imageView = [[PublishImageView alloc] initWithFrame:dynamicCell.scrollView.bounds withPath:recrod.video];
        imageView.tapBlock = ^(NSString * path){
            
            MPMoviePlayerViewController * player = [[MPMoviePlayerViewController alloc] initWithContentURL:[NSURL URLWithString:recrod.video]];
            player.moviePlayer.shouldAutoplay = YES;
            [player.moviePlayer setControlStyle:MPMovieControlStyleFullscreen];
            [player.moviePlayer prepareToPlay];
            [self presentViewController:player animated:YES completion:nil];
            
        };
        [imageView setCloseHidden];
        [dynamicCell.scrollView addSubview:imageView];
        imageView = nil;
    }
    else if([recrod.images count] != 0)
    {
        int count = [recrod.images count];
        if(count > 3)
        {
            count = 3;
        }
        float width = CGRectGetWidth(dynamicCell.scrollView.bounds)/count;
        for(int i = 0; i < [recrod.images count]; i++)
        {
            PublishImageView * imageView = [[PublishImageView alloc] initWithFrame:CGRectMake(i * width, 0, width, CGRectGetHeight(dynamicCell.scrollView.bounds)) withPath:recrod.images[i][@"image"]];
            imageView.tapBlock = ^(NSString * path){
                ImageDisplayView * displayView = [[ImageDisplayView alloc] initWithFrame:self.navigationController.view.bounds withPath:path];
                [self.navigationController.view addSubview:displayView];
                [displayView show];
            };
            [imageView setCloseHidden];
            [dynamicCell.scrollView addSubview:imageView];
            imageView = nil;
        }
        [dynamicCell.scrollView setContentSize:CGSizeMake([recrod.images count] * width, CGRectGetHeight(dynamicCell.scrollView.bounds))];
        
    }
    else
    {
        PublishImageView * imageView = [[PublishImageView alloc] initWithFrame:dynamicCell.scrollView.bounds withPath:nil];
        [imageView setCloseHidden];
        [dynamicCell.scrollView addSubview:imageView];
        imageView = nil;
    }
    
    return dynamicCell;
    
}
@end