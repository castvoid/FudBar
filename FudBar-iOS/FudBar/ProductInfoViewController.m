//
//  ProductInfoViewController.m
//  FudBar
//
//  Created by Harry Jones on 28/07/2014.
//  Copyright (c) 2014 FudBar. All rights reserved.
//

#import "ProductInfoViewController.h"

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
                NSLog(@"No product found in database for barcode %@", barcode);
                
            }
        } else {
            // Log details of the failure
            NSLog(@"Error loading food product w/ barcode %@: %@ %@", barcode, error, [error userInfo]);
        }
    }];
    
    
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
    return !_foodProduct ? 0 : 3;
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
    if ([[data class] isSubclassOfClass:[NSString class]] && [(NSString*)data length] == 0) return NO;
    
    return YES;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell;
    
    NSInteger section = indexPath.section;
    NSInteger row = indexPath.row;
    
    switch (section) {
        case 0: {
            if (row == 0)      cell = [tableView dequeueReusableCellWithIdentifier:@"title" forIndexPath:indexPath];
            else if (row == 1) cell = [tableView dequeueReusableCellWithIdentifier:@"subtitle" forIndexPath:indexPath];
            
            UILabel *label = (UILabel*)[cell viewWithTag:1];
            
            if (indexPath.row == 0)      [label setText:_foodProduct[@"productName"]];
            else if (indexPath.row == 1) [label setText:_foodProduct[@"subtitle"]];
            
            break;
        }
            
        case 1: {
            
            NSArray *fields = @[@"calories",@"carbohydrates",@"fats",@"saturates",@"sugars",@"salt"];
            NSArray *units = @[@"kcal",@"g",@"g",@"g",@"g",@"g"];
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
//            NSLog(@"Getting image...");
//            
//            cell = [tableView dequeueReusableCellWithIdentifier:@"image" forIndexPath:indexPath];
//            PFImageView *imageView = (PFImageView*)[cell viewWithTag:2];
//            
//            PFFile *imageFile = _foodProduct[@"image"];
//            
//            [imageView setFile:imageFile];
//            [imageView loadInBackground:^(UIImage *image, NSError *error) {
//                //[tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
//            }];
//            NSLog(@"Cell size: (%fx%f) / Image size: (%fx%f)",cell.frame.size.width,cell.frame.size.height,imageView.frame.size.width,imageView.frame.size.height);
//            [imageView sizeToFit];
//            break;
            cell = [tableView dequeueReusableCellWithIdentifier:@"image" forIndexPath:indexPath];
            UIImageView *imageView = (UIImageView*)[cell viewWithTag:2];
            
            [imageView setImage:productImage];
            [imageView sizeToFit];
            break;
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

/*
 // Override to support conditional editing of the table view.
 - (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
 {
 // Return NO if you do not want the specified item to be editable.
 return YES;
 }
 */

/*
 // Override to support editing the table view.
 - (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
 {
 if (editingStyle == UITableViewCellEditingStyleDelete) {
 // Delete the row from the data source
 [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
 } else if (editingStyle == UITableViewCellEditingStyleInsert) {
 // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
 }
 }
 */

/*
 // Override to support rearranging the table view.
 - (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
 {
 }
 */

/*
 // Override to support conditional rearranging of the table view.
 - (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
 {
 // Return NO if you do not want the item to be re-orderable.
 return YES;
 }
 */

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
 {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end
