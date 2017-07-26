//
//  SKAPIBaseManager.m
//  
//
//  Created by Wei on 17/2/20.
//  Copyright © 2017年 Wei. All rights reserved.
//

#import "SKAPIBaseManager.h"
#import "SKAPIClient.h"
#import "AFNetworkReachabilityManager.h"
#import "SKAPICache.h"
#define SKCallAPI(REQUEST_METHOD,REQUEST_ID)                                                   \
{                                                                                               \
    __weak typeof(self) weakSelf = self;                                                        \
    REQUEST_ID =[[SKAPIClient sharedInstance] call##REQUEST_METHOD##WithParams:apiParams host:self.realManager.host methodName:self.realManager.methodName constructingBodyWithBlock:self.formDataBlock progress:^(NSProgress *theProgress) {\
        __strong typeof(weakSelf) strongSelf = weakSelf;\
        [strongSelf requestProgress:theProgress];\
    } success:^(SKAPIResponse *response) {\
        __strong typeof(weakSelf) strongSelf = weakSelf;\
        [strongSelf requestSuccess:response];\
    } fail:^(SKAPIResponse *response) {\
        __strong typeof(weakSelf) strongSelf = weakSelf;\
        [strongSelf requestFail:response];\
    }];\
    [self.requestIdCache addObject:@(REQUEST_ID)];\
}

@interface SKAPIBaseManager()
@property (nonatomic, strong, readwrite) id resultData;
@property (nonatomic, strong) NSMutableArray *requestIdCache;
@property (nonatomic, assign, readwrite) BOOL isLoading;
@property (nonatomic, assign, readwrite) BOOL isMore;
@property (nonatomic, strong) SKAPICache *cache;
@property (nonatomic, assign) BOOL hasCache;
@property (nonatomic, assign) NSInteger nextCursor;
@property (nonatomic, copy) void(^formDataBlock)(id <AFMultipartFormData> formData);
@end
@implementation SKAPIBaseManager
- (instancetype)init
{
    self = [super init];
    if (self) {
        _delegate = nil;
        
        if ([self conformsToProtocol:@protocol(SKAPIManager)]) {
            self.realManager = (id <SKAPIManager>)self;
        } else {
            NSAssert(NO, @"子类必须要实现SKAPIManager这个协议");
        }
    }
    
    
    return self;

    
}
- (void)dealloc
{
    [self cancelAllRequests];
    self.requestIdCache = nil;
}
- (NSMutableArray *)requestIdCache
{
    if (_requestIdCache == nil) {
        _requestIdCache = [[NSMutableArray alloc] init];
    }
    return _requestIdCache;
}
- (BOOL)isLoading
{
    if (self.requestIdCache.count == 0) {
        _isLoading = NO;
    }
    return _isLoading;
}
-(SKAPICache *)cache{
    return [SKAPICache sharedCache];
}
-(void (^)(id<AFMultipartFormData>))formDataBlock{
    if ([self.realManager respondsToSelector:@selector(formData:)]) {
        return  ^(id<AFMultipartFormData> formData) {
            [self.realManager formData:formData];
        };
    }
    return nil;
}



- (void)cancelAllRequests
{
    [[SKAPIClient sharedInstance] cancelRequestWithRequestIDList:self.requestIdCache];
    [self.requestIdCache removeAllObjects];
}

- (void)cancelRequestWithRequestId:(NSInteger)requestID
{
    [self removeRequestIdWithRequestID:requestID];
    [[SKAPIClient sharedInstance] cancelRequestWithRequestID:@(requestID)];
}


- (void)removeRequestIdWithRequestID:(NSInteger)requestId
{
    NSNumber *requestIDToRemove = nil;
    for (NSNumber *storedRequestId in self.requestIdCache) {
        if ([storedRequestId integerValue] == requestId) {
            requestIDToRemove = storedRequestId;
        }
    }
    if (requestIDToRemove) {
        [self.requestIdCache removeObject:requestIDToRemove];
    }
}

- (void)run{
    self.isMore = NO;
    NSDictionary *apiParams;
    if(self.paramSource&&[self.paramSource respondsToSelector:@selector(param:)]){
        apiParams = [self.paramSource param:self];
    }
    if ([self.realManager respondsToSelector:@selector(shouldCache)]&&[self.realManager shouldCache]) {
        id response = [self.cache objectForHost:[self.realManager host] methodName:[self.realManager methodName] Param:apiParams];
        if (response) {
            self.hasCache = YES;
            SKAPIResponse *apiResponse = [[SKAPIResponse alloc]initWithResponse:response];
            self.response = apiResponse;
            if (self.delegate&&[self.delegate respondsToSelector:@selector(APIDidSuccess:)]) {
                [self.delegate APIDidSuccess:self];
            }
        }
    }
    [self runWithParam:apiParams];

}
- (void)loadMore{
    self.isMore = YES;
    if (_nextCursor == -1) {
        if (self.delegate&&[self.delegate respondsToSelector:@selector(APINoMoreData)]) {
            [self.delegate APINoMoreData];
        }
        return;
    }
    NSDictionary *apiParams;
    if(self.paramSource&&[self.paramSource respondsToSelector:@selector(param:)]){
        apiParams = [[self.paramSource param:self] mutableCopy];
    }
    if (_nextCursor>0) {
        [apiParams setValue:@(_nextCursor) forKey:@"cursor"];
    }
    [self runWithParam:apiParams];

}
-(void)runWithParam:(NSDictionary *)apiParams{
    if (self.isLoading) {
        return;
    }
    NSInteger requestId = 0;
    // 实际的网络请求
    if ([[AFNetworkReachabilityManager sharedManager] networkReachabilityStatus]) {
        //有连接
        self.isLoading = YES;
        switch (self.realManager.requestType)
        {
            case SKAPIRequestTypeGet:
                SKCallAPI(GET, requestId);
                
                break;
            case SKAPIRequestTypePost:{
                SKCallAPI(POST, requestId);
            }
                
                break;
            default:
                break;
                
        }
        
    } else {
        if (self.hasCache) {
            return;
        }
        if (self.delegate&&[self.delegate respondsToSelector:@selector(APIDidFailed:)]) {
            [self.delegate APIDidFailed:self];
        }
    }
}

- (id)reformDataWithReformer:(id<SKAPIDataReformer>)reformer{
    NSInteger apistatus = [[self.response.responseObject valueForKey:@"apistatus"]integerValue];
    if (apistatus == 1) {
        NSDictionary *result = [self.response.responseObject valueForKey:@"result"];
        _nextCursor = [[result valueForKey:@"nextCursor"]integerValue];
    }
   return [reformer reformData:self.response fromManager:self];
}
- (void)requestSuccess:(SKAPIResponse*)response{
    self.isLoading = NO;
    self.response = response;
    [self removeRequestIdWithRequestID:response.requestId];
    if ([self.realManager respondsToSelector:@selector(shouldCache)]&&[self.realManager shouldCache]) {
        NSDictionary *apiParams;
        if(self.paramSource&&[self.paramSource respondsToSelector:@selector(param:)]){
            apiParams = [[self.paramSource param:self] mutableCopy];
        }
        [self.cache setObject:response.responseObject forHost:[self.realManager host] methodName:[self.realManager methodName] Param:apiParams];
    }
    if (self.delegate&&[self.delegate respondsToSelector:@selector(APIDidSuccess:)]) {
        [self.delegate APIDidSuccess:self];
    }
}
- (void)requestFail:(SKAPIResponse*)response{
    self.isLoading = NO;
    self.response = response;
    [self removeRequestIdWithRequestID:response.requestId];
    if (self.hasCache) {
        return;
    }
    if (self.delegate&&[self.delegate respondsToSelector:@selector(APIDidFailed:)]) {
        [self.delegate APIDidFailed:self];
    }
}
- (void)requestProgress:(NSProgress*)progress{

    if (self.delegate&&[self.delegate respondsToSelector:@selector(APIDidFailed:)]) {
        [self.delegate API:self didProgress:progress];
    }
}
@end
