//
//  NSDictionary+allKeysMatching.m
//  FudBar
//
//  Created by Harry Jones on 01/08/2014.
//  Copyright (c) 2014 FudBar. All rights reserved.
//

#import "NSDictionary+allKeysMatching.h"

@implementation NSDictionary (allKeysMatching)

- (NSArray*)allKeysWhereObjectComparisonWith:(NSNumber*)comparision ResultsIn:(NSComparisonResult)desiredResult{
    NSMutableArray *results = [[NSMutableArray alloc] init];
    
    NSArray *keys = self.allKeys;
    NSLog(@"KEYS: %@",[keys description]);
    
    for (NSObject* key in keys){
        NSObject *object = [self objectForKey:key];
        NSNumber *valNumber;
        if (true || [object isMemberOfClass:[NSNumber class]]){
            valNumber = (NSNumber*)object;
        }else{
            continue;
        }
        NSComparisonResult result  = [valNumber compare:comparision];
        if (result == desiredResult){
            [results addObject:key];
        }
    }
    
    return results;
}

@end
