//
//  ViewController.m
//  Nemo-Master
//
//  Created by Junhan Huang on 12/8/15.
//  Copyright © 2015 Junhan Huang. All rights reserved.
//

#import "ViewController.h"
#import "Helper.h"
@import GoogleMaps;

@interface ViewController ()

@end



@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    UIImage *nemo = [UIImage imageNamed:@"Nemo"];
    UIImage *camera = [UIImage imageNamed:@"Camera"];
    [Helper customizeBarButton:self.fishButton image:nemo highlightedImage:nemo];
    [Helper customizeBarButton:self.cameraButton image:camera highlightedImage:camera];
    
    // Google Map View
    GMSCameraPosition *mapCamera = [GMSCameraPosition cameraWithLatitude:-13.86 longitude:121.20 zoom:6];
    [self.mapUIView setCamera:mapCamera];
    self.mapUIView.myLocationEnabled = YES;
    self.mapUIView.settings.myLocationButton = YES;
    self.mapUIView.settings.compassButton = YES;
    self.mapUIView.mapType = kGMSTypeNormal;
    self.mapUIView.delegate = self;
    
    
    
    self.mapUIView.padding = UIEdgeInsetsMake(self.topLayoutGuide.length + 10, 0, self.bottomLayoutGuide.length, 0);
    
    GMSMarker *marker = [[GMSMarker alloc] init];
    marker.position = CLLocationCoordinate2DMake(-33.86, 151.20);
    marker.title = @"Sydney";
    marker.snippet = @"Australia";
    marker.map = self.mapUIView;
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
