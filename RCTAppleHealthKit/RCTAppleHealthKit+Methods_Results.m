#import "RCTAppleHealthKit+Methods_Results.h"
#import "RCTAppleHealthKit+Queries.h"
#import "RCTAppleHealthKit+Utils.h"

#import <React/RCTBridgeModule.h>

@implementation RCTAppleHealthKit (Methods_Results)


- (void)results_getBloodGlucoseSamples:(NSDictionary *)input callback:(RCTResponseSenderBlock)callback
{
    HKQuantityType *bloodGlucoseType = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierBloodGlucose];

    HKUnit *mmoLPerL = [[HKUnit moleUnitWithMetricPrefix:HKMetricPrefixMilli molarMass:HKUnitMolarMassBloodGlucose] unitDividedByUnit:[HKUnit literUnit]];

    HKUnit *unit = [RCTAppleHealthKit hkUnitFromOptions:input key:@"unit" withDefault:mmoLPerL];
    NSUInteger limit = [RCTAppleHealthKit uintFromOptions:input key:@"limit" withDefault:HKObjectQueryNoLimit];
    BOOL ascending = [RCTAppleHealthKit boolFromOptions:input key:@"ascending" withDefault:false];
    NSDate *startDate = [RCTAppleHealthKit dateFromOptions:input key:@"startDate" withDefault:nil];
    NSDate *endDate = [RCTAppleHealthKit dateFromOptions:input key:@"endDate" withDefault:[NSDate date]];
    if(startDate == nil){
        callback(@[RCTMakeError(@"startDate is required in options", nil, nil)]);
        return;
    }
    NSPredicate * predicate = [RCTAppleHealthKit predicateForSamplesBetweenDates:startDate endDate:endDate];

    [self fetchQuantitySamplesOfType:bloodGlucoseType
                                unit:unit
                           predicate:predicate
                           ascending:ascending
                               limit:limit
                          completion:^(NSArray *results, NSError *error) {
        if(results){
            callback(@[[NSNull null], results]);
            return;
        } else {
            NSLog(@"error getting blood glucose samples: %@", error);
            callback(@[RCTMakeError(@"error getting blood glucose samples", nil, nil)]);
            return;
        }
    }];
}

- (void)results_saveBloodGlucose:(NSDictionary *)input callback:(RCTResponseSenderBlock)callback
{
    double value = [RCTAppleHealthKit doubleFromOptions:input key:@"value" withDefault:(double)0];
    NSDate *date = [RCTAppleHealthKit dateFromOptions:input key:@"date" withDefault:nil];
    HKUnit *mmoLPerL = [[HKUnit moleUnitWithMetricPrefix:HKMetricPrefixMilli molarMass:HKUnitMolarMassBloodGlucose] unitDividedByUnit:[HKUnit literUnit]];
    HKUnit *unit = [RCTAppleHealthKit hkUnitFromOptions:input key:@"unit" withDefault:mmoLPerL];

    if(date == nil){
        callback(@[RCTMakeError(@"Date are required in options", nil, nil)]);
        return;
    }

    HKQuantity *quantity = [HKQuantity quantityWithUnit:unit doubleValue:value];
    HKQuantityType *type = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierBloodGlucose];
    HKQuantitySample *sample = [HKQuantitySample quantitySampleWithType:type quantity:quantity startDate:date endDate:date];

    [self.healthStore saveObject:sample withCompletion:^(BOOL success, NSError *error) {
        if (!success) {
            NSLog(@"An error occured saving the blood glucose sample %@. The error was: %@.", sample, error);
            callback(@[RCTMakeError(@"An error occured saving the blood glucose sample", error, nil)]);
            return;
        }
        callback(@[[NSNull null], @(value)]);
    }];
}

@end
