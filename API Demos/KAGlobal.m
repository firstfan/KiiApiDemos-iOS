//
//  KAGlobal.m
//  API Demos
//
//  Created by Evan JIANG on 14-7-6.
//  Copyright (c) 2014 Kii Inc. All rights reserved.
//

#import "KAGlobal.h"

@implementation KAGlobal


static KAGlobal *instance = nil;
+ (KAGlobal *)getInstance
{
    @synchronized(self) {
        if (instance == nil) {
            instance = [[KAGlobal alloc] init];
        }
    }
    return instance;
}

- (id)init
{
    self = [super init];

    if (self) {
        self.us_app = [[KAAppConfig alloc] init];
        self.us_app.site = kiiSiteUS;
        self.us_app.analyticsSite = kiiAnalyticsSiteUS;
        self.us_app.appId = @"9ab79441";
        self.us_app.appKey = @"21ed90644560656412620e9107acce5f";

        self.cn_app = [[KAAppConfig alloc] init];
        self.cn_app.site = kiiSiteCN;
        self.cn_app.analyticsSite = kiiAnalyticsSiteCN;
        self.cn_app.appId = @"d825f784";
        self.cn_app.appKey = @"bbabd43176c6681e7dca576eedbc776d";

        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        self.custom_app = [[KAAppConfig alloc] init];
        int server = [defaults integerForKey:CUSTOM_SERVER];
        [self loadCustomAppServer:server];
        self.custom_app.appId = [defaults stringForKey:CUSTOM_APPID];
        self.custom_app.appKey = [defaults stringForKey:CUSTOM_APPKEY];
        
        _currentAppSelection = [defaults integerForKey:CURRENT_APP];
        [self switchApp];
    }

    return self;
}

- (void)switchApp
{
    switch (self.currentAppSelection) {
        case US_APP:
            self.currentApp = self.us_app;
            break;
        case CN_APP:
            self.currentApp = self.cn_app;
            break;
        case CUSTOM_APP:
            self.currentApp = self.custom_app;
            break;
    }
}

- (void)loadCustomAppServer:(int)server
{
    switch (server) {
        case  0:
            self.custom_app.site = kiiSiteUS;
            self.custom_app.analyticsSite = kiiAnalyticsSiteUS;
            break;
        case  1:
            self.custom_app.site = kiiSiteJP;
            self.custom_app.analyticsSite = kiiAnalyticsSiteJP;
            break;
        case  2:
            self.custom_app.site = kiiSiteCN;
            self.custom_app.analyticsSite = kiiAnalyticsSiteCN;
            break;
        case  3:
            self.custom_app.site = kiiSiteSG;
            self.custom_app.analyticsSite = kiiAnalyticsSiteSG;
            break;
    }
}

- (NSString*)token
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    return [defaults objectForKey:TOKEN];
}

- (void)setToken:(NSString *)token
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:token forKey:TOKEN];
    [defaults synchronize];
}

- (void)setCurrentAppSelection:(int)cas
{
    _currentAppSelection = cas;
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setInteger:cas forKey:CURRENT_APP];
    [defaults synchronize];
    [self switchApp];
}

- (void)saveCustomAppSite:(int)server appId:(NSString*)appId appKey:(NSString*)appKey
{
    [self loadCustomAppServer:server];
    self.custom_app.appId = appId;
    self.custom_app.appKey = appKey;
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setInteger:server forKey:CUSTOM_SERVER];
    [defaults setObject:appId forKey:CUSTOM_APPID];
    [defaults setObject:appKey forKey:CUSTOM_APPKEY];
    [defaults synchronize];
}

@end