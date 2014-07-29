//
//  KAABTestingViewController.m
//  API Demos
//
//  Created by Evan JIANG on 14-7-29.
//  Copyright (c) 2014年 Kii Inc. All rights reserved.
//

#import "KAABTestingViewController.h"
#import "KAViewUtils.h"
#import "KAGlobal.h"
#import "MBProgressHUD.h"
#import "iToast.h"
#import <KiiSDK/KiiRandomVariationSampler.h>
#import <KiiSDK/KiiVariationSampler.h>


@interface KAABTestingViewController () {
    KiiVariation *variation;
    KiiExperiment *exper;
}

@end

@implementation KAABTestingViewController

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
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [KiiExperiment getExperiment:[KAGlobal getInstance].currentApp.ABTestingID withBlock:^(KiiExperiment *experiment, NSError *error) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        if (error == nil) {
            exper = experiment;
            id<KiiVariationSampler> randomSampler =  [[KiiRandomVariationSampler alloc] init];
            KiiVariation *fallback = [experiment variationByName:@"A"];
            variation = [experiment appliedVariationWithSampler:randomSampler
                                                                fallback:fallback];
            
            NSDictionary *variableSet = variation.variableDictionary;
            
            // Get the details for Variation "A"
            NSString *buttonColor = variableSet[@"buttonColor"];
            NSString *buttonLabel = variableSet[@"buttonLabel"];
            if ([buttonColor isEqualToString:@"red"]) {
                [self.button setBackgroundColor:[UIColor redColor]];
            } else if ([buttonColor isEqualToString:@"green"]) {
                [self.button setBackgroundColor:[UIColor greenColor]];
            }
            [self.button setTitle:buttonLabel forState:UIControlStateNormal];
            NSDictionary *viewEvent = [variation eventDictionaryForConversionWithName:@"eventViewed"];
            [KiiAnalytics trackEvent:exper.experimentID
                          withExtras:viewEvent];
        } else {
            [[iToast makeText:@"Failed to get settings"] show];
        }
    }];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    NSDictionary *viewEvent = [variation eventDictionaryForConversionWithName:@"eventViewed"];
    [KiiAnalytics trackEvent:exper.experimentID
                  withExtras:viewEvent];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)clickOnButton:(id)sender {
    NSDictionary *clickEvent = [variation eventDictionaryForConversionWithName:@"eventClicked"];
    [KiiAnalytics trackEvent:exper.experimentID
                  withExtras:clickEvent];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://documentation.kii.com/en/guides/ab-testing/"]];
}

@end
