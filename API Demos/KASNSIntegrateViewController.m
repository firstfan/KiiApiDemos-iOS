//
//  KASNSIntegrateViewController.m
//  API Demos
//
//  Created by Evan JIANG on 14-7-9.
//  Copyright (c) 2014 Kii Inc. All rights reserved.
//

#import "KASNSIntegrateViewController.h"
#import "KAViewUtils.h"
#import "MBProgressHUD.h"
#import "iToast.h"
#import <KiiSDK/Kii.h>
#import "KAGlobal.h"
#import <Accounts/Accounts.h>

@interface KASNSIntegrateViewController ()

@end

#define ALERT_CHINA_SERVER 1

@implementation KASNSIntegrateViewController

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
    [KiiSocialConnect setupNetwork:kiiSCNFacebook
    withKey     :FacebookAppID
    andSecret   :nil
    andOptions  :nil];
    [KiiSocialConnect setupNetwork:kiiSCNTwitter
    withKey     :TwitterKey
    andSecret   :TwitterSecrect
    andOptions  :nil];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

    if ([[KAGlobal getInstance] currentApp].site == kiiSiteCN) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"SNS integration related features are not supported by China Server." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [alertView setTag:ALERT_CHINA_SERVER];
        [alertView show];
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if ([alertView tag] == ALERT_CHINA_SERVER) {
        [self.navigationController popViewControllerAnimated:YES];
        return;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)loginWithFacebook:(id)sender
{
    NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:
        [NSArray arrayWithObject:@"email"], @"permissions",
        nil];

    // Login with the Facebook Account.
    [KiiSocialConnect logIn:kiiSCNFacebook
    usingOptions:options
    withDelegate:self
    andCallback :@selector(myRegistrationFinished:usingNetwork:withError:)];
}

- (void)myRegistrationFinished  :(KiiUser *)user
        usingNetwork            :(KiiSocialNetworkName)network
        withError               :(NSError *)error
{
    if (error == nil) {
        [[KAGlobal getInstance] setToken:user.accessToken];
        [[iToast makeText:@"Login successfully"] show];
    } else {
        [[iToast makeText:[NSString stringWithFormat:@"Login failed:%@", error]] show];
        NSLog(@"Login failed:%@", error);
    }
}

- (IBAction)linkToFacebook:(id)sender {}

- (IBAction)unlinkFromFacebook:(id)sender {}

- (IBAction)loginWithTwitter:(id)sender
{
    if (NSClassFromString(@"ACAccountStore")) {
        ACAccountStore  *store = [[ACAccountStore alloc] init];
        ACAccountType   *twitterType = [store accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];

        // This will show a dialog asking the user to grant
        // the access to his/her Twitter accounts.
        [store requestAccessToAccountsWithType:twitterType
        options     :nil
        completion  :^(BOOL granted, NSError *error) {
            if (granted) {
                ACAccountType *twitterTypeGranted = [store accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];

                // Return an array of granted ACAccounts.
                NSArray *twitterAccounts = [store accountsWithAccountType:twitterTypeGranted];
                
                if ([twitterAccounts count] == 0) {
                    [[iToast makeText:@"There's no Twitter account existing now."] show];
                    return;
                }
                /* INSERT KII CLOUD AUTHENTICATION LOGIC HERE */
                ACAccount* account = twitterAccounts[0];
                
                // Fetch the OAuth token and secret.
                NSDictionary *options = @{@"twitter_account": account};
                
                // Execute the login.
                [KiiSocialConnect logIn:kiiSCNTwitter
                           usingOptions:options
                           withDelegate:self
                            andCallback:@selector(myRegistrationFinished:usingNetwork:withError:)];
            } else {
                // handle error
                [[iToast makeText:@"Cannot get Twitter accounts"] show];
            }
        }];
    }
}

- (IBAction)linkToTwitter:(id)sender {}

- (IBAction)unlinkFromTwitter:(id)sender {}

@end