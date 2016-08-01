//
//  GeoPointCompass.h
//  Camera
//
//  Created by 魏唯隆 on 16/7/22.
//  Copyright © 2016年 魏唯隆. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

@interface GeoPointCompass : NSObject <CLLocationManagerDelegate>

@property (nonatomic, retain) CLLocationManager* locationManager;

@property (nonatomic, retain) UIImageView *arrowImageView;

@property (nonatomic) CLLocationDegrees latitudeOfTargetedPoint;

@property (nonatomic) CLLocationDegrees longitudeOfTargetedPoint;

@end
