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

    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    textFields = [[NSMutableDictionary alloc] init];
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewWillDisappear:(BOOL)animated{
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

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    NSLog(@"Range: %@ -> '%@'",NSStringFromRange(range),string);
    return YES;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section>2) return 0;
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
    UILabel *textLabel = (UILabel*)[cell viewWithTag:1];
    if (section == 0 || section == 1){

        UITextField *textField = (UITextField*)[cell viewWithTag:3];
        textField.delegate = self;
        [textFields setObject:textField forKey:fields[section][row] ];
    
        if (section == 0){
            if (row == 0) [textLabel setText:@"Product Name"];
            else if (row == 1) [textLabel setText:@"Details"];
        }else if (section == 1){
            [textLabel setText: [(NSString*)fields[section][row] capitalizedString] ];
//            [textLabel sizeToFit];
            [textField setPlaceholder:@"0"];
            [textField setText:@""];
            [textField setKeyboardType:UIKeyboardTypeDecimalPad];
        }
    
//        textField.backgroundColor = [UIColor redColor];
//        textLabel.backgroundColor = [UIColor greenColor];
//        [textField setPlaceholder:@"Enter value"];
//        [textField setTextAlignment:NSTextAlignmentRight];
//        [textField setKeyboardType:UIKeyboardTypeAlphabet];
//        [textField setBorderStyle:UITextBorderStyleNone];
//        [cell.contentView addSubview:textField];
//        [textField pinEdges:JRTViewPinBottomEdge | JRTViewPinRightEdge | JRTViewPinTopEdge toSameEdgesOfView:[textField superview]];
//        [textField pinAttribute:NSLayoutAttributeLeft toAttribute:NSLayoutAttributeRight ofItem:cell.textLabel];
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 45;
}

- (void)textFieldDidEndEditing:(UITextField *)textField{
    NSArray *allKeys = [textFields allKeysForObject:textField];
    NSString *key = (NSString*)allKeys[0];
    NSLog(@"Finished editing key \"%@\".",key);
    
    if ([key isEqualToString:@"productName"] || [key isEqualToString:@"subtitle"]){
        if (textField.text.length == 0) [_object setObject:@"Untitled" forKey:key];
        else [_object setObject:textField.text forKey:key];
    }else{
        NSNumberFormatter *f = [[NSNumberFormatter alloc] init];
        [f setNumberStyle:NSNumberFormatterDecimalStyle];
        NSNumber *value = [f numberFromString:textField.text];
        if (value == nil) [_object setObject:[NSNull null] forKey:key];
        else [_object setObject:value forKey:key];
    }
    
    
}
@end
