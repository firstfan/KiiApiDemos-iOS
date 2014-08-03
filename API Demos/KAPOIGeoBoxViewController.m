//
//  KAPOIGeoBoxViewController.m
//  API Demos
//
//  Created by Evan JIANG on 14-8-3.
//  Copyright (c) 2014年 Kii Inc. All rights reserved.
//

#import "KAPOIGeoBoxViewController.h"
#import "KAGlobal.h"
#import "MBProgressHUD.h"
#import "KAViewUtils.h"

@interface KAPOIGeoBoxViewController () {
    CLLocationManager *locationManager;
    NSArray *allData;
}

@end

@implementation KAPOIGeoBoxViewController

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
        [self.swLatField setText:[NSString stringWithFormat:@"%f",coordinate.latitude]];
        [self.swLongField setText:[NSString stringWithFormat:@"%f",coordinate.longitude]];
        [self.neLatField setText:[NSString stringWithFormat:@"%f",coordinate.latitude]];
        [self.neLongField setText:[NSString stringWithFormat:@"%f",coordinate.longitude]];
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
    [KAViewUtils resignFirstResponder:self.view];
    KiiBucket  *bucket = [[KiiUser currentUser] bucketWithName:GEOLOCATION_BUCKET];
    double lat = [[self.swLatField text] doubleValue];
    double lng = [[self.swLongField text] doubleValue];
    KiiGeoPoint *sw = [[KiiGeoPoint alloc] initWithLatitude:lat
                                               andLongitude:lng];
    lat = [[self.neLatField text] doubleValue];
    lng = [[self.neLongField text] doubleValue];
    KiiGeoPoint *ne = [[KiiGeoPoint alloc] initWithLatitude:lat
                                               andLongitude:lng];
    
    KiiClause *clause = [KiiClause geoBox:@"poi"
                                northEast:ne
                                southWest:sw];
    KiiQuery *query = [KiiQuery queryWithClause:clause];
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [bucket executeQuery:query withBlock:^(KiiQuery *query, KiiBucket *bucket, NSArray *results, KiiQuery *nextQuery, NSError *error) {
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        allData = results;
        [self.tableView reloadData];
    }];
}
@end
