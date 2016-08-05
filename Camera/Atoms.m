//
//  Atoms.m
//  Camera
//
//  Created by 魏唯隆 on 16/8/2.
//  Copyright © 2016年 魏唯隆. All rights reserved.
//

#import "Atoms.h"


@implementation Atoms
{
    CFTimeInterval _beginTime;
}
- (instancetype)init{
    self = [super init];
    if(self){
        _beginTime = 0;
    }
    return self;
}

- (SCNGeometry *)fluorineAtom{
    SCNSphere *fluorineAtom = [SCNSphere sphereWithRadius:1.5];
    fluorineAtom.firstMaterial.diffuse.contents = [UIColor greenColor];
    fluorineAtom.firstMaterial.specular.contents = [UIColor whiteColor];
    
    CABasicAnimation *colorAnimation = [CABasicAnimation animationWithKeyPath:@"contents"];
    colorAnimation.beginTime = _beginTime;
    _beginTime += 0.1;
    colorAnimation.autoreverses = YES;
    colorAnimation.repeatCount = HUGE_VALF;
    colorAnimation.duration = 1.2;
    colorAnimation.fromValue = [UIColor greenColor];
    colorAnimation.toValue = [UIColor redColor];
    [fluorineAtom.firstMaterial.diffuse addAnimation:colorAnimation forKey:@"colorAnimation"];
    
    return fluorineAtom;
    
    /*
    let fluorineAtom = SCNSphere(radius: 1.5)
    fluorineAtom.firstMaterial!.diffuse.contents = UIColor.green()
    fluorineAtom.firstMaterial!.specular.contents = UIColor.white()
    
    // 添加动画
    let colorAnimation = CABasicAnimation(keyPath: "contents")
    colorAnimation.beginTime = time
    print(time)
    time += 0.1
    colorAnimation.autoreverses = true//是否自动返回
    colorAnimation.repeatCount = Float.infinity//重复次数
    colorAnimation.duration = 1.2//持续时间
    colorAnimation.fromValue = UIColor.green()
    colorAnimation.toValue = UIColor.red()
    fluorineAtom.firstMaterial!.diffuse.add(colorAnimation, forKey: "colorAnimation")
    
    return fluorineAtom
     */
}

- (SCNNode *)allAtoms{
    SCNNode *atomsNode = [[SCNNode alloc] init];
    
    for (int i=0; i<=10; i++) {
        SCNNode *fluorineNode = [SCNNode nodeWithGeometry:[self fluorineAtom]];
        float y = 3*i;
        float z = -4*i;
        fluorineNode.position = SCNVector3Make(0, y, z);
        [atomsNode addChildNode:fluorineNode];
    }
    
    
    return atomsNode;
}
@end
