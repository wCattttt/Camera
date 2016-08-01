//
//  PhotoViewController.m
//  Opencv_test
//
//  Created by 魏唯隆 on 16/7/21.
//  Copyright © 2016年 魏唯隆. All rights reserved.
//

#import "PhotoViewController.h"
#import "PhotoView.h"
#import "GeoPointCompass.h"

#import <CoreMotion/CoreMotion.h>

#define KScreenWidth [UIScreen mainScreen].bounds.size.width
#define KScreenHeight [UIScreen mainScreen].bounds.size.height
static const CGFloat CRMotionViewRotationMinimumTreshold = 0.1f;
static const CGFloat CRMotionGyroUpdateInterval = 1 / 100;
static const CGFloat CRMotionViewRotationFactor = 5.0f;

@interface PhotoViewController ()
{
    __weak IBOutlet UILabel *_msgLabel;
    UIButton *_trackerBt;
    CMMotionManager *_motionManager;
    
    GeoPointCompass *geoPointCompass;
    
    
    UILabel *label1;
    UILabel *label2;
    UILabel *label3;
}

@property (nonatomic, assign) CGFloat motionRate;
@property (nonatomic, assign) NSInteger minimumXOffset;
@property (nonatomic, assign) NSInteger maximumXOffset;
@end

@implementation PhotoViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    
    _minimumXOffset = -100;
    _maximumXOffset = KScreenWidth;
    
    [self _createSession];
    
    [self startMonitoring];
    [self useGyroPush];
}



- (void)_createSession{
    PhotoView *photoView = [[PhotoView alloc] initWithFrame:[UIScreen mainScreen].bounds withPositionDevice:YES];
    
    CGRect frame;
    frame.size = CGSizeMake(100, 150);
    frame.origin = CGPointMake(self.view.center.x - frame.size.width/2, self.view.center.x - frame.size.height/2);
    
    _trackerBt = [[UIButton alloc] initWithFrame:frame];
    _trackerBt.backgroundColor = [UIColor clearColor];
    [_trackerBt setImage:[UIImage imageNamed:@"A"] forState:UIControlStateNormal];
    [_trackerBt setImage:[UIImage imageNamed:@"B"] forState:UIControlStateSelected];
    [_trackerBt addTarget:self action:@selector(clickTracker:) forControlEvents:UIControlEventTouchUpInside];
    [photoView addSubview:_trackerBt];
    _motionRate = _trackerBt.frame.size.width / _trackerBt.frame.size.width * CRMotionViewRotationFactor;
    
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake([UIScreen mainScreen].bounds.size.width - 68, 20, 60, 40)];
    button.layer.masksToBounds =YES;
    button.layer.cornerRadius = 8;
    button.backgroundColor = [UIColor orangeColor];
    [button setTitle:@"点击" forState:UIControlStateNormal];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(clickAciton) forControlEvents:UIControlEventTouchUpInside];
    [photoView addSubview:button];
    
    UIImageView *arrowImageView = [[UIImageView alloc] initWithFrame:CGRectMake(([UIScreen mainScreen].bounds.size.width - 100)/2, 400, 100, 100)];
    arrowImageView.image = [UIImage imageNamed:@"arrow.png"];
    [photoView addSubview:arrowImageView];
    
    geoPointCompass = [[GeoPointCompass alloc] init];
    [geoPointCompass setArrowImageView:arrowImageView];
    // Set the coordinates of the location to be used for calculating the angle
    geoPointCompass.latitudeOfTargetedPoint = 48.858093;
    geoPointCompass.longitudeOfTargetedPoint = 2.294694;
    
    label1 = [[UILabel alloc] initWithFrame:CGRectMake(8, 20, 100, 20)];
    label1.textColor = [UIColor redColor];
    [photoView addSubview:label1];
    label2 = [[UILabel alloc] initWithFrame:CGRectMake(8, 40, 100, 20)];
    label2.textColor = [UIColor redColor];
    [photoView addSubview:label2];
    label3 = [[UILabel alloc] initWithFrame:CGRectMake(8, 60, 100, 20)];
    label3.textColor = [UIColor redColor];
    [photoView addSubview:label3];
    
    /*
    UIButton *backButton = [[UIButton alloc] initWithFrame:CGRectMake(8, 20, 60, 40)];
    backButton.layer.masksToBounds =YES;
    backButton.layer.cornerRadius = 8;
    backButton.backgroundColor = [UIColor redColor];
    [backButton setTitle:@"关闭" forState:UIControlStateNormal];
    [backButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [backButton addTarget:self action:@selector(backAciton) forControlEvents:UIControlEventTouchUpInside];
    [photoView addSubview:backButton];
    */
     
    [photoView addSubview:_msgLabel];
    
    [self.view addSubview:photoView];
}

- (void)clickTracker:(UIButton *)button{
    button.selected = !button.selected;
}

- (void)backAciton{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)clickAciton{
    _msgLabel.text = @"点击按钮";
    [NSTimer scheduledTimerWithTimeInterval:3 target:self selector:@selector(timeAction) userInfo:nil repeats:NO];
}

- (void)timeAction{
    _msgLabel.text = nil;
}

#pragma mark Motion方法
- (void)startMonitoring
{
    if (!_motionManager) {
        _motionManager = [[CMMotionManager alloc] init];
        _motionManager.gyroUpdateInterval = CRMotionGyroUpdateInterval;
    }
    
    if (![_motionManager isGyroActive] && [_motionManager isGyroAvailable]) {
    [_motionManager startGyroUpdatesToQueue:[NSOperationQueue currentQueue] withHandler:^(CMGyroData *gyroData, NSError *error) {
        CGFloat rotationRateY = gyroData.rotationRate.y;
        if (fabs(rotationRateY) >= CRMotionViewRotationMinimumTreshold) {
            CGFloat offsetX = _trackerBt.frame.origin.x + rotationRateY * _motionRate;
//            if (offsetX > _maximumXOffset) {
//                offsetX = _maximumXOffset;
//            } else if (offsetX < _minimumXOffset) {
//                offsetX = _minimumXOffset;
//            }
            [UIView animateWithDuration:0.3f delay:0.0f options:UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionAllowUserInteraction | UIViewAnimationOptionCurveEaseOut animations:^{
                 _trackerBt.frame = CGRectMake(offsetX, _trackerBt.frame.origin.y, _trackerBt.frame.size.width, _trackerBt.frame.size.height);
             }completion:nil];
        }
        
        CGFloat rotationRateX = gyroData.rotationRate.x;
        if (fabs(rotationRateX) >= CRMotionViewRotationMinimumTreshold) {
            CGFloat offsetY = _trackerBt.frame.origin.y + rotationRateX * _motionRate;
            [UIView animateWithDuration:0.3f delay:0.0f options:UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionAllowUserInteraction | UIViewAnimationOptionCurveEaseOut animations:^{
                _trackerBt.frame = CGRectMake(_trackerBt.frame.origin.x, offsetY, _trackerBt.frame.size.width, _trackerBt.frame.size.height);
            }completion:nil];
        }
    }];
    } else {
        NSLog(@"There is not available gyro.");
    }
}

- (void)useGyroPush{
    if (!_motionManager) {
        _motionManager = [[CMMotionManager alloc] init];
        _motionManager.gyroUpdateInterval = CRMotionGyroUpdateInterval;
    }
    
    [_motionManager startDeviceMotionUpdatesToQueue:[NSOperationQueue currentQueue] withHandler:^(CMDeviceMotion * _Nullable motion, NSError * _Nullable error) {
        double roll = motion.attitude.roll;
        double pitch = motion.attitude.pitch;
        double yaw = motion.attitude.yaw;
        label1.text = [NSString stringWithFormat:@"roll:%f", roll];
        label2.text = [NSString stringWithFormat:@"pitch:%f", pitch];
        label3.text = [NSString stringWithFormat:@"yaw:%f", yaw];
        
        double gravityX = motion.gravity.x;
        double gravityY = motion.gravity.y;
        double gravityZ = motion.gravity.z;
//        double zTheta = atan2(gravityX, sqrtf(gravityZ * gravityZ + gravityY * gravityY)) / M_PI*180.0;
        double xyTheta = atan2(gravityX,gravityY)/M_PI*180.0;
//        NSLog(@"======%f", zTheta);
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
