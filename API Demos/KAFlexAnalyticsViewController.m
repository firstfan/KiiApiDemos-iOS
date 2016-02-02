//
//  KAFlexAnalyticsViewController.m
//  API Demos
//
//  Created by Evan JIANG on 14-7-29.
//  Copyright (c) 2014年 Kii Inc. All rights reserved.
//

#import "KAFlexAnalyticsViewController.h"
#import "KAViewUtils.h"
#import "MBProgressHUD.h"
#import "iToast.h"
#import "KAGlobal.h"
#import <KiiSDK/KiiAnalytics.h>

@interface KAFlexAnalyticsViewController ()

@end

@implementation KAFlexAnalyticsViewController

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

- (IBAction)clickOnSave:(id)sender {
    int score = [[self.scoreField text] intValue];
    if (score<0 || score > 100) {
        [[iToast makeText:@"Score need to be in [0,100]"] show];
        return;
    }
    int appVer = [[self.verField text] intValue];
    if (appVer < 0) {
        [[iToast makeText:@"AppVersion need to be larger than 0"] show];
        return;
    }
    NSString *level;
    switch (self.levelSegment.selectedSegmentIndex) {
        case 0:
            level=@"Easy";
            break;
        case 1:
            level=@"Normal";
            break;
        case 2:
            level=@"Hard";
            break;
        default:
            [[iToast makeText:@"Choose level first"] show];
            return;
    }
    KiiObject *scoreObject= [[Kii bucketWithName:@"score"] createObject];
    [scoreObject setObject:[NSNumber numberWithInt:score] forKey:@"Score"];
    [scoreObject setObject:[NSNumber numberWithInt:appVer] forKey:@"AppVersion"];
    [scoreObject setObject:level forKey:@"Level"];
    [scoreObject setObject:[KiiUser currentUser].username forKey:@"username"];
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [scoreObject save:YES withBlock:^(KiiObject *object, NSError *error) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        if (error == nil) {
            [[iToast makeText:@"Save successfully"] show];
        } else {
            [[iToast makeText:[NSString stringWithFormat:@"Save failed:%@", error]] show];
            NSLog(@"Save failed:%@", error);
        }
    }];
}

- (IBAction)clickOnShowResults:(id)sender {

    KAResultQuery *query = [[KAResultQuery alloc] init];
    // Set grouping key to query
    [query setGroupingKey:@"UserLevel"];
    
    
    // Retrieve result
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [KiiAnalytics getResultWithID:[KAGlobal getInstance].currentApp.analytics_avg_score_id
                         andQuery:query
                         andBlock:^(KAGroupedResult *results, NSError *error) {
                             [MBProgressHUD hideHUDForView:self.view animated:YES];
                             if(error == nil){
                                 NSArray *snapshots = [results snapshots];
                                 NSString *resultData = [[NSString alloc] init];
                                 for (KAGroupedSnapShot *gs in snapshots) {
                                     NSNumber * number = [[gs data] lastObject];
                                     NSString *item = [NSString stringWithFormat:@"%@ %@\n", [gs name],number];
                                     resultData = [resultData stringByAppendingString:item];
                                 }
                                 UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Average Scores" message:resultData delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
                                 [alertView show];
                             } else {
                                 [[iToast makeText:@"Failed to get results"] show];
                             }
                         }];
}


@end
