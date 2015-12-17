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
    [self addMarkers];
}

- (void) addMarkers {
    NSLog(@"AddMarkers");
    self.mapView.delegate = self;
    [self.mapView clear];
    for (ParkingSpot *ps in [self.parkingSpots filteredParkingSpots]) {
        GMSMarker *marker = [[GMSMarker alloc] init];
        marker.position = CLLocationCoordinate2DMake([[ps latitude] doubleValue],
                                                     [[ps longitude] doubleValue]);
        marker.userData = ps;
        marker.icon = [UIImage imageNamed:@"Nemo"];
        marker.title = ps.name;
        
        marker.map = self.mapView;
        NSLog(@"Add marker: %@", ps.name);
    }
}

- (UIView *) mapView:(GMSMapView *)mapView markerInfoWindow:(GMSMarker *)marker {
    CustomInfoWindow *infoWindow = [[[NSBundle mainBundle] loadNibNamed:@"InfoWindow" owner:self options:nil] objectAtIndex:0];
    
    ParkingSpot *parkingSpot = marker.userData;
    
    infoWindow.address.text = parkingSpot.name;
    infoWindow.price.text = parkingSpot.price ? [NSString stringWithFormat:@"$%@", parkingSpot.price] : @"$0";
    infoWindow.image.image = parkingSpot.image;
    
    NSLog(@"%@", parkingSpot.created_at.description);
    
    NSString *createdDate = parkingSpot.created_at.description;
    int days = [[createdDate substringWithRange: NSMakeRange(8, 2)] intValue];
    int hours = [[createdDate substringWithRange: NSMakeRange(11, 2)] intValue];
    int minutes = [[createdDate substringWithRange: NSMakeRange(14, 2)] intValue];
    int seconds = [[createdDate substringWithRange: NSMakeRange(17, 2)] intValue];
    
    NSCalendar *sysCalendar = [NSCalendar currentCalendar];
    NSCalendarUnit unitFlags = NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond;
    NSDateComponents *components = [sysCalendar components:unitFlags
                                                  fromDate:[NSDate date]];
    
    if ([components day] - days > 3) infoWindow.time.text = @"Several days ago";
    else if ([components day] - days > 0) infoWindow.time.text = [NSString stringWithFormat:@"%ld days ago", [components day] - days];
    else if ([components hour] - hours > 0) infoWindow.time.text = [NSString stringWithFormat:@"%ld hours ago", [components hour] - hours];
    else if ([components minute] - minutes > 0) infoWindow.time.text = [NSString stringWithFormat:@"%ld minutes ago", [components minute] - minutes];
    else if ([components second] - seconds > 0) infoWindow.time.text = [NSString stringWithFormat:@"%ld seconds ago", [components second] - seconds];
    else infoWindow.time.text = @"Just added";
    
    NSLog(@"%ld, %d", [components day], days);
    NSLog(@"%ld, %d", [components hour], hours);
    NSLog(@"%ld, %d", [components minute], minutes);
    NSLog(@"%ld, %d", [components second], seconds);
    
    NSLog(@"Marker info: %@", parkingSpot.name);
    return infoWindow;
}

- (void)modelUpdated {
    // UPDATE MARKERS
    NSLog(@"modelUpdated");
    dispatch_async(dispatch_get_main_queue(),
    ^{
        NSLog(@"AsyncDispatch START");
        [self addMarkers];
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
    NSLog(@"gets called");
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
    [self addMarkers];
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
