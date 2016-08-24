//
//  ViewController.m
//  Camera
//
//  Created by 魏唯隆 on 16/7/22.
//  Copyright © 2016年 魏唯隆. All rights reserved.
//

#import "ViewController.h"
#import <CoreMotion/CoreMotion.h>
#import "NavViewController.h"
#import "ParabolaViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
}

- (IBAction)nav:(id)sender {
    NavViewController *navVC = [[NavViewController alloc] init];
    [self presentViewController:navVC animated:YES completion:nil];
}
- (IBAction)parabola:(id)sender {
    ParabolaViewController *parabolaVC = [[ParabolaViewController alloc] init];
    [self presentViewController:parabolaVC animated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
