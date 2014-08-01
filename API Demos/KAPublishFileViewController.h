//
//  KAPublishFileViewController.h
//  API Demos
//
//  Created by Evan JIANG on 14-7-31.
//  Copyright (c) 2014年 Kii Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface KAPublishFileViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UITextField *expireField;
@end
