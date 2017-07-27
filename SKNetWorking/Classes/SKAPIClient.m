//
//  SKAPIClient.m
//  
//
//  Created by Wei on 17/2/24.
//  Copyright © 2017年 Wei. All rights reserved.
//

#import "SKAPIClient.h"
#import "AFNetworking.h"



@interface SKAPIClient ()
@property (nonatomic, strong) NSMutableDictionary *requestCache;
@property (nonatomic, strong) NSDictionary *errorCodeDic;
//AFNetworking (可更换其他网络框架)
@property (nonatomic, strong) AFHTTPSessionManager *sessionManager;
@property (nonatomic, assign) BOOL headerCustom;
@end
@implementation SKAPIClient
#pragma mark - life cycle
- (NSMutableDictionary *)requestCache
{
    if (_requestCache == nil) {
        _requestCache = [[NSMutableDictionary alloc] init];
    }
    return _requestCache;
}
-(NSDictionary *)errorCodeDic{
    if (_errorCodeDic == nil) {
        NSString *errorCodeDicPath = [[NSBundle mainBundle] pathForResource:@"ALPErrorCodeTip" ofType:@"plist"];
        _errorCodeDic = [NSDictionary dictionaryWithContentsOfFile:errorCodeDicPath];
    }
    return _errorCodeDic;
}
+ (instancetype)sharedInstance
{
    static dispatch_once_t onceToken;
    static SKAPIClient *sharedInstance = nil;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[SKAPIClient alloc] init];
    });
    return sharedInstance;
}

- (AFHTTPSessionManager *)sessionManager
{
    if (_sessionManager == nil) {
        _sessionManager = [AFHTTPSessionManager manager];
        _sessionManager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript",@"text/html",@"text/plain",@"image/png", @"application/octet-stream", nil];

    }
    return _sessionManager;
}
- (void)setCommonHeader:(NSDictionary *)header{
    if (self.headerCustom) {
        NSArray *keys = [header allKeys];
        for (NSString *key in keys) {
            NSString* value = [header valueForKey:key];
            if (value) {
                [self.sessionManager.requestSerializer setValue:value forHTTPHeaderField:key];
            }
        }
        self.headerCustom = NO;
    }
}
- (void)setCustomHeader:(NSDictionary *)header{
    NSArray *keys = [header allKeys];
    for (NSString *key in keys) {
        NSString* value = [header valueForKey:key];
        if (value) {
            [self.sessionManager.requestSerializer setValue:value forHTTPHeaderField:key];
        }
    }
    self.headerCustom = YES;
}


//根据参数生成Request请求,目前还是使用AFNetworking的方法
- (NSInteger)callGETWithParams:(NSDictionary*)apiParams host:(NSString*)hostName methodName:(NSString*)methodName constructingBodyWithBlock:(void (^)(id<AFMultipartFormData>))block progress:(SKAPIProgress)progress success:(SKAPICallback)success fail:(SKAPICallback)fail{
    return [self requestWithParams:apiParams HTTPMethod:@"GET" host:hostName
                        methodName:methodName constructingBodyWithBlock:block progress:progress success:success fail:fail];
}
- (NSInteger)callPOSTWithParams:(NSDictionary*)apiParams host:(NSString*)hostName methodName:(NSString*)methodName constructingBodyWithBlock:(void (^)(id<AFMultipartFormData>))block progress:(SKAPIProgress)progress success:(SKAPICallback)success fail:(SKAPICallback)fail{
    return [self requestWithParams:apiParams HTTPMethod:@"POST" host:hostName
                        methodName:methodName constructingBodyWithBlock:block progress:progress success:success fail:fail];
}
- (NSInteger)requestWithParams:(NSDictionary*)apiParams HTTPMethod:(NSString*)httpMethod host:(NSString*)hostName methodName:(NSString*)methodName constructingBodyWithBlock:(void (^)(id<AFMultipartFormData>))block progress:(SKAPIProgress)progress success:(SKAPICallback)success fail:(SKAPICallback)fail{
    NSError *serializationError = nil;
    NSNumber *requestId;
    NSString *urlString = [NSString stringWithFormat:@"%@%@", hostName, methodName];
    NSMutableURLRequest *request;
    if (!block) {
        request = [self.sessionManager.requestSerializer requestWithMethod:httpMethod URLString:urlString parameters:apiParams error:&serializationError];
        requestId = [self callApiWithRequest:request success:success fail:fail];
    }else{
        request = [self.sessionManager.requestSerializer multipartFormRequestWithMethod:httpMethod URLString:urlString  parameters:apiParams constructingBodyWithBlock:block error:&serializationError];
        requestId = [self callUploadWithRequest:request progress:progress success:success fail:fail];
    }
    
    return [requestId integerValue];
    
    
   
}
- (void)cancelRequestWithRequestID:(NSNumber *)requestID
{
    NSURLSessionDataTask *requestOperation = self.requestCache[requestID];
    [requestOperation cancel];
    [self.requestCache removeObjectForKey:requestID];
}

- (void)cancelRequestWithRequestIDList:(NSArray *)requestIDList
{
    for (NSNumber *requestId in requestIDList) {
        [self cancelRequestWithRequestID:requestId];
    }
}
/**
 此内部方法存在的意义有以下几点
 1.不完全使用AFNetworking封装好的请求方法,后续可以更好的适应后台返回的非200的返回值而不需要改动AFnetWorking
 2.可以在此处后续添加HUD之类的逻辑,将其从已加入AFNetWorking的代码中剥离出来
 3.toast的黑白名单逻辑也可以提出(好像跟2没什么区别,手动滑稽)
 4.如果更换网络框架只需要改这一个方法就可以了
 5.基于网络请求的埋点也可以放在这里
 6.文件上传类的请求需要再写一个方法,暂时无优化方案
 @param request API请求
 @param success 成功回调
 @param fail 失败回调
 @return 返回值为当前Request的ID
 */
- (NSNumber *)callApiWithRequest:(NSURLRequest *)request success:(SKAPICallback)success fail:(SKAPICallback)fail
{
    
    __block NSURLSessionDataTask *dataTask = nil;
    
    dataTask = [self.sessionManager dataTaskWithRequest:request uploadProgress:nil downloadProgress:nil completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
        //已完成的请求从缓存中去掉
        NSNumber *requestID = @([dataTask taskIdentifier]);
        [self.requestCache removeObjectForKey:requestID];
        //设想此处应有一个response接收类
        SKAPIResponse *SKResponse = [[SKAPIResponse alloc]initWithRequestID:requestID.integerValue request:request response:responseObject error:error];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (error) {
                //接口访问失败
                if (fail) {
                    fail(SKResponse);
                }
            } else {
                if (success) {
                    success(SKResponse);
                }
            }
        });
    }];
    //请求缓存下来  可中途取消
    NSNumber *requestId = @([dataTask taskIdentifier]);
    self.requestCache[requestId] = dataTask;
    [dataTask resume];
    
    return requestId;
}
- (NSNumber *)callUploadWithRequest:(NSURLRequest *)request progress:(void (^)(NSProgress *uploadProgress)) uploadProgressBlock success:(SKAPICallback)success fail:(SKAPICallback)fail{
    __block NSURLSessionDataTask *task = [self.sessionManager uploadTaskWithStreamedRequest:request progress:^(NSProgress * _Nonnull uploadProgress) {
        if (uploadProgressBlock) {
            uploadProgressBlock(uploadProgress);
        }
    } completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
        NSNumber *requestID = @([task taskIdentifier]);
        [self.requestCache removeObjectForKey:requestID];
        //设想此处应有一个response接收类
        SKAPIResponse *SKResponse = [[SKAPIResponse alloc]initWithRequestID:requestID.integerValue request:request response:responseObject error:error];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (error) {
                //接口访问失败
                if (fail) {
                    fail(SKResponse);
                }
            } else {
                if (success) {
                    success(SKResponse);
                }
            }
        });
    }];
    NSNumber *requestId = @([task taskIdentifier]);
    self.requestCache[requestId] = task;
    [task resume];
    return requestId;
}
@end
