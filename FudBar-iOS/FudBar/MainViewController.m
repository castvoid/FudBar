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
    scannerState = kReadyToScan;
    
    UIImage *image = [[UIImage imageNamed:@"Barcode"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [_scanButton setImage:image forState:UIControlStateNormal];
    [_scanButton setTitleColor:_scanButton.tintColor forState:UIControlStateNormal];
    
    CGFloat spacing = 6.0;
    CGSize imageSize = _scanButton.imageView.frame.size;
    _scanButton.titleEdgeInsets = UIEdgeInsetsMake(
                                              0.0, - imageSize.width, - (imageSize.height + spacing), 0.0);
    
    // raise the image and push it right so it appears centered
    //  above the text
    CGSize titleSize = _scanButton.titleLabel.frame.size;
    _scanButton.imageEdgeInsets = UIEdgeInsetsMake(
                                              - (titleSize.height + spacing), 0.0, 0.0, - titleSize.width);
}

- (void)viewWillAppear:(BOOL)animated{
    
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
                [self detectedBarCode:barCode];
            }];
        }
    }
}

- (void)detectedBarCode:(NSString*)barCode{
    _barcodeLabel.text = _currentBarCode;
    scannerState = kReadyToScan;
    [self showProductInfoForBarcode:barCode];
}

- (IBAction)scanButtonPressed:(id)sender {
    HHBarCodeViewController *hhbvc = [HHBarCodeViewController new];
    hhbvc.delegate = self;
    
    
    [self presentViewController:hhbvc animated:YES completion:^{
        //code
    }];
}

- (IBAction)testBarCodeButtonPressed:(id)sender {
    [self detectedBarCode:@"0012345678905"];
}

- (void)showProductInfoForBarcode:(NSString*)barcode{
    ProductInfoViewController *pIVC = [[self storyboard] instantiateViewControllerWithIdentifier:@"productInfoViewController"];
    pIVC.barcode = barcode;
    [self presentViewController:pIVC animated:YES completion:^{
        NSLog(@"Presenting product info for barcode %@",barcode);
    }];
}
@end