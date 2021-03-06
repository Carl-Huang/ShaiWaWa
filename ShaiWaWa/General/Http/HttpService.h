//
//  HttpService.h
//  HWSDK
//
//  Created by Carl on 13-11-28.
//  Copyright (c) 2013年 helloworld. All rights reserved.
//

#import "AFHttp.h"
#define URL_PREFIX @"https://115.29.248.57/api/"
#define User_Login                                  @"login"
#define User_Register                               @"register"
#define Open_Login                                  @"open_login"
#define ValidateCode                                @"validatecode"
#define Is_Exists                                   @"is_exists"
#define Change_Password                             @"change_password"
#define Update_User_Info                            @"update_user"
#define Get_System_Notification                     @"get_system_notification"
#define Update_System_Notification                  @"update_system_notification"
#define Add_Baby                                    @"add_baby"
#define Get_Baby_List                               @"get_baby_list"
#define Delete_Baby                                 @"delete_baby"
#define Search_Baby                                 @"search_baby"
#define Get_Baby_List_By_Friend                     @"get_baby_list_by_friend"
#define Get_Baby_Info                               @"get_baby_info"
#define Add_Baby_Grow_Record                        @"add_baby_grow_record"
#define Get_Baby_Grow_Record                        @"get_baby_grow_record_list"
#define Update_Baby_Info                            @"update_baby_info"
#define Publish_Record                              @"publish_record"
#define Update_Praise_Status                        @"update_praise_status"
#define Add_Like                                    @"add_like"
#define Cancel_Like                                 @"cancel_like"
#define Get_Likes_List                              @"get_likes_list"
#define Add_Comment                                 @"add_comment"
#define Get_Comment_List                            @"get_record_comment_list"
#define Add_Favorite                                @"add_favorite"
#define Unfavorite                                  @"unfavorite"
#define Delete_Record                               @"delete_record"
#define Get_Record_List                             @"get_record_list"
#define Get_Record_By_User_ID                       @"get_baby_record_list"
#define Get_Record_By_Friend                        @"get_record_by_friend"
#define Get_Recrod_By_Follow                        @"get_record_by_follow"
#define Get_Record_By_Baby                          @"get_record_by_baby"
#define Search_Recrod                               @"search_record"
#define Get_Record_By_Topic                         @"get_record_by_topic"
#define Get_Favorite_List                           @"get_favorite_list"
#define Apply_Friend                                @"apply_friend"
#define Pass_Friend                                 @"pass_friend"
#define Verify_Friend                               @"verify_friend"
#define Get_Friend_List                             @"get_friend_list"
#define Delete_Friend                               @"delete_friend"
#define Search_Friend                               @"search_friend"
#define Get_Sina_Friend                             @"get_sina_friends"
#define Get_QQ_Friend                               @"get_qq_friends"
#define Get_Addressbook_Friend                      @"get_contacts_friends"
#define Get_User_Info                               @"get_user_info"
#define Follow_Baby                                 @"follow"
#define Is_Focus                                    @"is_focus"
#define Unfollow_Baby                               @"unfollow"
#define Get_User_Setting                            @"get_user_setting"
#define Add_Feedback                                @"add_feedback"
#define Get_Baby_Remark                             @"get_baby_remark"
#define Add_Baby_Remark                             @"add_remark"
#define Update_Baby_Remark                          @"update_remark"
#define Delete_Baby_Remark                          @"delete_remark"
#define Update_User_Setting                         @"update_user_setting"
#define Get_Square_Recrod                           @"square"
#define Bind_Phone                                  @"bind_phone"
#define Verify_Validatecode                         @"verify_validatecode"
#define Is_Friend                                   @"friendship"
#define UnBind                                      @"unbind"
#define Bind_Open_Login                             @"bind_open_login"
#define Find_Friends                                @"find_friends"
#define Add_Report                                  @"add_report"
typedef enum {
    No_Error_Code = 10000,
    Unknow_Error_Code,
    Name_Or_Pass_Error_Code,
    Validate_Error_Code,
    Phone_Existed_Error_Code,
    Param_Invalid_Error_Code,
    Illegal_Request_Error_Code,
    Username_Existed_Error_Code,
    ShaiWaWa_Num_Existed_Error_Code,
    Validate_Times_Beyond_Error_Code,
    Validate_Num_Timeout_Error_Code,
    Invalidate_Num_Error_Code,
    Dynamic_Have_Collected_Error_Code,
    Dynamic_Have_Liked_Error_Code,
    Have_Apply_Friend_Error_Code,
    Were_Friends_Error_Code,
    Open_Platform_Unbind_Error_Code,
    No_Password_Error_Code,
    Not_Friend_Error_Code,
    Normal_Friend_Error_Code,
    Is_Spouses_Error_Code,
    Open_Platform_Bind_Error_Code
}API_Error_Code;

@interface HttpService : AFHttp

+ (HttpService *)sharedInstance;

- (id)mapModel:(id)reponseObject withClass:(Class)cls;
- (NSArray *)mapModelsProcess:(id)responseObject withClass:(Class)class;
/**
 @desc 用户登录
 */
//TODO:用户登录
- (void)userLogin:(NSDictionary *)params completionBlock:(void (^)(id object))success failureBlock:(void (^)(NSError * error,NSString * responseString))failure;

/**
 @desc 用户注册
 */
//TODO:用户注册
- (void)userRegister:(NSDictionary *)params completionBlock:(void (^)(id object))success failureBlock:(void (^)(NSError * error,NSString * responseString))failure;

/**
 @desc 第三方登陆
 */
//TODO:第三方登陆
- (void)openLogin:(NSDictionary *)params completionBlock:(void (^)(id object))success failureBlock:(void (^)(NSError * error,NSString * responseString))failure;

/**
 @desc 发送验证码
 */
//TODO:发送验证码
- (void)sendValidateCode:(NSDictionary *)params completionBlock:(void (^)(id object))success failureBlock:(void (^)(NSError * error,NSString * responseString))failure;

/**
 @desc 验证晒娃娃号是否存在
 */
//TODO:验证晒娃娃号是否存在
- (void)isExists:(NSDictionary *)params completionBlock:(void (^)(id object))success failureBlock:(void (^)(NSError * error,NSString * responseString))failure;



/**
 @desc 修改密码
 */
//TODO:修改密码
- (void)changePassword:(NSDictionary *)params completionBlock:(void (^)(id object))success failureBlock:(void (^)(NSError * error,NSString * responseString))failure;

/**
 @desc 更新用户信息
 */
//TODO:更新用户信息
- (void)updateUserInfo:(NSDictionary *)params completionBlock:(void (^)(id object))success failureBlock:(void (^)(NSError * error,NSString * responseString))failure;


/**
 @desc 获取系统短消息
 */
//TODO:获取系统短消息
- (void)getSystemNotification:(NSDictionary *)params completionBlock:(void (^)(id object))success failureBlock:(void (^)(NSError * error,NSString * responseString))failure;

/**
 @desc 更新系统短消息
 */
//TODO:更新系统短消息
- (void)updateSystemNotification:(NSDictionary *)params completionBlock:(void (^)(id object))success failureBlock:(void (^)(NSError * error,NSString * responseString))failure;


/**
 @desc 添加宝宝
 */
//TODO:添加宝宝
- (void)addBaby:(NSDictionary *)params completionBlock:(void (^)(id object))success failureBlock:(void (^)(NSError * error,NSString * responseString))failure;

/**
 @desc 删除宝宝
 */
//TODO:删除宝宝
- (void)deleteBaby:(NSDictionary *)params completionBlock:(void (^)(id object))success failureBlock:(void (^)(NSError * error,NSString * responseString))failure;

/**
 @desc 搜索宝宝
 */
//TODO:搜索宝宝
- (void)searchBaby:(NSDictionary *)params completionBlock:(void (^)(id object))success failureBlock:(void (^)(NSError * error,NSString * responseString))failure;

/**
 @desc 获取宝宝列表
 */
//TODO:获取宝宝列表
- (void)getBabyList:(NSDictionary *)params completionBlock:(void (^)(id object))success failureBlock:(void (^)(NSError * error,NSString * responseString))failure;

/**
 @desc 获取好友宝宝列表
 */
//TODO:获取好友宝宝列表
- (void)getBabyListByFriend:(NSDictionary *)params completionBlock:(void (^)(id object))success failureBlock:(void (^)(NSError * error,NSString * responseString))failure;

/**
 @desc 获取宝宝信息
 */
//TODO:获取宝宝信息
- (void)getBabyInfo:(NSDictionary *)params completionBlock:(void (^)(id object))success failureBlock:(void (^)(NSError * error,NSString * responseString))failure;


/**
 @desc 添加宝宝成长记录
 */
//TODO:添加宝宝成长记录
- (void)addBabyGrowRecord:(NSDictionary *)params completionBlock:(void (^)(id object))success failureBlock:(void (^)(NSError * error,NSString * responseString))failure;


/**
 @desc 获取宝宝成长记录
 */
//TODO:获取宝宝成长记录
- (void)getBabyGrowRecord:(NSDictionary *)params completionBlock:(void (^)(id object))success failureBlock:(void (^)(NSError * error,NSString * responseString))failure;

/**
 @desc 更新宝宝信息
 */
//TODO:更新宝宝信息
- (void)updateBabyInfo:(NSDictionary *)params completionBlock:(void (^)(id object))success failureBlock:(void (^)(NSError * error,NSString * responseString))failure;

/**
 @desc 发布动态
 */
//TODO:发布动态
- (void)publishRecord:(NSDictionary *)params completionBlock:(void (^)(id object))success failureBlock:(void (^)(NSError * error,NSString * responseString))failure;

/**
 @desc 删除动态
 */
//TODO:删除动态
- (void)deleteRecord:(NSDictionary *)params completionBlock:(void (^)(id object))success failureBlock:(void (^)(NSError * error,NSString * responseString))failure;

/**
 @desc 更新赞状态
 */
//TODO:更新赞状态
- (void)updatePraiseStatus:(NSDictionary *)params completionBlock:(void (^)(id object))success failureBlock:(void (^)(NSError * error,NSString * responseString))failure;

/**
 @desc 动态取消赞
 */
//TODO:动态取消赞
- (void)cancelLike:(NSDictionary *)params completionBlock:(void (^)(id object))success failureBlock:(void (^)(NSError * error,NSString * responseString))failure;


/**
 @desc 动态添加赞
 */
//TODO:动态添加赞
- (void)addLike:(NSDictionary *)params completionBlock:(void (^)(id object))success failureBlock:(void (^)(NSError * error,NSString * responseString))failure;

/**
 @desc 获取动态被赞用户列表
 */
//TODO:获取动态被赞用户列表

- (void)getLikingList:(NSDictionary *)params completionBlock:(void (^)(id object))success failureBlock:(void (^)(NSError * error,NSString * responseString))failure;

/**
 @desc 添加评论
 */
//TODO:添加评论
- (void)addComment:(NSDictionary *)params completionBlock:(void (^)(id object))success failureBlock:(void (^)(NSError * error,NSString * responseString))failure;

/**
 @desc 获取评论列表
 */
//TODO:获取评论列表
- (void)getCommentList:(NSDictionary *)params completionBlock:(void (^)(id object))success failureBlock:(void (^)(NSError * error,NSString * responseString))failure;


/**
 @desc 添加收藏
 */
//TODO:添加收藏
- (void)addFavorite:(NSDictionary *)params completionBlock:(void (^)(id object))success failureBlock:(void (^)(NSError * error,NSString * responseString))failure;

/**
 @desc 取消收藏
 */
//TODO:取消收藏
- (void)unfavorite:(NSDictionary *)params completionBlock:(void (^)(id object))success failureBlock:(void (^)(NSError * error,NSString * responseString))failure;

/**
 @desc 获取收藏列表
 */
//TODO:获取收藏列表
- (void)getFavorite:(NSDictionary *)params completionBlock:(void (^)(id object))success failureBlock:(void (^)(NSError * error,NSString * responseString))failure;

/**
 @desc 获取动态列表
 */
//TODO:获取动态列表
- (void)getRecordList:(NSDictionary *)params completionBlock:(void (^)(id object))success failureBlock:(void (^)(NSError * error,NSString * responseString))failure;

/**
 @desc 根据用户id获取宝宝动态接口
 */
//TODO:根据用户id获取宝宝动态接口
- (void)getRecordByUserID:(NSDictionary *)params completionBlock:(void (^)(id object))success failureBlock:(void (^)(NSError * error,NSString * responseString))failure;


/**
 @desc 获取好友宝宝动态
 */
//TODO: 获取好友宝宝动态
- (void)getRecordByFriend:(NSDictionary *)params completionBlock:(void (^)(id object))success failureBlock:(void (^)(NSError * error,NSString * responseString))failure;


/**
 @desc 获取特别关注宝宝动态接口
 */
//TODO:获取特别关注宝宝动态接口
- (void)getRecordByFollow:(NSDictionary *)params completionBlock:(void (^)(id object))success failureBlock:(void (^)(NSError * error,NSString * responseString))failure;

/**
 @desc 根据话题获取宝宝动态接口
 */
//TODO:根据话题获取宝宝动态接口
- (void)getRecordByTopic:(NSDictionary *)params completionBlock:(void (^)(id object))success failureBlock:(void (^)(NSError * error,NSString * responseString))failure;

/**
 @desc 根据宝宝获取动态
 */
//TODO:根据宝宝获取动态
- (void)getRecordByBaby:(NSDictionary *)params completionBlock:(void (^)(id object))success failureBlock:(void (^)(NSError * error,NSString * responseString))failure;


/**
 @desc 搜索动态接口
 */
//TODO:搜索动态接口
- (void)searchRecord:(NSDictionary *)params completionBlock:(void (^)(id object))success failureBlock:(void (^)(NSError * error,NSString * responseString))failure;

/**
 @desc 获取广场动态
 */
//TODO:获取广场动态
- (void)getSquareRecord:(NSDictionary *)params completionBlock:(void (^)(id object))success failureBlock:(void (^)(NSError * error,NSString * responseString))failure;


/**
 @desc 申请好友
 */
//TODO:申请好友
- (void)applyFriend:(NSDictionary *)params completionBlock:(void (^)(id object))success failureBlock:(void (^)(NSError * error,NSString * responseString))failure;

/**
 @desc 通过好友
 */
//TODO:通过好友
- (void)passFriend:(NSDictionary *)params completionBlock:(void (^)(id object))success failureBlock:(void (^)(NSError * error,NSString * responseString))failure;

/**
 @desc 通过以及拒绝申请好友
 */
//TODO:通过以及拒绝申请好友
- (void)verifyFriend:(NSDictionary *)params completionBlock:(void (^)(id object))success failureBlock:(void (^)(NSError * error,NSString * responseString))failure;

/**
 @desc 获取好友列表
 */
//TODO:获取好友列表
- (void)getFriendList:(NSDictionary *)params completionBlock:(void (^)(id object))success failureBlock:(void (^)(NSError * error,NSString * responseString))failure;

/**
 @desc 删除好友
 */
//TODO:删除好友
- (void)deleteFriend:(NSDictionary *)params completionBlock:(void (^)(id object))success failureBlock:(void (^)(NSError * error,NSString * responseString))failure;

/**
 @desc 搜索好友
 */
//TODO:搜索好友
- (void)searchFriend:(NSDictionary *)params completionBlock:(void (^)(id object))success failureBlock:(void (^)(NSError * error,NSString * responseString))failure;

/**
 @desc 获取新浪好友
 */
//TODO:获取新浪好友
- (void)getSinaFriend:(NSDictionary *)params completionBlock:(void (^)(id object))success failureBlock:(void (^)(NSError * error,NSString * responseString))failure;

/**
 @desc 获取QQ好友
 */
//TODO:获取QQ好友
- (void)getQQFriend:(NSDictionary *)params completionBlock:(void (^)(id object))success failureBlock:(void (^)(NSError * error,NSString * responseString))failure;

/**
 @desc 获取通讯录好友
 */
//TODO:获取通讯录好友
- (void)getAddressBookFriend:(NSDictionary *)params completionBlock:(void (^)(id object))success failureBlock:(void (^)(NSError * error,NSString * responseString))failure;

/**
 @desc 根据用户id获取用户信息接口
 */
//TODO:根据用户id获取用户信息接口
- (void)getUserInfo:(NSDictionary *)params completionBlock:(void (^)(id object))success failureBlock:(void (^)(NSError * error,NSString * responseString))failure;

/**
 @desc 特别关注宝宝接口
 */
//TODO:特别关注宝宝接口
- (void)followBaby:(NSDictionary *)params completionBlock:(void (^)(id object))success failureBlock:(void (^)(NSError * error,NSString * responseString))failure;

/**
 @desc 获取宝宝备注
 */
//TODO:获取宝宝备注
- (void)getBabyRemark:(NSDictionary *)params completionBlock:(void (^)(id object))success failureBlock:(void (^)(NSError * error,NSString * responseString))failure;

/**
 @desc 添加宝宝备注
 */
//TODO:添加宝宝备注
- (void)addBabyRemark:(NSDictionary *)params completionBlock:(void (^)(id object))success failureBlock:(void (^)(NSError * error,NSString * responseString))failure;

/**
 @desc 更新宝宝备注
 */
//TODO:更新宝宝备注
- (void)updateBabyRemark:(NSDictionary *)params completionBlock:(void (^)(id object))success failureBlock:(void (^)(NSError * error,NSString * responseString))failure;

/**
 @desc 删除宝宝备注
 */
//TODO:删除宝宝备注
- (void)deleteBabyRemark:(NSDictionary *)params completionBlock:(void (^)(id object))success failureBlock:(void (^)(NSError * error,NSString * responseString))failure;

/**
 @desc 添加意见反馈
 */
//TODO:添加意见反馈
- (void)addFeedback:(NSDictionary *)params completionBlock:(void (^)(id object))success failureBlock:(void (^)(NSError * error,NSString * responseString))failure;

/**
 @desc 获取用户设置
 */
//TODO:获取用户设置
- (void)getUserSetting:(NSDictionary *)params completionBlock:(void (^)(id object))success failureBlock:(void (^)(NSError * error,NSString * responseString))failure;

/**
 @desc 更新用户配置
 */
//TODO:更新用户配置
- (void)updateUserSetting:(NSDictionary *)params completionBlock:(void (^)(id object))success failureBlock:(void (^)(NSError * error,NSString * responseString))failure;

/**
 @desc 绑定手机
 */
//TODO:绑定手机
- (void)bindPhone:(NSDictionary *)params completionBlock:(void (^)(id object))success failureBlock:(void (^)(NSError * error,NSString * responseString))failure;

/**
 @desc 校验验证码
 */
//TODO:校验验证码
- (void)verifyValidateCode:(NSDictionary *)params completionBlock:(void (^)(id object))success failureBlock:(void (^)(NSError * error,NSString * responseString))failure;

/**
 @desc 判断是否为好友
 */
//TODO:判断是否为好友
- (void)isFriend:(NSDictionary *)params completionBlock:(void (^)(id object))success failureBlock:(void (^)(NSError * error,NSString * responseString))failure;
/**
 @desc 判断是否特别关注
 */
//TODO:判断是否特别关注
- (void)isFocus:(NSDictionary *)params completionBlock:(void (^)(id object))success failureBlock:(void (^)(NSError * error,NSString * responseString))failure;

/**
 @desc 解除绑定
 */
//TODO:解除绑定
- (void)unbind:(NSDictionary *)params completionBlock:(void (^)(id object))success failureBlock:(void (^)(NSError * error,NSString * responseString))failure;

/**
 @desc 第三方绑定
 */
//TODO:第三方绑定
- (void)bindOpenLogin:(NSDictionary *)params completionBlock:(void (^)(id object))success failureBlock:(void (^)(NSError * error,NSString * responseString))failure;

/**
 @desc 查找好友（整站）
 */
//TODO:查找好友（整站）
- (void)findFriends:(NSDictionary *)params completionBlock:(void (^)(id object))success failureBlock:(void (^)(NSError * error,NSString * responseString))failure;

/**
 @desc 举报动态
 */
//TODO:举报动态
- (void)addReport:(NSDictionary *)params completionBlock:(void (^)(id object))success failureBlock:(void (^)(NSError * error,NSString * responseString))failure;


/**
 @desc 取消特别关注宝宝
 */
//TODO:取消特别关注宝宝
- (void)unfollowBaby:(NSDictionary *)params completionBlock:(void (^)(id object))success failureBlock:(void (^)(NSError * error,NSString * responseString))failure;


@end
