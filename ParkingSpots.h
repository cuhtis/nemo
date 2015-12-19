//
//  ParkingSpots.h
//  Nemo-Master
//
//  Created by Curtis Li on 12/10/15.
//  Copyright © 2015 Junhan Huang. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ParkingSpot;

// Delegate protocol for class listening to parking spot updates
@protocol ParkingSpotModelDelegate <NSObject>

// Called when parking spots are updated/changed
- (void) modelUpdated;

@end

@interface ParkingSpots : NSObject

// Delegate which responds to parking spot updates
@property (nonatomic, weak) id<ParkingSpotModelDelegate> delegate;

// Getter function for the local array of parking spots
- (NSArray*) filteredParkingSpots;

// Add a parking spot to the local array
- (void) addParkingSpot:(ParkingSpot*)parkingSpot;

// Remove a parking spot to the local array
- (void) removeParkingSpot:(ParkingSpot*)parkingSpot;

// Import parking spots from the database
- (void) import;

// Save a parking spot to the database
- (void) persist:(ParkingSpot*)parkingSpot;

@end
