//
//  KAEventAnalyticsViewController.m
//  API Demos
//
//  Created by Evan JIANG on 14-7-29.
//  Copyright (c) 2014年 Kii Inc. All rights reserved.
//

#import "KAEventAnalyticsViewController.h"
#import "KAGlobal.h"
#import "MBProgressHUD.h"
#import "iToast.h"

@interface KAEventAnalyticsViewController () {
    NSMutableArray *resultsArray;
}

@end

@implementation KAEventAnalyticsViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    resultsArray = [[NSMutableArray alloc] init];
    
    //Send the event
    NSString *eventType = @"LaunchEventAnalytics";
    [KiiAnalytics trackEvent:eventType withExtras:nil];
    //Fetch results
    // Set date range
    NSDate *start = [NSDate dateWithTimeIntervalSinceNow:-1*60*60*24*7]; // One week ago
    NSDate *end = [NSDate date]; // Now
    KADateRange *range = [KADateRange rangeWithStart:start
                                              andEnd:end];
    
    // Create query
    KAResultQuery *query = [[KAResultQuery alloc] init];
    // Set date range to query
    [query setDateRange:range];
    
    // Retrieve result
    NSDateFormatter *format = [[NSDateFormatter alloc] init];
    [format setDateFormat:@"yyyy-MM-dd"];
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [KiiAnalytics getResultWithID:[KAGlobal getInstance].currentApp.analytics_event_id
                         andQuery:query
                         andBlock:^(KAGroupedResult *results, NSError *error) {
                             [MBProgressHUD hideHUDForView:self.view animated:YES];
                             if (error == nil) {
                                 NSArray *snapshots = [results snapshots];
                                 if ([snapshots count]>0) {
                                     KAGroupedSnapShot *gs = [snapshots objectAtIndex:0];
                                     double time = gs.pointStart;
                                     NSArray *data = [gs data];
                                     for (int i=0;i<[data count];i++) {
                                         int count = [[data objectAtIndex:i] intValue];
                                         long long ti = (long long)time;
                                         ti = ti/1000;
                                         NSDate *date = [NSDate dateWithTimeIntervalSince1970:ti];
                                         NSString *item = [NSString stringWithFormat:@"%@   %d",[format stringFromDate:date],count];
                                         [resultsArray addObject:item];
                                         time += gs.pointInterval;
                                     }
                                 }
                                 [self.tableView reloadData];
                             } else {
                                 [[iToast makeText:@"Failed to get results"] show];
                             }
                         }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [resultsArray count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    NSString *s = [resultsArray objectAtIndex:[indexPath row]];
    [cell.textLabel setText:s];
    return cell;
}


@end
