//
//  TGDealCell.h
//  团购HD
//
//  Created by BJT on 17/6/22.
//  Copyright © 2017年 BJT. All rights reserved.
// 团购订单 cell

#import <UIKit/UIKit.h>

@class TGDeal, TGDealCell;

@interface TGDealCell : UICollectionViewCell
/**  团购订单模型 */
@property (nonatomic, strong) TGDeal *deal;

@end
