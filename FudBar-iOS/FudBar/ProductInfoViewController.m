//
//  ProductInfoViewController.m
//  FudBar
//
//  Created by Harry Jones on 28/07/2014.
//  Copyright (c) 2014 FudBar. All rights reserved.
//

#import "ProductInfoViewController.h"
#import "UIView+AutoLayout.h"
#import "APIRequester.h"
#import "UIImage+resizeAndCrop.h"
#import "AppDelegate.h"

@interface ProductInfoViewController ()

@property (nonatomic) HKHealthStore *healthStore;
@property (nonatomic) NSMutableSet *savedObjects;

@end

@implementation ProductInfoViewController

#pragma mark - UIViewController Methods

- (instancetype)initWithStyle:(UITableViewStyle)style {
    self = [super initWithStyle:style];
    if (self) {
        _foodProduct = nil;
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated {
    self.healthStore = [(AppDelegate*)[[UIApplication sharedApplication] delegate] healthStore];
    
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self loadFoodProductForBarcode:_barcode];
    _savedObjects = [[NSMutableSet alloc] init];
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Data management

- (void)loadFoodProductForBarcode:(NSString*)barcode{
    
    if (_barcode.length >= 4 && [[_barcode substringToIndex:4] isEqualToString:@"noDB"]){
        [self showProductEntryViewControllerForBarcode:_barcode];
        return;
    }
    
    PFQuery *query =  [PFQuery queryWithClassName:@"FoodProduct"];
    [query whereKey:@"barCodeNumber" equalTo:barcode];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            // The find succeeded.
            NSLog(@"Query for barcode %@ returned %lu results.", barcode,(unsigned long)objects.count);
            // Do something with the found objects
            if ([objects count] > 0){
                PFObject *object = objects[0];
                [self updateTableWithFoodProduct:object];
            }else{
                if ([[NSUserDefaults standardUserDefaults] boolForKey:@"shouldUseNutritionix"]){
                    NSLog(@"Product not in Füdbar database with barcode \"%@\", will query Nutritionix...", barcode);
                    [self loadProductInfoFromNutritionxForBarcode:barcode];
                }else{
                    NSLog(@"Product not in Füdbar database with barcode \"%@\", will prompt for input...", barcode);
                    [self showProductEntryViewControllerForBarcode:barcode];
                }
            }
        } else {
            // Log details of the failure
            NSLog(@"Error loading food product w/ barcode %@: %@ %@", barcode, error, [error userInfo]);
        }
    }];
    
    
}

- (void)loadProductInfoFromNutritionxForBarcode:(NSString*)barcode{
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"https://api.nutritionix.com/v1_1/item?upc=%@&appId=%@&appKey=%@",barcode,NUTRITIONIX_APP_ID,NUTRITIONIX_APP_KEY]];
    [APIRequester requestJSONWithURL:url andHandler:^(id data) {
        if (!data || [data[@"status_code"] isEqualToNumber:@404] || ![data objectForKey:@"brand_name"]){
            NSLog(@"Product not in Nutritionix db either, will request user data entry...");
            dispatch_sync(dispatch_get_main_queue(), ^{
                [self showProductEntryViewControllerForBarcode:barcode];
            });
        }else{
            float m = [(NSNumber*)data[@"nf_servings_per_container"] floatValue];
            NSArray *values = @[@"brand_name",@"item_name",@"nf_calories",@"nf_total_fats",@"nf_total_carbohydrate",@"nf_saturated_fat",@"nf_sugars",@"nf_sodium"];
            for (id value in values){
                if (data[value] == nil || !data[value] || data[value] == [NSNull null]){
                    data[value] = @0;
                }
            }
            NSDictionary *mapping = @{
                                      @"productName":data[@"brand_name"],
                                      @"subtitle":data[@"item_name"],
                                      @"barCodeNumber":barcode,
                                      @"calories":@(m*[data[@"nf_calories"] floatValue]),
                                      @"fats":@(m*[data[@"nf_total_fats"] floatValue]),
                                      @"carbohydrates":@(m*[data[@"nf_total_carbohydrate"] floatValue]),
                                      @"saturates":@(m*[data[@"nf_saturated_fat"] floatValue]),
                                      @"sugars":@(m*[data[@"nf_sugars"] floatValue]),
                                      @"salt":@(m*[data[@"nf_sodium"] floatValue])
                                      };
            NSLog(@"Mapping: %@",[mapping description]);
            PFObject *object = [PFObject objectWithClassName:@"FoodProduct" dictionary:mapping];
            [object saveInBackground];
            dispatch_sync(dispatch_get_main_queue(), ^{
                [self updateTableWithFoodProduct:object];
            });
        }
    }];
}

- (void)showProductEntryViewControllerForBarcode:(NSString*)barcode{
    ProductDataEntryTableViewController *pDEVC = [self.storyboard instantiateViewControllerWithIdentifier:@"ProductDataEntryTableViewController"];
    pDEVC.object = [PFObject objectWithClassName:@"FoodProduct"];
    [pDEVC.object setObject:barcode forKey:@"barCodeNumber"];
    pDEVC.delegate = self;
    [self.navigationController pushViewController:pDEVC animated:YES];
}

- (void)updateTableWithFoodProduct: (PFObject*) object{
    _foodProduct = object;
    PFFile *imageFile = _foodProduct[@"image"];
    [imageFile getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
        NSLog(@"Got image data");
        productImage = [UIImage imageWithData:data];
        [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:2]] withRowAnimation:UITableViewRowAnimationAutomatic];
    }];
    [[self tableView] reloadData];
    
}


#pragma mark - Alert methods

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex{
    if (alertView.tag == 1) { // If it is "no product identified"
        [self dismiss];
    }else{
        
    }
}

- (void)dismiss {
    if (self.navigationController) {
        if ([self.navigationController.viewControllers lastObject] == self) {
            [self.navigationController popViewControllerAnimated:YES];
        }
    }
    else if (self.presentingViewController) {
        [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
    }
}


#pragma mark - Table view data sonurce

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return !_foodProduct ? 0 : 4;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSArray *keys;
    switch (section) {
        case 0:
            keys = @[@"productName",@"subtitle"];
            break;
        case 1:
            keys = @[@"calories",@"carbohydrates",@"fats",@"saturates",@"sugars",@"salt"];
            break;
        case 2:
            keys = @[@"image"];
            break;
        case 3:
            return [self object:_foodProduct doesHaveDataForKey:@"calories"] ? 3 : 0;
            break;
    }
    return [self numberOfValidKeysFromArray:keys forObject:_foodProduct];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell;
    
    NSInteger section = indexPath.section;
    NSInteger row = indexPath.row;
    
    switch (section) {
        case 0: { // Title section
            if (row == 0)      cell = [tableView dequeueReusableCellWithIdentifier:@"title" forIndexPath:indexPath];
            else if (row == 1) cell = [tableView dequeueReusableCellWithIdentifier:@"subtitle" forIndexPath:indexPath];
            
            UILabel *label = (UILabel*)[cell viewWithTag:1];
            
            if (indexPath.row == 0)      [label setText:_foodProduct[@"productName"]];
            else if (indexPath.row == 1) [label setText:_foodProduct[@"subtitle"]];
            
            break;
        }
            
        case 1: { // Nutrition Info
            
            NSArray *fields = @[@"calories",@"carbohydrates",@"fats",@"saturates",@"sugars",@"salt"];
            NSArray *units = @[@"kcal",@"g",@"g",@"g",@"g",@"g"];
            
            for (int i = 0; i <= row; i++){
                if (![self object:_foodProduct doesHaveDataForKey:fields[i]]){
                    row++;
                }
            }
            
            NSString *fieldName = [fields objectAtIndex:row];
            NSNumber *rawNumber = _foodProduct[fieldName];
            
            if (rawNumber == nil){
                rawNumber = @0;
            }
            cell = [tableView dequeueReusableCellWithIdentifier:@"rightDetail" forIndexPath:indexPath];
            
            
            NSNumberFormatter *fmt = [[NSNumberFormatter alloc] init];
            [fmt setPositiveFormat:@"0.##"];
            
            NSString *value = [NSString stringWithFormat:@"%@%@",[fmt stringFromNumber:rawNumber],units[row]];
            NSString *title = [fieldName capitalizedString];
            
            [[cell textLabel] setText:title];
            [[cell detailTextLabel] setText:value];
            
            break;
        }
            
        case 2: {
            cell = [tableView dequeueReusableCellWithIdentifier:@"image" forIndexPath:indexPath];
            UIImageView *imageView = (UIImageView*)[cell viewWithTag:2];
            
            [imageView setImage:productImage];
            [imageView sizeToFit];
            break;
        }
        case 3: { // Running distance
            
            NSString *reuseID = @[@"loggingCell",@"runningCell",@"altCell"][row];
            cell = [tableView dequeueReusableCellWithIdentifier:reuseID forIndexPath:indexPath];
            
            if (row < 2){
                UIImageView *iconView = (UIImageView*)[cell viewWithTag:101];
                UILabel *largeTextLabel = (UILabel*)[cell viewWithTag:102];
                
                iconView.image = [iconView.image rasterizedImageWithTintColor:[UIColor redColor]];
                
                NSString *primaryString;
                NSString *secondaryString;
                
                if (row == 0){
                    primaryString = [(NSNumber*)_foodProduct[@"calories"] stringValue];
                    secondaryString = @"kcal";
                } else if (row == 1){
                    float distanceToBurnOff = [(NSNumber*)_foodProduct[@"calories"] floatValue] / 81.0;
                    primaryString = [NSString stringWithFormat:@"%.1f", distanceToBurnOff];
                    secondaryString = @"km";
                }
                NSMutableAttributedString *distanceText = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@%@",primaryString,secondaryString]];
                
                [distanceText addAttributes:@{NSFontAttributeName: [UIFont fontWithName:@"HelveticaNeue" size:65]}
                                      range:NSMakeRange(0, primaryString.length)];
                [distanceText addAttributes:@{NSFontAttributeName: [UIFont fontWithName:@"HelveticaNeue" size:17]}
                                      range:NSMakeRange(primaryString.length, secondaryString.length)];
                [largeTextLabel setAttributedText:distanceText];
                
                if (row == 0){
                    ToggleButton *button = (ToggleButton*)[cell viewWithTag:107];
                    button.delegate = self;
                    button.tintColor = [UIColor whiteColor];
                    button.layer.cornerRadius = 30;
                    button.layer.masksToBounds = YES;
                    
                    [button setColor:self.view.tintColor forState:UIControlStateNormal];
                    [button setColor:[UIColor greenColor] forState:UIControlStateSelected];
                    
                    UIImage *plus = [[UIImage imageNamed:@"plus"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
                    [button setImage:plus forState:UIControlStateNormal];
                    
                    UIImage *tick = [[UIImage imageNamed:@"tick"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
                    [button setImage:tick forState:UIControlStateSelected];
                    
                    //                [button addTarget:self action:@selector(toggleStoringCalories) forControlEvents:UIControlEventTouchDown];
                }
            }else if (row == 2){
                UILabel *textLabel = (UILabel*)[cell viewWithTag:112];
                NSLog(@"Setting up alternate food cell");
                NSString *text = @"If you ate a Carrots and Hummus instead you would save 327kcal (thats 1.4km of running!)";
                [textLabel setText:text];
            }
            
        }
        default:
            break;
    }
    
    
    // Configure the cell...
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    switch (section) {
        case 1: // If not available, do not display...
            return @"Nutritional Information";
            
        case 2:
            return @"Image";
            
        default:
            return nil;
    }
}


#pragma mark - Other methods

- (void)toggleButtonPressed: (UIButton*)button {
    if (button.selected){
        [self saveFoodDataToHealthKit];
    }else{
        [self removeFoodDataFromHealthKit];
    }
}

- (void)saveFoodDataToHealthKit {
    NSDate *now = [NSDate date];
    NSDictionary *metadata = @{ HKMetadataKeyFoodType:_foodProduct[@"productName"] };
    
    
    HKQuantityType *quantityType = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierDietaryEnergyConsumed];
    HKQuantity *quantity = [HKQuantity quantityWithUnit:[HKUnit calorieUnit] doubleValue:[_foodProduct[@"calories"] floatValue]*1000];
    HKQuantitySample *calorieSample = [HKQuantitySample quantitySampleWithType:quantityType quantity:quantity startDate:now endDate:now metadata:metadata];
    
    [self.healthStore saveObject:calorieSample withCompletion:^(BOOL success, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (success) {
                NSLog(@"Stored food object ot HealthKit!");
                [self.savedObjects addObject:calorieSample];
            }
            else {
                NSLog(@"An error occured saving the food %@. In your app, try to handle this gracefully. The error was: %@.", _foodProduct[@"productName"], error);
            }
        });
    }];
}

- (void)removeFoodDataFromHealthKit{
    for (HKObject* object in self.savedObjects){
        if (object != nil){
            [self.healthStore deleteObject:object withCompletion:^(BOOL success, NSError *error) {
                NSLog(@"Removed HKObject %@ from HealthKit.", object.UUID);
            }];
        }else{
            NSLog(@"Didn't remove nil object from HealthKit.");
        }
    }
}

- (void)productInfoEntryCompleteForObject:(PFObject *)object {
    NSLog(@"Updating product info");
    _foodProduct = object;
    [self updateTableWithFoodProduct:object];
}

#pragma mark - Helper methods

- (NSInteger)numberOfValidKeysFromArray:(NSArray*)array forObject:(PFObject*)object{
    NSInteger validKeys = 0;
    for (NSString* key in array){
        if ([self object:object doesHaveDataForKey:key]) validKeys++;
    }
    return validKeys;
}

- (BOOL)object:(PFObject*)object doesHaveDataForKey:(NSString*)key{
    id data = object[key];
    
    if (data == nil) return NO;
    if (data == [NSNull null]) return NO;
    if ([[data class] isSubclassOfClass:[NSString class]] && [(NSString*)data length] == 0) return NO;
    
    return YES;
}

@end
