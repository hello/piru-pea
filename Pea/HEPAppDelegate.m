//
//  HEPAppDelegate.m
//  Pea
//
//  Created by Delisa Mason on 6/6/14.
//  Copyright (c) 2014 Hello. All rights reserved.
//

#import "HEPAppDelegate.h"
#import "HEPAuthorizationService.h"
#import "HEPDeviceService.h"
#import "HEPAuthenticationViewController.h"
#import "HEPSleepTrackerViewController.h"

@implementation HEPAppDelegate

- (BOOL)application:(UIApplication*)application didFinishLaunchingWithOptions:(NSDictionary*)launchOptions
{
    return YES;
}

- (void)applicationWillResignActive:(UIApplication*)application
{
}

- (void)applicationDidEnterBackground:(UIApplication*)application
{
}

- (void)applicationWillEnterForeground:(UIApplication*)application
{
}

- (void)applicationDidBecomeActive:(UIApplication*)application
{
    if (![HEPAuthorizationService isAuthorized]) {
        [self showAuthViewController];
    }
}

- (void)applicationWillTerminate:(UIApplication*)application
{
}

- (void)showAuthViewController
{
    UINavigationController* rootNavigationController = (UINavigationController*)self.window.rootViewController;
    [rootNavigationController popToRootViewControllerAnimated:NO];
    HEPAuthenticationViewController* authController = [[HEPAuthenticationViewController alloc] init];
    UINavigationController* navController = [[UINavigationController alloc] initWithRootViewController:authController];
    [rootNavigationController presentViewController:navController animated:NO completion:NULL];
}

@end
