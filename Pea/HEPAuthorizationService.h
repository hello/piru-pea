//
//  HEPAuthorizationService.h
//  Pea
//
//  Created by Delisa Mason on 6/6/14.
//  Copyright (c) 2014 Hello. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HEPAuthorizationService : NSObject

/**
 *  Sends a request for a new access token, saving the returned credentials to the keychain.
 *  Future requests have the access token in the response set as the authorization header.
 *
 *  @param username the username of the entity to authorize
 *  @param password the password for the given username
 *  @param block    a block invoked after the authentication attempt is completed
 */
+ (void)authorizeWithUsername:(NSString*)username password:(NSString*)password callback:(void(^)(NSError* error))block;

/**
 *  Deauthorize future requests and remove the active credentials from the keychain.
 */
+ (void)deauthorize;

/**
 *  Check whether there are cached credentials in the keychain
 */
+ (BOOL)isAuthorized;
@end
