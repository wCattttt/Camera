//
//  ViewController.m
//  SceneKit_03
//
//  Created by 魏唯隆 on 2016/8/25.
//  Copyright © 2016年 魏唯隆. All rights reserved.
//

#import "MotionViewController.h"
#import <SceneKit/SceneKit.h>
#import <CoreMotion/CoreMotion.h>
#import <GLKit/GLKit.h>

#import "PhotoView.h"

#define ScreenWidth [UIScreen mainScreen].bounds.size.width
#define ScreenHeight [UIScreen mainScreen].bounds.size.height

#define CAMERA_FOX  70             //50
#define CAMERA_HEIGHT   20          //20
#define GROUND_POS  -50
#define MENU_ZAN         @"MENU_ZAN"

@interface  MotionViewController()<SCNSceneRendererDelegate>
{
//    PhotoView *photoView;
}


//基础Scene
@property (nonatomic,retain)SCNScene *rootScene;
@property (nonatomic,retain)SKScene *spriteKitScene;
@property (nonatomic,retain)SCNNode *floorNode;
@property (nonnull,retain)SCNLight *light;  //灯光

//摄像机
@property(nonatomic,retain)SCNView *leftView;
@property(nonatomic,retain)SCNNode *cameraLeftNode;

@property(nonatomic,retain)SCNNode *cameraRollLeftNode;
@property(nonatomic,retain)SCNNode *cameraPitchLeftNode;
@property(nonatomic,retain)SCNNode *cameraYawLeftNode;

@property(nonatomic,retain)CMMotionManager *motionManager;
@end

@implementation MotionViewController

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
    // Do any additional setup after loading the view.
    
//    photoView = [[PhotoView alloc] initWithFrame:[UIScreen mainScreen].bounds withPositionDevice:YES];
//    [self.view addSubview:photoView];
    
    [self initScene];
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(8, 20, 60, 40);
    button.layer.masksToBounds = YES;
    button.layer.cornerRadius = 8;
    [button setTitle:@"back" forState:UIControlStateNormal];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    button.backgroundColor = [UIColor colorWithRed:40.2f/255 green:180.2f/255 blue:247.2f/255 alpha:1];
    [button addTarget:self action:@selector(backAction) forControlEvents:UIControlEventTouchUpInside];
//    [photoView addSubview:button];
    [self.view addSubview:button];
    
    
    [self addPlaneNodeControlWidth:30 Height:30 Scale:1 Position:SCNVector3Make(150, 0, 0) Rotation:SCNVector4Make(0, 1, 0, -(float)M_PI_2) andName:@"icon_praise.png" withTag:MENU_ZAN];
    
    [self addPlaneNodeControlWidth:30 Height:25 Scale:1 Position:SCNVector3Make(150, 0, 80) Rotation:SCNVector4Make(0, 1, 0, -(float)M_PI_2) andName:@"icon_praise.png" withTag:@"okok"];
}

- (void)backAction {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    self.leftView.playing = YES;
    self.leftView.scene.paused = NO;
 
}
- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    if(self.leftView != nil)
    {
        self.leftView.playing = NO;
        self.leftView.scene.paused = YES;
    }
    [self.motionManager stopDeviceMotionUpdates];
}


- (void)initScene
{
    _rootScene = [SCNScene scene];
    _leftView = [[SCNView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight) options:nil];
    _leftView.scene = self.rootScene;
    _leftView.alpha = 0;
    _leftView.playing = NO;
    _leftView.autoenablesDefaultLighting = YES;
    _leftView.userInteractionEnabled = YES;
    _leftView.multipleTouchEnabled = YES;
    [_leftView setJitteringEnabled:YES];
    [_leftView autoenablesDefaultLighting];
    _leftView.backgroundColor = [UIColor clearColor];
    _leftView.delegate = self;
//    [photoView addSubview:_leftView];
    [self.view addSubview:_leftView];
    
    self.cameraLeftNode = [SCNNode node];
    SCNCamera *cameraLeft = [SCNCamera camera];
    cameraLeft.xFov = CAMERA_FOX;
    cameraLeft.yFov = CAMERA_FOX;
    cameraLeft.zFar = 700;
    self.cameraLeftNode.camera = cameraLeft;
    SCNVector3 v3Left = {-0.1,CAMERA_HEIGHT,0};
    _cameraLeftNode.position = v3Left;
    _cameraLeftNode.eulerAngles = SCNVector3Make(GLKMathDegreesToRadians(-90), 0, 0);
    
    
    _cameraRollLeftNode = [SCNNode node];
    _cameraPitchLeftNode = [SCNNode node];
    _cameraYawLeftNode = [SCNNode node];
    [_cameraRollLeftNode addChildNode:_cameraLeftNode];
    [_cameraPitchLeftNode addChildNode:_cameraRollLeftNode];
    [_cameraYawLeftNode addChildNode:_cameraPitchLeftNode];
    
    
    [_rootScene.rootNode addChildNode:_cameraYawLeftNode];
    _leftView.pointOfView = _cameraLeftNode;
    
    
    _motionManager = [[CMMotionManager alloc] init];
    _motionManager.deviceMotionUpdateInterval = 1/60;
    [_motionManager startDeviceMotionUpdatesUsingReferenceFrame:CMAttitudeReferenceFrameXArbitraryCorrectedZVertical toQueue:[[NSOperationQueue alloc] init] withHandler:^(CMDeviceMotion *motion, NSError *error) {
    }];
    
    _light = [SCNLight light];
    _light.type = SCNLightTypeOmni;
    _light.color = [UIColor whiteColor];
    SCNNode *lightNode = [SCNNode node];
    lightNode.light = self.light;
    SCNVector3 lightV3 = {0,0,0};
    lightNode.position = lightV3;
    [_rootScene.rootNode addChildNode:lightNode];
    
    SCNLight *light2 = [SCNLight light];
    light2.type = SCNLightTypeSpot;
    light2.color = [UIColor colorWithWhite:0.3 alpha:1.0f];
    SCNNode *lightNode2 = [SCNNode node];
    lightNode2.light = light2;
    lightNode2.rotation = SCNVector4Make(1, 0, 0, -M_PI/2);
    SCNVector3 light2V3 = {0,900,0};
    lightNode2.position = light2V3;
    [_rootScene.rootNode addChildNode:lightNode2];
    
    _leftView.alpha = 1;
    
}


- (BOOL)addPlaneNodeControlWidth:(float)width Height:(float)height Scale:(float)scale Position:(SCNVector3)position Rotation:(SCNVector4)rotation andName:(NSString *)name withTag:(NSString *)tag
{
    
    SCNPlane *plane = [SCNPlane planeWithWidth:width height:height];
    plane.firstMaterial.doubleSided = YES;
    plane.firstMaterial.diffuse.contents = [UIImage imageNamed:name];
    plane.firstMaterial.diffuse.wrapS = SCNWrapModeClamp;
    plane.firstMaterial.diffuse.wrapT = SCNWrapModeClamp;
    plane.firstMaterial.diffuse.mipFilter = SCNFilterModeNearest;
    plane.firstMaterial.locksAmbientWithDiffuse = YES;
    plane.firstMaterial.shininess = 0.0f;
    
    SCNBox *fluorineAtom = [SCNBox boxWithWidth:50 height:50 length:50 chamferRadius:1];
    fluorineAtom.firstMaterial.diffuse.contents = [UIColor greenColor];
    fluorineAtom.firstMaterial.specular.contents = [UIColor whiteColor];
    
    SCNNode *node = [SCNNode node];
    node.name = tag;
    node.physicsBody = SCNPhysicsBodyTypeStatic;
    node.physicsBody.restitution = 1.0f;
    node.geometry = fluorineAtom;
    node.scale = SCNVector3Make(scale, scale, scale);
    node.position = position;
    node.rotation = rotation;
    if(tag != nil){
        node.name = tag;
    }
    [_rootScene.rootNode addChildNode:node];
    return YES;
}

- (void)renderer:(id <SCNSceneRenderer>)renderer willRenderScene:(SCNScene *)scene atTime:(NSTimeInterval)time
{
    if(_cameraRollLeftNode != nil && _cameraPitchLeftNode != nil && _cameraYawLeftNode != nil && _motionManager != nil)
    {
        @autoreleasepool {
            SCNVector3 v13 = _cameraRollLeftNode.eulerAngles;
            v13.z = (float)(0 - _motionManager.deviceMotion.attitude.roll);
            _cameraRollLeftNode.eulerAngles = v13;
            
            SCNVector3 v23 = _cameraPitchLeftNode.eulerAngles;
            v23.x = _motionManager.deviceMotion.attitude.pitch;
            _cameraPitchLeftNode.eulerAngles = v23;
            
            SCNVector3 v33 = _cameraYawLeftNode.eulerAngles;
            v33.y = _motionManager.deviceMotion.attitude.yaw;
            _cameraYawLeftNode.eulerAngles = v33;
        }
        
    }
}


- (void)dealloc{
    _rootScene = nil;
    _spriteKitScene = nil;
    _floorNode = nil;
    
    _leftView = nil;
    _cameraLeftNode = nil;
    
    _cameraRollLeftNode = nil;
    _cameraPitchLeftNode = nil;
    _cameraYawLeftNode = nil;
    
    _motionManager = nil;

}


@end
