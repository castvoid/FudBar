//
//  ViewController.m
//  FudBar
//
//  Created by Harry Jones on 28/07/2014.
//  Copyright (c) 2014 FudBar. All rights reserved.
//

#import "MainViewController.h"
#import "ProductInfoViewController.h"

@interface MainViewController ()


@end

@implementation MainViewController

- (instancetype)init{
    self = [super init];
    if (self){
        _currentBarCode = [[NSString alloc] init];
        scannerState = kNotReadyToScan;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    scannerState = kReadyToScan;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void) barCodeViewController:(UIViewController *)barCodeViewController didDetectBarCode:(NSString *)barCode {
    if (scannerState != kScanComplete){
        scannerState = kScanComplete;
        _currentBarCode = barCode;
        NSLog(@"Detected barcode: %@", barCode);
        if (![self.presentedViewController isBeingDismissed]){
            [self dismissViewControllerAnimated:YES completion:^{
                _barcodeLabel.text = _currentBarCode;
                scannerState = kReadyToScan;
                [self showProductInfoForBarcode:barCode];
            }];
        }
    }
}

- (IBAction)scanButtonPressed:(id)sender {
    HHBarCodeViewController *hhbvc = [HHBarCodeViewController new];
    hhbvc.delegate = self;
    
    
    [self presentViewController:hhbvc animated:YES completion:^{
        //code
    }];
}

- (void)showProductInfoForBarcode:(NSString*)barcode{
    ProductInfoViewController *pIVC = [[self storyboard] instantiateViewControllerWithIdentifier:@"productInfoViewController"];
    pIVC.barcode = barcode;
    [self presentViewController:pIVC animated:YES completion:^{
        NSLog(@"Presenting product info for barcode %@",barcode);
    }];
}
@end
