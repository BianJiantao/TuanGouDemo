//
//  TGSort.h
//  团购HD
//
//  Created by BJT on 17/6/19.
//  Copyright © 2017年 BJT. All rights reserved.
// 排序模型

#import <Foundation/Foundation.h>

@interface TGSort : NSObject
/** 排序名称 */
@property (nonatomic, copy) NSString *label;
/** 排序的值(将来发给服务器) */
@property (nonatomic, assign) NSInteger value;
@end
