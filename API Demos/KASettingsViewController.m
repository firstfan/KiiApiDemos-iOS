//
//  KASettingsViewController.m
//  API Demos
//
//  Created by Evan JIANG on 14-7-5.
//  Copyright (c) 2014 Kii Inc. All rights reserved.
//

#import "KASettingsViewController.h"
#import "KAViewUtils.h"
#import "KAGlobal.h"
#import "iToast.h"

#define ALERT_DONE 1

@interface KASettingsViewController ()

@end

@implementation KASettingsViewController

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
    KAGlobal *global = [KAGlobal getInstance];
    [self.appIdField setText:global.custom_app.appId];
    [self.appKeyField setText:global.custom_app.appKey];
    [self.serverSegment setSelectedSegmentIndex:global.custom_app.site];
    switch (global.currentAppSelection) {
        case US_APP:
        case CN_APP:
            [self.appSegment setSelectedSegmentIndex:global.currentAppSelection];
            break;
        case CUSTOM_APP:
            [self.appSegment setSelectedSegmentIndex:2];
            break;
    }
    [self changeApp:nil];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)clickOnDone:(id)sender {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"Changing app will logout current user and wipe all local data." delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Ok", nil];
    [alert setTag:ALERT_DONE];
    [alert show];
}

- (IBAction)changeApp:(id)sender {
    bool selectCustom = ([self.appSegment selectedSegmentIndex] == 2);
    [self.serverSegment setHidden:!selectCustom];
    [self.appIdField setHidden:!selectCustom];
    [self.appKeyField setHidden:!selectCustom];
    if (!selectCustom) {
        [KAViewUtils resignFirstResponder:self.view];
    }
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if ([alertView tag] == ALERT_DONE && buttonIndex == 1) {
        KAGlobal *global = [KAGlobal getInstance];
        int appIndex = (int)[self.appSegment selectedSegmentIndex];
        if (appIndex == 2) {
            [global saveCustomAppSite:(int)[self.serverSegment selectedSegmentIndex]
                                appId:[self.appIdField text]
                               appKey:[self.appKeyField text]];
            [global setCurrentAppSelection:CUSTOM_APP];
        } else {
            [global setCurrentAppSelection:appIndex];
        }
        if ([KiiUser currentUser]) {
            [KiiUser logOut];
        }
        [Kii beginWithID:global.currentApp.appId
                  andKey:global.currentApp.appKey
                 andSite:global.currentApp.site];
        [global setToken:@""];
    }
}


@end
