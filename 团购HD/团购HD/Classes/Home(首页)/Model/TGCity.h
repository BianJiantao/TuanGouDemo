//
//  TGCity.h
//  团购HD
//
//  Created by BJT on 17/6/17.
//  Copyright © 2017年 BJT. All rights reserved.
// 城市模型

#import <Foundation/Foundation.h>

@interface TGCity : NSObject
/** 城市名字 */
@property (nonatomic, copy) NSString *name;
/** 城市名字的拼音 */
@property (nonatomic, copy) NSString *pinYin;
/** 城市名字的拼音声母 */
@property (nonatomic, copy) NSString *pinYinHead;
/** 区域(存放的都是TGRegion模型) */
@property (nonatomic, strong) NSArray *regions;
@end
