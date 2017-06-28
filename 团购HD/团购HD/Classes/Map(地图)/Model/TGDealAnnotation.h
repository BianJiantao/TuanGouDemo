//
//  TGDealAnnotation.h
//  团购HD
//
//  Created by BJT on 17/6/28.
//  Copyright © 2017年 BJT. All rights reserved.
// 地图大头针模型

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface TGDealAnnotation : NSObject <MKAnnotation>

@property (nonatomic, assign) CLLocationCoordinate2D coordinate;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *subtitle;
/** 图片名 */
@property (nonatomic, copy) NSString *icon;

@end
