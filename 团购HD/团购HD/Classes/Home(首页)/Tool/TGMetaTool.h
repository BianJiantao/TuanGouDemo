//
//  TGMetaTool.h
//  团购HD
//
//  Created by BJT on 17/6/18.
//  Copyright © 2017年 BJT. All rights reserved.
// 元数据工具类: 管理所有元数据(固定不变的描述性数据)

#import <Foundation/Foundation.h>

@class TGCategory,TGCity;
@interface TGMetaTool : NSObject

/**
 *  获取所有分类数据 (categories.plist)
 */
+(NSArray<TGCategory *> *)categories;

/**
 *  获取所有的城市数据 (cities.plist)
 */
+(NSArray <TGCity *> *)cities;

@end
