//
//  SKAPICache.m
//  AllLivePlayer
//
//  Created by Wei on 2017/5/18.
//  Copyright © 2017年 hzky. All rights reserved.
//

#import "SKAPICache.h"
#import <CommonCrypto/CommonDigest.h>
@implementation SKAPICache
static SKAPICache *sharedCache = nil;
+(instancetype)sharedCache{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedCache = [[self alloc] initWithName:@"SKAPICache"];
    });
    return sharedCache;
}
- (void)setObject:(id<NSCoding>)object forHost:(NSString *)host methodName:(NSString *)methodName Param:(NSDictionary *)param{
    NSParameterAssert(host);
    NSParameterAssert(methodName);
    NSMutableString *keyStr = [[NSMutableString alloc]init];
    [keyStr appendString:host];
    [keyStr appendString:methodName];
    if (param) {
        NSString *paramStr = [self dictionaryToJson:param];
        [keyStr appendString:paramStr];
    }
    NSString *MD5Str = [SKAPICache getMD5:keyStr];
    [self setObject:object forKey:MD5Str];
}

- (id<NSCoding>)objectForHost:(NSString *)host methodName:(NSString *)methodName Param:(NSDictionary *)param{
    NSParameterAssert(host);
    NSParameterAssert(methodName);
    NSMutableString *keyStr = [[NSMutableString alloc]init];
    [keyStr appendString:host];
    [keyStr appendString:methodName];
    if (param) {
        NSString *paramStr = [self dictionaryToJson:param];
        [keyStr appendString:paramStr];
    }
    NSString *MD5Str = [SKAPICache getMD5:keyStr];
    return [self objectForKey:MD5Str];
}




- (NSString*)dictionaryToJson:(NSDictionary *)dic
{
    NSError *parseError = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dic options:NSJSONWritingPrettyPrinted error:&parseError];
    return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
}

+ (NSString *)getMD5:(NSString *)str {
    
    const char *cStr = [str UTF8String];
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    CC_MD5( cStr, (CC_LONG)strlen(cStr), result );
    
    return [NSString stringWithFormat: @"%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X",
            result[0], result[1], result[2], result[3],
            result[4], result[5], result[6], result[7],
            result[8], result[9], result[10], result[11],
            result[12], result[13], result[14], result[15]
            ];
    
}


@end
