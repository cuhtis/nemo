//
//  ViewController.m
//  Nemo-Master
//
//  Created by Junhan Huang on 12/8/15.
//  Copyright © 2015 Junhan Huang. All rights reserved.
//

#import "GlobalHead.h"
#import "ViewController.h"
#import "Helper.h"
#import "ParkingSpot.h"
#import "ParkingSpots.h"
#import "AppDelegate.h"
#import "CustomInfoWindow.h"

@interface ViewController () <ParkingSpotModelDelegate>

@end


@implementation ViewController {
    BOOL firstLocationUpdate_;
    CLLocationManager *locationManager;
    GMSCameraPosition *firstPosition;
}

/* Retreive the ParkingSpots object from the app delegate */
- (ParkingSpots *)parkingSpots {
    return [AppDelegate appDelegate].parkingSpots;
}

- (void)viewWillAppear:(BOOL)animated {
#ifdef DEBUG_NEMO
    NSLog(@"viewWillAppear");
#endif
    // add observer for Google Maps myLocation object (to see location changes)
    if (!firstLocationUpdate_)
    [_mapView addObserver:self forKeyPath:@"myLocation" options:0 context:nil];
    
}

- (void)viewWillDisappear:(BOOL)animated {
    firstLocationUpdate_ = NO;
#ifdef DEBUG
    NSLog(@"viewWillDisappear");
#endif
    [locationManager stopUpdatingLocation];
}

- (void)viewDidLoad {
#ifdef DEBUG
    NSLog(@"viewDidLoad");
#endif
    [super viewDidLoad];
#ifdef DEBUG
    NSLog(@"global added");
#endif
    [self parkingSpots].delegate = self;
    
    /* Setting up Toolbar*/
    UIImage *nemo = [UIImage imageNamed:@"Nemo"];
    UIImage *camera = [UIImage imageNamed:@"Camera"];
    [Helper customizeBarButton:self.fishButton image:nemo highlightedImage:nemo];
    [Helper customizeBarButton:self.cameraButton image:camera highlightedImage:camera];
    self.mainToolBar.clipsToBounds = YES;
    
    /* Getting My Location */
    locationManager = [[CLLocationManager alloc] init];
    [locationManager setDelegate:self];
    
    //Set some parameters for the location object.
    [locationManager setDistanceFilter:kCLDistanceFilterNone];
    [locationManager setDesiredAccuracy: kCLLocationAccuracyBest];
    [locationManager requestWhenInUseAuthorization];
    [locationManager startUpdatingLocation];
    NSLog(@"created locationManager");
    
    /* Google Map View */
    _mapView.settings.compassButton = YES;
    _mapView.padding = UIEdgeInsetsMake(self.topLayoutGuide.length + 10, 0, self.bottomLayoutGuide.length, 0);
    
    // Setting Up Markers
    [NSThread sleepForTimeInterval:2];
    // wait for server to download
    while ([[self.parkingSpots filteredParkingSpots] count] == 0) {
        [NSThread sleepForTimeInterval:.5];
    }
    
    // update map with new markers
    [self updateMarkers];
}

/* Update the markers on the GMSMapView */
- (void) updateMarkers {
#ifdef DEBUG_NEMO
    NSLog(@"AddMarkers");
#endif
    
    // Reset the map
    self.mapView.delegate = self;
    [self.mapView clear];
    
    // Add each parking spot as a marker
    for (ParkingSpot *ps in [self.parkingSpots filteredParkingSpots]) {
        // Only add the parking spot if it's not taken
        if (ps.is_taken == NO) {
            // Create a new marker and set its values to the parking spot's data
            GMSMarker *marker = [[GMSMarker alloc] init];
            marker.position = CLLocationCoordinate2DMake([[ps latitude] doubleValue],
                                                         [[ps longitude] doubleValue]);
            marker.userData = ps;
            marker.icon = [UIImage imageNamed:@"Nemo"];
            marker.title = ps.name;
        
            // Add the marker to the map
            marker.map = self.mapView;
            ps.marker = marker;
            
#ifdef DEBUG_NEMO
            NSLog(@"Add marker: %@", ps.name);
#endif
        }
    }
    
    // Add the temporary global parking spot as a marker
    ParkingSpot *global =[AppDelegate appDelegate].globalSpot;
    if (global) {
        // Only add the parking spot if it's not taken
        if (global.is_taken == NO) {
            // Create a new marker and set its values to the parking spot's data
            GMSMarker *marker = [[GMSMarker alloc] init];
            marker.position = CLLocationCoordinate2DMake([[global latitude] doubleValue],
                                                         [[global longitude] doubleValue]);
            marker.userData = global;
            marker.icon = [UIImage imageNamed:@"Nemo"];
            marker.title = global.name;
            
            // Add the marker to the map
            marker.map = self.mapView;
            global.marker = marker;
            
#ifdef DEBUG_NEMO
            NSLog(@"Add marker: %@", [AppDelegate appDelegate].globalSpot.name);
#endif
        }
    }
}

/* Custom info window setup for markers */
- (UIView *) mapView:(GMSMapView *)mapView markerInfoWindow:(GMSMarker *)marker {
    
    // Create an instance of the info window
    CustomInfoWindow *infoWindow = [[[NSBundle mainBundle] loadNibNamed:@"InfoWindow" owner:self options:nil] objectAtIndex:0];
    
    // Retrieve the parking spot object
    ParkingSpot *parkingSpot = marker.userData;
    
    // Set the text fields in the info window
    infoWindow.address.text = parkingSpot.name;
    infoWindow.price.text = parkingSpot.price ? [NSString stringWithFormat:@"$%@", parkingSpot.price] : @"$0";
    
    // Set the image
    [infoWindow.image setContentMode:UIViewContentModeScaleAspectFit];
    infoWindow.image.image = parkingSpot.image;
    
#ifdef DEBUG_NEMO
    NSLog(@"%@", parkingSpot.create_date);
    NSLog(@"%@", [NSDate date].description);
#endif
    
    // Calculate the time stamp
    NSString *created = parkingSpot.create_date;
    NSString *now = [NSDate date].description;
    int days = [[now substringWithRange: NSMakeRange(8, 2)] intValue] - [[created substringWithRange: NSMakeRange(8, 2)] intValue];
    int hours = [[now substringWithRange: NSMakeRange(11, 2)] intValue] - [[created substringWithRange: NSMakeRange(11, 2)] intValue];
    int minutes = [[now substringWithRange: NSMakeRange(14, 2)] intValue] - [[created substringWithRange: NSMakeRange(14, 2)] intValue];
    int seconds = [[now substringWithRange: NSMakeRange(17, 2)] intValue] - [[created substringWithRange: NSMakeRange(17, 2)] intValue];
    
    // Set the time stamp text
    if (days > 3) infoWindow.time.text = @"Several days ago";
    else if (days > 0) infoWindow.time.text = [NSString stringWithFormat:@"%d days ago", days];
    else if (hours > 0) infoWindow.time.text = [NSString stringWithFormat:@"%d hours ago", hours];
    else if (minutes > 0) infoWindow.time.text = [NSString stringWithFormat:@"%d minutes ago", minutes];
    else if (seconds > 0) infoWindow.time.text = [NSString stringWithFormat:@"%d seconds ago", seconds];
    else infoWindow.time.text = @"Just added";
    
#ifdef DEBUG_NEMO
    NSLog(@"D:%d, H:%d, M:%d, S:%d", days, hours, minutes, seconds);
    NSLog(@"Marker info: %@", parkingSpot.name);
#endif
    
    return infoWindow;
}

/* UIAlert when the user clicks on the info window, option to claim parking spot */
- (void)mapView:(GMSMapView *)mapView didTapInfoWindowOfMarker:(GMSMarker *)marker {
    
    // Get the parking spot object
    ParkingSpot *parkingSpot = marker.userData;
    
    // Create the alert with messages
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Claim this spot?"
                                                                   message:@"Claiming this parking spot will make it unavailable for others to see."
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    // Set the action for claiming the spot
    UIAlertAction* claimAction = [UIAlertAction actionWithTitle:@"Claim!" style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction * action)
    {
        marker.map = nil;
        parkingSpot.marker = nil;
        parkingSpot.is_taken = YES;
        [self.parkingSpots removeParkingSpot:parkingSpot];
    }];
    [alert addAction:claimAction];
    
    // Set the action for the spot being already gone
    UIAlertAction* goneAction = [UIAlertAction actionWithTitle:@"It's Gone!" style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction * action)
    {
        marker.map = nil;
        parkingSpot.marker = nil;
        parkingSpot.is_taken = YES;
        [self.parkingSpots removeParkingSpot:parkingSpot];
    }];
    [alert addAction:goneAction];
    
    // Set the action for cancelling the UIAlert
    UIAlertAction* cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDefault
                                                       handler:^(UIAlertAction * action) {}];
    [alert addAction:cancelAction];
    
    // Present the alert
    [self presentViewController:alert animated:YES completion:nil];
}

/* Function that is called whenever the parking spots model is updated */
- (void)modelUpdated {
#ifdef DEBUG_NEMO
    NSLog(@"modelUpdated");
#endif
    
    // Update markers in main thread
    // Only main thread can change the GMSMapView
    dispatch_async(dispatch_get_main_queue(),
    ^{
#ifdef DEBUG_NEMO
        NSLog(@"AsyncDispatch START");
#endif
        
        [self updateMarkers];
        
#ifdef DEBUG_NEMO
        NSLog(@"AsyncDispatch END");
#endif
    });
}

/* Authorization of location services */
- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    
    // if user authorizes location services, enable myLocation
    if (status == kCLAuthorizationStatusAuthorizedWhenInUse) {
#ifdef DEBUG_NEMO
        NSLog(@"successfully authorized");
#endif
        _mapView.myLocationEnabled = YES;
    }
}

- (void)locationManager: (CLLocationManager *) manager didUpdateLocations:(nonnull NSArray<CLLocation *> *)locations {
    
#ifdef DEBUG_NEMO
    NSLog(@"didUpdateToLocation: %@", locations);
#endif
    
    CLLocation *currentLocation = [locations lastObject];

    // only zoom map to current location first time app opens
    if (currentLocation != nil && !firstLocationUpdate_) {
        CLLocationCoordinate2D target =
        CLLocationCoordinate2DMake(currentLocation.coordinate.latitude, currentLocation.coordinate.longitude);
        [manager stopUpdatingLocation];
        [self.mapView animateToLocation:target];
        [self.mapView animateToZoom:17];
    }
}

#pragma mark - Key Value Observer updates

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context {
    
    // only track location the first time app opens
    if (!firstLocationUpdate_) {
        
        CLLocation *location = [change objectForKey:NSKeyValueChangeNewKey];
        CLLocationCoordinate2D target =
        CLLocationCoordinate2DMake(location.coordinate.latitude, location.coordinate.longitude);
        
        firstPosition = [GMSCameraPosition cameraWithLatitude: location.coordinate.latitude longitude: location.coordinate.longitude zoom:6];
        
        _mapView.settings.myLocationButton = YES;
        _mapView = [GMSMapView mapWithFrame:CGRectZero camera:firstPosition];
        [_mapView animateToCameraPosition:firstPosition];
        [_mapView animateToLocation:target];
        [_mapView animateToZoom:17];
        firstLocationUpdate_ = YES;

        
    }
}

/* Refresh button clicked */
- (IBAction)refreshFish:(id)sender {
#ifdef DEBUG_NEMO
    NSLog(@"Refresh");
#endif
    
    // Update the markers
    [self updateMarkers];
}

// called when view is removed from stack
- (void)dealloc {
#ifdef DEBUG_NEMO
    NSLog(@"Dealloc ViewController");
#endif
    // try to dealloc the observer
        @try {
        [_mapView removeObserver:self forKeyPath:@"myLocation"];
        }@catch (id noObserverException) {
            
    }
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/* Called when a view unwinds back to the map view */
-(IBAction)unwindtoRoot:(UIStoryboardSegue *)segue {
#ifdef DEBUG_NEMO
    NSLog(@"unwindToRoot");
#endif
    //[self addMarkers];

}

@end
