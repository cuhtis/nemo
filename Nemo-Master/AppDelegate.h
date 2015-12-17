//
//  AppDelegate.h
//  Nemo-Master
//
//  Created by Junhan Huang on 12/8/15.
//  Copyright © 2015 Junhan Huang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ParkingSpots.h"
@import GoogleMaps;
#import "ParkingSpot.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) ParkingSpots *parkingSpots;
@property (strong, nonatomic) ParkingSpot *globalSpot;

+ (AppDelegate *) appDelegate;

@end

