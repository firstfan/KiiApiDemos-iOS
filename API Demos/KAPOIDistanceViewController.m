//
//  KAPOIDistanceViewController.m
//  API Demos
//
//  Created by Evan JIANG on 14-8-3.
//  Copyright (c) 2014年 Kii Inc. All rights reserved.
//

#import "KAPOIDistanceViewController.h"
#import "KAGlobal.h"

@interface KAPOIDistanceViewController () {
    CLLocationManager *locationManager;
    NSArray *allData;
}

@end

@implementation KAPOIDistanceViewController

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

- (IBAction)query:(id)sender {
    double lat = [[self.latField text] doubleValue];
    double lng = [[self.longField text] doubleValue];
    int distance = [[self.distanceField text] intValue];
    KiiGeoPoint *poi = [[KiiGeoPoint alloc] initWithLatitude:lat
                                                andLongitude:lng];
    KiiBucket  *bucket = [[KiiUser currentUser] bucketWithName:GEOLOCATION_BUCKET];
    KiiClause *clause = [KiiClause geoDistance:@"poi"
                                        center:poi radius:distance putDistanceInto:nil];
    KiiQuery *query = [KiiQuery queryWithClause:clause];
    [bucket executeQuery:query withBlock:^(KiiQuery *query, KiiBucket *bucket, NSArray *results, KiiQuery *nextQuery, NSError *error) {
        allData = results;
        [self.tableView reloadData];
    }];

}

@end
