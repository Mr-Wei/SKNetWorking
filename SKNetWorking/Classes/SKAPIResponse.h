//
//  SKAPIResponse.h
//  
//
//  Created by Wei on 17/2/27.
//  Copyright © 2017年 Wei. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SKAPIResponse : NSObject
@property (nonatomic, assign, readonly) NSInteger requestId;
@property (nonatomic, copy, readonly) NSURLRequest *request;
@property (nonatomic, copy, readonly) id responseObject;
@property (nonatomic, copy, readonly) NSError * error;
@property (nonatomic, assign, readonly) BOOL  isCache;
- (instancetype)initWithRequestID:(NSInteger)requestId request:(NSURLRequest*)request response:(id)responseObject error:(NSError*)error;
- (instancetype)initWithResponse:(id)responseObject;
@end
