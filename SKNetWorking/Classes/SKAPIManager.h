//
//  SKAPIManager.h
//  
//
//  Created by Wei on 17/2/20.
//  Copyright © 2017年 Wei. All rights reserved.
//

#import <Foundation/Foundation.h>
@protocol AFMultipartFormData;
typedef NS_ENUM (NSUInteger, SKAPIRequestType){
    SKAPIRequestTypeGet,
    SKAPIRequestTypePost
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

 @return API地址域名
 */
- (NSString *)host;

/**
 API方法

 @return GET/POST
 */
- (SKAPIRequestType)requestType;

@optional
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

/**
  通用参数
 */
- (NSDictionary *)commonParam;

/**
 通用Header
 */
- (NSDictionary *)commonHeader;

/**
 定制Header
 */
- (NSDictionary *)customHeader;



@end
