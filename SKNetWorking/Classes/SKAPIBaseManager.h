//
//  SKAPIBaseManager.h
//  AllLivePlayer
//
//  Created by Wei on 17/2/20.
//  Copyright © 2017年 hzky. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SKAPIManager.h"
#import "SKAPIDataReformer.h"
@class SKAPIBaseManager,SKAPIResponse;
@protocol SKAPIManagerDelegate <NSObject>
@required
- (void)APIDidSuccess:(SKAPIBaseManager *)manager;
@optional
- (void)APIDidFailed:(SKAPIBaseManager *)manager;
- (void)APINoMoreData;
@end
@protocol SKAPIParamSource <NSObject>
@optional
- (NSDictionary*)param:(SKAPIBaseManager *)manager;
@end



@interface SKAPIBaseManager : NSObject
@property (nonatomic, weak) NSObject<SKAPIManager> *realManager;
@property (nonatomic, weak) id<SKAPIManagerDelegate> delegate;
@property (nonatomic, weak) id<SKAPIParamSource> paramSource;
@property (nonatomic, strong) SKAPIResponse *response;
@property (nonatomic, assign, readonly) BOOL isLoading;
@property (nonatomic, assign, readonly) BOOL isMore;
- (void)run;
- (void)runWithParam:(NSDictionary*)param;
- (void)loadMore;
- (id)reformDataWithReformer:(id<SKAPIDataReformer>)reformer;
@end
