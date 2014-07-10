//
//  KAGlobal.h
//  API Demos
//
//  Created by Evan JIANG on 14-7-6.
//  Copyright (c) 2014 Kii Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KAAppConfig.h"

#define CURRENT_APP     @"current_app"
#define CUSTOM_SERVER   @"custom_server"
#define CUSTOM_APPID    @"custom_appid"
#define CUSTOM_APPKEY   @"custom_appkey"
#define TOKEN           @"token"

#define US_APP          0
#define CN_APP          1
#define CUSTOM_APP      9

#define FacebookAppID   @"1440773252805693"
#define TwitterKey      @"nxRS6qwgmkuty79umuBhug"
#define TwitterSecrect  @"YWWw1kBhf0hSPzbSs4uHKeMtE93PvaM7gXN6d33S2U"

@interface KAGlobal : NSObject

@property (retain, nonatomic) KAAppConfig   *currentApp;
@property (retain, nonatomic) KAAppConfig   *us_app;
@property (retain, nonatomic) KAAppConfig   *cn_app;
@property (retain, nonatomic) KAAppConfig   *custom_app;
@property (retain, nonatomic) NSString      *token;
@property (nonatomic) int                   currentAppSelection;

+ (KAGlobal *)getInstance;
- (void)switchApp;
- (void)saveCustomAppSite:(int)server appId:(NSString *)appId appKey:(NSString *)appKey;
@end