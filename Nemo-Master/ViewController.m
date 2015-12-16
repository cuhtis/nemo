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
    NSLog(@"first");
    [_mapView addObserver:self forKeyPath:@"myLocation" options:0 context:nil];
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
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
    NSLog(@"dwadawd");
    
    _mapView.settings.compassButton = YES;
    _mapView.padding = UIEdgeInsetsMake(self.topLayoutGuide.length + 10, 0, self.bottomLayoutGuide.length, 0);
    
    
    /* Setting Up Markers */
    for (ParkingSpot *ps in [self.parkingSpots filteredParkingSpots]) {
        GMSMarker *marker = [[GMSMarker alloc] init];
        marker.position = CLLocationCoordinate2DMake([[ps latitude] doubleValue], [[ps longitude] doubleValue]);
        marker.title = [ps name];
        marker.snippet = [NSString stringWithFormat:@"%@", [ps price]];
        marker.icon = [UIImage imageNamed:@"Nemo"];
        marker.map = self.mapView;
    }
}

- (void)modelUpdated {
    
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

- (void)dealloc {
    [_mapView removeObserver:self forKeyPath:@"myLocation"];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction)unwindtoRoot:(UIStoryboardSegue *)segue{}

@end
