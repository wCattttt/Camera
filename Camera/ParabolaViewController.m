//
//  ParabolaViewController.m
//  Camera
//
//  Created by 魏唯隆 on 2016/8/23.
//  Copyright © 2016年 魏唯隆. All rights reserved.
//

#import "ParabolaViewController.h"
#import "PhotoView.h"
#import <SceneKit/SceneKit.h>
#import <ModelIO/ModelIO.h>
#import <CoreMotion/CoreMotion.h>
#import <AVFoundation/AVFoundation.h>

#define KScreeenWidth [UIScreen mainScreen].bounds.size.width
#define KScreeenHeight [UIScreen mainScreen].bounds.size.height

#define KAtomsNodeZ 3

@interface ParabolaViewController ()<SCNPhysicsContactDelegate>
{
//    PhotoView *photoView;
    
    SCNView *sceneView;
    SCNScene *scene;
    
    SCNNode *rotationNode;
    
    SCNNode *floorNode;
    SCNNode *daeNode;
    SCNNode *atomsNode;
    
    CMMotionManager *motionManager;
 
    
    NSMutableArray *points;
}
@end

@implementation ParabolaViewController

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
//    [photoView startRunning];
    
}
- (void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
//    [photoView stopRunning];
    
    [motionManager stopAccelerometerUpdates];
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    points = @[].mutableCopy;
 
    [self createView];
    
    [self sceneSetup];
    
    [self setupLights];
    
    [self setupFloor];
    
    [self createbox];
    
    
    motionManager = [[CMMotionManager alloc] init];
    motionManager.accelerometerUpdateInterval = 0.1;
//    [motionManager startAccelerometerUpdatesToQueue:[NSOperationQueue currentQueue] withHandler:^(CMAccelerometerData * _Nullable accelerometerData, NSError * _Nullable error) {
//        float accelX = accelerometerData.acceleration.x * 9.8;
//        float accelY = accelerometerData.acceleration.y * 9.8;
//        float accelZ = accelerometerData.acceleration.z * 9.8;
//        
//        self->scene.physicsWorld.gravity = SCNVector3Make(scene.rootNode.position.x, accelY, accelZ);
//        NSLog(@"%f", accelZ);
//    }];
    
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
    
    /*
    // 目标图片
    _trackerBt = [[UIButton alloc] initWithFrame:frame];
    _trackerBt.hidden = YES;
    _trackerBt.backgroundColor = [UIColor clearColor];
    [_trackerBt setImage:[UIImage imageNamed:@"B"] forState:UIControlStateNormal];
    [photoView addSubview:_trackerBt];
     */
    
}

- (void)sceneSetup{
    //        let scene = SCNScene(named: "EthanolScene.dae")
    //    SCNScene *scene = [SCNScene sceneNamed:@"EthanolScene.dae"];
    
//    SCNScene *daeScene = [SCNScene sceneNamed:@"dae.dae"];
//    //    SCNNode *daeNode = [daeScene.rootNode childNodeWithName:@"Dae" recursively:YES];
//    daeNode = daeScene.rootNode.childNodes.firstObject;
    
    scene = [SCNScene scene];
    scene.physicsWorld.contactDelegate = self;
    
    // 全向光 它有方向。其光照方向与它跟物体的位置关系相关。
    SCNNode *omniLightNode = [[SCNNode alloc] init];
    omniLightNode.light = [[SCNLight alloc] init];
    omniLightNode.light.type = SCNLightTypeOmni;
    omniLightNode.light.color = [UIColor colorWithWhite:0.75 alpha:1];
    omniLightNode.position = SCNVector3Make(0, 50, 50);
    //    [scene.rootNode addChildNode:omniLightNode];
    
    
    // 摄像机
    // 摄像机拍摄的方向永远是其所在节点位置的 负的 Z 轴 方向。
    SCNNode *cameraNode = [[SCNNode alloc] init];
    cameraNode.camera = [[SCNCamera alloc] init];
    cameraNode.position = SCNVector3Make(0, 4, 15);
    [scene.rootNode addChildNode:cameraNode];
    
    // 将场景放进sceneView中显示
    sceneView.scene = scene;
    sceneView.autoenablesDefaultLighting = YES;
    sceneView.allowsCameraControl = NO;
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(8, 20, 50, 40);
    button.layer.masksToBounds = YES;
    button.layer.cornerRadius = 8;
    [button setTitle:@"返回" forState:UIControlStateNormal];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    button.backgroundColor = [UIColor colorWithRed:40.2f/255 green:180.2f/255 blue:247.2f/255 alpha:0.8];
    [button addTarget:self action:@selector(backAction) forControlEvents:UIControlEventTouchUpInside];
    [sceneView addSubview:button];

}
- (void)backAction{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)setupLights {
    SCNNode *ambientLightNode = [[SCNNode alloc] init];
    ambientLightNode.light = [[SCNLight alloc] init];
    ambientLightNode.light.type = SCNLightTypeAmbient;
    ambientLightNode.light.color = [UIColor colorWithRed:0.4 green:0.4 blue:0.4 alpha:1];
    [scene.rootNode addChildNode:ambientLightNode];
    
    SCNNode *spotlightNode = [[SCNNode alloc] init];
    spotlightNode.light = [[SCNLight alloc] init];
    spotlightNode.light.type = SCNLightTypeSpot;
    spotlightNode.light.color = [UIColor whiteColor];
    spotlightNode.light.spotInnerAngle = 60;
    spotlightNode.light.spotOuterAngle = 140;
    spotlightNode.light.attenuationFalloffExponent = 1;
    spotlightNode.position = SCNVector3Make(0, 10, 0);
    spotlightNode.rotation = SCNVector4Make(-1, 0, 0, M_PI_2);
    [scene.rootNode addChildNode:spotlightNode];
    
//    // Setup ambient light
//    let ambientLightNode = SCNNode()
//    ambientLightNode.light = SCNLight()
//    ambientLightNode.light!.type = SCNLight.LightType.ambient
//    ambientLightNode.light!.color = UIColor.init(red: 0.4, green: 0.4, blue: 0.4, alpha: 1)
//    scene.rootNode.addChildNode(ambientLightNode)
//    
//    // Add spotlight
//    let spotlightNode = SCNNode()
//    spotlightNode.light = SCNLight()
//    spotlightNode.light!.type = SCNLight.LightType.spot
//    spotlightNode.light!.color = UIColor.white
//    spotlightNode.light!.spotInnerAngle = 60;
//    spotlightNode.light!.spotOuterAngle = 140;
//    spotlightNode.light!.attenuationFalloffExponent = 1
//    spotlightNode.position = SCNVector3(x: 0, y: 10, z: 0)
//    spotlightNode.rotation = SCNVector4(x: -1, y: 0, z: 0, w: Float(M_PI_2))
//    scene.rootNode.addChildNode(spotlightNode)
}

- (void)setupFloor {
    SCNMaterial *floorMaterial = [[SCNMaterial alloc] init];
//    floorMaterial.diffuse.contents = [UIColor colorWithRed:0.4 green:0.4 blue:0.5 alpha:1];
    floorMaterial.diffuse.contents = [UIColor clearColor];
    SCNFloor *floor = [[SCNFloor alloc] init];
    floor.materials = @[floorMaterial];
    floor.reflectivity = 0.1;
    
    floorNode = [[SCNNode alloc] init];
    floorNode.geometry = floor;
    floorNode.physicsBody = [SCNPhysicsBody staticBody];
    
    [scene.rootNode addChildNode:floorNode];
    
//    let floorMaterial = SCNMaterial()
//    floorMaterial.diffuse.contents = UIColor.init(red: 0.4, green: 0.4, blue: 0.4, alpha: 1)
//    
//    let floor = SCNFloor()
//    floor.materials = [floorMaterial]
//    floor.reflectivity = 0.1
//    
//    floorNode = SCNNode()
//    floorNode.geometry = floor
//    floorNode.physicsBody = SCNPhysicsBody.static()
//    
//    scene.rootNode.addChildNode(floorNode)
}

- (void)createbox {
    SCNGeometry *geometry = [self fluorineBox];
    atomsNode = [SCNNode nodeWithGeometry:geometry];
    SCNMaterial *material = [[SCNMaterial alloc] init];
    material.specular.contents = [UIColor greenColor];
    material.diffuse.contents = [UIColor greenColor];
    
    atomsNode.geometry.materials = @[material];
    atomsNode.physicsBody = [SCNPhysicsBody dynamicBody];
    atomsNode.physicsBody.usesDefaultMomentOfInertia = YES;
    atomsNode.physicsBody.categoryBitMask = 1;
    atomsNode.physicsBody.contactTestBitMask = 1;
    atomsNode.position = SCNVector3Make(0, 0, KAtomsNodeZ);
    [scene.rootNode addChildNode:atomsNode];
    
    // ++++++++++++
    
    
//    SCNBox *fluorineBox = [SCNBox boxWithWidth:10 height:10 length:10 chamferRadius:1];
//    fluorineBox.firstMaterial.diffuse.contents = [UIColor redColor];
//    fluorineBox.firstMaterial.specular.contents = [UIColor whiteColor];
//    daeNode = [SCNNode nodeWithGeometry:fluorineBox];
////    daeNode.physicsBody = [SCNPhysicsBody staticBody];
//    daeNode.physicsBody = [SCNPhysicsBody kinematicBody];
//    daeNode.physicsBody.categoryBitMask = 1;
//    daeNode.physicsBody.contactTestBitMask = 1;
//    daeNode.position = SCNVector3Make(0, 0, -20);
    
     
    
    SCNScene *daeScene = [SCNScene sceneNamed:@"dae.dae"];
    //    SCNNode *daeNode = [daeScene.rootNode childNodeWithName:@"Dae" recursively:YES];
    daeNode = daeScene.rootNode.childNodes.firstObject;
    daeNode.position = SCNVector3Make(0, 0, -20);
    daeNode.physicsBody = [SCNPhysicsBody staticBody];
    daeNode.physicsBody.categoryBitMask = 1;
    daeNode.physicsBody.contactTestBitMask = 1;

    rotationNode = [SCNNode node];
    [rotationNode addChildNode:daeNode];
    
    [scene.rootNode addChildNode:daeNode];
}

- (SCNGeometry *)fluorineBox{
//    SCNBox *fluorineBox = [SCNBox boxWithWidth:3 height:3 length:3 chamferRadius:1];
//    fluorineBox.firstMaterial.diffuse.contents = [UIColor greenColor];
//    fluorineBox.firstMaterial.specular.contents = [UIColor whiteColor];

    SCNSphere *fluorineBox = [SCNSphere sphereWithRadius:1];
    fluorineBox.firstMaterial.diffuse.contents = [UIColor redColor];
    fluorineBox.firstMaterial.specular.contents = [UIColor whiteColor];

    
    
//    CABasicAnimation *colorAnimation = [CABasicAnimation animationWithKeyPath:@"contents"];
//    colorAnimation.beginTime = _beginTime;
//    _beginTime += 0.1;
//    colorAnimation.autoreverses = YES;
//    colorAnimation.repeatCount = HUGE_VALF;
//    colorAnimation.duration = 1.2;
//    colorAnimation.fromValue = [UIColor greenColor];
//    colorAnimation.toValue = [UIColor redColor];
//    [fluorineAtom.firstMaterial.diffuse addAnimation:colorAnimation forKey:@"colorAnimation"];
    
    return fluorineBox;
    
}

#pragma mark touch begin/move/end 等协议方法
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    //    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"rotation"];
    //    animation.duration = 5;
    //    animation.toValue = [NSValue valueWithSCNVector4:SCNVector4Make(0, 1, 0, M_PI * 2)];
    //    animation.repeatCount = FLT_MAX;
    //    //    [atomsNode addAnimation:animation forKey:@"AtomsNodeAnimation"];
    //
    //    //    [rotationNode addAnimation:animation forKey:@"RotationNodeAnimation"];
    
    //    [motionManager stopAccelerometerUpdates];
    
    scene.physicsWorld.gravity = SCNVector3Make(0, 0, 0);
    
    [atomsNode removeFromParentNode];
    
    SCNGeometry *geometry = [self fluorineBox];
    atomsNode = [SCNNode nodeWithGeometry:geometry];
    SCNMaterial *material = [[SCNMaterial alloc] init];
    material.specular.contents = [UIColor greenColor];
    material.diffuse.contents = [UIColor greenColor];
    
    atomsNode.geometry.materials = @[material];
    atomsNode.physicsBody = [SCNPhysicsBody dynamicBody];
    atomsNode.position = SCNVector3Make(0, 0, KAtomsNodeZ);
    [scene.rootNode addChildNode:atomsNode];
    
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    NSSet *allTouches = [event allTouches];    //返回与当前接收者有关的所有的触摸对象
    UITouch *touch = [allTouches anyObject];   //视图中的所有对象
    CGPoint point = [touch locationInView:[touch view]]; //返回触摸点在视图中的当前坐标
    
    if(points.count >= 2){
        [points removeObjectAtIndex:0];
    }
    NSValue *value = [NSValue valueWithCGPoint:point];
    [points addObject:value];
    
    float x = point.x;
    float y = point.y;
    
    if(x <= KScreeenWidth/2){
        x = x - KScreeenWidth/2;
    }else if (x > KScreeenWidth/2){
        x = x - KScreeenWidth/2;
    }
    
    
    if (y <= KScreeenHeight/2) {
        y = KScreeenHeight/2 - y;
    }else if (y > KScreeenHeight/2) {
        y = - (y - KScreeenHeight/2);
    }
    
    atomsNode.position = SCNVector3Make(x/28.4f, y/28.4f, KAtomsNodeZ);

//    NSLog(@"touch (x, y) is (%f, %f)", x, y);
    
//    SCNPhysicsBody
    
}
- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    /*
    [motionManager startAccelerometerUpdatesToQueue:[NSOperationQueue currentQueue] withHandler:^(CMAccelerometerData * _Nullable accelerometerData, NSError * _Nullable error) {
        float accelX = accelerometerData.acceleration.x * 9.8;
        float accelY = accelerometerData.acceleration.y * 9.8;
        float accelZ = accelerometerData.acceleration.z * 9.8;
        
        self->scene.physicsWorld.gravity = SCNVector3Make(scene.rootNode.position.x, accelY, accelZ);
        NSLog(@"%f", accelZ);
    }];
     */
    NSValue *value1 = points.firstObject;
    NSValue *value2 = points.lastObject;

    
    float graY = value2.CGPointValue.y - value1.CGPointValue.y;
    float graX = value2.CGPointValue.x - value1.CGPointValue.x;
    scene.physicsWorld.gravity = SCNVector3Make(graX/4.4f, -9.8, graY/5.4f);
    
    // 初速度
//    float autoX = (graX - graX1)*200 / 28.35;
//    float autoY = (graY - graY1)*200 / 28.35;
    
    SCNVector3 vector = SCNVector3Make(graX/19.4f, - graY/19.4f, 0);
    SCNAction *action = [SCNAction moveBy:vector duration: - graY/100.4f];
    action.speed = - graY / 10.4f;
    action.timingMode = SCNActionTimingModeEaseOut;
    
    [atomsNode runAction:action];
    
//    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"rotation"];
//    animation.duration = 5;
//    animation.toValue = [NSValue valueWithSCNVector4:SCNVector4Make(0, 1, 0, M_PI * 2)];
//    animation.repeatCount = FLT_MAX;
//    [atomsNode addAnimation:animation forKey:@"AtomsNodeAnimation"];
//
//    [rotationNode addAnimation:animation forKey:@"RotationNodeAnimation"];

    NSLog(@"%f", scene.physicsWorld.speed);
}


- (void)physicsWorld:(SCNPhysicsWorld *)world didBeginContact:(SCNPhysicsContact *)contact{
    NSLog(@"didBeginContact");
    SystemSoundID ID;
    
    NSString *urlPath = [[NSBundle mainBundle] pathForResource:@"in" ofType:@"caf"];
    NSURL *url = [NSURL fileURLWithPath:urlPath];
    
    // 创建系统声音，同时返回一个ID
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)(url), &ID);
    
    // 根据ID播放自定义系统声音
    AudioServicesPlaySystemSound(ID);
//    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
}
- (void)physicsWorld:(SCNPhysicsWorld *)world didUpdateContact:(SCNPhysicsContact *)contact{
//    NSLog(@"didUpdateContact");
}
- (void)physicsWorld:(SCNPhysicsWorld *)world didEndContact:(SCNPhysicsContact *)contact{
//    NSLog(@"didEndContact");
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
