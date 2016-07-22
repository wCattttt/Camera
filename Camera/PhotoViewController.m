//
//  PhotoViewController.m
//  Opencv_test
//
//  Created by 魏唯隆 on 16/7/21.
//  Copyright © 2016年 魏唯隆. All rights reserved.
//

#import "PhotoViewController.h"

#import "PhotoView.h"

@interface PhotoViewController ()
{
    
    __weak IBOutlet UILabel *_msgLabel;
}
@end

@implementation PhotoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self _createSession];
    
    
}



- (void)_createSession{
    PhotoView *photoView = [[PhotoView alloc] initWithFrame:[UIScreen mainScreen].bounds withPositionDevice:YES];
    
    CGRect frame;
    frame.size = CGSizeMake(100, 150);
    frame.origin = CGPointMake(self.view.center.x - frame.size.width/2, self.view.center.x - frame.size.height/2);
    
    UIImageView *imgView = [[UIImageView alloc] initWithFrame:frame];
    imgView.image = [UIImage imageNamed:@"A"];
    [photoView addSubview:imgView];
    
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake([UIScreen mainScreen].bounds.size.width - 68, 20, 60, 40)];
    button.layer.masksToBounds =YES;
    button.layer.cornerRadius = 8;
    button.backgroundColor = [UIColor orangeColor];
    [button setTitle:@"点击" forState:UIControlStateNormal];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(clickAciton) forControlEvents:UIControlEventTouchUpInside];
    [photoView addSubview:button];
    
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

#pragma mark Motion方法



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
