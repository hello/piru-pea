//
//  HEPAPI.m
//  Pea
//
//  Created by Delisa Mason on 6/6/14.
//  Copyright (c) 2014 Hello. All rights reserved.
//

#import <AFNetworking/AFHTTPSessionManager.h>

#import "HEPAPIClient.h"

//static NSString* const HEPDefaultBaseURLPath = @"http://api.skeletor.com";
static NSString* const HEPDefaultBaseURLPath = @"http://192.168.128.88:9999";
static NSString* const HEPAPIClientBaseURLPathKey = @"HEPAPIClientBaseURLPathKey";
static AFHTTPSessionManager* sessionManager = nil;

@implementation HEPAPIClient

+ (AFHTTPSessionManager*)HTTPSessionManager
{
    if (!sessionManager) {
        sessionManager = [[AFHTTPSessionManager alloc] initWithBaseURL:[self baseURL]];
        sessionManager.requestSerializer = [[AFHTTPRequestSerializer alloc] init];
    }
    return sessionManager;
}

+ (NSURL*)baseURL
{
    NSString* cachedPath = [[NSUserDefaults standardUserDefaults] stringForKey:HEPAPIClientBaseURLPathKey];
    NSString* baseURLPath = cachedPath.length > 0 ? cachedPath : HEPDefaultBaseURLPath;
    return [NSURL URLWithString:baseURLPath];
}

+ (void)resetToDefaultBaseURL
{
    sessionManager = nil;
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:HEPAPIClientBaseURLPathKey];
}

+ (BOOL)setBaseURLFromPath:(NSString*)baseURLPath
{
    NSURL* baseURL = [NSURL URLWithString:baseURLPath];
    if (baseURL && baseURLPath.length > 0) {
        sessionManager = nil;
        if (baseURLPath.length == 0) {
            [[NSUserDefaults standardUserDefaults] removeObjectForKey:HEPAPIClientBaseURLPathKey];
        } else {
            [[NSUserDefaults standardUserDefaults] setObject:baseURLPath forKey:HEPAPIClientBaseURLPathKey];
        }
        return YES;
    }
    return NO;
}

@end
