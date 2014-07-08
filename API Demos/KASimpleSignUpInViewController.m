//
//  KASimpleSignUpInViewController.m
//  API Demos
//
//  Created by Evan JIANG on 14-7-6.
//  Copyright (c) 2014 Kii Inc. All rights reserved.
//

#import "KASimpleSignUpInViewController.h"
#import "MBProgressHUD.h"
#import "iToast.h"
#import <KiiSDK/Kii.h>
#import "KAGlobal.h"
#import "KAViewUtils.h"

@interface KASimpleSignUpInViewController ()

@end

@implementation KASimpleSignUpInViewController

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

- (IBAction)clickOnLogin:(id)sender
{
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [KiiUser authenticate:[self.usernameField text] withPassword:[self.passwordField text] andBlock:^(KiiUser *user, NSError *error) {
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];

        if (error == nil) {
            [[KAGlobal getInstance] setToken:user.accessToken];
            [[iToast makeText:@"Login successfully"] show];
            [self.navigationController popViewControllerAnimated:YES];
        } else {
            [[iToast makeText:[NSString stringWithFormat:@"Login failed:%@", error]] show];
            NSLog(@"Login failed:%@", error);
        }
    }];
}

- (IBAction)clickOnRegister:(id)sender
{
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    KiiUser *user = [KiiUser userWithUsername:[self.usernameField text] andPassword:[self.passwordField text]];
    [user performRegistrationWithBlock:^(KiiUser *user, NSError *error) {
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];

        if (error == nil) {
            [[KAGlobal getInstance] setToken:user.accessToken];
            [[iToast makeText:@"Register successfully"] show];
            [self.navigationController popViewControllerAnimated:YES];
        } else {
            [[iToast makeText:[NSString stringWithFormat:@"Register failed:%@", error]] show];
            NSLog(@"Register failed:%@", error);
        }
    }];
}

@end