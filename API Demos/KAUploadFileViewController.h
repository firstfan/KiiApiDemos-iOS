//
//  KAUploadFileViewController.h
//  API Demos
//
//  Created by Evan JIANG on 14-7-29.
//  Copyright (c) 2014年 Kii Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface KAUploadFileViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UIActionSheetDelegate,UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) UIImagePickerController *imgPicker;
@end
