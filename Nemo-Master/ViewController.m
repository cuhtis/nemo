//
//  ViewController.m
//  Nemo-Master
//
//  Created by Junhan Huang on 12/8/15.
//  Copyright © 2015 Junhan Huang. All rights reserved.
//

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
- (ParkingSpots *)parkingSpots {
    return [AppDelegate appDelegate].parkingSpots;
}
- (void)viewWillAppear:(BOOL)animated {
#ifdef DEBUG
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

- (void) updateMarkers {
    NSLog(@"AddMarkers");
    self.mapView.delegate = self;
    [self.mapView clear];
    for (ParkingSpot *ps in [self.parkingSpots filteredParkingSpots]) {
        if (true) {
            GMSMarker *marker = [[GMSMarker alloc] init];
            marker.position = CLLocationCoordinate2DMake([[ps latitude] doubleValue],
                                                         [[ps longitude] doubleValue]);
            marker.userData = ps;
            marker.icon = [UIImage imageNamed:@"Nemo"];
            marker.title = ps.name;
        
            marker.map = self.mapView;
            ps.marker = marker;
            NSLog(@"Add marker: %@", ps.name);
        }
    }
    // attaches information to marker just added
    if ([AppDelegate appDelegate].globalSpot) {
        if (true) {
            GMSMarker *marker = [[GMSMarker alloc] init];
            marker.position = CLLocationCoordinate2DMake([[[AppDelegate appDelegate].globalSpot latitude] doubleValue],
                                                         [[[AppDelegate appDelegate].globalSpot longitude] doubleValue]);
            marker.userData = [AppDelegate appDelegate].globalSpot;
            marker.icon = [UIImage imageNamed:@"Nemo"];
            marker.title = [AppDelegate appDelegate].globalSpot.name;
            
            marker.map = self.mapView;
            [AppDelegate appDelegate].globalSpot.marker = marker;
            NSLog(@"Add marker: %@", [AppDelegate appDelegate].globalSpot.name);
        }
        NSLog(@"added new marker to map");
    }
}
    
- (UIView *) mapView:(GMSMapView *)mapView markerInfoWindow:(GMSMarker *)marker {
    CustomInfoWindow *infoWindow = [[[NSBundle mainBundle] loadNibNamed:@"InfoWindow" owner:self options:nil] objectAtIndex:0];
    
    ParkingSpot *parkingSpot = marker.userData;
    
    infoWindow.address.text = parkingSpot.name;
    infoWindow.price.text = parkingSpot.price ? [NSString stringWithFormat:@"$%@", parkingSpot.price] : @"$0";
    
    [infoWindow.image setContentMode:UIViewContentModeScaleAspectFit];
    infoWindow.image.image = parkingSpot.image;
    
    NSLog(@"%@", parkingSpot.create_date);
    NSLog(@"%@", [NSDate date].description);
    
    NSString *created = parkingSpot.create_date;
    NSString *now = [NSDate date].description;
    int days = [[now substringWithRange: NSMakeRange(8, 2)] intValue] - [[created substringWithRange: NSMakeRange(8, 2)] intValue];
    int hours = [[now substringWithRange: NSMakeRange(11, 2)] intValue] - [[created substringWithRange: NSMakeRange(11, 2)] intValue];
    int minutes = [[now substringWithRange: NSMakeRange(14, 2)] intValue] - [[created substringWithRange: NSMakeRange(14, 2)] intValue];
    int seconds = [[now substringWithRange: NSMakeRange(17, 2)] intValue] - [[created substringWithRange: NSMakeRange(17, 2)] intValue];
    
    if (days > 3) infoWindow.time.text = @"Several days ago";
    else if (days > 0) infoWindow.time.text = [NSString stringWithFormat:@"%d days ago", days];
    else if (hours > 0) infoWindow.time.text = [NSString stringWithFormat:@"%d hours ago", hours];
    else if (minutes > 0) infoWindow.time.text = [NSString stringWithFormat:@"%d minutes ago", minutes];
    else if (seconds > 0) infoWindow.time.text = [NSString stringWithFormat:@"%d seconds ago", seconds];
    else infoWindow.time.text = @"Just added";
    
    NSLog(@"D:%d, H:%d, M:%d, S:%d", days, hours, minutes, seconds);
    
    NSLog(@"Marker info: %@", parkingSpot.name);
    return infoWindow;
}

- (void)mapView:(GMSMapView *)mapView didTapInfoWindowOfMarker:(GMSMarker *)marker {
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Claim this spot?"
                                                                   message:@"Claiming this parking spot will make it unavailable for others to see."
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* claimAction = [UIAlertAction actionWithTitle:@"Claim!" style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction * action)
    {
        marker.map = nil;
        [self.parkingSpots removeParkingSpot:marker.userData];
    }];
    [alert addAction:claimAction];
    
    UIAlertAction* goneAction = [UIAlertAction actionWithTitle:@"It's Gone!" style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction * action)
    {
        marker.map = nil;
        [self.parkingSpots removeParkingSpot:marker.userData];
    }];
    [alert addAction:goneAction];
    
    UIAlertAction* cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDefault
                                                       handler:^(UIAlertAction * action) {}];
    [alert addAction:cancelAction];
    
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)modelUpdated {
    // UPDATE MARKERS
    NSLog(@"modelUpdated");
    dispatch_async(dispatch_get_main_queue(),
    ^{
        NSLog(@"AsyncDispatch START");
        [self updateMarkers];
        NSLog(@"AsyncDispatch END");
    });
}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    
    // if user authorizes location services, enable myLocation
    if (status == kCLAuthorizationStatusAuthorizedWhenInUse) {
        NSLog(@"successfully authorized");
        _mapView.myLocationEnabled = YES;
    }
}

- (void)locationManager: (CLLocationManager *) manager didUpdateLocations:(nonnull NSArray<CLLocation *> *)locations {
#ifdef DEBUG
    NSLog(@"didUpdateToLocation: %@", locations);
#endif
    CLLocation *currentLocation = [locations lastObject];

    // zoom map to current location first time app opens
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

- (IBAction)refreshFish:(id)sender {
#ifdef DEBUG
    NSLog(@"Refresh");
#endif
    [self updateMarkers];
}

    // called when view is removed from stack
- (void)dealloc {
#ifdef DEBUG
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

//The target unwind to Root. 
-(IBAction)unwindtoRoot:(UIStoryboardSegue *)segue {
#ifdef DEBUG
    NSLog(@"unwindToRoot");
#endif
    //[self addMarkers];

}

@end
