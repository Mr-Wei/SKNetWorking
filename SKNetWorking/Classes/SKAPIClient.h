//
//  SKAPIClient.h
//  
//
//  Created by Wei on 17/2/24.
//  Copyright © 2017年 Wei. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SKAPIResponse.h"
@protocol AFMultipartFormData;
typedef void(^SKAPICallback)(SKAPIResponse *response);
typedef void(^SKAPIProgress)(NSProgress *progress);
@interface SKAPIClient : NSObject
+ (instancetype)sharedInstance;
- (NSInteger)callGETWithParams:(NSDictionary*)apiParams host:(NSString*)hostName methodName:(NSString*)methodName constructingBodyWithBlock:(void (^)(id <AFMultipartFormData> formData))block progress:(SKAPIProgress)progress success:(SKAPICallback)success fail:(SKAPICallback)fail;
- (NSInteger)callPOSTWithParams:(NSDictionary*)apiParams host:(NSString*)hostName methodName:(NSString*)methodName constructingBodyWithBlock:(void (^)(id <AFMultipartFormData> formData))block progress:(SKAPIProgress)progress success:(SKAPICallback)success fail:(SKAPICallback)fail;


- (void)cancelRequestWithRequestID:(NSNumber *)requestID;
- (void)cancelRequestWithRequestIDList:(NSArray *)requestIDList;

- (void)setCommonHeader:(NSDictionary *)header;
- (void)setCustomHeader:(NSDictionary *)header;
@end
