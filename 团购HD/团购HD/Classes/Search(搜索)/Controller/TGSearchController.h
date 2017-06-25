//
//  TGSearchController.h
//  团购HD
//
//  Created by BJT on 17/6/23.
//  Copyright © 2017年 BJT. All rights reserved.
// 继承自 TGDealViewController

#import "TGDealViewController.h"

@interface TGSearchController : TGDealViewController

/** 要搜索的城市名字 */
@property (nonatomic,copy) NSString *searchCityNmae;

@end
