//
//  TGDealViewController.h
//  团购HD
//
//  Created by BJT on 17/6/23.
//  Copyright © 2017年 BJT. All rights reserved.
//  团购订单控制器,用于获取订单数据并展示订单  ( 作为抽取的父类 )

#import <UIKit/UIKit.h>

@interface TGDealViewController : UICollectionViewController

/**
 *  设置请求参数,暴露出来,由子类实现
 */
-(void)setupRequestParas:(NSMutableDictionary *)paras;

@end
