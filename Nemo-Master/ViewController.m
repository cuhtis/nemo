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
    NSLog(@"viewWillAppear");
    if (!firstLocationUpdate_)
    [_mapView addObserver:self forKeyPath:@"myLocation" options:0 context:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
    firstLocationUpdate_ = NO;
    NSLog(@"viewWillDisappear");
    [locationManager stopUpdatingLocation];
}

- (void)viewDidLoad {
    NSLog(@"viewDidLoad");
    [super viewDidLoad];
    
    [self parkingSpots].delegate = self;
    
    UIImage *nemo = [UIImage imageNamed:@"Nemo"];
    UIImage *camera = [UIImage imageNamed:@"Camera"];
    [Helper customizeBarButton:self.fishButton image:nemo highlightedImage:nemo];
    [Helper customizeBarButton:self.cameraButton image:camera highlightedImage:camera];
    self.mainToolBar.clipsToBounds = YES;
    
    // Getting My Location
    //Instantiate a location object.
    locationManager = [[CLLocationManager alloc] init];
    [locationManager setDelegate:self];
    
    //Set some parameters for the location object.
    [locationManager setDistanceFilter:kCLDistanceFilterNone];
    [locationManager setDesiredAccuracy: kCLLocationAccuracyBest];
    [locationManager requestWhenInUseAuthorization];
    [locationManager startUpdatingLocation];
    NSLog(@"created locationManager");
    
    // Google Map View
    _mapView.settings.compassButton = YES;
    _mapView.padding = UIEdgeInsetsMake(self.topLayoutGuide.length + 10, 0, self.bottomLayoutGuide.length, 0);
    
    /* Setting Up Markers */
    self.mapView.delegate = self;
    [self updateMarkers];
}

- (void) updateMarkers {
    NSLog(@"AddMarkers");
    self.mapView.delegate = self;
    [self.mapView clear];
    for (ParkingSpot *ps in [self.parkingSpots filteredParkingSpots]) {
        if (ps.is_taken == 0 && ps.marker == nil) {
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
}

- (UIView *) mapView:(GMSMapView *)mapView markerInfoWindow:(GMSMarker *)marker {
    CustomInfoWindow *infoWindow = [[[NSBundle mainBundle] loadNibNamed:@"InfoWindow" owner:self options:nil] objectAtIndex:0];
    
    ParkingSpot *parkingSpot = marker.userData;
    
    infoWindow.address.text = parkingSpot.name;
    infoWindow.price.text = parkingSpot.price ? [NSString stringWithFormat:@"$%@", parkingSpot.price] : @"$0";
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
    
    if (status == kCLAuthorizationStatusAuthorizedWhenInUse) {
        NSLog(@"successfully authorized");
        _mapView.myLocationEnabled = YES;
    }
}

- (void)locationManager: (CLLocationManager *) manager didUpdateLocations:(nonnull NSArray<CLLocation *> *)locations {
    NSLog(@"didUpdateToLocation: %@", locations);
    CLLocation *currentLocation = [locations lastObject];
    
    if (currentLocation != nil && !firstLocationUpdate_) {
        CLLocationCoordinate2D target =
        CLLocationCoordinate2DMake(currentLocation.coordinate.latitude, currentLocation.coordinate.longitude);
        [manager stopUpdatingLocation];
        [self.mapView animateToLocation:target];
        [self.mapView animateToZoom:17];
    }
}

#pragma mark - KVO updates

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context {
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
    NSLog(@"Refresh");
    [self updateMarkers];
}

- (void)dealloc {
    NSLog(@"Dealloc ViewController");
        @try {
        [_mapView removeObserver:self forKeyPath:@"myLocation"];
        }@catch (id noObserverException) {
            
        NSLog(@"dwadad");
    }
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction)unwindtoRoot:(UIStoryboardSegue *)segue {
    NSLog(@"unwindToRoot");
    //[self addMarkers];
}

@end
