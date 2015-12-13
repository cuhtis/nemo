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

- (NSString *)encodeToBase64String:(UIImage *)image {
    return [UIImagePNGRepresentation(image) base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if([segue.identifier isEqualToString:@"Submission"]){
        SubmitViewController *controller = (SubmitViewController *)segue.destinationViewController;
        
        controller.EncodedImage = [self encodeToBase64String:imageView.image];
        
    }
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
            imageView.image = image;
        }
    }];
    
    
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
