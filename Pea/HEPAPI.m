//
//  HEPAPI.m
//  Pea
//
//  Created by Delisa Mason on 6/6/14.
//  Copyright (c) 2014 Hello. All rights reserved.
//

#import <AFNetworking/AFHTTPSessionManager.h>

#import "HEPAPI.h"

static NSString* const HEP_defaultBaseURLPath = @"http://0.0.0.0:9999";

@implementation HEPAPI

+ (AFHTTPSessionManager*)HTTPSessionManager {
    static AFHTTPSessionManager* sessionManager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sessionManager = [[AFHTTPSessionManager alloc] initWithBaseURL:[self baseURL]];
        sessionManager.requestSerializer = [[AFHTTPRequestSerializer alloc] init];
    });
    return sessionManager;
}

+ (NSURL *)baseURL {
    return [NSURL URLWithString:HEP_defaultBaseURLPath];
}

+ (void)setBaseURLFromPath:(NSString *)baseURLPath {
    // TODO
}

@end
