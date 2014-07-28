//
//  KANoteEditorViewController.h
//  API Demos
//
//  Created by Evan JIANG on 14-7-16.
//  Copyright (c) 2014 Kii Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KAGlobal.h"

@interface KANoteEditorViewController : UIViewController <UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIActionSheetDelegate>

@property (weak, nonatomic) IBOutlet UITextField *titleField;
@property (weak, nonatomic) IBOutlet UITextView *contentView;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (strong, nonatomic) UIImagePickerController *imgPicker;

@property (retain, nonatomic) KiiObject *data;
@end
