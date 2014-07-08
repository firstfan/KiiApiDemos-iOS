//
//  KAViewUtils.m
//  API Demos
//
//  Created by Evan JIANG on 14-7-6.
//  Copyright (c) 2014 Kii Inc. All rights reserved.
//

#import "KAViewUtils.h"
#import <KiiSDK/Kii.h>
#import "iToast.h"

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

+ (void)alertForAlreadyLogin
{
    [[[UIAlertView alloc] initWithTitle:nil message:@"You are already logged in.\n"
                                                    "Register or login again will change your current login user."
    delegate            :nil
    cancelButtonTitle   :@"Ok"
    otherButtonTitles   :nil]
    show];
}

+ (UIActionSheet *)showSelectCountryCode
{
    UIActionSheet *actionSheet = [UIActionSheet alloc];

    actionSheet = [actionSheet initWithTitle:@"Select phone country"
        delegate                            :nil
        cancelButtonTitle                   :@"Cancel"
        destructiveButtonTitle              :nil
        otherButtonTitles                   :@"US", @"JP", @"CN", @"HK", @"TW", nil];
    [actionSheet setTag:ACTIONSHEET_COUNTRY_CODE];
    return actionSheet;
}


+ (void)makeSureAlreadyLogin:(UINavigationController *)nav
{
    if ([KiiUser currentUser] == nil) {
        [[iToast makeText:@"You need to login first."] show];
        [nav popViewControllerAnimated:YES];
    }
}
@end