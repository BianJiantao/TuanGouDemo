//
//  TGHomeDropDownMenu.h
//  团购HD
//
//  Created by BJT on 17/6/16.
//  Copyright © 2017年 BJT. All rights reserved.
// 导航栏点击弹出的下拉菜单

#import <UIKit/UIKit.h>

@interface TGHomeDropDownMenu : UIView

@property (nonatomic,strong) NSArray *categories;


+(instancetype)dropDownMenu;



@end
