//
//  KAPOIGeoBoxViewController.h
//  API Demos
//
//  Created by Evan JIANG on 14-8-3.
//  Copyright (c) 2014年 Kii Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

@interface KAPOIGeoBoxViewController : UIViewController <CLLocationManagerDelegate, UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITextField *swLatField;
@property (weak, nonatomic) IBOutlet UITextField *swLongField;
@property (weak, nonatomic) IBOutlet UITextField *neLatField;
@property (weak, nonatomic) IBOutlet UITextField *neLongField;
@property (weak, nonatomic) IBOutlet UITableView *tableView;


@end
