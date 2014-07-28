//
//  ProductInfoViewController.h
//  FudBar
//
//  Created by Harry Jones on 28/07/2014.
//  Copyright (c) 2014 FudBar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

@interface ProductInfoViewController : UITableViewController <UIAlertViewDelegate>

@property (nonatomic) NSString* barcode;
@property (nonatomic) PFObject *foodProduct;

@end
