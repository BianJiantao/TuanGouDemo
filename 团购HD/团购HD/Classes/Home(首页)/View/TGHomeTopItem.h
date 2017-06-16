//
//  TGHomeTopItem.h
//  团购HD
//
//  Created by BJT on 17/6/14.
//  Copyright © 2017年 BJT. All rights reserved.
// home导航栏左侧 可点击 view

#import <UIKit/UIKit.h>

@interface TGHomeTopItem : UIView

/**
 *  从 xib 加载 view
 */
+(instancetype)item;

/**
 *  设置 view 的监听(传递 view 内部的按钮)
 *
 *  @param target 监听器
 *  @param action 监听方法
 */
-(void)addTarget:(id)target action:(SEL)action;

@end
