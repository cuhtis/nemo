//
//  ParkingSpots.h
//  Nemo-Master
//
//  Created by Curtis Li on 12/10/15.
//  Copyright © 2015 Junhan Huang. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ParkingSpot;

@protocol ParkingSpotModelDelegate <NSObject>

- (void) modelUpdated;

@end

@interface ParkingSpots : NSObject

@property (nonatomic, weak) id<ParkingSpotModelDelegate> delegate;

- (NSArray*) filteredParkingSpots;
- (void) addParkingSpot:(ParkingSpot*)parkingSpot;
- (void) removeParkingSpot:(ParkingSpot*)parkingSpot;

- (void) import;
- (void) persist:(ParkingSpot*)parkingSpot;

@end
