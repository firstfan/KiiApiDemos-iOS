//
//  KAUploadFileViewController.m
//  API Demos
//
//  Created by Evan JIANG on 14-7-29.
//  Copyright (c) 2014年 Kii Inc. All rights reserved.
//

#import "KAUploadFileViewController.h"
#import "KAViewUtils.h"
#import "MBProgressHUD.h"
#import "iToast.h"
#import "KAGlobal.h"

#define ACTION_TAG_PHOTO 1
#define ACTION_TAG_SUSPEND 2
#define ACTION_TAG_ONGOING 3

@interface KAUploadFileViewController () {
    KiiBucket   *bucket;
    NSArray     *uploadEntries;
    KiiRTransferBlock progress;
    KiiUploader *currUploader;
}

@end

@implementation KAUploadFileViewController

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
    __unsafe_unretained KAUploadFileViewController *vc = self;
    progress = ^(id <KiiRTransfer> transferObject, NSError *retError) {
        if (retError) {
            NSLog(@"Err:%@",retError);
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [vc refreshList];
        });
    };
    bucket = [[KiiUser currentUser] bucketWithName:FILE_BUCKET];
    [self refreshList];
}

- (void)refreshList
{
    NSLog(@"refresh list");
    NSError             *error = nil;
    KiiRTransferManager *manager = [bucket transferManager];

    uploadEntries = [manager getUploadEntries:&error];
    if (error!=nil) {
        NSLog(@"Error:%@",error);
    }
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [uploadEntries count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    KiiUploader     *uploader = [uploadEntries objectAtIndex:[indexPath row]];
    NSString        *name = [uploader.localPath lastPathComponent];

    [cell.textLabel setText:name];
    switch ([uploader info].status) {
        case KiiRTStatus_NOENTRY:
            [cell.detailTextLabel setText:@"Done"];
            break;

        case KiiRTStatus_SUSPENDED:
            [cell.detailTextLabel setText:@"Suspended"];
            break;

        case KiiRTStatus_ONGOING:
        {
            KiiRTransferInfo *info = [uploader info];
            int progressValue = (int)(((float) [info completedSizeInBytes] / [info totalSizeInBytes]) * 100);
            [cell.detailTextLabel setText:[NSString stringWithFormat:@"%d%%",progressValue]];
        }
            break;
    }
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    KiiUploader     *uploader = [uploadEntries objectAtIndex:[indexPath row]];
    currUploader = uploader;
    switch ([uploader info].status) {
        case KiiRTStatus_NOENTRY:
            break;
            
        case KiiRTStatus_SUSPENDED: {
            UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Operation" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Resume",@"Terminate", nil];
            [actionSheet setTag:ACTION_TAG_SUSPEND];
            [actionSheet showInView:self.view];
        }
            break;
            
        case KiiRTStatus_ONGOING:{
            UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Operation" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Suspend",@"Terminate", nil];
            [actionSheet setTag:ACTION_TAG_ONGOING];
            [actionSheet showInView:self.view];
        }
            break;
    }
}

- (IBAction)clickOnUploadFile:(id)sender
{
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Attach photo" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Take a photo", @"Pick a photo", nil];

    [actionSheet setTag:ACTION_TAG_PHOTO];
    [actionSheet showInView:self.view];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if ([actionSheet tag] == ACTION_TAG_PHOTO) {
        switch (buttonIndex) {
            case 0:
                [self showImagePicker:UIImagePickerControllerSourceTypeCamera edit:NO];
                break;

            case 1:
                [self showImagePicker:UIImagePickerControllerSourceTypePhotoLibrary edit:NO];
                break;
        }
    } else if (buttonIndex == 1) {
        NSError *error = nil;
        NSLog(@"Terminate");
        [currUploader terminate:&error];
        if (error) {
            NSLog(@"Err:%@",error);
        }
        [self refreshList];
    } else if (buttonIndex == 0) {
        if ([actionSheet tag] == ACTION_TAG_SUSPEND) {
            NSLog(@"Resume");
            [currUploader transferWithProgressBlock:progress
                             andCompletionBlock:progress];
            [self refreshList];
        } else if ([actionSheet tag] == ACTION_TAG_ONGOING) {
            NSError *error = nil;
            NSLog(@"Suspend");
            [currUploader suspend:&error];
            if (error) {
                NSLog(@"Err:%@",error);
            }
            [self refreshList];
        }
    }
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [self.imgPicker dismissViewControllerAnimated:YES completion:nil];
    UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
    NSData *imgData = UIImageJPEGRepresentation(image, 100);
    NSString *name = [NSString stringWithFormat:@"%lld.jpg",(long long)([[NSDate date] timeIntervalSince1970]*1000)];
    NSString *pathStr = [[KAGlobal getInstance].cachePath stringByAppendingPathComponent:name];
    [imgData writeToFile:pathStr atomically:YES];
    KiiObject *object = [bucket createObject];
    
    [object setObject:name
               forKey:@"title"];
    [object setObject:[NSNumber numberWithUnsignedInteger:[imgData length]]
               forKey:@"fileSize"];
    KiiUploader *uploader = [object uploader:pathStr];
    [uploader transferWithProgressBlock:progress
                               andCompletionBlock:progress];
    [self refreshList];
}

- (void)showImagePicker:(UIImagePickerControllerSourceType)sourceType edit:(BOOL)edit
{
    self.imgPicker = [[UIImagePickerController alloc]init];
    _imgPicker.sourceType = sourceType;
    _imgPicker.delegate = self;
    _imgPicker.allowsEditing = edit;
    [self presentViewController:_imgPicker animated:YES completion:NULL];
}

@end