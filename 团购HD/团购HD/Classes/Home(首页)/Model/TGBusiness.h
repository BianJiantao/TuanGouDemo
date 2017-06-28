//
//  TGBusiness.h
//  团购HD
//
//  Created by BJT on 17/6/28.
//  Copyright © 2017年 BJT. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TGBusiness : NSObject

/** 店名 */
@property (nonatomic, copy) NSString *name;
/** 纬度 */
@property (nonatomic, assign) float latitude;
/** 经度 */
@property (nonatomic, assign) float longitude;

@end
