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
#import "NavViewController.h"

#import "Atoms.h"

#import <CoreMotion/CoreMotion.h>
#import <SceneKit/SceneKit.h>

#define KScreenWidth [UIScreen mainScreen].bounds.size.width
#define KScreenHeight [UIScreen mainScreen].bounds.size.height
static const CGFloat CRMotionViewRotationMinimumTreshold = 0.1f;
static const CGFloat CRMotionGyroUpdateInterval = 1 / 100;
static const CGFloat CRMotionViewRotationFactor = 5.0f;

@interface PhotoViewController ()
{
    __weak IBOutlet UILabel *_msgLabel;
    __weak IBOutlet UIButton *backBt;
    UIButton *_trackerBt;
    CMMotionManager *_motionManager;
    
    GeoPointCompass *geoPointCompass;
    
//    PhotoView *photoView;
    
    
    UILabel *label1;
    UILabel *label2;
    UILabel *label3;
    
//    __weak IBOutlet SCNView *sceneView;
    SCNView *sceneView;
    
    SCNScene *scene;
}

@property (nonatomic, assign) CGFloat motionRate;
@property (nonatomic, assign) NSInteger minimumXOffset;
@property (nonatomic, assign) NSInteger maximumXOffset;
@end

@implementation PhotoViewController

- (IBAction)back:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    backBt.layer.masksToBounds = YES;
    backBt.layer.cornerRadius = 8;
    
    _minimumXOffset = -100;
    _maximumXOffset = KScreenWidth;
    
    [self _createSession];
    [self sceneSetup];
    
    [self startMonitoring];
//    [self useGyroPush];
    
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
//    [photoView startRunning];
}

- (void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
//    [photoView stopRunning];
}

- (void)_createSession{
//    photoView = [[PhotoView alloc] initWithFrame:[UIScreen mainScreen].bounds withPositionDevice:YES];
//    
//    [photoView addSubview:backBt];
    
    CGRect frame;
    frame.size = CGSizeMake(100, 150);
    frame.origin = CGPointMake(self.view.center.x - frame.size.width/2, self.view.center.x - frame.size.height/2);
    
    // 目标图片
    _trackerBt = [[UIButton alloc] initWithFrame:frame];
    _trackerBt.backgroundColor = [UIColor clearColor];
    [_trackerBt setImage:[UIImage imageNamed:@"A"] forState:UIControlStateNormal];
    [_trackerBt setImage:[UIImage imageNamed:@"B"] forState:UIControlStateSelected];
    [_trackerBt addTarget:self action:@selector(clickTracker:) forControlEvents:UIControlEventTouchUpInside];
//    [photoView addSubview:_trackerBt];
    [self.view addSubview:_trackerBt];
    _motionRate = _trackerBt.frame.size.width / _trackerBt.frame.size.width * CRMotionViewRotationFactor;
    
    // 下方指示图标
    UIImageView *arrowImageView = [[UIImageView alloc] initWithFrame:CGRectMake(([UIScreen mainScreen].bounds.size.width - 100)/2, 400, 100, 100)];
    arrowImageView.image = [UIImage imageNamed:@"arrow.png"];
//    [photoView addSubview:arrowImageView];
    [self.view addSubview:arrowImageView];
    geoPointCompass = [[GeoPointCompass alloc] init];
    [geoPointCompass setArrowImageView:arrowImageView];
    // Set the coordinates of the location to be used for calculating the angle
    geoPointCompass.latitudeOfTargetedPoint = 48.858093;
    geoPointCompass.longitudeOfTargetedPoint = 2.294694;
    
    // 陀螺仪数据Label
    label1 = [[UILabel alloc] initWithFrame:CGRectMake(8, 20, 100, 20)];
    label1.textColor = [UIColor redColor];
//    [photoView addSubview:label1];
    label2 = [[UILabel alloc] initWithFrame:CGRectMake(8, 40, 100, 20)];
    label2.textColor = [UIColor redColor];
//    [photoView addSubview:label2];
    label3 = [[UILabel alloc] initWithFrame:CGRectMake(8, 60, 100, 20)];
    label3.textColor = [UIColor redColor];
//    [photoView addSubview:label3];
    
    sceneView = [[SCNView alloc] initWithFrame:CGRectMake(0, KScreenHeight/2, KScreenWidth, KScreenHeight/2)];
    sceneView.backgroundColor = [UIColor clearColor];
//    [photoView addSubview:sceneView];
    [self.view addSubview:sceneView];
    
//    [photoView addSubview:_msgLabel];
    
//    [self.view addSubview:photoView];
}

- (void)clickTracker:(UIButton *)button{
    button.selected = !button.selected;
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
        CGFloat rotationRateX = gyroData.rotationRate.x;
        CGFloat rotationRateY = gyroData.rotationRate.y;
        if (fabs(rotationRateY) >= CRMotionViewRotationMinimumTreshold && fabs(rotationRateX) >= CRMotionViewRotationMinimumTreshold) {
            CGFloat offsetX = _trackerBt.frame.origin.x + rotationRateY * _motionRate;
            CGFloat offsetY = _trackerBt.frame.origin.y + rotationRateX * _motionRate;
//            NSLog(@"%f", offsetX);
//            if (offsetX > _maximumXOffset) {
//                offsetX = _maximumXOffset;
//            } else if (offsetX < _minimumXOffset) {
//                offsetX = _minimumXOffset;
//            }
            
            [UIView animateWithDuration:1.0f delay:0.0f options:UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionAllowUserInteraction | UIViewAnimationOptionCurveEaseOut animations:^{
                 _trackerBt.frame = CGRectMake(offsetX, offsetY, _trackerBt.frame.size.width, _trackerBt.frame.size.height);
//                scene.rootNode.rotation = SCNVector4Make(rotationRateX, rotationRateY, 0, M_PI_2);
                scene.rootNode.position = SCNVector3Make(-offsetX/50, offsetY/50, 0);
             }completion:nil];
        }
        
//        CGFloat rotationRateX = gyroData.rotationRate.x;
//        if (fabs(rotationRateX) >= CRMotionViewRotationMinimumTreshold) {
//            CGFloat offsetY = _trackerBt.frame.origin.y + rotationRateX * _motionRate;
//            [UIView animateWithDuration:0.3f delay:0.0f options:UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionAllowUserInteraction | UIViewAnimationOptionCurveEaseOut animations:^{
//                _trackerBt.frame = CGRectMake(_trackerBt.frame.origin.x, offsetY, _trackerBt.frame.size.width, _trackerBt.frame.size.height);
//                scene.rootNode.position = SCNVector3Make(0, rotationRateX, 0);
//            }completion:nil];
//        }
        
        
    }];
    } else {
        NSLog(@"There is not available gyro.");
    }
}

/*
- (void)useGyroPush{
    if (!_motionManager) {
        _motionManager = [[CMMotionManager alloc] init];
        _motionManager.gyroUpdateInterval = CRMotionGyroUpdateInterval;
    }
    
    // 设备运动数据更新
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
    
    // 陀螺仪数据更新
    [_motionManager startGyroUpdatesToQueue:[NSOperationQueue currentQueue] withHandler:^(CMGyroData * _Nullable gyroData, NSError * _Nullable error) {
        double rotationX = gyroData.rotationRate.x;
        double rotationY = gyroData.rotationRate.y;
        double rotationZ = gyroData.rotationRate.z;
        NSLog(@"%f", rotationX);
        NSLog(@"%f", rotationY);
        NSLog(@"%f", rotationZ);
    }];
    
    // 加速计更新
    [_motionManager startAccelerometerUpdatesToQueue:[NSOperationQueue currentQueue] withHandler:^(CMAccelerometerData * _Nullable accelerometerData, NSError * _Nullable error) {
        
    }];
    
//    [_motionManager star];
}
*/



- (void)sceneSetup{
    //        let scene = SCNScene(named: "EthanolScene.dae")
    scene = [SCNScene sceneNamed:@"file.dae"];
//    SCNScene *scene = [SCNScene scene];
    
    
    // 全向光 它有方向。其光照方向与它跟物体的位置关系相关。
    SCNNode *omniLightNode = [[SCNNode alloc] init];
    omniLightNode.light = [[SCNLight alloc] init];
    omniLightNode.light.type = SCNLightTypeOmni;
    omniLightNode.light.color = [UIColor colorWithWhite:0.75 alpha:1];
    omniLightNode.position = SCNVector3Make(0, 50, 50);
//    [scene.rootNode addChildNode:omniLightNode];
    
    
    // 摄像机
    SCNNode *cameraNode = [[SCNNode alloc] init];
    cameraNode.camera = [[SCNCamera alloc] init];
    cameraNode.position = SCNVector3Make(0, 0, 15);
    [scene.rootNode addChildNode:cameraNode];
    
    // 将场景放进sceneView中显示
    sceneView.scene = scene;
    sceneView.autoenablesDefaultLighting = YES;
    sceneView.allowsCameraControl = YES;

    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction)];
    [sceneView addGestureRecognizer:tap];
}

- (void)tapAction{
    NavViewController *navVC = [[NavViewController alloc] init];
    [self presentViewController:navVC animated:YES completion:nil];
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
