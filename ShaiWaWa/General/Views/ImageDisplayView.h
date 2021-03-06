//
//  ImageDisplayView.h
//  ShaiWaWa
//
//  Created by Carl on 14-8-31.
//  Copyright (c) 2014年 helloworld. All rights reserved.
//

#import "CommonAlert.h"

@interface ImageDisplayView : CommonAlert
@property (nonatomic,strong) NSString * path;
@property (nonatomic,strong) NSArray * images;
- (id)initWithFrame:(CGRect)frame withPath:(NSString *)path;
- (id)initWithFrame:(CGRect)frame withPath:(NSString *)path withAllImages:(NSArray *)images;
@end
