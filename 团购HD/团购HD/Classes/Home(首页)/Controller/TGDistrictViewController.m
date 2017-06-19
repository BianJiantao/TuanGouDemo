//
//  TGDistrictViewController.m
//  团购HD
//
//  Created by BJT on 17/6/16.
//  Copyright © 2017年 BJT. All rights reserved.
//

#import "UIView+Extension.h"

#import "TGConst.h"
#import "TGDistrictViewController.h"
#import "TGHomeDropDownMenu.h"
#import "TGCityViewController.h"
#import "TGNavigationController.h"
#import "TGRegion.h"

@interface TGDistrictViewController ()<TGHomeDropDownMenuDataSource,TGHomeDropDownMenuDelegate>
- (IBAction)switchCity;

@end

@implementation TGDistrictViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIView *title = [self.view.subviews firstObject];
    
    TGHomeDropDownMenu *dropDownMenu = [TGHomeDropDownMenu dropDownMenu];
    dropDownMenu.dataSource = self;
    dropDownMenu.delegate = self;
    [self.view addSubview:dropDownMenu];
    dropDownMenu.y = CGRectGetMaxY(title.frame);
    
    self.preferredContentSize = CGSizeMake(dropDownMenu.width, CGRectGetMaxY(dropDownMenu.frame));
    
}


- (IBAction)switchCity
{
    // 关闭 popover
    [self.pop dismissPopoverAnimated:YES];
    
    TGCityViewController *cityVc = [[TGCityViewController alloc] init];
    TGNavigationController *navCityVc = [[TGNavigationController alloc] initWithRootViewController:cityVc];
    navCityVc.modalPresentationStyle =  UIModalPresentationFormSheet;
    [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:navCityVc animated:YES completion:nil];
    
}

#pragma mark -TGHomeDropDownMenuDataSource 数据源方法

-(NSInteger)numberOfRowsInMainTable:(TGHomeDropDownMenu *)homeDropDownMenu
{
    return self.regions.count;
}

-(NSString *)homeDropDownMenu:(TGHomeDropDownMenu *)homeDropDownMenu titleForRowInMainTable:(NSInteger)row
{
    TGRegion *region = self.regions[row];
    return region.name;
}

-(NSArray *)homeDropDownMenu:(TGHomeDropDownMenu *)homeDropDownMenu subdataForRowInMainTable:(NSInteger)row
{
    TGRegion *region = self.regions[row];
    return region.subregions;
}

#pragma mark -TGHomeDropDownMenuDelegate 代理方法
-(void)homeDropDownMenu:(TGHomeDropDownMenu *)homeDropDownMenu didSelectRowInMainTable:(NSInteger)row
{
    TGRegion *region = self.regions[row];
    if (region.subregions.count == 0) { // 没有子区域
        
        // 发出切换分类的通知
        [TGNotificationCenter postNotificationName:TGRegionDidChangeNotification object:nil userInfo:@{TGSelectRegion:region}];
    }
}

-(void)homeDropDownMenu:(TGHomeDropDownMenu *)homeDropDownMenu didSelectRowInSubTable:(NSInteger)subRow forMainTableRow:(NSInteger)mainRow
{
     TGRegion *region = self.regions[mainRow];
    NSString *subregionName = region.subregions[subRow];
    [TGNotificationCenter postNotificationName:TGRegionDidChangeNotification object:nil userInfo:@{TGSelectRegion:region,TGSelectSubRegionName:subregionName}];
}

@end
