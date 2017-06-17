//
//  TGRegion.h
//  团购HD
//
//  Created by BJT on 17/6/17.
//  Copyright © 2017年 BJT. All rights reserved.
//  城市的街区模型

#import <Foundation/Foundation.h>

@interface TGRegion : NSObject
/** 区域名字 */
@property (nonatomic, copy) NSString *name;
/** 子区域 (存储字符串) */
@property (nonatomic, strong) NSArray *subregions;
@end
