//
//  ViewController.h
//  Nemo-Master
//
//  Created by Junhan Huang on 12/8/15.
//  Copyright © 2015 Junhan Huang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/Mapkit.h>
#import "GlobalHead.h"
@import CoreLocation;
@import GoogleMaps;

@interface ViewController : UIViewController <GMSMapViewDelegate, CLLocationManagerDelegate>

@property (weak, nonatomic) IBOutlet UIBarButtonItem *fishButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *cameraButton;
@property (weak, nonatomic) IBOutlet UIToolbar *mainToolBar;
@property (strong, nonatomic) IBOutlet GMSMapView *mapView;
-(IBAction)unwindtoRoot:(UIStoryboardSegue *)segue;
@end

