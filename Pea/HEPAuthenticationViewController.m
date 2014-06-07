//
//  HEPViewController.m
//  Pea
//
//  Created by Delisa Mason on 6/6/14.
//  Copyright (c) 2014 Hello. All rights reserved.
//
#import <CoreBluetooth/CoreBluetooth.h>

#import "HEPAuthenticationViewController.h"
#import "HEPAuthorizationService.h"
#import "HEPDevicePickerTableViewController.h"

@interface HEPAuthenticationViewController ()
@property (weak, nonatomic) IBOutlet UITextField *usernameField;
@property (weak, nonatomic) IBOutlet UITextField *passwordField;
@property (weak, nonatomic) IBOutlet UIButton *logInButton;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicatorView;

@end

@implementation HEPAuthenticationViewController

- (IBAction)didTapLogInButton:(id)sender {
    self.logInButton.enabled = NO;
    [self.activityIndicatorView startAnimating];
    __weak typeof(self) weakSelf = self;
    [HEPAuthorizationService authorizeWithUsername:self.usernameField.text password:self.passwordField.text callback:^(NSError *error) {
        typeof(self) strongSelf = weakSelf;
        [strongSelf.activityIndicatorView stopAnimating];
        strongSelf.logInButton.enabled = YES;
        if (error) {
            [[[UIAlertView alloc] initWithTitle:@"Log in Failed" message:error.localizedDescription delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil] show];
            return;
        }
        [strongSelf presentPeripheralPicker];
    }];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    NSString* newText = [textField.text stringByReplacingCharactersInRange:range withString:string];
    UITextField* otherField;
    if ([textField isEqual:self.usernameField]) {
        otherField = self.passwordField;
    } else {
        otherField = self.usernameField;
    }
    self.logInButton.enabled = newText.length > 0 && otherField.text.length > 0;

    return YES;
}

- (void)presentPeripheralPicker {
    HEPDevicePickerTableViewController* pickerController = [HEPDevicePickerTableViewController new];
    [self presentViewController:pickerController animated:YES completion:NULL];
}

@end
