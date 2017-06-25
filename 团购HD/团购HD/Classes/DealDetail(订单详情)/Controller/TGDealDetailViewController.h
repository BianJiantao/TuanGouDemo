//
//  TGDealDetailViewController.h
//  团购HD
//
//  Created by BJT on 17/6/24.
//  Copyright © 2017年 BJT. All rights reserved.
//  订单详情

#import <UIKit/UIKit.h>

@class TGDeal;

@interface TGDealDetailViewController : UIViewController
/** 要展示的订单 */
@property (nonatomic,strong) TGDeal *deal;

@end
