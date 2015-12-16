//
//  CustomInfoWindow.h
//  Nemo-Master
//
//  Created by Curtis Li on 12/16/15.
//  Copyright © 2015 Junhan Huang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CustomInfoWindow : UIView

@property (strong, nonatomic) IBOutlet UILabel *address;
@property (strong, nonatomic) IBOutlet UILabel *price;
@property (strong, nonatomic) IBOutlet UILabel *time;

@property (strong, nonatomic) IBOutlet UIImageView *image;

@end
