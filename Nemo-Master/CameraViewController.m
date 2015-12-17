//
//  CameraViewController.m
//  Nemo-Master
//
//  Created by Jonathan Chen on 12/9/15.
//  Copyright (c) 2015 Junhan Huang. All rights reserved.
//

#import "CameraViewController.h"
#import "SubmitViewController.h"

@interface CameraViewController ()

@end

AVCaptureSession *session;
AVCaptureStillImageOutput *StillImageOutput;

@implementation CameraViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _retakeBut.hidden=YES;
    _retakeBut.enabled=NO;
    _submitBut.hidden=YES;
    _submitBut.enabled=NO;
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated{
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
    
    [session startRunning];
    
}

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
