//
//  KASettingsViewController.h
//  API Demos
//
//  Created by Evan JIANG on 14-7-6.
//  Copyright (c) 2014年 Kii Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface KASettingsViewController : UIViewController <UIAlertViewDelegate>
@property (weak, nonatomic) IBOutlet UISegmentedControl *appSegment;
@property (weak, nonatomic) IBOutlet UISegmentedControl *serverSegment;
@property (weak, nonatomic) IBOutlet UITextField *appIdField;
@property (weak, nonatomic) IBOutlet UITextField *appKeyField;
@end
