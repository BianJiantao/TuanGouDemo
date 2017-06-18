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


#define NSTGNotificationCenter [NSNotificationCenter defaultCenter]
/**
 *  切换城市的通知
 */
extern NSString *const NSCityDidChangeNotification;
/**
 *  切换的城市名字
 */
extern NSString *const NSDidSelectCityName;
