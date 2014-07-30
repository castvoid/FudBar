//
//  ProductDataEntryTableViewController.m
//  FudBar
//
//  Created by Harry Jones on 29/07/2014.
//  Copyright (c) 2014 FudBar. All rights reserved.
//

#import "ProductDataEntryTableViewController.h"
#import "UIView+AutoLayout.h"
#import "UIImage+resizeAndCrop.h"

@interface ProductDataEntryTableViewController ()
@property  UIImageView* imagePreviewView;
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
    if ( !( ((NSString*)_object[@"barcode"]).length >= 4 && [[_object[@"barcode"] substringToIndex:4] isEqualToString:@"noDB"] )  ){
        NSLog(@"Saving object to DB...");
        [_object saveInBackground];
    }
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
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
//    if (section>2) return 0;
    NSInteger rets[] = {2,6,1};
    return rets[section];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger section = indexPath.section;
    NSInteger row = indexPath.row;

    NSString *reuseID;
    if (section == 0 || section == 1){
        reuseID = @"fieldCell";
    }else if (section == 2){
        reuseID = @"imageCell";
    }
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseID forIndexPath:indexPath];
    
    
    if (section < 2){
    NSArray *fields = @[
                        @[@"productName",@"subtitle"],
                        @[@"calories",@"carbohydrates",@"fats",@"saturates",@"sugars",@"salt"]
                        ];
    UILabel *textLabel = (UILabel*)[cell viewWithTag:1];

        UITextField *textField = (UITextField*)[cell viewWithTag:3];
        textField.delegate = self;
        [textFields setObject:textField forKey:fields[section][row] ];
    
        if (section == 0){
            if (row == 0) [textLabel setText:@"Product Name"];
            else if (row == 1) [textLabel setText:@"Details"];
            [textField setPlaceholder:@""];
        }else if (section == 1){
            NSString *unit = !row ? @"kcals" : @"grams";
            NSMutableAttributedString *labelText = [[NSMutableAttributedString alloc] initWithString:[(NSString*)fields[section][row] capitalizedString]];
            [labelText appendAttributedString:
             [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@" (%@)",unit]
                                             attributes:@{
                                                          NSForegroundColorAttributeName:[UIColor grayColor]
                                                          }
              ]
             ];
            
            [textLabel setAttributedText:labelText];
            [textField setPlaceholder:@"0"];
            [textField setKeyboardType:UIKeyboardTypeDecimalPad];
        }
    }else if (section == 2){
        UIImageView *imageView = (UIImageView*)[cell viewWithTag:5];
        self.imagePreviewView = imageView;
        UIButton *button = (UIButton*)[cell viewWithTag:6];
        button.clipsToBounds = YES;
        button.layer.cornerRadius = button.frame.size.width / 2;
    }
    
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return indexPath.section < 2 ? 45 : 150;
}

#pragma mark - Other methods

- (IBAction)takePhotoButtonPressed:(id)sender {
    UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
    
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        [imagePickerController setSourceType:UIImagePickerControllerSourceTypeCamera];
    }
    
    // image picker needs a delegate,
    [imagePickerController setDelegate:self];
    
    // Place image picker on the screen
    [self presentViewController:imagePickerController animated:YES completion:^{}];
}


- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    // Access the uncropped image from info dictionary
    UIImage *image = [info objectForKey:@"UIImagePickerControllerOriginalImage"];
    
    // Dismiss controller
    [picker dismissViewControllerAnimated:YES completion:^{}];
    
    UIImage *smallImage = [self imageWithImage:image scaledToWidth:640];
    UIImage *newImage = [smallImage imageByCroppingToSize:CGSizeMake(640, 300)];
    
    
    [self.imagePreviewView setImage:newImage];
    
    NSLog(@"Full image: %@\nSmall: %@\nNew: %@",NSStringFromCGSize(image.size), NSStringFromCGSize(smallImage.size), NSStringFromCGSize(newImage.size));
    
    // Upload image
    NSData *imageData = UIImageJPEGRepresentation(newImage, 0.5f);
    

    PFFile *imageFile = [PFFile fileWithName:@"image.jpg" data:imageData];
    
    [imageFile saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (succeeded && !error){
            [self.object setObject:imageFile forKey:@"image"];
            [self.object saveInBackground];
        }
        NSLog(@"Saved image");
    }];
    
}

-(UIImage*)imageWithImage: (UIImage*) sourceImage scaledToWidth: (float) i_width
{
    float oldWidth = sourceImage.size.width;
    float scaleFactor = i_width / oldWidth;
    
    float newHeight = sourceImage.size.height * scaleFactor;
    float newWidth = oldWidth * scaleFactor;
    
    UIGraphicsBeginImageContext(CGSizeMake(newWidth, newHeight));
    [sourceImage drawInRect:CGRectMake(0, 0, newWidth, newHeight)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
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
