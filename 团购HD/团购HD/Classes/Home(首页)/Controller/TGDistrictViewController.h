//
//  TGDistrictViewController.h
//  团购HD
//
//  Created by BJT on 17/6/16.
//  Copyright © 2017年 BJT. All rights reserved.
//  地区控制器

#import <UIKit/UIKit.h>

@class TGRegion;
@interface TGDistrictViewController : UIViewController
/**
 *  一个城市的 regions
 */
@property (nonatomic,strong) NSArray<TGRegion *> *regions;
/**
 *  the pop which initWithContentViewController: self
 *  以便于在该控制器中,可以操纵 pop
 */
@property (nonatomic,weak) UIPopoverController *pop;

@end
