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


@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) ParkingSpots *parkingSpots;

+ (AppDelegate *) appDelegate;

@end

