//
//  DefaultLayoutViewController.m
//  MediaManagerDemo
//
//  Created by DJI on 1/8/2017.
//  Copyright © 2017 DJI. All rights reserved.
//

#import "DefaultLayoutViewController.h"
#import "DemoUtility.h"

@interface DefaultLayoutViewController ()
@property (weak, nonatomic) IBOutlet UIButton *mediaDownloadBtn;

@end

@implementation DefaultLayoutViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if (IS_IPAD) {
        [self.mediaDownloadBtn setImage:[UIImage imageNamed:@"mediaDownload_icon_iPad"] forState:UIControlStateNormal];
    }else{
        [self.mediaDownloadBtn setImage:[UIImage imageNamed:@"mediaDownload_icon"] forState:UIControlStateNormal];
    }
    
}

@end
