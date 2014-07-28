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

- (instancetype)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        _foodProduct = nil;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self loadFoodProductForBarcode:_barcode];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Data management

- (void)loadFoodProductForBarcode:(NSString*)barcode{
    PFQuery *query = [PFQuery queryWithClassName:@"FoodProduct"];
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
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"No product identified" message:@"Try something else" delegate:self cancelButtonTitle:@"Okay" otherButtonTitles: nil];
                alert.tag = 1;
                [alert show];
            }
        } else {
            // Log details of the failure
            NSLog(@"Error loading food product w/ barcode %@: %@ %@", barcode, error, [error userInfo]);
        }
    }];
    
    
}

- (void)updateTableWithFoodProduct: (PFObject*) object{
    _foodProduct = object;
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

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return !_foodProduct ? 0 : 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    int ret[] = {2,6,1};
    return ret[section];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
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
            
            if (_foodProduct[fieldName] != nil){
                cell = [tableView dequeueReusableCellWithIdentifier:@"rightDetail" forIndexPath:indexPath];
                

                NSString *value = [NSString stringWithFormat:@"%@%@",_foodProduct[fieldName],units[row]];
                NSString *title = [fieldName capitalizedString];
                
                [[cell textLabel] setText:title];
                [[cell detailTextLabel] setText:value];
            }
            break;
        }
            
        case 2: {
            cell = [tableView dequeueReusableCellWithIdentifier:@"image" forIndexPath:indexPath];
            UIImage *image = (UIImage*)[cell viewWithTag:2];
            
            
            
            break;
        }
            
        default:
            break;
    }
    
    
    // Configure the cell...
    
    return cell;
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
