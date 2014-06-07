//
//  HEPAPI.h
//  Pea
//
//  Created by Delisa Mason on 6/6/14.
//  Copyright (c) 2014 Hello. All rights reserved.
//

#import <Foundation/Foundation.h>
@class AFHTTPSessionManager;

@interface HEPAPI : NSObject

/**
 *  A convenience helper for making requests through an NSURLSession
 */
+ (AFHTTPSessionManager*)HTTPSessionManager;

/**
 *  The base URL for the suripu app service
 */
+ (NSURL*)baseURL;

/**
 *  Updates the base URL for the suripu app service
 */
+ (void)setBaseURLFromPath:(NSString*)baseURLPath;
@end
