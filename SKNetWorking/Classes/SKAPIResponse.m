//
//  SKAPIResponse.m
//  AllLivePlayer
//
//  Created by Wei on 17/2/27.
//  Copyright © 2017年 hzky. All rights reserved.
//

#import "SKAPIResponse.h"
@interface SKAPIResponse()
@property (nonatomic, assign, readwrite) NSInteger requestId;
@property (nonatomic, copy, readwrite) NSURLRequest *request;
@property (nonatomic, copy, readwrite) id responseObject;
@property (nonatomic, copy, readwrite) NSError * error;
@property (nonatomic, assign, readwrite) BOOL  isCache;
@end
@implementation SKAPIResponse
- (instancetype)initWithRequestID:(NSInteger)requestId request:(NSURLRequest*)request response:(id)responseObject error:(NSError*)error{
    self = [super init];
    if (self) {
        self.requestId = requestId;
        self.request = request;
        self.responseObject = responseObject;
        self.error = error;
    }
    return self;
}
- (instancetype)initWithResponse:(id)responseObject{
    self = [super init];
    if (self) {
        self.responseObject = responseObject;
        self.isCache = YES;;
    }
    return self;
}
@end
