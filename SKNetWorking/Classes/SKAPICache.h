//
//  SKAPICache.h
//  
//
//  Created by Wei on 2017/5/18.
//  Copyright © 2017年 Wei. All rights reserved.
//

#import <YYCache/YYCache.h>
NS_ASSUME_NONNULL_BEGIN

@interface SKAPICache : YYCache
+(instancetype)sharedCache;
- (void)setObject:(id<NSCoding>)object forHost:(NSString *)host methodName:(NSString *)methodName Param:(NSDictionary *)param;
- (id<NSCoding>)objectForHost:(NSString *)host methodName:(NSString *)methodName Param:(NSDictionary *)param;
@end
NS_ASSUME_NONNULL_END
