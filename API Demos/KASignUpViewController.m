//
//  KASignUpViewController.m
//  API Demos
//
//  Created by Evan JIANG on 14-7-6.
//  Copyright (c) 2014 Kii Inc. All rights reserved.
//

#import "KASignUpViewController.h"
#import "MBProgressHUD.h"
#import "iToast.h"
#import <KiiSDK/Kii.h>
#import "KAGlobal.h"
#import "KAViewUtils.h"

@interface KASignUpViewController ()

@end

@implementation KASignUpViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if ([KiiUser currentUser] != nil) {
        [KAViewUtils alertForAlreadyLogin];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return NO;
}

- (IBAction)changeCountryCode:(id)sender
{
    UIActionSheet *actionSheet = [KAViewUtils showSelectCountryCode];
    
    [actionSheet setDelegate:self];
    [actionSheet showInView:self.view];
}
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (([actionSheet tag] == ACTIONSHEET_COUNTRY_CODE) && (buttonIndex != [actionSheet cancelButtonIndex])) {
        NSString *title = [actionSheet buttonTitleAtIndex:buttonIndex];
        [self.countryButton setTitle:title forState:UIControlStateNormal];
    }
}

- (IBAction)clickOnRegister:(id)sender {
    NSString *username = [self.usernameField text];
    NSString *email = [self.emailField text];
    NSString *phone = [self.phoneField text];
    NSString *password = [self.passwordField text];
    NSString *countryCode = [self.countryButton titleForState:UIControlStateNormal];
    KiiUser *user = nil;
    if ([username length]>0) {
        if ([email length]>0) {
            if ([phone length]>0) {
                user = [KiiUser userWithUsername:username andEmailAddress:email andPhoneNumber:phone andPassword:password];
            } else {
                user = [KiiUser userWithUsername:username andEmailAddress:email andPassword:password];
            }
        } else {
            if ([phone length]>0) {
                user = [KiiUser userWithUsername:username andPhoneNumber:phone andPassword:password];
            } else {
                user = [KiiUser userWithUsername:username andPassword:password];
            }
        }
    } else if ([email length]>0) {
        if ([phone length]>0) {
            user = [KiiUser userWithEmailAddress:email andPhoneNumber:phone andPassword:password];
        } else {
            user = [KiiUser userWithEmailAddress:email andPassword:password];
        }
    } else if ([phone length]>0) {
        user = [KiiUser userWithPhoneNumber:phone andPassword:password];
    } else {
        [[iToast makeText:@"You need to at least fill in one of username/email/phone"] show];
        return;
    }
    if ([password length]<6) {
        [[iToast makeText:@"Password cannot be shorter than 6 letters."] show];
        return;
    }
    [user setCountry:countryCode];
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [user performRegistrationWithBlock:^(KiiUser *user, NSError *error) {
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        
        if (error == nil) {
            [[KAGlobal getInstance] setToken:user.accessToken];
            [[iToast makeText:@"Register successfully"] show];
        } else {
            [[iToast makeText:[NSString stringWithFormat:@"Register failed:%@", error]] show];
            NSLog(@"Register failed:%@", error);
        }
    }];
}

- (IBAction)refershVerifyStatus:(id)sender {
    if ([KiiUser currentUser] == nil) {
        [[iToast makeText:@"You need to register or login first"] show];
        return;
    }
    [[KiiUser currentUser] refreshWithBlock:^(KiiUser *user, NSError *error) {
        if (error == nil) {
            NSString *str = [NSString stringWithFormat:@"Email is %@verified\nPhone is %@verified",user.emailVerified?@"":@"not ", user.phoneVerified?@"":@"not "];
            [self.verifyLabel setText:str];
            [[iToast makeText:@"Verification status updated"] show];
        } else {
            [[iToast makeText:[NSString stringWithFormat:@"Refresh failed:%@", error]] show];
            NSLog(@"Refresh failed:%@", error);
        }
    }];
}

- (IBAction)verfiyPhone:(id)sender {
    if ([KiiUser currentUser] == nil) {
        [[iToast makeText:@"You need to register or login first"] show];
        return;
    }
    NSString *code = [self.codeField text];
    [[KiiUser currentUser] verifyPhoneNumber:code withBlock:^(KiiUser *user, NSError *error) {
        if (error == nil) {
            [[iToast makeText:@"Verify successfully"] show];
        } else {
            [[iToast makeText:[NSString stringWithFormat:@"Verify failed:%@", error]] show];
            NSLog(@"Verify failed:%@", error);
        }
        NSString *str = [NSString stringWithFormat:@"Email is %@verified\nPhone is %@verified",user.emailVerified?@"":@"not ", user.phoneVerified?@"":@"not "];
        [self.verifyLabel setText:str];
    }];
}

@end
