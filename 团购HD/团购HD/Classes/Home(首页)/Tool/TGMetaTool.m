//
//  TGMetaTool.m
//  团购HD
//
//  Created by BJT on 17/6/18.
//  Copyright © 2017年 BJT. All rights reserved.
//

#import "TGMetaTool.h"
#import "MJExtension.h"
#import "TGCategory.h"
#import "TGCity.h"
#import "TGSort.h"

@implementation TGMetaTool

// 只加载一次
static NSArray *_categories;
+(NSArray<TGCategory *> *)categories
{
    if (_categories == nil) {
        
        _categories = [TGCategory objectArrayWithFilename:@"categories.plist"];
    }
     return _categories;
}

static NSArray *_cities;
+(NSArray<TGCity *> *)cities
{
    if (_cities == nil) {
        
        _cities = [TGCity objectArrayWithFilename:@"cities.plist"];
    }
    return _cities;
}

static NSArray *_sorts;
+(NSArray<TGSort *> *)sorts
{
    if (_sorts == nil) {
        
        _sorts = [TGSort objectArrayWithFilename:@"sorts.plist"];
    }
    return _sorts;
}

@end
