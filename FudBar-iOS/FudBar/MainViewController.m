//
//  ViewController.m
//  FudBar
//
//  Created by Harry Jones on 28/07/2014.
//  Copyright (c) 2014 FudBar. All rights reserved.
//

#import "MainViewController.h"
#import "ProductInfoViewController.h"
#import "AppDelegate.h"

@import HealthKit;

@interface MainViewController ()
@property (nonatomic) HKHealthStore *healthStore;
@end

@implementation MainViewController

#pragma mark - UIViewController methods

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
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillEnterForeground:) name:UIApplicationWillEnterForegroundNotification object:nil];
    
    scannerState = kReadyToScan;
    
    [_manualBarcodeEntryField setDelegate:self];
    
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
    [self.navigationController setNavigationBarHidden:YES animated:animated];
    [super viewWillAppear:animated];
    
    self.healthStore = [(AppDelegate*)[[UIApplication sharedApplication] delegate] healthStore];
    _calorieDisplayView.text = @"?kcal";
    
    // Set up an HKHealthStore, asking the user for read/write permissions. The profile view controller is the
    // first view controller that's shown to the user, so we'll ask for all of the desired HealthKit permissions now.
    // In your own app, you should consider requesting permissions the first time a user wants to interact with
    // HealthKit data.
    if ([HKHealthStore isHealthDataAvailable]) {
        NSSet *writeDataTypes = [self dataTypesToWrite];
        NSSet *readDataTypes = [self dataTypesToRead];
        
        [self.healthStore requestAuthorizationToShareTypes:writeDataTypes readTypes:readDataTypes completion:^(BOOL success, NSError *error) {
            if (!success) {
                NSLog(@"You didn't allow HealthKit to access these read/write data types. In your app, try to handle this error gracefully when a user decides not to provide access. The error was: %@. If you're using a simulator, try it on a device.", error);
                return;
            }
            
//            dispatch_async(dispatch_get_main_queue(), ^{
//                // Update the user interface based on the current user's health information.
//                [self updateUsersAge];
//                [self updateUsersHeight];
//                [self updateUsersWeight];
//            });
            
            [self updateCalorieCount];
        }];
    }
    
    

}

- (void)viewWillDisappear:(BOOL)animated {
    [self.navigationController setNavigationBarHidden:NO animated:animated];
    [super viewWillDisappear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)applicationWillEnterForeground:(NSNotification *)notification{
    [self updateCalorieCount];
}


#pragma mark - UIView methods

- (void)updateCalorieCount{
    [self fetchTotalJoulesConsumedWithCompletionHandler:^(double totalJoulesConsumed, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            double kCalories = (totalJoulesConsumed * 0.239005736) / 1000;
            self.calorieDisplayView.text = [NSString stringWithFormat:@"%.0fkcal",kCalories];
        });
    }];
}

- (IBAction)scanButtonPressed:(id)sender {
    // Setup scan view
    HHBarCodeViewController *hhbvc = [HHBarCodeViewController new];
    hhbvc.delegate = self;
    [self.navigationController presentViewController:hhbvc animated:YES completion:nil];
}

- (IBAction)testBarCodeButtonPressed:(id)sender {
    _barcodeLabel.text = _currentBarCode;
    scannerState = kReadyToScan;
    [self showProductInfoForBarcode:@"50054039" animated:YES];
}


#pragma mark - Barcode methods

- (void) barCodeViewController:(UIViewController *)barCodeViewController didDetectBarCode:(NSString *)barCode {
    if (scannerState != kScanComplete){
        scannerState = kScanComplete;
        _currentBarCode = barCode;
        NSLog(@"Detected barcode: %@", barCode);

        _barcodeLabel.text = _currentBarCode;
        
        [self showProductInfoForBarcode:barCode animated:NO];
        [self.navigationController dismissViewControllerAnimated:YES completion:^{
            scannerState = kReadyToScan;
        }];
    }
}

- (void)showProductInfoForBarcode:(NSString*)barcode animated:(BOOL)animated {
    ProductInfoViewController *pIVC = [[self storyboard] instantiateViewControllerWithIdentifier:@"productInfoViewController"];
    pIVC.barcode = barcode;
    
    NSLog(@"Presenting product info for barcode %@",barcode);
    
    [self.navigationController pushViewController:pIVC animated:animated];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    NSLog(@"Pressed enter... Running query for barcode");
    
    [textField resignFirstResponder];
    [self showProductInfoForBarcode:textField.text animated:YES];
    
    return YES;
}


#pragma mark - Healthkit helpers

- (NSSet *)dataTypesToWrite {
    HKQuantityType *dietaryCalorieEnergyType = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierDietaryEnergyConsumed];
//    HKQuantityType *heightType = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierHeight];
//    HKQuantityType *weightType = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierBodyMass];
    
    return [NSSet setWithObjects:dietaryCalorieEnergyType, nil];
}

- (NSSet *)dataTypesToRead {
    HKQuantityType *dietaryCalorieEnergyType = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierDietaryEnergyConsumed];
//    HKQuantityType *activeEnergyBurnType = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierActiveEnergyBurned];
//    HKQuantityType *heightType = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierHeight];
//    HKQuantityType *weightType = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierBodyMass];
//    HKCharacteristicType *birthdayType = [HKCharacteristicType characteristicTypeForIdentifier:HKCharacteristicTypeIdentifierDateOfBirth];
    
    return [NSSet setWithObjects:dietaryCalorieEnergyType, nil];
}

- (void)fetchTotalJoulesConsumedWithCompletionHandler:(void (^)(double, NSError *))completionHandler {
    NSCalendar *calendar = [NSCalendar currentCalendar];
    
    NSDate *now = [NSDate date];
    
    NSDateComponents *components = [calendar components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay fromDate:now];
    
    NSDate *startDate = [calendar dateFromComponents:components];
    
    NSDate *endDate = [calendar dateByAddingUnit:NSCalendarUnitDay value:1 toDate:startDate options:0];
    
    HKQuantityType *sampleType = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierDietaryEnergyConsumed];
    NSPredicate *predicate = [HKQuery predicateForSamplesWithStartDate:startDate endDate:endDate options:HKQueryOptionStrictStartDate];
    
    HKStatisticsQuery *query = [[HKStatisticsQuery alloc] initWithQuantityType:sampleType quantitySamplePredicate:predicate options:HKStatisticsOptionCumulativeSum completionHandler:^(HKStatisticsQuery *query, HKStatistics *result, NSError *error) {
        if (!result) {
            if (completionHandler) {
                completionHandler(0.0f, error);
            }
            return;
        }
        
        double totalCalories = [result.sumQuantity doubleValueForUnit:[HKUnit jouleUnit]];
        if (completionHandler) {
            completionHandler(totalCalories, error);
        }
    }];
    
    [self.healthStore executeQuery:query];
}

@end
