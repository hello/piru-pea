//
//  HEPViewController.m
//  Pea
//
//  Created by Delisa Mason on 6/6/14.
//  Copyright (c) 2014 Hello. All rights reserved.
//
#import <CoreBluetooth/CoreBluetooth.h>
#import <SVProgressHUD/SVProgressHUD.h>

#import "HEPAuthenticationViewController.h"
#import "HEPAuthorizationService.h"
#import "HEPDevicePickerTableViewController.h"
#import "HEPAPIClient.h"

static NSInteger const HEPURLAlertButtonIndexSave = 1;
static NSInteger const HEPURLAlertButtonIndexReset = 2;

@interface HEPAuthenticationViewController () <UIAlertViewDelegate>
@property (weak, nonatomic) IBOutlet UITextField* usernameField;
@property (weak, nonatomic) IBOutlet UITextField* passwordField;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView* activityIndicatorView;

@property (strong, nonatomic) IBOutlet UIView* view;
@end

@implementation HEPAuthenticationViewController

- (id)init
{
    self = [super initWithNibName:NSStringFromClass([HEPAuthenticationViewController class]) bundle:nil];

    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = NSLocalizedString(@"authorization.title", nil);
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"authorization.set-url.button", nil)
                                                                             style:UIBarButtonItemStyleBordered
                                                                            target:self
                                                                            action:@selector(setAPIURL:)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"authorization.sign-in.button", nil)
                                                                              style:UIBarButtonItemStyleBordered
                                                                             target:self
                                                                             action:@selector(didTapLogInButton:)];
    self.navigationItem.rightBarButtonItem.enabled = NO;
}

- (void)presentPeripheralPickerAnimated:(BOOL)animated
{
    HEPDevicePickerTableViewController* pickerController = [HEPDevicePickerTableViewController new];
    [self.navigationController pushViewController:pickerController animated:animated];
}

- (void)showURLUpdateAlertView
{
    UIAlertView* URLAlertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"authorization.set-url.title", nil)
                                                           message:NSLocalizedString(@"authorization.set-url.message", nil)
                                                          delegate:self
                                                 cancelButtonTitle:NSLocalizedString(@"actions.cancel", nil)
                                                 otherButtonTitles:NSLocalizedString(@"actions.save", nil), NSLocalizedString(@"authorization.set-url.action.reset", nil), nil];
    URLAlertView.alertViewStyle = UIAlertViewStylePlainTextInput;
    UITextField* URLField = [URLAlertView textFieldAtIndex:0];
    URLField.text = [HEPAPIClient baseURL].absoluteString;
    URLField.clearButtonMode = UITextFieldViewModeWhileEditing;
    [URLAlertView show];
}

#pragma mark - Actions

- (IBAction)didTapLogInButton:(id)sender
{
    self.navigationItem.rightBarButtonItem.enabled = NO;
    [SVProgressHUD showWithStatus:NSLocalizedString(@"authorization.sign-in.loading-message", nil) maskType:SVProgressHUDMaskTypeBlack];
    __weak typeof(self) weakSelf = self;
    [HEPAuthorizationService authorizeWithUsername:self.usernameField.text password:self.passwordField.text callback:^(NSError* error) {
        typeof(self) strongSelf = weakSelf;
        strongSelf.navigationItem.rightBarButtonItem.enabled = YES;
        [SVProgressHUD dismiss];
        if (error) {
            [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"authorization.sign-in.failed.title", nil)
                                        message:error.localizedDescription
                                       delegate:nil
                              cancelButtonTitle:nil
                              otherButtonTitles:NSLocalizedString(@"actions.ok", nil), nil] show];
            return;
        }
        [strongSelf.navigationController dismissViewControllerAnimated:YES completion:NULL];
    }];
}

- (IBAction)setAPIURL:(id)sender
{
    [self showURLUpdateAlertView];
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView*)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    switch (buttonIndex) {
    case HEPURLAlertButtonIndexReset: {
        [HEPAPIClient resetToDefaultBaseURL];
        break;
    }
    case HEPURLAlertButtonIndexSave: {
        UITextField* URLField = [alertView textFieldAtIndex:0];
        if (![HEPAPIClient setBaseURLFromPath:URLField.text]) {
            [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"authorization.failed-url.title", nil)
                                        message:NSLocalizedString(@"authorization.failed-url.message", nil)
                                       delegate:self
                              cancelButtonTitle:NSLocalizedString(@"actions.cancel", nil)
                              otherButtonTitles:nil] show];
        }
        break;
    }
    }
}

#pragma mark - UITextFieldDelegate

- (BOOL)textField:(UITextField*)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString*)string
{
    NSString* newText = [textField.text stringByReplacingCharactersInRange:range withString:string];
    UITextField* otherField;
    if ([textField isEqual:self.usernameField]) {
        otherField = self.passwordField;
    } else {
        otherField = self.usernameField;
    }
    self.navigationItem.rightBarButtonItem.enabled = newText.length > 0 && otherField.text.length > 0;

    return YES;
}

@end
