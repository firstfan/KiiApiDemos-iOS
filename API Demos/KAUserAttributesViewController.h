//
//  KAUserAttributesViewController.h
//  API Demos
//
//  Created by Evan JIANG on 14-7-8.
//  Copyright (c) 2014年 Kii Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface KAUserAttributesViewController : UIViewController
@property (weak, nonatomic) IBOutlet UISegmentedControl *genderSegment;
@property (weak, nonatomic) IBOutlet UITextField *ageField;
@property (weak, nonatomic) IBOutlet UITextField *oldPasswordField;
@property (weak, nonatomic) IBOutlet UITextField *passwordField;

@end
