//
//  KAUserAttributesViewController.m
//  API Demos
//
//  Created by Evan JIANG on 14-7-8.
//  Copyright (c) 2014年 Kii Inc. All rights reserved.
//

#import "KAUserAttributesViewController.h"
#import "KAViewUtils.h"
#import <KiiSDK/Kii.h>
#import "MBProgressHUD.h"
#import "iToast.h"

@interface KAUserAttributesViewController ()

@end

@implementation KAUserAttributesViewController

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
    [self loadUserAttributes];
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

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return NO;
}

-(void)loadUserAttributes
{
    KiiUser *user = [KiiUser currentUser];
    if (user) {
        [self.genderSegment setSelectedSegmentIndex:[[user getObjectForKey:@"gender"] intValue]];
        int age = [[user getObjectForKey:@"age"] intValue];
        [self.ageField setText:[NSString stringWithFormat:@"%d",age]];
    }
}

- (IBAction)saveAttributes:(id)sender {
    KiiUser *user = [KiiUser currentUser];
    int age = [[self.ageField text] intValue];
    [user setObject:[NSNumber numberWithInt:age] forKey:@"age"];
    int gender = [self.genderSegment selectedSegmentIndex];
    [user setObject:[NSNumber numberWithInt:gender] forKey:@"gender"];
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [user saveWithBlock:^(KiiUser *user, NSError *error) {
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        if (error == nil) {
            [[iToast makeText:@"Saved successfully"] show];
        } else {
            [[iToast makeText:[NSString stringWithFormat:@"Save failed:%@", error]] show];
            NSLog(@"Save failed:%@", error);
        }

    }];

}
- (IBAction)changePassword:(id)sender {
    KiiUser *user = [KiiUser currentUser];
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [user updatePassword:[self.oldPasswordField text] to:[self.passwordField text] withBlock:^(KiiUser *user, NSError *error) {
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        if (error == nil) {
            [[iToast makeText:@"Changed successfully"] show];
        } else {
            [[iToast makeText:[NSString stringWithFormat:@"Change password failed:%@", error]] show];
            NSLog(@"Change password failed:%@", error);
        }
    }];
}


@end
