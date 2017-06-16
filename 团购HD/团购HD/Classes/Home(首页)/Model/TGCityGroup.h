//
//  TGCityGroup.h
//  团购HD
//
//  Created by BJT on 17/6/16.
//  Copyright © 2017年 BJT. All rights reserved.
// 城市组模型

#import <Foundation/Foundation.h>

@interface TGCityGroup : NSObject

/** 这组的标题 */
@property (nonatomic, copy) NSString *title;
/** 这组的所有城市 */
@property (nonatomic, strong) NSArray *cities;

@end
