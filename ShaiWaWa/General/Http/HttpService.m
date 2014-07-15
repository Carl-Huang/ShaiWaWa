//
//  HttpService.m
//  HWSDK
//
//  Created by Carl on 13-11-28.
//  Copyright (c) 2013年 helloworld. All rights reserved.
//

#import "HttpService.h"
#import "AllModels.h"
#import <objc/runtime.h>
#define HW @"hw_"       //关键字属性前缀
@implementation HttpService

#pragma mark Life Cycle
- (id)init
{
    if ((self = [super init])) {
        
    }
    return  self;
}

#pragma mark Class Method
+ (HttpService *)sharedInstance
{
    static HttpService * this = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        this = [[self alloc] init];
    });
    return this;
}

#pragma mark Private Methods
- (NSString *)mergeURL:(NSString *)methodName
{
    NSString * str =[NSString stringWithFormat:@"%@%@",URL_PREFIX,methodName];
    str = [str stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    return str;
}

/**
 @desc 返回类的属性列表
 @param 类对应的class
 @return NSArray 属性列表
 */
+ (NSArray *)propertiesName:(Class)cls
{
    if(cls == nil) return nil;
    unsigned int outCount,i;
    objc_property_t * properties = class_copyPropertyList(cls, &outCount);
    NSMutableArray * list = [NSMutableArray arrayWithCapacity:outCount];
    for (i = 0; i < outCount; i++)
    {
        objc_property_t property = properties[i];
        NSString * propertyName = [NSString stringWithUTF8String:property_getName(property)];
        if(propertyName && [propertyName length] != 0)
        {
            [list addObject:propertyName];
        }
    }
    return list;
}



//将取得的内容转换为模型
- (NSArray *)mapModelsProcess:(id)responseObject withClass:(Class)class
{
    //判断返回值
    if(!responseObject || [responseObject isKindOfClass:[NSNull class]] || ![responseObject isKindOfClass:[NSArray class]])
    {
        return nil;
    }
    
//    NSArray * properties = [[self class] propertiesName:class];
    NSMutableArray * models = [NSMutableArray array];
    for (NSDictionary * info in responseObject) {
        if (info) {
            id model = [self mapModel:info withClass:class];
            if(model)
            {
                [models addObject:model];
            }
        }
        
    }
    
    return (NSArray *)models;
}

- (id)mapModel:(id)reponseObject withClass:(Class)cls
{
    if (!reponseObject || [reponseObject isKindOfClass:[NSNull class]]) {
        return nil;
    }
    id model  = [[cls alloc] init];
    NSArray * properties = [[self class] propertiesName:cls];
    for(NSString * property in properties)
    {
        NSString * tmp = [property stringByReplacingOccurrencesOfString:HW withString:@""];
        id value = [reponseObject valueForKey:tmp];
        if(![value isKindOfClass:[NSNull class]])
        {
            if(![value isKindOfClass:[NSString class]])
            {
                [model setValue:[value stringValue] forKey:property];
            }
            else
            {
                [model setValue:value forKey:property];
            }
        }
    }
    return model;
}

#pragma mark Instance Method
/**
 @desc 用户登录
 */
- (void)userLogin:(NSDictionary *)params completionBlock:(void (^)(id object))success failureBlock:(void (^)(NSError * error,NSString * responseString))failure
{

    [self post:[self mergeURL:User_Login] withParams:params completionBlock:^(id obj) {
        if((obj == nil || [obj[@"error"] isEqualToString:@"1"]) && failure)
        {
            failure(nil,obj[@"msg"]);
            return ;
        }
        if(success)
        {
            NSMutableDictionary * data = [obj[@"data"] mutableCopy];
            data[@"password"] = params[@"psw"];
            User * user  = [self mapModel:data withClass:[User class]];
            success(user);
            data = nil;
            
        }
    } failureBlock:failure];
}

/**
 @desc 用户注册
 */
- (void)userRegister:(NSDictionary *)params completionBlock:(void (^)(id object))success failureBlock:(void (^)(NSError * error,NSString * reponseString))failure
{
    [self post:[self mergeURL:User_Register] withParams:params completionBlock:^(id obj) {
        if((obj == nil || [obj count] == 0) && failure)
        {
            failure(nil,@"注册失败.");
            return ;
        }
        
        if(!success)
            return ;
        NSString * state = obj[0][@"state"];
        if([state isEqualToString:@"Y"])
        {
            NSString * userID ;
            if ([obj count] == 2)
            {
                userID = obj[1][@"id"];
            }
            success(userID);
        }
        else
        {
            NSString * message = @"注册失败.";
            if([obj count] == 2)
                message = obj[1][@"msg"];
            if(failure) failure(nil,message);
        }
    } failureBlock:failure];
}








@end
