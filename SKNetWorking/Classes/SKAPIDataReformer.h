//
//  SKAPIDataReformer.h
//  
//
//  Created by Wei on 17/3/7.
//  Copyright © 2017年 Wei. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SKAPIResponse.h"
@class SKAPIBaseManager;
@protocol SKAPIDataReformer <NSObject>
@required
- (id)reformData:(SKAPIResponse *)response fromManager:(SKAPIBaseManager *)manager;
@end
