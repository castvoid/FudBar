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

@interface ProductInfoViewController ()

@end

@implementation ProductInfoViewController

- (instancetype)initWithStyle:(UITableViewStyle)style {
    self = [super initWithStyle:style];
    if (self) {
        _foodProduct = nil;
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated {
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self loadFoodProductForBarcode:_barcode];
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
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"https://api.nutritionix.com/v1_1/item?upc=%@&appId=***REMOVED***&appKey=***REMOVED***",barcode]];
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

#pragma mark - VC handling

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex{
    if (alertView.tag == 1) { // If it is "no product identified"
        [self dismiss];
    }else{
        
    }
}

- (void) dismiss {
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
            keys = @[@"calories"];
            break;
    }
    return [self numberOfValidKeysFromArray:keys forObject:_foodProduct];
}

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
            cell = [tableView dequeueReusableCellWithIdentifier:@"runningCell" forIndexPath:indexPath];
            UIImageView *runnerView = (UIImageView*)[cell viewWithTag:101];
            UILabel *distanceLabel = (UILabel*)[cell viewWithTag:102];
            
            runnerView.image = [runnerView.image rasterizedImageWithTintColor:runnerView.tintColor];
            
            float distanceToBurnOff = [(NSNumber*)_foodProduct[@"calories"] floatValue] / 81.0;
            NSMutableAttributedString *distanceText = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%.1fkm",distanceToBurnOff]];
            [distanceText addAttributes:@{NSFontAttributeName: [UIFont fontWithName:@"HelveticaNeue" size:65]} range:NSMakeRange(0, distanceText.length - 2)];
            [distanceText addAttributes:@{NSFontAttributeName: [UIFont fontWithName:@"HelveticaNeue" size:17]} range:NSMakeRange(distanceText.length - 2, 2)];
            [distanceLabel setAttributedText:distanceText];
            
            UILabel *realDistance = (UILabel*)[cell viewWithTag:103];;
            [realDistance setText:@""];
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

- (void)productInfoEntryCompleteForObject:(PFObject *)object{
    NSLog(@"Updating product info");
    _foodProduct = object;
    [self updateTableWithFoodProduct:object];
}

@end
