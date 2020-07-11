//
//  HKActivitySummaryQuery+ResultsHandler.m
//  Project SFTests
//
//  Created by William Taylor on 11/7/20.
//

#import <Foundation/Foundation.h>
#import <HealthKit/HealthKit.h>
#import "HKActivitySummaryQuery+ResultsHandler.h"

@implementation HKActivitySummaryQuery (Testing)

- (void (^)(HKActivitySummaryQuery *query, NSArray<HKActivitySummary *> *activitySummaries, NSError *error)) getResultsHandler {
    return [self valueForKey:@"_completionHandler"];
}

@end
