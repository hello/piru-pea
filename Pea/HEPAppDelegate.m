
#import <SenseKit/SENAuthorizationService.h>

#import "HEPAppDelegate.h"
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
    if (![SENAuthorizationService isAuthorized]) {
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
