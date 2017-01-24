//
//  NavViewController.m
//  Camera
//
//  Created by 魏唯隆 on 16/8/2.
//  Copyright © 2016年 魏唯隆. All rights reserved.
//

#import "NavViewController.h"
#import <SceneKit/SceneKit.h>
#import <CoreMotion/CoreMotion.h>
#import "Atoms.h"

#import "PhotoView.h"

@interface NavViewController ()
{
    SCNView *sceneView;
    SCNScene *scene;
    
    CMMotionManager *_motionManager;
//    PhotoView *photoView;
    
    UILabel *label1;
    UILabel *label2;
    UILabel *label3;
    
    UIButton *_trackerBt;
}
/** 粒子动画 */
@property(nonatomic, weak) CAEmitterLayer *emitterLayer;
@end

@implementation NavViewController


- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
//    [photoView startRunning];
}
- (void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
//    [photoView stopRunning];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self createView];
    
    [self sceneSetup];
    [self createAtoms];
    
    [self startMonitoring];
    
    // 开始粒子动画
//    [self.emitterLayer setHidden:NO];
}

- (void)createView{
//    photoView = [[PhotoView alloc] initWithFrame:[UIScreen mainScreen].bounds withPositionDevice:YES];
//    [self.view addSubview:photoView];
    
    sceneView = [[SCNView alloc] initWithFrame:self.view.frame];
    sceneView.backgroundColor = [UIColor clearColor];
//    [photoView addSubview:sceneView];
    [self.view addSubview:sceneView];
    
    CGRect frame;
    frame.size = CGSizeMake(100, 150);
    frame.origin = CGPointMake(self.view.center.x - frame.size.width/2, self.view.center.x - frame.size.height/2);
    
    // 目标图片
    _trackerBt = [[UIButton alloc] initWithFrame:frame];
    _trackerBt.hidden = YES;
    _trackerBt.backgroundColor = [UIColor clearColor];
    [_trackerBt setImage:[UIImage imageNamed:@"B"] forState:UIControlStateNormal];
//    [photoView addSubview:_trackerBt];
    [self.view addSubview:_trackerBt];
}

#pragma mark 创建3d原子
- (void)createAtoms{
    Atoms *atoms = [[Atoms alloc] init];
    SCNNode *geometryNode = [atoms allAtoms];
    
    [scene.rootNode addChildNode:geometryNode];
}

- (void)sceneSetup{
    //        let scene = SCNScene(named: "EthanolScene.dae")
//    SCNScene *scene = [SCNScene sceneNamed:@"EthanolScene.dae"];
    scene = [SCNScene scene];
    
    
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
    cameraNode.position = SCNVector3Make(0, 0, 25);
    [scene.rootNode addChildNode:cameraNode];
    
    // 将场景放进sceneView中显示
    sceneView.scene = scene;
    sceneView.autoenablesDefaultLighting = YES;
    sceneView.allowsCameraControl = YES;
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(8, 20, 50, 40);
    button.layer.masksToBounds = YES;
    button.layer.cornerRadius = 8;
    [button setTitle:@"返回" forState:UIControlStateNormal];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    button.backgroundColor = [UIColor colorWithRed:40.2f/255 green:180.2f/255 blue:247.2f/255 alpha:0.8];
    [button addTarget:self action:@selector(backAction) forControlEvents:UIControlEventTouchUpInside];
    [sceneView addSubview:button];
    
    
    // 陀螺仪数据Label
    label1 = [[UILabel alloc] initWithFrame:CGRectMake(8, 20, 100, 20)];
    label1.textColor = [UIColor redColor];
    [sceneView addSubview:label1];
    label2 = [[UILabel alloc] initWithFrame:CGRectMake(8, 40, 100, 20)];
    label2.textColor = [UIColor redColor];
    [sceneView addSubview:label2];
    label3 = [[UILabel alloc] initWithFrame:CGRectMake(8, 60, 100, 20)];
    label3.textColor = [UIColor redColor];
    [sceneView addSubview:label3];
}

- (void)backAction{
    [self dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark Motion方法
- (void)startMonitoring
{
    if (!_motionManager) {
        _motionManager = [[CMMotionManager alloc] init];
        _motionManager.gyroUpdateInterval = 0.01;
    }
    
    /*
    if (![_motionManager isDeviceMotionActive] && [_motionManager isDeviceMotionAvailable]) {
        [_motionManager startDeviceMotionUpdatesToQueue:[NSOperationQueue currentQueue] withHandler:^(CMDeviceMotion * _Nullable motion, NSError * _Nullable error) {
            
            CGFloat gravityX = motion.gravity.x;
            CGFloat gravityY = motion.gravity.y;
            CGFloat gravityZ = motion.gravity.z;
            
            CGFloat rool = motion.attitude.roll;
            CGFloat pitch = motion.attitude.pitch;
            CGFloat yaw = motion.attitude.yaw;
            
            label1.text = [NSString stringWithFormat:@"rool:%f", rool];
            label2.text = [NSString stringWithFormat:@"pitch:%f", pitch];
            label3.text = [NSString stringWithFormat:@"yaw:%f", yaw];
            
            double zTheta = atan2(gravityZ, sqrtf(gravityX * gravityX + gravityY * gravityY))/M_PI*180.0;
            double xyTheta = atan2(gravityX, gravityY)/M_PI*180.0;
//            NSLog(@"%f", zTheta);
//            NSLog(@"%f", xyTheta);
            
            [UIView animateWithDuration:1.0f delay:0.0f options:UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionAllowUserInteraction | UIViewAnimationOptionCurveEaseOut animations:^{
//                scene.rootNode.rotation = SCNVector4Make(1, 1, 0, zTheta);
                scene.rootNode.position = SCNVector3Make(-rool, pitch, yaw);
            }completion:nil];
        }];
    } else {
        NSLog(@"There is not available gyro.");
    }
     */
    
    if (![_motionManager isGyroActive] && [_motionManager isGyroAvailable]) {
        [_motionManager startGyroUpdatesToQueue:[NSOperationQueue currentQueue] withHandler:^(CMGyroData *gyroData, NSError *error) {
            CGFloat rotationRateX = gyroData.rotationRate.x;
            CGFloat rotationRateY = gyroData.rotationRate.y;
            if (fabs(rotationRateY) >= 0.1f && fabs(rotationRateX) >= 0.1f) {
                CGFloat offsetX = _trackerBt.frame.origin.x + rotationRateY * 5;
                CGFloat offsetY = _trackerBt.frame.origin.y + rotationRateX * 5;
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


- (CAEmitterLayer *)emitterLayer
{
    if (!_emitterLayer) {
        CAEmitterLayer *emitterLayer = [CAEmitterLayer layer];
        // 发射器在xy平面的中心位置
        emitterLayer.emitterPosition = CGPointMake(self.view.frame.size.width-50,self.view.frame.size.height-50);
        // 发射器的尺寸大小
        emitterLayer.emitterSize = CGSizeMake(20, 20);
        // 渲染模式
        emitterLayer.renderMode = kCAEmitterLayerUnordered;
        // 开启三维效果
        //    _emitterLayer.preservesDepth = YES;
        NSMutableArray *array = [NSMutableArray array];
        // 创建粒子
        for (int i = 0; i<10; i++) {
            // 发射单元
            CAEmitterCell *stepCell = [CAEmitterCell emitterCell];
            // 粒子的创建速率，默认为1/s
            stepCell.birthRate = 1;
            // 粒子存活时间
            stepCell.lifetime = arc4random_uniform(4) + 1;
            // 粒子的生存时间容差
            stepCell.lifetimeRange = 1.5;
            // 颜色
            // fire.color=[[UIColor colorWithRed:0.8 green:0.4 blue:0.2 alpha:0.1]CGColor];
            UIImage *image = [UIImage imageNamed:[NSString stringWithFormat:@"good%d_30x30", i]];
            // 粒子显示的内容
            stepCell.contents = (id)[image CGImage];
            // 粒子的名字
            //            [fire setName:@"step%d", i];
            // 粒子的运动速度
            stepCell.velocity = arc4random_uniform(100) + 100;
            // 粒子速度的容差
            stepCell.velocityRange = 80;
            // 粒子在xy平面的发射角度
            stepCell.emissionLongitude = M_PI+M_PI_2;;
            // 粒子发射角度的容差
            stepCell.emissionRange = M_PI_2/6;
            // 缩放比例
            stepCell.scale = 0.3;
            [array addObject:stepCell];
        }
        
        emitterLayer.emitterCells = array;
        [self.view.layer addSublayer:emitterLayer];
        _emitterLayer = emitterLayer;
    }
    return _emitterLayer;
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
