//
//  APIRequester.m
//  FudBar
//
//  Created by Harry Jones on 29/07/2014.
//  Copyright (c) 2014 FudBar. All rights reserved.
//

#import "APIRequester.h"

@implementation APIRequester

+ (NSString *) escapeString: (NSString *)string{
    CFStringRef escaped = CFURLCreateStringByAddingPercentEscapes (kCFAllocatorDefault,
                                                                   (CFStringRef)string,
                                                                   NULL,
                                                                   (CFStringRef)@"/%&=?$#+-~@<>|\\*,.()[]{}^!",
                                                                   kCFStringEncodingUTF8);
    return (__bridge NSString *)(escaped);
    // Stolen from Google Toolbox for Mac "GTMNSString+URLArguments.m".
    // The NSURL escape thing doesn't escape things such as '&', potentially allowing
    // the user to enter these and mess up the HTTP request URL.
}

+ (void) requestWithURL: (NSURL*) url andHandler: (void (^)(NSURLResponse* response, NSData* data, NSError* connectionError)) handler{
    NSLog(@"🕑 Requesting: %@",[url absoluteString]);
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url cachePolicy:NSURLRequestReturnCacheDataElseLoad timeoutInterval:7.5];
    [NSURLConnection sendAsynchronousRequest:request queue:[[NSOperationQueue alloc]init] completionHandler:handler];
    // Sends the actual request.
}

+ (void)requestJSONWithURL: (NSURL*) url andHandler: (void (^)(id data)) handler{
    [self requestWithURL:url andHandler:^(NSURLResponse *response, NSData *data, NSError *error)
     {
         if (error) { // If there is an error sending the request (e.g. unsupported protocol)
             NSLog(@"Error sending request: %@",[error description]);
         } else {
             // Otherwise, try converting it from JSON
             NSArray *array = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
             if (error){ // If we get an error
                 NSLog(@"JSONObjectWithData error on URL %@: %@", [response URL],[error description]);
                 handler(Nil);
             }else{ // Otherwise, we're probably all good to call the user's handler
                 handler(array);
             }
         }
     }];
}

@end
