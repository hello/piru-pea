//
//  HEPSleepTrackerViewController.m
//  Pea
//
//  Created by Delisa Mason on 6/10/14.
//  Copyright (c) 2014 Hello. All rights reserved.
//

#import "HEPSleepTrackerViewController.h"
#import "HEPAuthorizationService.h"
#import "HEPDeviceService.h"
#import "HEPAuthenticationViewController.h"
#import "HEPDevicePickerTableViewController.h"
#import "HEPConnectedDeviceTableViewController.h"

@interface HEPSleepTrackerViewController ()

@property (weak, nonatomic) IBOutlet UIButton* trackingButton;
@end

@implementation HEPSleepTrackerViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = NSLocalizedString(@"tracker.title", nil);
    UIBarButtonItem* configItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"tracker.config.title", nil) style:UIBarButtonItemStyleBordered target:self action:@selector(openConfig)];
    UIBarButtonItem* signOutItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"tracker.sign-out.title", nil) style:UIBarButtonItemStyleBordered target:self action:@selector(signOut)];
    self.navigationItem.rightBarButtonItem = configItem;
    self.navigationItem.leftBarButtonItem = signOutItem;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if (![HEPDeviceService hasDevices]) {
        [self presentNavigationControllerForViewController:[[HEPDevicePickerTableViewController alloc] init]];
    }
}

- (IBAction)didTapTrackingButton:(id)sender
{
}

- (void)openConfig
{
    [self presentNavigationControllerForViewController:[[HEPConnectedDeviceTableViewController alloc] init]];
}

- (void)signOut
{
    [HEPAuthorizationService deauthorize];
    [self presentNavigationControllerForViewController:[[HEPAuthenticationViewController alloc] init]];
}

- (void)presentNavigationControllerForViewController:(UIViewController*)aController
{
    UINavigationController* controller = [[UINavigationController alloc] initWithRootViewController:aController];
    [self.navigationController presentViewController:controller animated:YES completion:NULL];
}

@end
