//
//  KAAddPOIViewController.m
//  API Demos
//
//  Created by Evan JIANG on 14-8-3.
//  Copyright (c) 2014年 Kii Inc. All rights reserved.
//

#import "KAAddPOIViewController.h"
#import "KAGlobal.h"
#import "MBProgressHUD.h"
#import "iToast.h"

@interface KAAddPOIViewController () {
    CLLocationManager *locationManager;
    NSArray *allData;
}

@end

@implementation KAAddPOIViewController

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
    locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate = self;
    [locationManager startUpdatingLocation];
    [self getPOILists];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return NO;
}

-(void)getPOILists
{
    KiiBucket  *bucket = [[KiiUser currentUser] bucketWithName:GEOLOCATION_BUCKET];
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

- (IBAction)clickOnAdd:(id)sender {
    [self.latField resignFirstResponder];
    [self.longField resignFirstResponder];
    [self.titleField resignFirstResponder];
    double lat = [[self.latField text] doubleValue];
    double lng = [[self.longField text] doubleValue];
    NSString *title = [self.titleField text];
    KiiGeoPoint *poi = [[KiiGeoPoint alloc] initWithLatitude:lat
                                                   andLongitude:lng];
    KiiBucket  *bucket = [[KiiUser currentUser] bucketWithName:GEOLOCATION_BUCKET];
    KiiObject *object = [bucket createObject];
    [object setGeoPoint:poi forKey:@"poi"];
    [object setObject:title forKey:@"title"];
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [object save:YES withBlock:^(KiiObject *object, NSError *error) {
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        if (error == nil) {
            [self getPOILists];
        } else {
            [[iToast makeText:@"Add POI failed"] show];
        }
    }];
}

-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    if ([locations count]>0) {
        CLLocation *loc = [locations objectAtIndex:0];
        CLLocationCoordinate2D coordinate = loc.coordinate;
        [self.latField setText:[NSString stringWithFormat:@"%f",coordinate.latitude]];
        [self.longField setText:[NSString stringWithFormat:@"%f",coordinate.longitude]];
        [locationManager stopUpdatingLocation];
    }
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [allData count];
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    KiiObject *obj = [allData objectAtIndex:[indexPath row]];
    [cell.textLabel setText:[obj getObjectForKey:@"title"]];
    KiiGeoPoint *point = [obj getGeoPointForKey:@"poi"];
    NSString *subtitle = [NSString stringWithFormat:@"Latitude:%f Longitude:%f",point.latitude, point.longitude];
    [cell.detailTextLabel setText:subtitle];
    return cell;
}

@end
