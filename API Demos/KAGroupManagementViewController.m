//
//  KAGroupManagementViewController.m
//  API Demos
//
//  Created by Evan JIANG on 14-7-15.
//  Copyright (c) 2014 Kii Inc. All rights reserved.
//

#import "KAGroupManagementViewController.h"
#import "KAViewUtils.h"
#import "MBProgressHUD.h"
#import "iToast.h"
#import <KiiSDK/Kii.h>
#import "KAGlobal.h"

@interface KAGroupManagementViewController () {
    //Group1 is for showing creating group and add member to the group
    KiiGroup *group1;
    //Group 2 is for showing to modify group bucket
    KiiGroup *group2;
    NSArray* tempGroups;
    KiiObject *groupContent;
}

@end

#define ACTION_TAG_OWNED    1
#define ACTION_TAG_MEMBER   2
#define NOTE_FILED_NAME @"note"

@implementation KAGroupManagementViewController

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
    NSArray *versionCompatibility = [[UIDevice currentDevice].systemVersion componentsSeparatedByString:@"."];
    if ([[versionCompatibility objectAtIndex:0] intValue]>=7) {
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [KAViewUtils makeSureAlreadyLogin:self.navigationController];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return NO;
}


- (IBAction)createGroup:(id)sender {
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    NSString *groupName = [NSString stringWithFormat:@"g%lld",(long long)[[NSDate date] timeIntervalSince1970]];
    KiiGroup* group = [KiiGroup groupWithName:groupName];
    [group saveWithBlock:^(KiiGroup *group, NSError *error) {
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        
        if (error == nil) {
            group1 = group;
            [self.groupLabel1 setText:[group name]];
            [[iToast makeText:@"Create group successfully"] show];
        } else {
            [[iToast makeText:[NSString stringWithFormat:@"Create group failed:%@", error]] show];
            NSLog(@"Create group failed:%@", error);
        }
    }];
}
- (IBAction)selectOwnedGroup:(id)sender {
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [[KiiUser currentUser] ownerOfGroupsWithBlock:^(KiiUser *user, NSArray *results, NSError *error) {
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        
        if (error == nil) {
            tempGroups = results;
            UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Select group" delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil];
            for (KiiGroup *g in results) {
                [actionSheet addButtonWithTitle:g.name];
            }
            [actionSheet addButtonWithTitle:@"Cancel"];
            [actionSheet setCancelButtonIndex:[results count]];
            [actionSheet setTag:ACTION_TAG_OWNED];
            [actionSheet showInView:self.view];
        } else {
            [[iToast makeText:[NSString stringWithFormat:@"Get groups failed:%@", error]] show];
            NSLog(@"Get groups failed:%@", error);
        }

    }];
}
- (IBAction)addToGroup:(id)sender {
    if (group1 == nil) {
        [[iToast makeText:@"You need to create or select a group first"] show];
        return;
    }
    NSString *username = [self.usernameField text];
    if ([username length]==0) {
        [[iToast makeText:@"You need to input username first"] show];
        return;
    }
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        NSError *error;
        KiiUser *userToAdd = [KiiUser findUserByUsernameSynchronous:username withError:&error];
        if (error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
                [[iToast makeText:@"Cannot find the user"] show];
                NSLog(@"Find user error:%@",error);
            });
            return;
        }
        [group1 addUser:userToAdd];
        [group1 saveSynchronous:&error];
        if (error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
                [[iToast makeText:@"Add user to group failed"] show];
                NSLog(@"Add user to group failed:%@",error);
            });
            return;
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
                [[iToast makeText:@"Add user to group successfully"] show];
            });
        }
    });
}

- (IBAction)listGroupMembers:(id)sender {
    if (group1 == nil) {
        [[iToast makeText:@"You need to create or select a group first"] show];
        return;
    }
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        NSError *error;
        NSArray *members = [group1 getMemberListSynchronous:&error];
        if (error == nil) {
            for (KiiUser *u in members) {
                [u refreshSynchronous:&error];
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
                UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Group members" delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil];
                for (KiiUser *u in members) {
                    [actionSheet addButtonWithTitle:u.username];
                }
                [actionSheet addButtonWithTitle:@"Cancel"];
                [actionSheet setCancelButtonIndex:[members count]];
                [actionSheet showInView:self.view];

            });
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
                [[iToast makeText:[NSString stringWithFormat:@"Get group members failed:%@", error]] show];
                NSLog(@"Get group members failed:%@", error);
            });
        }
    });
}

- (IBAction)selectGroupWithMe:(id)sender {
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [[KiiUser currentUser] memberOfGroupsWithBlock:^(KiiUser *user, NSArray *results, NSError *error) {
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        
        if (error == nil) {
            tempGroups = results;
            UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Select group" delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil];
            for (KiiGroup *g in results) {
                [actionSheet addButtonWithTitle:g.name];
            }
            [actionSheet addButtonWithTitle:@"Cancel"];
            [actionSheet setCancelButtonIndex:[results count]];
            [actionSheet setTag:ACTION_TAG_MEMBER];
            [actionSheet showInView:self.view];
        } else {
            [[iToast makeText:[NSString stringWithFormat:@"Get groups failed:%@", error]] show];
            NSLog(@"Get groups failed:%@", error);
        }
        
    }];
}

- (IBAction)saveNoteToGroupBucket:(id)sender {
    if (group2 == nil) {
        [[iToast makeText:@"You need to select a group with you first"] show];
        return;
    }
    if (groupContent == nil) {
        [[iToast makeText:@"Try to select group again"] show];
        return;
    }
    NSString *note = [self.groupNoteField text];
    if ([note length]==0) {
        [[iToast makeText:@"The note field is empty"] show];
        return;
    }
    [groupContent setObject:note forKey:NOTE_FILED_NAME];
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [groupContent saveWithBlock:^(KiiObject *object, NSError *error) {
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        
        if (error == nil) {
           [[iToast makeText:@"Save note successfully"] show];
        } else {
            [[iToast makeText:[NSString stringWithFormat:@"Save note failed:%@", error]] show];
            NSLog(@"Save note failed:%@", error);
        }

    }];
}

-(void)fetchGroupNote
{
    if (group2 == nil) {
        [[iToast makeText:@"You need to select a group with you first"] show];
        return;
    }
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        NSError *error;
        KiiBucket *bucket = [group2 bucketWithName:@"group_bucket"];
        KiiQuery *all_query = [KiiQuery queryWithClause:nil];
        // Create a placeholder for any paginated queries
        KiiQuery *nextQuery;
        
        // Get an array of KiiObjects by querying the bucket
        NSArray *results = [bucket executeQuerySynchronous:all_query
                                                 withError:&error
                                                   andNext:&nextQuery];
        if ([results count]>0) {
            groupContent = [results objectAtIndex:0];
            [groupContent refreshSynchronous:&error];
        } else {
            groupContent = [bucket createObject];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
            [self.groupNoteField setPlaceholder:@"Not set yet"];
            [self.groupNoteField setText:[groupContent getObjectForKey:NOTE_FILED_NAME]];
        });
    });
}

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == [actionSheet cancelButtonIndex]) {
        return;
    }
    switch ([actionSheet tag]) {
        case ACTION_TAG_OWNED:
            group1 = [tempGroups objectAtIndex:buttonIndex];
            [self.groupLabel1 setText:[group1 name]];
            break;
        case ACTION_TAG_MEMBER:
            group2 = [tempGroups objectAtIndex:buttonIndex];
            [self.groupLabel2 setText:[group2 name]];
            [self fetchGroupNote];
            break;
    }
}

@end
