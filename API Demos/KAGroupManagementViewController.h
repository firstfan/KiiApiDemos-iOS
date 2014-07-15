//
//  KAGroupManagementViewController.h
//  API Demos
//
//  Created by Evan JIANG on 14-7-15.
//  Copyright (c) 2014 Kii Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface KAGroupManagementViewController : UIViewController <UIActionSheetDelegate>

@property (weak, nonatomic) IBOutlet UILabel *groupLabel1;
@property (weak, nonatomic) IBOutlet UILabel *groupLabel2;
@property (weak, nonatomic) IBOutlet UITextField *usernameField;
@property (weak, nonatomic) IBOutlet UITextField *groupNoteField;
@end
