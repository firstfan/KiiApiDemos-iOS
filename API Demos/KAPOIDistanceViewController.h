//
//  KAPOIDistanceViewController.h
//  API Demos
//
//  Created by Evan JIANG on 14-8-3.
//  Copyright (c) 2014年 Kii Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

@interface KAPOIDistanceViewController : UIViewController <CLLocationManagerDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITextField *latField;
@property (weak, nonatomic) IBOutlet UITextField *longField;
@property (weak, nonatomic) IBOutlet UITextField *distanceField;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@end
