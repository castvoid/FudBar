//
//  NSDictionary+allKeysMatching.h
//  FudBar
//
//  Created by Harry Jones on 01/08/2014.
//  Copyright (c) 2014 FudBar. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDictionary (allKeysMatching)

- (NSArray*)allKeysWhereObjectComparisonWith:(NSNumber*)comparision ResultsIn:(NSComparisonResult)desiredResult;

@end
