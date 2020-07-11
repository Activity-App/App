//
//  HKActivitySummaryQuery+ResultsHandler.h
//  Project SFTests
//
//  Created by William Taylor on 11/7/20.
//

#import <Foundation/Foundation.h>
#import <HealthKit/HealthKit.h>

@interface HKActivitySummaryQuery (Testing)

- (void (^)(HKActivitySummaryQuery *query, NSArray<HKActivitySummary *> *activitySummaries, NSError *error)) getResultsHandler;

@end
