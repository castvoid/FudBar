//
//  ProductDataEntryTableViewController.h
//  FudBar
//
//  Created by Harry Jones on 29/07/2014.
//  Copyright (c) 2014 FudBar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

@protocol ProductInfoEntryDelegate <NSObject>

@optional
- (void)productInfoEntryCompleteForObject:(PFObject*)object;

@end

@interface ProductDataEntryTableViewController : UITableViewController<UITextFieldDelegate>{
    NSMutableDictionary *textFields;
}

@property (nonatomic) PFObject *object;
@property (nonatomic) NSObject<ProductInfoEntryDelegate> *delegate;
@end
