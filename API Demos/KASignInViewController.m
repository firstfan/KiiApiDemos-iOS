//
//  KASignInViewController.m
//  API Demos
//
//  Created by Evan JIANG on 14-7-6.
//  Copyright (c) 2014 Kii Inc. All rights reserved.
//

#import "KASignInViewController.h"
#import "MBProgressHUD.h"
#import "iToast.h"
#import <KiiSDK/Kii.h>
#import "KAGlobal.h"
#import "KAViewUtils.h"

@interface KASignInViewController ()

@end

@implementation KASignInViewController

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

    [self updateUsernameAndToken];
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

- (void)updateUsernameAndToken
{
    if ([KiiUser currentUser]) {
        self.usernameLabel.text = [NSString stringWithFormat:@"Current user: %@", [KiiUser currentUser].username];
    } else {
        self.usernameLabel.text = @"Not login yet";
    }

    KAGlobal    *global = [KAGlobal getInstance];
    NSString    *token = [global token];

    if ([token length] > 0) {
        self.tokenLabel.text = [NSString stringWithFormat:@"Token: %@", token];
        [self.loginWithTokenButton setEnabled:YES];
    } else {
        self.tokenLabel.text = @"";
        [self.loginWithTokenButton setEnabled:NO];
    }
}

- (IBAction)loginWithToken:(id)sender
{
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    KAGlobal    *global = [KAGlobal getInstance];
    NSString    *token = [global token];
    [KiiUser authenticateWithToken:token andDelegate:self andCallback:@selector(authenticationComplete:withError:)];
}

- (IBAction)login:(id)sender {
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    NSString *username = [self.nameField text];
    NSString *password = [self.passwordField text];
    NSString *countryCode = [self.countryButton titleForState:UIControlStateNormal];
    if ([self.loginTypeSegment selectedSegmentIndex] == 0) {
        [KiiUser authenticate:username withPassword:password andDelegate:self andCallback:@selector(authenticationComplete:withError:)];
    } else {
        [KiiUser authenticateWithLocalPhoneNumber:username andPassword:password andCountryCode:countryCode andDelegate:self andCallback:@selector(authenticationComplete:withError:)];
    }
}

- (IBAction)changeCountryCode:(id)sender
{
    UIActionSheet *actionSheet = [KAViewUtils showSelectCountryCode];

    [actionSheet setDelegate:self];
    [actionSheet showInView:self.view];
}

/**
 * In Simple Sign In and Sign Up, we are using block method
 * Here we use delegate&callback, for re-using the same callback for all login types
 */
- (void)authenticationComplete:(KiiUser *)user withError:(NSError *)error
{
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];

    // the request was successful
    if (error == nil) {
        [[KAGlobal getInstance] setToken:user.accessToken];
        [[iToast makeText:@"Login successfully"] show];
    } else {
        [[iToast makeText:[NSString stringWithFormat:@"Login failed:%@", error]] show];
        NSLog(@"Login failed:%@", error);
    }

    [self updateUsernameAndToken];
}

- (IBAction)changeLoginType:(id)sender
{
    if ([self.loginTypeSegment selectedSegmentIndex] == 0) {
        [self.countryButton setHidden:YES];
        [self.nameField setPlaceholder:@"Username / Email"];
    } else {
        [self.countryButton setHidden:NO];
        [self.nameField setPlaceholder:@"Phone (Without country code)"];
    }
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (([actionSheet tag] == ACTIONSHEET_COUNTRY_CODE) && (buttonIndex != [actionSheet cancelButtonIndex])) {
        NSString *title = [actionSheet buttonTitleAtIndex:buttonIndex];
        [self.countryButton setTitle:title forState:UIControlStateNormal];
    }
}

@end