//
//  KANoteEditorViewController.m
//  API Demos
//
//  Created by Evan JIANG on 14-7-16.
//  Copyright (c) 2014 Kii Inc. All rights reserved.
//

#import "KANoteEditorViewController.h"
#import "MBProgressHUD.h"
#import "iToast.h"

@interface KANoteEditorViewController () {
    bool isNew;
    bool imgChanged;
    NSString *filePath;
}

@end

@implementation KANoteEditorViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    if (self.data == nil) {
        isNew = YES;
        KiiBucket *bucket = [[KiiUser currentUser] bucketWithName:@"notes"];
        self.data = [bucket createObject];
    } else {
        isNew = NO;
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
            NSError *refreshError = nil;
            [self.data refreshSynchronous:&refreshError];

            NSURL *path = [self getCacheFileURL];
            NSError *downloadError = nil;
            [self.data downloadBodySynchronousWithURL:path
                                          andError:&downloadError];
            if (downloadError == nil) {
                UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:path]];
                if (image != nil) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self.imageView setImage:image];
                    });
                }
            }
        });
        
    }
    [self.titleField setText:[self.data getObjectForKey:@"title"]];
    [self.contentView setText:[self.data getObjectForKey:@"content"]];
    UITapGestureRecognizer *recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickOnImage:)];
    self.imageView.userInteractionEnabled = YES;
    [self.imageView addGestureRecognizer:recognizer];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)clickOnImage:(UITapGestureRecognizer*)sender {
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Attach photo" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Take a photo",@"Pick a photo",@"Delete photo",nil];
    [actionSheet showInView:self.view];
}

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (buttonIndex) {
        case 0:
            [self showImagePicker:UIImagePickerControllerSourceTypeCamera edit:NO];
            break;
        case 1:
            [self showImagePicker:UIImagePickerControllerSourceTypePhotoLibrary edit:NO];
            break;
        case 2:
            [self deletePhoto];
            break;
    }
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [self.imgPicker dismissViewControllerAnimated:YES completion:nil];
    UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
    imgChanged = YES;
    [self.imageView setImage:image];
}

- (void)showImagePicker:(UIImagePickerControllerSourceType)sourceType edit:(BOOL)edit
{
    self.imgPicker = [[UIImagePickerController alloc]init];
    _imgPicker.sourceType = sourceType;
    _imgPicker.delegate = self;
    _imgPicker.allowsEditing = edit;
    [self presentViewController:_imgPicker animated:YES completion:NULL];
}

- (void)deletePhoto
{
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [self.data deleteBodyWithBlock:^(KiiObject *object, NSError *error) {
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        if (error == nil) {
            imgChanged = NO;
            [self.imageView setImage:nil];
        } else {
            [[iToast makeText:@"Delete photo failed"] show];
        }
    }];
}

- (NSURL*)getCacheFileURL
{
    NSString *pathStr = [[KAGlobal getInstance].cachePath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.jpg",self.data.uuid]];
    NSURL *path = [NSURL fileURLWithPath:pathStr];
    return path;
}

- (IBAction)clickOnSave:(id)sender {
    [self.data setObject:[self.titleField text] forKey:@"title"];
    [self.data setObject:[self.contentView text] forKey:@"content"];
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        NSError *error;
        [self.data saveSynchronous:&error];
        if (error == nil && imgChanged) {
            NSURL *path = [self getCacheFileURL];
            UIImage *image = [self.imageView image];
            NSData *imgData = UIImageJPEGRepresentation(image, 100);
            [imgData writeToURL:path atomically:YES];
            [self.data uploadBodySynchronousWithURL:path
                                  andContentType:@"image/jpg"
                                        andError:&error];
        }
       dispatch_async(dispatch_get_main_queue(), ^{
           [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
          });
    });

}

@end
