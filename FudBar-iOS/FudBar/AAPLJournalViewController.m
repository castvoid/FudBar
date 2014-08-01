/*
    Copyright (C) 2014 Apple Inc. All Rights Reserved.
    See LICENSE.txt for this sample’s licensing information
    
    Abstract:
    
                Displays information retrieved from HealthKit about the food items consumed today.
            
*/

#import "AAPLJournalViewController.h"
#import "AAPLFoodItem.h"
#import "AppDelegate.h"

@import HealthKit;

NSString *const AAPLJournalViewControllerTableViewCellReuseIdentifier = @"cell";


@interface AAPLJournalViewController()

@property (nonatomic) NSMutableArray *foodItems;
@property (nonatomic) HKHealthStore *healthStore;

@end


@implementation AAPLJournalViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.healthStore = [(AppDelegate*)[[UIApplication sharedApplication] delegate] healthStore];
    
    self.foodItems = [[NSMutableArray alloc] init];
    
    [self updateJournal];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateJournal) name:UIApplicationDidBecomeActiveNotification object:nil];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidBecomeActiveNotification object:nil];
}

#pragma mark - Using HealthKit APIs

- (void)updateJournal {
    NSCalendar *calendar = [NSCalendar currentCalendar];
    
    NSDate *now = [NSDate date];
    
    NSDateComponents *components = [calendar components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay fromDate:now];
    
    NSDate *startDate = [calendar dateFromComponents:components];
    
    NSDate *endDate = [calendar dateByAddingUnit:NSCalendarUnitDay value:1 toDate:startDate options:0];
    
    HKSampleType *sampleType = [HKSampleType quantityTypeForIdentifier:HKQuantityTypeIdentifierDietaryEnergyConsumed];
    NSPredicate *predicate = [HKQuery predicateForSamplesWithStartDate:startDate endDate:endDate options:HKQueryOptionNone];

    HKSampleQuery *query = [[HKSampleQuery alloc] initWithSampleType:sampleType predicate:predicate limit:0 sortDescriptors:nil resultsHandler:^(HKSampleQuery *query, NSArray *results, NSError *error) {
        if (!results) {
            NSLog(@"An error occured fetching the user's tracked food. In your app, try to handle this gracefully. The error was: %@.", error);
            abort();
        }

        dispatch_async(dispatch_get_main_queue(), ^{
            [self.foodItems removeAllObjects];
            
            for (HKQuantitySample *sample in results) {
                NSString *foodName = sample.metadata[HKMetadataKeyFoodType];
                double joules = [sample.quantity doubleValueForUnit:[HKUnit jouleUnit]];
                
                AAPLFoodItem *foodItem = [AAPLFoodItem foodItemWithName:foodName joules:joules];
                
                [self.foodItems addObject:foodItem];
            }
            
            [self.tableView reloadData];
        });
    }];
    
    [self.healthStore executeQuery:query];
}

- (void)addFoodItem:(AAPLFoodItem *)foodItem {
    HKQuantityType *quantityType = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierDietaryEnergyConsumed];

    HKQuantity *quantity = [HKQuantity quantityWithUnit:[HKUnit jouleUnit] doubleValue:foodItem.joules];
    
    NSDate *now = [NSDate date];

    NSDictionary *metadata = @{ HKMetadataKeyFoodType:foodItem.name };
    
    HKQuantitySample *calorieSample = [HKQuantitySample quantitySampleWithType:quantityType quantity:quantity startDate:now endDate:now metadata:metadata];
    
    [self.healthStore saveObject:calorieSample withCompletion:^(BOOL success, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (success) {
                [self.foodItems insertObject:foodItem atIndex:0];
                
                NSIndexPath *indexPathForInsertedFoodItem = [NSIndexPath indexPathForRow:0 inSection:0];
                
                [self.tableView insertRowsAtIndexPaths:@[indexPathForInsertedFoodItem] withRowAnimation:UITableViewRowAnimationAutomatic];
            }
            else {
                NSLog(@"An error occured saving the food %@. In your app, try to handle this gracefully. The error was: %@.", foodItem.name, error);
                abort();
            }
        });
    }];
}

#pragma mark - UITableViewDelegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.foodItems.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:AAPLJournalViewControllerTableViewCellReuseIdentifier forIndexPath:indexPath];
    
    AAPLFoodItem *foodItem = self.foodItems[indexPath.row];

    cell.textLabel.text = foodItem.name;

    NSEnergyFormatter *energyFormatter = [self energyFormatter];
    cell.detailTextLabel.text = [energyFormatter stringFromJoules:foodItem.joules];

    return cell;
}

#pragma mark - Convenience

- (NSEnergyFormatter *)energyFormatter {
    static NSEnergyFormatter *energyFormatter;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        energyFormatter = [[NSEnergyFormatter alloc] init];
        energyFormatter.unitStyle = NSFormattingUnitStyleLong;
        energyFormatter.forFoodEnergyUse = YES;
        energyFormatter.numberFormatter.maximumFractionDigits = 2;
    });
    
    return energyFormatter;
}

@end
