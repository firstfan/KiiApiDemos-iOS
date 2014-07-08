//
//  KASignInViewController.h
//  API Demos
//
//  Created by Evan JIANG on 14-7-6.
//  Copyright (c) 2014 Kii Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface KASignInViewController : UIViewController <UIActionSheetDelegate>
@property (weak, nonatomic) IBOutlet UILabel *usernameLabel;
@property (weak, nonatomic) IBOutlet UILabel *tokenLabel;
@property (weak, nonatomic) IBOutlet UISegmentedControl *loginTypeSegment;
@property (weak, nonatomic) IBOutlet UITextField *nameField;
@property (weak, nonatomic) IBOutlet UITextField *passwordField;
@property (weak, nonatomic) IBOutlet UIButton *loginWithTokenButton;
@property (weak, nonatomic) IBOutlet UIButton *countryButton;

@end
