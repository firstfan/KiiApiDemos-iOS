//
//  KASettingsViewController.h
//  API Demos
//
//  Created by Evan JIANG on 14-7-5.
//  Copyright (c) 2014 Kii Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface KASettingsViewController : UIViewController <UIAlertViewDelegate>
@property (weak, nonatomic) IBOutlet UISegmentedControl *appSegment;
@property (weak, nonatomic) IBOutlet UISegmentedControl *serverSegment;
@property (weak, nonatomic) IBOutlet UITextField *appIdField;
@property (weak, nonatomic) IBOutlet UITextField *appKeyField;
@end
