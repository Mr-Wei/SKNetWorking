//
//  SKAPIManager.h
//  
//
//  Created by Wei on 17/2/20.
//  Copyright © 2017年 Wei. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFNetworking.h"
typedef NS_ENUM (NSUInteger, SKAPIRequestType){
    SKAPIRequestTypeGet,
    SKAPIRequestTypePost
//,
//    SKAPIRequestTypePut,
//    SKAPIRequestTypeDelete
};

//manager的共同协议
@protocol SKAPIManager <NSObject>
@required
/**
 API方法名

 @return string
 */
- (NSString *)methodName;

/**
 host地址

 @return SKAPIHOST枚举不同的接口
 */
- (NSString *)host;

/**
 API方法

 @return GET/POST
 */
- (SKAPIRequestType)requestType;

@optional
/**
 转换API所需参数列表

 @param obj 参数
 */

- (void)setParam:(id)obj;

/**
 自行准备测试数据然后走正常的回调   不产生网络访问
 */
- (void)dummyRun;

/**
 标记API是否需要缓存

 @return BOOL
 */
- (BOOL)shouldCache;

/**
 formData
 */
- (void)formData:(id<AFMultipartFormData>)formData;

@end
