//
//  TGConst.h
//  团购HD
//
//  Created by BJT on 17/6/14.
//  Copyright © 2017年 BJT. All rights reserved.
//

#ifdef DEBUG
     //#define  TGLog(...) NSLog(__VA_ARGS__)
     #define TGLog(...) NSLog(@"%s\n %@ \n\n",__func__,[NSString stringWithFormat:__VA_ARGS__])
#else
    #define TGLog(...)
#endif

#define kTGColorRGB(r, g, b) [UIColor colorWithRed:(r)/255.0 green:(g)/255.0 blue:(b)/255.0 alpha:1.0]
#define kTGColorRandom kTGColorRGB(arc4random_uniform(256), arc4random_uniform(256), arc4random_uniform(256))

#define kTGGlobalBackGroundColor kTGColorRGB(230, 230, 230)

#define TGNotificationCenter [NSNotificationCenter defaultCenter]
/**
 *  切换城市的通知
 */
extern NSString *const TGCityDidChangeNotification;
/**
 *  切换的城市名字 (key)
 */
extern NSString *const TGSelectCityName;

/**
 *  切换分类的通知
 */
extern NSString *const TGCategoryDidChangeNotification;
/**
 *  切换的分类 (key)
 */
extern NSString *const TGSelectCategory;
/**
 *  切换的子分类名称 (key)
 */
extern NSString *const TGSelectSubCategoryName;

/**
 *  切换区域的通知
 */
extern NSString *const TGRegionDidChangeNotification;
/**
 *  切换的区域 (key)
 */
extern NSString *const TGSelectRegion;
/**
 *  切换的子区域名称 (key)
 */
extern NSString *const TGSelectSubRegionName;

/**
 *  切换排序的通知
 */
extern NSString *const TGSortDidChangeNotification;
/**
 *  切换的排序 (key)
 */
extern NSString *const TGSelectSort;
