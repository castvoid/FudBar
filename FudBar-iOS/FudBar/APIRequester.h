//
//  APIRequester.h
//  FudBar
//
//  Created by Harry Jones on 29/07/2014.
//  Copyright (c) 2014 FudBar. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface APIRequester : NSObject <NSURLConnectionDelegate>

/**
 *  Escapes the inputted string, by converting all characters that are invalid (e.g. '*','&',' ') to their escaped equivalents, ready for inseting into a URL.
 *
 *  @param string The string by escaped
 *
 *  @return The escaped string
 */
+ (NSString *) escapeString: (NSString *)string;

/**
 *  Makes an asynchronous request to the specified URL using `NSURLConection`. Once the request has completed, the handler is called, giving the response, data, and any error codes. If useAuth is true, then it will make the request using a valid API key.
 *
 *  @param url     The url to be requested, as a NSURL.
 *  @param useAuth A bool, if true the request will be made using a valid API key.
 */
+ (void) requestWithURL: (NSURL*) url andHandler: (void (^)(NSURLResponse* response, NSData* data, NSError* connectionError)) handler;

/**
 *  Makes an asynchronous request to the specified URL using `NSURLConection`. Once the request has completed, the handler is called, with the only argument being the returned JSON as an object. If useAuth is true, then it will make the request using a valid API key.
 *
 *  @param url     The url to be requested, as a NSURL.
 *  @param useAuth A bool, if true the request will be made using a valid API key.
 */
+ (void)requestJSONWithURL: (NSURL*) url andHandler: (void (^)(id data)) handler;


@end
