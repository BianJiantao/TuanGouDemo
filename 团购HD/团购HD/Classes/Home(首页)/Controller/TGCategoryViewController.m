//
//  TGCategoryViewController.m
//  团购HD
//
//  Created by BJT on 17/6/16.
//  Copyright © 2017年 BJT. All rights reserved.
//

#import "MJExtension.h"
#import "UIView+Extension.h"

#import "TGMetaTool.h"
#import "TGCategoryViewController.h"
#import "TGHomeDropDownMenu.h"
#import "TGConst.h"
#import "TGCategory.h"

@interface TGCategoryViewController ()<TGHomeDropDownMenuDataSource,TGHomeDropDownMenuDelegate>

@end

@implementation TGCategoryViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    TGHomeDropDownMenu *dropDownMenu = [TGHomeDropDownMenu dropDownMenu];
    dropDownMenu.dataSource = self;
    dropDownMenu.delegate  = self;
    self.view = dropDownMenu;
    
    // 设置控制器在 popover 中的尺寸
    self.preferredContentSize = dropDownMenu.size;
    
    
}
//
//-(void)viewWillAppear:(BOOL)animated
//{
//    [super viewWillAppear:animated];
//    
//    
//    TGLog(@"%@",self.view);
//    TGLog(@"preferredContentSize%@",NSStringFromCGSize(self.preferredContentSize));
//}


#pragma mark -TGHomeDropDownMenuDataSource 数据源方法
-(NSInteger)numberOfRowsInMainTable:(TGHomeDropDownMenu *)homeDropDownMenu
{
    return [TGMetaTool categories].count;
}

-(NSString *)homeDropDownMenu:(TGHomeDropDownMenu *)homeDropDownMenu titleForRowInMainTable:(NSInteger)row
{
    TGCategory *category = [TGMetaTool categories][row];
    return category.name;
}
-(NSArray *)homeDropDownMenu:(TGHomeDropDownMenu *)homeDropDownMenu subdataForRowInMainTable:(NSInteger)row
{
    TGCategory *category = [TGMetaTool categories][row];
    return category.subcategories;
}

-(NSString *)homeDropDownMenu:(TGHomeDropDownMenu *)homeDropDownMenu iconForRowInMainTable:(NSInteger)row
{
    TGCategory *category = [TGMetaTool categories][row];
    return category.small_icon;
}
-(NSString *)homeDropDownMenu:(TGHomeDropDownMenu *)homeDropDownMenu highLightedIconForRowInMainTable:(NSInteger)row
{
    TGCategory *category = [TGMetaTool categories][row];
    return category.small_highlighted_icon;
}

#pragma mark -TGHomeDropDownMenuDelegate  代理方法

-(void)homeDropDownMenu:(TGHomeDropDownMenu *)homeDropDownMenu didSelectRowInMainTable:(NSInteger)row
{
    TGCategory *category = [TGMetaTool categories][row];
    if (category.subcategories.count == 0) { // 没有子分类
        
        // 发出切换分类的通知
        [TGNotificationCenter postNotificationName:TGCategoryDidChangeNotification object:nil userInfo:@{TGSelectCategory:category}];
    }
}

-(void)homeDropDownMenu:(TGHomeDropDownMenu *)homeDropDownMenu didSelectRowInSubTable:(NSInteger)subRow forMainTableRow:(NSInteger)mainRow
{
    TGCategory *category = [TGMetaTool categories][mainRow];
    NSString *subcategoryName = category.subcategories[subRow];
    [TGNotificationCenter postNotificationName:TGCategoryDidChangeNotification object:nil userInfo:@{TGSelectCategory:category,TGSelectSubCategoryName:subcategoryName}];
}

@end
