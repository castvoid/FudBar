//
//  ProductDataEntryTableViewController.m
//  FudBar
//
//  Created by Harry Jones on 29/07/2014.
//  Copyright (c) 2014 FudBar. All rights reserved.
//

#import "ProductDataEntryTableViewController.h"
#import "UIView+AutoLayout.h"

@interface ProductDataEntryTableViewController ()

@end

@implementation ProductDataEntryTableViewController

- (instancetype)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        textFields = [[NSMutableDictionary alloc] init];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"fieldCell"];
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewDidDisappear:(BOOL)animated{
    [_object saveInBackground];
    if ([_delegate respondsToSelector:@selector(productInfoEntryCompleteForObject:)]){
        [_delegate productInfoEntryCompleteForObject:_object];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section>3) return 0;
    NSInteger rets[] = {2,6,1};
    return rets[section];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger section = indexPath.section;
    NSInteger row = indexPath.row;

    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"fieldCell" forIndexPath:indexPath];
    
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    NSArray *fields = @[
                        @[@"productName",@"subtitle"],
                        @[@"calories",@"carbohydrates",@"fats",@"saturates",@"sugars",@"salt"]
                        ];
    if (section == 0 || section == 1){
        

        if (section == 0){
            if (row == 0) [cell.textLabel setText:@"Product Name"];
            else if (row == 1) [cell.textLabel setText:@"Details"];
        }else if (section == 1){
            [cell.textLabel setText: [(NSString*)fields[section][row] capitalizedString] ];
        }
        
        UITextField *textField = [[UITextField alloc] initWithFrame:CGRectMake(cell.frame.size.width - 100, 0, 100, cell.frame.size.height)];
        textField.delegate = self;
        [textFields setObject:textField forKey:fields[section][row] ];
        [textField setPlaceholder:@"Enter value"];
        [textField setTextAlignment:NSTextAlignmentRight];
        [textField setKeyboardType:UIKeyboardTypeAlphabet];
        [textField setBorderStyle:UITextBorderStyleNone];
        [cell.contentView addSubview:textField];
//        [textField pinEdges:JRTViewPinBottomEdge | JRTViewPinRightEdge | JRTViewPinTopEdge toSameEdgesOfView:[textField superview]];
//        [textField pinAttribute:NSLayoutAttributeLeft toAttribute:NSLayoutAttributeRight ofItem:cell.textLabel];
    }
    
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

- (void)textFieldDidEndEditing:(UITextField *)textField{
    NSString *key = (NSString*)[textFields allKeysForObject:textField][0];
    NSLog(@"Finished editing key \"%@\".",key);
    
    if ([key isEqualToString:@"productName"] || [key isEqualToString:@"subtitle"]){
        [_object setObject:textField.text forKey:key];
    }else{
        NSNumberFormatter *f = [[NSNumberFormatter alloc] init];
        [f setNumberStyle:NSNumberFormatterDecimalStyle];
        NSNumber *value = [f numberFromString:textField.text];
        [_object setObject:value forKey:key];
    }
    
    
}
@end
