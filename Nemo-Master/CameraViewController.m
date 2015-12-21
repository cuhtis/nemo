//
//  CameraViewController.m
//  Nemo-Master
//
//  Created by Jonathan Chen on 12/9/15.
//  Copyright (c) 2015 Junhan Huang. All rights reserved.
//

#import "GlobalHead.h"
#import "CameraViewController.h"
#import "SubmitViewController.h"
@interface CameraViewController ()

@end

AVCaptureSession *session;
AVCaptureStillImageOutput *StillImageOutput;

@implementation CameraViewController

//Initialize some buttons to be hidden and disabled.
//E.g. we don't want the retake button to be avialalbe if you haven't even taken a picture yet.
- (void)viewDidLoad {
    [super viewDidLoad];
    _retakeBut.hidden=YES;
    _retakeBut.enabled=NO;
    _submitBut.hidden=YES;
    _submitBut.enabled=NO;
    // Do any additional setup after loading the view.
    
    session = [[AVCaptureSession alloc] init];
    [session setSessionPreset:AVCaptureSessionPresetPhoto];
    
    AVCaptureDevice *inputDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    NSError *error;
    AVCaptureDeviceInput *deviceInput = [AVCaptureDeviceInput deviceInputWithDevice:inputDevice error:&error];
    
    if([session canAddInput:deviceInput]){
        [session addInput:deviceInput];
    }
    
    AVCaptureVideoPreviewLayer *previewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:session];
    [previewLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
    CALayer *rootLayer = [[self view] layer];
    [rootLayer setMasksToBounds:YES];
    CGRect frame = frameforCapture.frame;
    
    [previewLayer setFrame:frame];
    
    [rootLayer insertSublayer:previewLayer atIndex:0];
    
    StillImageOutput = [[AVCaptureStillImageOutput alloc] init];
    NSDictionary *outputSettings = [[NSDictionary alloc] initWithObjectsAndKeys:AVVideoCodecJPEG,AVVideoCodecKey, nil];
    [StillImageOutput setOutputSettings:outputSettings];
    
    [session addOutput:StillImageOutput];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//Utilizes AVFoundation to produce the live feed on the view.
- (void)viewWillAppear:(BOOL)animated{
    
    [session startRunning];
    
}

//allows for the taken photo to be passed onto the SubmitView
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if([segue.identifier isEqualToString:@"snap"]){
        SubmitViewController *controller = (SubmitViewController *)segue.destinationViewController;
        controller.snappedImage = imageView.image;
        
    }
}

- (void)dealloc {
    NSLog(@"Dealloc CameraViewController");
}

-(void)hideStatusBar {
    [self setNeedsStatusBarAppearanceUpdate];
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

//whatever's on the current View (live feed) will be captured on the
//ImageView
- (IBAction)takephoto:(id)sender{
    AVCaptureConnection *videoConnection = nil;
    for(AVCaptureConnection *connection in StillImageOutput.connections){
        for(AVCaptureInputPort *port in [connection inputPorts]){
            if([[port mediaType] isEqual:AVMediaTypeVideo]){
                videoConnection = connection;
                break;
            }
        }
    }
    [StillImageOutput captureStillImageAsynchronouslyFromConnection:videoConnection completionHandler:^(CMSampleBufferRef imageDataSampleBuffer, NSError *error) {
        if(imageDataSampleBuffer!=NULL){
            NSData *imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageDataSampleBuffer];
            UIImage *image = [UIImage imageWithData:imageData];
            [imageView setContentMode:UIViewContentModeScaleAspectFill];
            imageView.image = image;
            
            _retakeBut.hidden=NO;
            _retakeBut.enabled=YES;
            _submitBut.hidden=NO;
            _submitBut.enabled=YES;
            _snapBut.hidden=YES;
            _snapBut.enabled=NO;
            _backBut.enabled=NO;
            _backBut.hidden=YES;
            
        }
    }];
}

//Retake Button, clearing the ImageView and reenabling buttons that are set to work
- (IBAction)retakephoto:(id)sender {
    _snapBut.hidden=NO;
    _snapBut.enabled=YES;
    _retakeBut.hidden=YES;
    _retakeBut.enabled=NO;
    _submitBut.hidden=YES;
    _submitBut.enabled=NO;
    _backBut.enabled=YES;
    _backBut.hidden=NO;
    imageView.image=nil;
}

//Creates destination for unwind
-(IBAction)unwindtoCamera:(UIStoryboardSegue *)segue{
    _retakeBut.hidden=NO;
    _retakeBut.enabled=YES;
    _submitBut.hidden=NO;
    _submitBut.enabled=YES;
    _snapBut.hidden=YES;
    _snapBut.enabled=NO;
    _backBut.enabled=NO;
    _backBut.hidden=YES;
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
