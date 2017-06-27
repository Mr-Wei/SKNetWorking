//
//  SKAPIClient.h
//  AllLivePlayer
//
//  Created by Wei on 17/2/24.
//  Copyright © 2017年 hzky. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SKAPIResponse.h"
typedef void(^SKAPICallback)(SKAPIResponse *response);
@interface SKAPIClient : NSObject
+ (instancetype)sharedInstance;
- (NSInteger)callGETWithParams:(NSDictionary*)apiParams host:(NSString*)hostName methodName:(NSString*)methodName success:(SKAPICallback)success fail:(SKAPICallback)fail;
- (NSInteger)callPOSTWithParams:(NSDictionary*)apiParams host:(NSString*)hostName methodName:(NSString*)methodName success:(SKAPICallback)success fail:(SKAPICallback)fail;


- (void)cancelRequestWithRequestID:(NSNumber *)requestID;
- (void)cancelRequestWithRequestIDList:(NSArray *)requestIDList;
@end
