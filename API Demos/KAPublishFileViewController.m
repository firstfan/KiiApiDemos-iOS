//
//  KAPublishFileViewController.m
//  API Demos
//
//  Created by Evan JIANG on 14-7-31.
//  Copyright (c) 2014年 Kii Inc. All rights reserved.
//

#import "KAPublishFileViewController.h"
#import "KAGlobal.h"
#import "MBProgressHUD.h"
#import "iToast.h"

@interface KAPublishFileViewController () {
    NSArray *allData;
}

@end

@implementation KAPublishFileViewController

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
    [self getFileLists];
}

-(void)getFileLists
{
    KiiBucket  *bucket = [[KiiUser currentUser] bucketWithName:FILE_BUCKET];
    KiiQuery *all_query = [KiiQuery queryWithClause:nil];
    [bucket executeQuery:all_query withBlock:^(KiiQuery *query, KiiBucket *bucket, NSArray *results, KiiQuery *nextQuery, NSError *error) {
        allData = results;
        [self.tableView reloadData];
    }];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [allData count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    KiiObject *obj = [allData objectAtIndex:[indexPath row]];
    NSString *title = [obj getObjectForKey:@"title"];
    NSNumber *size = [obj getObjectForKey:@"fileSize"];
    [cell.textLabel setText:title];
    int sizeInK = [size unsignedIntValue] / 1024;
    [cell.detailTextLabel setText:[NSString stringWithFormat:@"%dK",sizeInK]];
    return cell;
}

- (IBAction)clickOnPublish:(id)sender {
    int index = [[self.tableView indexPathForSelectedRow] row];
    if (index<0) {
        [[iToast makeText:@"Select a uploaded file first"] show];
        return;
    }
    int time = [[self.expireField text] intValue];
    if (time==0) {
        [[iToast makeText:@"Expiration time must be larger than 0."] show];
        return;
    }
    KiiObject *obj = [allData objectAtIndex:index];
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [obj publishBodyExpiresIn:time withBlock:^(KiiObject *obj, NSString *url, NSError *error) {
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        if (error == nil) {
            NSLog(@"Published url:%@",url);
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
        } else {
            [[iToast makeText:@"Publish body failed"] show];
            NSLog(@"Publish error:%@",error);
        }
    }];
}


@end
