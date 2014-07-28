//
//  ViewController.h
//  FudBar
//
//  Created by Harry Jones on 28/07/2014.
//  Copyright (c) 2014 FudBar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HHBarCodeViewController.h"

typedef enum {
    kNotReadyToScan,
    kReadyToScan,
    kScanComplete
} ScannerState;

@interface MainViewController : UIViewController<HHBarCodeViewControllerDelegate>{
    ScannerState scannerState;
}

@property (nonatomic) NSString *currentBarCode;

- (IBAction)scanButtonPressed:(id)sender;

@property (weak, nonatomic) IBOutlet UILabel *barcodeLabel;

@end

