//
//  KAViewUtils.m
//  API Demos
//
//  Created by Evan JIANG on 14-7-6.
//  Copyright (c) 2014年 Kii Inc. All rights reserved.
//

#import "KAViewUtils.h"

@implementation KAViewUtils

+ (UIView *)resignFirstResponder:(UIView *)theView
{
    if ([theView isFirstResponder]) {
        [theView resignFirstResponder];
        return theView;
    }

    for (UIView *subview in theView.subviews) {
        UIView *result = [KAViewUtils resignFirstResponder:subview];

        if (result) {
            return result;
        }
    }

    return nil;
}

@end