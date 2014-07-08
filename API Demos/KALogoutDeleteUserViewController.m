//
//  KALogoutDeleteUserViewController.m
//  API Demos
//
//  Created by Evan JIANG on 14-7-8.
//  Copyright (c) 2014年 Kii Inc. All rights reserved.
//

#import "KALogoutDeleteUserViewController.h"
#import "KAViewUtils.h"
#import "MBProgressHUD.h"
#import "iToast.h"
#import <KiiSDK/Kii.h>
#import "KAGlobal.h"

#define ALERT_DELETE 10

@interface KALogoutDeleteUserViewController ()

@end

@implementation KALogoutDeleteUserViewController

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
    // Do any additional setup after loading the view.
}


- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [KAViewUtils makeSureAlreadyLogin:self.navigationController];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)logout:(id)sender {
    [KiiUser logOut];
    [[iToast makeText:@"Logout successfully"] show];
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)deleteUser:(id)sender {
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Warning" message:@"Are you sure to delete current user?" delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil];
    [alertView setTag:ALERT_DELETE];
    [alertView show];
}

- (void)doDeleteUser
{
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [[KiiUser currentUser] deleteWithBlock:^(KiiUser *user, NSError *error) {
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        if (error == nil) {
            [[iToast makeText:@"Deleted successfully"] show];
            [[KAGlobal getInstance] setToken:@""];
            [self.navigationController popViewControllerAnimated:YES];
        } else {
            [[iToast makeText:[NSString stringWithFormat:@"Delete failed:%@", error]] show];
            NSLog(@"Delete failed:%@", error);
        }
    }];
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if ([alertView tag]==ALERT_DELETE && buttonIndex!=[alertView cancelButtonIndex]) {
        [self doDeleteUser];
    }
}

@end
