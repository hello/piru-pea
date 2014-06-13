//
//  HEPAuthorizationService.m
//  Pea
//
//  Created by Delisa Mason on 6/6/14.
//  Copyright (c) 2014 Hello. All rights reserved.
//
#import <AFNetworking/AFHTTPSessionManager.h>
#import <FXKeychain/FXKeychain.h>

#import "HEPAuthorizationService.h"
#import "HEPAPIClient.h"

NSString* const HEPAuthorizationServiceDidAuthorizeNotification = @"HEPAuthorizationServiceDidAuthorize";
NSString* const HEPAuthorizationServiceDidDeauthorizeNotification = @"HEPAuthorizationServiceDidDeauthorize";

static NSString* const HEP_tokenPath = @"oauth2/token";
static NSString* const HEP_applicationClientID = @"iphone_pill";
static NSString* const HEP_credentialsKey = @"credentials";
static NSString* const HEP_accessTokenKey = @"access_token";
static NSString* const HEP_authorizationHeaderKey = @"Authorization";

@implementation HEPAuthorizationService

+ (void)authorizeWithUsername:(NSString*)username password:(NSString*)password callback:(void (^)(NSError*))block
{
    NSDictionary* params = @{ @"grant_type" : @"password",
                              @"client_id" : HEP_applicationClientID,
                              @"username" : username ?: @"",
                              @"password" : password ?: @"" };

    [[HEPAPIClient HTTPSessionManager] POST:HEP_tokenPath parameters:params success:^(NSURLSessionDataTask* task, id responseObject) {
        [self authorizeRequestsWithResponse:responseObject];
        if (block)
            block(task.error);
    } failure:^(NSURLSessionDataTask* task, NSError* error) {
        if (block)
            block(error);
    }];
}

+ (void)deauthorize
{
    [[FXKeychain defaultKeychain] removeObjectForKey:HEP_credentialsKey];
    [self authorizeRequestsWithToken:nil];
}

+ (BOOL)isAuthorized
{
    id token = [self authorizationHeaderValue];
    if (!token) {
        [self authorizeRequestsFromKeychain];
        token = [self authorizationHeaderValue];
    }

    return token != nil;
}

#pragma mark Private

+ (id)authorizationHeaderValue
{
    return [[HEPAPIClient HTTPSessionManager].requestSerializer HTTPRequestHeaders][HEP_authorizationHeaderKey];
}

+ (void)authorizeRequestsFromKeychain
{
    id token = [FXKeychain defaultKeychain][HEP_credentialsKey][HEP_accessTokenKey];
    if (token)
        [self authorizeRequestsWithToken:token];
}

+ (void)authorizeRequestsWithResponse:(id)responseObject
{
    NSDictionary* responseData = (NSDictionary*)responseObject;
    [[FXKeychain defaultKeychain] setObject:responseObject forKey:HEP_credentialsKey];
    [self authorizeRequestsWithToken:responseData[HEP_accessTokenKey]];
}

+ (void)authorizeRequestsWithToken:(NSString*)token
{
    [[HEPAPIClient HTTPSessionManager].requestSerializer setValue:token forHTTPHeaderField:HEP_authorizationHeaderKey];
    if (token) {
        [[NSNotificationCenter defaultCenter] postNotificationName:HEPAuthorizationServiceDidAuthorizeNotification object:self userInfo:nil];
    } else {
        [[NSNotificationCenter defaultCenter] postNotificationName:HEPAuthorizationServiceDidDeauthorizeNotification object:self userInfo:nil];
    }
}

@end
