//
//  TGDealRestrictions.h
//  团购HD
//
//  Created by BJT on 17/6/25.
//  Copyright © 2017年 BJT. All rights reserved.
// 订单限制条件

#import <Foundation/Foundation.h>

@interface TGDealRestrictions : NSObject

/** int	是否需要预约，0：不是，1：是 */
@property (nonatomic, assign) int  is_reservation_required;
/** int	是否支持随时退款，0：不是，1：是*/
@property (nonatomic, assign) int  is_refundable;
/** string	附加信息(一般为团购信息的特别提示)*/
@property (nonatomic, copy) NSString *special_tips;

@end
