//
//  KADownloadFileViewController.m
//  API Demos
//
//  Created by Evan JIANG on 14-7-31.
//  Copyright (c) 2014年 Kii Inc. All rights reserved.
//

#import "KADownloadFileViewController.h"
#import "KAGlobal.h"
#import "MBProgressHUD.h"
#import "iToast.h"

@interface KADownloadFileViewController () {
    KiiBucket       *bucket;
    NSArray         *allData;
    NSArray         *downloadEntries;
    KiiDownloader   *currDownloader;
    KiiRTransferBlock progress;
}

@end

#define ACTION_TAG_SUSPEND  2
#define ACTION_TAG_ONGOING  3

@implementation KADownloadFileViewController

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

    __unsafe_unretained KADownloadFileViewController *vc = self;
    progress = ^(id <KiiRTransfer> transferObject, NSError *retError) {
        if (retError) {
            NSLog(@"Err:%@",retError);
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [vc refreshList];
        });
    };
    
    [self getFileLists];
    [self refreshList];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)getFileLists
{
    bucket = [[KiiUser currentUser] bucketWithName:FILE_BUCKET];
    KiiQuery *all_query = [KiiQuery queryWithClause:nil];
    [bucket executeQuery:all_query withBlock:^(KiiQuery *query, KiiBucket *bucket, NSArray *results, KiiQuery *nextQuery, NSError *error) {
        allData = results;
        [self.tableView reloadData];
    }];
}

- (void)refreshList
{
    NSError             *error = nil;
    KiiRTransferManager *manager = [bucket transferManager];

    downloadEntries = [manager getDownloadEntries:&error];

    if (error != nil) {
        NSLog(@"Error:%@", error);
    }

    [self.tableView reloadData];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return @"Files on server";
    } else {
        return @"Downloader tasks";
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return [allData count];
    } else {
        return [downloadEntries count];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    int             section = [indexPath section];
    int             row = [indexPath row];

    if (section == 0) {
        KiiObject   *obj = [allData objectAtIndex:row];
        NSString    *title = [obj getObjectForKey:@"title"];
        NSNumber    *size = [obj getObjectForKey:@"fileSize"];
        [cell.textLabel setText:title];
        int sizeInK = [size unsignedIntValue] / 1024;
        [cell.detailTextLabel setText:[NSString stringWithFormat:@"%dK", sizeInK]];
        return cell;
    } else {
        KiiDownloader   *downloader = [downloadEntries objectAtIndex:[indexPath row]];
        NSString        *name = [downloader.localPath lastPathComponent];

        [cell.textLabel setText:name];
        switch ([downloader info].status) {
            case KiiRTStatus_NOENTRY:
                [cell.detailTextLabel setText:@"Done"];
                break;

            case KiiRTStatus_SUSPENDED:
                [cell.detailTextLabel setText:@"Suspended"];
                break;

            case KiiRTStatus_ONGOING:
                {
                    KiiRTransferInfo    *info = [downloader info];
                    int                 progressValue = (int)(((float)[info completedSizeInBytes] / [info totalSizeInBytes]) * 100);
                    [cell.detailTextLabel setText:[NSString stringWithFormat:@"%d%%", progressValue]];
                }
                break;
        }
        return cell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    int section = [indexPath section];
    int row = [indexPath row];

    if (section == 0) {
        KiiObject *object = [allData objectAtIndex:row];
        NSString *name = [object getObjectForKey:@"title"];
        NSString *pathStr = [[KAGlobal getInstance].cachePath stringByAppendingPathComponent:name];
        KiiDownloader *downloader = [object downloader:pathStr];
        [downloader transferWithProgressBlock:progress
                           andCompletionBlock:progress];
        [self refreshList];
    } else {
        KiiDownloader *downloader = [downloadEntries objectAtIndex:row];
        currDownloader = downloader;
        switch ([downloader info].status) {
            case KiiRTStatus_NOENTRY:
                break;

            case KiiRTStatus_SUSPENDED:
                {
                    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Operation" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Resume", @"Terminate", nil];
                    [actionSheet setTag:ACTION_TAG_SUSPEND];
                    [actionSheet showInView:self.view];
                }
                break;

            case KiiRTStatus_ONGOING:
                {
                    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Operation" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Suspend", @"Terminate", nil];
                    [actionSheet setTag:ACTION_TAG_ONGOING];
                    [actionSheet showInView:self.view];
                }
                break;
        }
    }
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
        NSError *error = nil;
        NSLog(@"Terminate");
        [currDownloader terminate:&error];
        if (error) {
            NSLog(@"Err:%@",error);
        }
        [self refreshList];
    } else if (buttonIndex == 0) {
        if ([actionSheet tag] == ACTION_TAG_SUSPEND) {
            NSLog(@"Resume");
            [currDownloader transferWithProgressBlock:progress
                                 andCompletionBlock:progress];
            [self refreshList];
        } else if ([actionSheet tag] == ACTION_TAG_ONGOING) {
            NSError *error = nil;
            NSLog(@"Suspend");
            [currDownloader suspend:&error];
            if (error) {
                NSLog(@"Err:%@",error);
            }
            [self refreshList];
        }
    }
}

@end