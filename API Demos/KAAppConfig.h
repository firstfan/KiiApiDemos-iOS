//
//  KAAppConfig.h
//  API Demos
//
//  Created by Evan JIANG on 14-7-6.
//  Copyright (c) 2014 Kii Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <KiiSDK/Kii.h>
#import <KiiAnalytics/KiiAnalytics.h>

@interface KAAppConfig : NSObject

@property (nonatomic) KiiSite           site;
@property (nonatomic) KiiAnalyticsSite  analyticsSite;
@property (retain, nonatomic) NSString  *appId;
@property (retain, nonatomic) NSString  *appKey;

@end