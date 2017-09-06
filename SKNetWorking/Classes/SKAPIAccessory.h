//
//  SKAPIAccessory.h
//  SKNetWorking
//
//  Created by Mr.Wei on 2017/9/6.
//  Copyright © 2017年 Wei. All rights reserved.
//

#import <Foundation/Foundation.h>
@protocol SKAPIAccessory <NSObject>
@required
- (BOOL)hanleApiAccessory;
@optional
- (void)apiWillRun;


- (void)apiDidFinish;


- (void)apiDidFail;

@end
