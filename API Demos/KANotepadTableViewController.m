//
//  KANotepadTableViewController.m
//  API Demos
//
//  Created by Evan JIANG on 14-7-16.
//  Copyright (c) 2014 Kii Inc. All rights reserved.
//

#import "KANotepadTableViewController.h"
#import "KAViewUtils.h"
#import "MBProgressHUD.h"
#import "iToast.h"
#import <KiiSDK/Kii.h>
#import "KAGlobal.h"
#import "KANoteEditorViewController.h"

@interface KANotepadTableViewController () {
    NSMutableArray *allResults;
}
@end

@implementation KANotepadTableViewController

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
    self.clearsSelectionOnViewWillAppear = NO;

    allResults = [[NSMutableArray alloc] init];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [KAViewUtils makeSureAlreadyLogin:self.navigationController];
    if ([KiiUser currentUser] == nil) {
        return;
    }
    [self refreshData];
}

- (void)refreshData
{
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
            NSError *error = nil;
            KiiBucket *bucket = [[KiiUser currentUser] bucketWithName:@"notes"];
            // Build "all" query
            KiiQuery *all_query = [KiiQuery queryWithClause:nil];
            // Create a placeholder for any paginated queries
            KiiQuery *nextQuery;
            // Get an array of KiiObjects by querying the bucket
            NSArray *results = [bucket executeQuerySynchronous:all_query
            withError   :&error
            andNext     :&nextQuery];
            [allResults removeAllObjects];
            // Add all the results from this query to the total results
            [allResults addObjectsFromArray:results];


            dispatch_async(dispatch_get_main_queue(), ^{
                [MBProgressHUD hideHUDForView:self.view animated:YES];
                [self.tableView reloadData];
                NSString *msg;
                if (error == nil) {
                    msg = @"Refresh data successfully";
                } else {
                    msg = @"Fetching data failed";
                }
                [[iToast makeText:msg] show];
            });
        });
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [allResults count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    KiiObject *retObj = [allResults objectAtIndex:[indexPath row]];
    [[cell textLabel] setText:[retObj getObjectForKey:@"title"]];
    return cell;
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    KiiObject *retObj = [allResults objectAtIndex:[indexPath row]];
    [self performSegueWithIdentifier:@"edit" sender:retObj];
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"edit"]) {
        KANoteEditorViewController *vc = segue.destinationViewController;
        vc.data = sender;
    }
}

@end