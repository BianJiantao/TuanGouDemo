//
//  TGDealTool.h
//  团购HD
//
//  Created by BJT on 17/6/25.
//  Copyright © 2017年 BJT. All rights reserved.
// 管理收藏到数据库的订单数据


#import <Foundation/Foundation.h>

// 数据库每页记录数, 暴露出来以便其他地方计算数据页码使用 (内存数据与数据库数据同步)
//static int const PageSize = 20;
#define PageSize 20

@class TGDeal;

@interface TGDealTool : NSObject


/**
 *  获取指定页码的收藏订单, page 从 1 开始
 */
+(NSArray *)dealsOfCollectWithPage:(NSInteger)page;
/** 收藏订单的总数 */
+(NSInteger)dealCollectTotalCount;

/**
 *  添加一个收藏订单
 */
+(void)addDealToCollect:(TGDeal *)deal;
/**
 *  取消一个收藏订单
 */
+(void)removeDealFromCollect:(TGDeal *)deal;

/**
 *  判断一个订单是否已收藏
 */
+(BOOL)isCollected:(TGDeal *)deal;

@end
