//
//  KAViewUtils.h
//  API Demos
//
//  Created by Evan JIANG on 14-7-6.
//  Copyright (c) 2014 Kii Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

#define ACTIONSHEET_COUNTRY_CODE 1000

@interface KAViewUtils : NSObject

+ (UIView *)resignFirstResponder:(UIView *)theView;
+ (void)alertForAlreadyLogin;
+ (UIActionSheet *)showSelectCountryCode;
@end