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
#import "HEPAPI.h"

static NSString* const HEP_tokenPath = @"oauth2/token";
static NSString* const HEP_applicationClientID = @"local_client_id";
static NSString* const HEP_credentialsKey = @"credentials";
static NSString* const HEP_accessTokenKey = @"access_token";
static NSString* const HEP_authorizationHeaderKey = @"Authorization";

@implementation HEPAuthorizationService

+ (void)authorizeWithUsername:(NSString *)username password:(NSString *)password callback:(void (^)(NSError *))block {
    NSDictionary* params = @{@"grant_type": @"password",
                             @"client_id": HEP_applicationClientID,
                             @"username": username?:@"",
                             @"password": password?:@""};

    [[HEPAPI HTTPSessionManager] POST:HEP_tokenPath parameters:params success:^(NSURLSessionDataTask *task, id responseObject) {
        if (block)
            block(task.error);
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        if (block)
            block(error);
    }];
}

+ (void)deauthorize {
    [[FXKeychain defaultKeychain] removeObjectForKey:HEP_credentialsKey];
    [self authorizeRequestsWithToken:nil];
}

+ (BOOL)isAuthorized {
    id token = [self authorizationHeaderValue];
    if (!token) {
        [self authorizeRequestsFromKeychain];
        token = [self authorizationHeaderValue];
    }

    return token != nil;
}

#pragma mark Private

+ (id)authorizationHeaderValue {
    return [[HEPAPI HTTPSessionManager].requestSerializer HTTPRequestHeaders][HEP_authorizationHeaderKey];
}

+ (void)authorizeRequestsFromKeychain {
    id token = [FXKeychain defaultKeychain][HEP_credentialsKey][HEP_accessTokenKey];
    if (token)
        [self authorizeRequestsWithToken:token];
}

+ (void)authorizeRequestsWithResponse:(id)responseObject {
    NSDictionary* responseData = (NSDictionary*)responseObject;
    [[FXKeychain defaultKeychain] setObject:responseObject forKey:HEP_credentialsKey];
    [self authorizeRequestsWithToken:responseData[HEP_accessTokenKey]];
}

+ (void)authorizeRequestsWithToken:(NSString*)token {
    [[HEPAPI HTTPSessionManager].requestSerializer setValue:token forHTTPHeaderField:HEP_authorizationHeaderKey];
}

@end
