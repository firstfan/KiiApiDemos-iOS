//
//  KAServerExtensionViewController.m
//  API Demos
//
//  Created by Evan JIANG on 14-7-30.
//  Copyright (c) 2014年 Kii Inc. All rights reserved.
//

#import "KAServerExtensionViewController.h"
#import "KAGlobal.h"
#import "MBProgressHUD.h"
#import "iToast.h"

@interface KAServerExtensionViewController ()

@end

@implementation KAServerExtensionViewController

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
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)clickOnDeleteAll:(id)sender {
    // Instantiate with the endpoint.
    KiiServerCodeEntry* entry =[Kii serverCodeEntry:@"deleteAllNotes"];
    
    // Set the custom parameters.
    NSDictionary* argDict= [[NSDictionary alloc] init];
    KiiServerCodeEntryArgument* argument= [KiiServerCodeEntryArgument argumentWithDictionary:argDict];
    
    // Execute the Server Code.
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [entry execute:argument withBlock:^(KiiServerCodeEntry *entry, KiiServerCodeEntryArgument *argument, KiiServerCodeExecResult *result, NSError *error) {
        [MBProgressHUD hideHUDForView:self.view animated:NO];
        if (error == nil) {
            int resultCode = [[result.returnedValue objectForKey:@"result"] intValue];
            NSString *msg = [result.returnedValue objectForKey:@"msg"];
            if (resultCode == 0) {
                [[iToast makeText:@"Run server extension successfully"] show];
            } else {
                [[iToast makeText:[NSString stringWithFormat:@"Extension:%@",msg]] show];
            }
        } else {
            [[iToast makeText:@"Run server extension failed"] show];
            NSLog(@"Err:%@",error);
        }
    }];

}

@end
