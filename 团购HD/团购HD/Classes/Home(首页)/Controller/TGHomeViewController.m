//
//  TGHomeViewController.m
//  团购HD
//
//  Created by BJT on 17/6/14.
//  Copyright © 2017年 BJT. All rights reserved.
//

#import "MJRefresh.h"
#import "AwesomeMenu.h"
#import "UIView+AutoLayout.h"
#import "MBProgressHUD+MJ.h"

#import "UIBarButtonItem+Extension.h"
#import "UIView+Extension.h"

#import "TGMetaTool.h"
#import "TGHomeViewController.h"
#import "TGConst.h"
#import "TGHomeTopItem.h"
#import "TGCategoryViewController.h"
#import "TGDistrictViewController.h"
#import "TGCity.h"
#import "TGCategory.h"
#import "TGRegion.h"
#import "TGSortViewController.h"
#import "TGSort.h"
#import "TGSearchController.h"
#import "TGNavigationController.h"
#import "TGCollecController.h"
#import "TGScanHistoryController.h"
#import "TGMapViewController.h"

@interface TGHomeViewController ()<AwesomeMenuDelegate>

/**  分类 */
@property (nonatomic,weak) UIBarButtonItem *categoryItem;
/** 地区*/
@property (nonatomic,weak) UIBarButtonItem *districtItem;
/** 排序*/
@property (nonatomic,weak) UIBarButtonItem *sortItem;

/** 当前选中的城市名字 */
@property (nonatomic,copy) NSString *selectedCityName;
/** 当前选中的分类名字 */
@property (nonatomic,copy) NSString *selectedCategoryName;
/** 当前选中的区域名字 */
@property (nonatomic,copy) NSString *selectedRegionName;
/**  当前选中的排序 */
@property (nonatomic,strong) TGSort *selectedSort;

/**  分类PopoverController */
@property (nonatomic,strong) UIPopoverController * categoryPopover;
/**  区域PopoverController */
@property (nonatomic,strong) UIPopoverController *districtPopover;
/** 排序PopoverController */
@property (nonatomic,strong) UIPopoverController * sortPopover;

@end

@implementation TGHomeViewController


/** 控制器将要可见时,开启通知监听 */
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    // 设置通知监听
    [self setupNotifications];
    
}

/** 控制器不可见时,移除通知监听 */
-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [TGNotificationCenter removeObserver:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 设置导航条左侧内容
    [self setupNavBarLeft];
    // 设置导航条右侧内容
    [self setupNavBarRight];
    // 设置AwesomeMenu
    [self setupAwesomeMenu];
}

-(void)setupNotifications
{
    // 监听城市切换
    [TGNotificationCenter addObserver:self selector:@selector(cityDidChange:) name:TGCityDidChangeNotification object:nil];
    // 监听分类切换
    [TGNotificationCenter addObserver:self selector:@selector(categoryDidChange:) name:TGCategoryDidChangeNotification object:nil];
    // 监听区域切换
    [TGNotificationCenter addObserver:self selector:@selector(regionDidChange:) name:TGRegionDidChangeNotification object:nil];
    // 监听排序切换
    [TGNotificationCenter addObserver:self selector:@selector( sortDidChange:) name:TGSortDidChangeNotification object:nil];
}




#pragma mark - 设置AwesomeMenu
-(void)setupAwesomeMenu
{
    AwesomeMenuItem *startItem = [[AwesomeMenuItem alloc] initWithImage:[UIImage imageNamed:@"icon_pathMenu_background_normal"] highlightedImage:[UIImage imageNamed:@"icon_pathMenu_background_highlighted"] ContentImage:[UIImage imageNamed:@"icon_pathMenu_mainMine_normal"] highlightedContentImage:[UIImage imageNamed:@"icon_pathMenu_mainMine_highlighted"]];
    // 个人
    AwesomeMenuItem *mineItem = [[AwesomeMenuItem alloc] initWithImage:[UIImage imageNamed:@"bg_pathMenu_black_normal"] highlightedImage:[UIImage imageNamed:@"icon_pathMenu_background"] ContentImage:[UIImage imageNamed:@"icon_pathMenu_mine_normal"] highlightedContentImage:[UIImage imageNamed:@"icon_pathMenu_mine_highlighted"]];
    // 收藏
    AwesomeMenuItem *collectItem = [[AwesomeMenuItem alloc] initWithImage:[UIImage imageNamed:@"bg_pathMenu_black_normal"] highlightedImage:[UIImage imageNamed:@"icon_pathMenu_background"] ContentImage:[UIImage imageNamed:@"icon_pathMenu_collect_normal"] highlightedContentImage:[UIImage imageNamed:@"icon_pathMenu_collect_highlighted"]];
    // 浏览记录
    AwesomeMenuItem *scanItem = [[AwesomeMenuItem alloc] initWithImage:[UIImage imageNamed:@"bg_pathMenu_black_normal"] highlightedImage:[UIImage imageNamed:@"icon_pathMenu_background"] ContentImage:[UIImage imageNamed:@"icon_pathMenu_scan_normal"] highlightedContentImage:[UIImage imageNamed:@"icon_pathMenu_scan_highlighted"]];
    // 更多
    AwesomeMenuItem *moreItem = [[AwesomeMenuItem alloc] initWithImage:[UIImage imageNamed:@"bg_pathMenu_black_normal"] highlightedImage:[UIImage imageNamed:@"icon_pathMenu_background"] ContentImage:[UIImage imageNamed:@"icon_pathMenu_more_normal"] highlightedContentImage:[UIImage imageNamed:@"icon_pathMenu_more_highlighted"]];
    
    NSArray *otherItems = @[mineItem,collectItem,scanItem,moreItem];
    AwesomeMenu *menu = [[AwesomeMenu alloc] initWithFrame:CGRectZero startItem:startItem menuItems:otherItems];
    menu.delegate = self;
    menu.startPoint = CGPointMake(50, 150);
    menu.menuWholeAngle = M_PI_2;
    menu.rotateAddButton = NO;
    menu.alpha = 0.3;
    
    [self.view addSubview:menu];
    
    //  设置 menu 的 autoLayout
    [menu autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:0];
    [menu autoPinEdgeToSuperviewEdge:ALEdgeBottom withInset:0];
    [menu autoSetDimensionsToSize:CGSizeMake(200, 200)];
                         
}

#pragma mark - AwesomeMenu代理方法
-(void)awesomeMenuWillAnimateOpen:(AwesomeMenu *)menu
{
    // 更换 主item 图片
    menu.contentImage = [UIImage imageNamed:@"icon_pathMenu_cross_normal"];
    menu.alpha = 1;
}
-(void)awesomeMenuWillAnimateClose:(AwesomeMenu *)menu
{
    // 更换 主item 图片
    menu.contentImage = [UIImage imageNamed:@"icon_pathMenu_mainMine_normal"];
    menu.alpha = 0.3;
    
}
-(void)awesomeMenu:(AwesomeMenu *)menu didSelectIndex:(NSInteger)idx
{
    // 更换 主item 图片
    menu.contentImage = [UIImage imageNamed:@"icon_pathMenu_mainMine_normal"];
    menu.alpha = 0.3;
//    TGLog(@"%d",idx);
    
    switch (idx) {
        case 1:  {  // 收藏
            
            TGCollecController *collect = [[TGCollecController alloc] init];
            TGNavigationController *collectNav = [[TGNavigationController alloc] initWithRootViewController:collect];
            [self presentViewController:collectNav animated:YES completion:nil];
            
        }
            break;
        case 2:  {  // 浏览记录
            
            TGScanHistoryController *scan = [[TGScanHistoryController alloc] init];
            TGNavigationController *scanNav = [[TGNavigationController alloc] initWithRootViewController:scan];
            [self presentViewController:scanNav animated:YES completion:nil];
            
        }
            break;
    }
    
    
}


#pragma mark - 设置导航栏内容
/**
 *  设置导航条左侧内容
 */
-(void)setupNavBarLeft
{
    
    // 1. logo
    UIBarButtonItem *logoItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"icon_meituan_logo"] style:UIBarButtonItemStyleDone target:nil action:nil];
    logoItem.enabled = NO;
    
    // 2. 分类
    TGHomeTopItem *categoryTopItem = [TGHomeTopItem item];
    [categoryTopItem setTitle:@"全部分类"];
    [categoryTopItem setSubTitle:@""];
    [categoryTopItem addTarget:self action:@selector(categoryDidClick)];
    UIBarButtonItem *categoryItem = [[UIBarButtonItem alloc] initWithCustomView:categoryTopItem];
    self.categoryItem = categoryItem;
    
    // 3. 地区
    TGHomeTopItem *districtTopItem = [TGHomeTopItem item];
    [districtTopItem setTitle:@"城市"];
    [districtTopItem setSubTitle:@"市区街道"];
    [districtTopItem setIcon:@"icon_district" highlightedIcon:@"icon_district_highlighted"];
    [districtTopItem addTarget:self action:@selector(districtDidClick)];
    UIBarButtonItem *districtItem = [[UIBarButtonItem alloc] initWithCustomView:districtTopItem];
    self.districtItem = districtItem;
    
    // 4. 排序
    TGHomeTopItem *sortTopItem = [TGHomeTopItem item];
    [sortTopItem setIcon:@"icon_sort" highlightedIcon:@"icon_sort_highlighted"];
    [sortTopItem setTitle:@"排序"];
    [sortTopItem setSubTitle:@"默认排序"];
    
    [sortTopItem addTarget:self action:@selector(sortDidClick)];
    UIBarButtonItem *sortItem = [[UIBarButtonItem alloc] initWithCustomView:sortTopItem];
    self.sortItem = sortItem;
    
    self.navigationItem.leftBarButtonItems = @[logoItem,categoryItem,districtItem,sortItem];
}
/**
 *  设置导航条右侧内容
 */
-(void)setupNavBarRight
{
    // 1.地图
    UIBarButtonItem *mapItem = [UIBarButtonItem itemWithTarget:self action:@selector(map) image:@"icon_map" highlightedImage:@"icon_map_highlighted"];
//    mapItem.customView.backgroundColor = kTGColorRandom;
    mapItem.customView.width = 50; // 设置宽度,拉开两个 item 之间的间距
    
    // 2.搜索
    UIBarButtonItem *searchItem = [UIBarButtonItem itemWithTarget:self action:@selector(search) image:@"icon_search" highlightedImage:@"icon_search_highlighted"];
//    searchItem.customView.backgroundColor = kTGColorRandom;
    searchItem.customView.width = 50;
    self.navigationItem.rightBarButtonItems = @[mapItem,searchItem];
}


#pragma mark - 导航栏点击监听方法
/** 地图按钮点击 */
-(void)map
{
    TGMapViewController *map = [[TGMapViewController alloc] init];
    TGNavigationController *mapNav = [[TGNavigationController alloc] initWithRootViewController:map];
    [self presentViewController:mapNav animated:YES completion:nil];
    
}

/**
 *  搜索按钮点击
 */
-(void)search
{
    TGSearchController *search = [[TGSearchController alloc] init];
    // 设置搜索的城市
    if (self.selectedCityName.length) { // 已选择城市
        
        search.searchCityNmae = self.selectedCityName;
        TGNavigationController *searchNav = [[TGNavigationController alloc] initWithRootViewController:search];
        [self presentViewController:searchNav animated:YES completion:nil];
        
    }else{
        
        [MBProgressHUD showError:@"请选择城市后再搜索" toView: self.view];
    }
}

/**
 *  分类点击
 */
-(void)categoryDidClick
{
    self.categoryPopover = [[UIPopoverController alloc] initWithContentViewController:[[TGCategoryViewController alloc] init]];
    [self.categoryPopover presentPopoverFromBarButtonItem:self.categoryItem permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    
}

/**
 *  地区点击
 */
-(void)districtDidClick
{
    TGDistrictViewController *districtVc = [[TGDistrictViewController alloc] init];
    self.districtPopover = [[UIPopoverController alloc] initWithContentViewController:districtVc];
    [self.districtPopover presentPopoverFromBarButtonItem:self.districtItem permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
     if(self.selectedCityName.length)
     {
         // 通过当前选中的城市名字找出对应的城市模型
         NSPredicate *predicate = [NSPredicate predicateWithFormat:@"name == %@",self.selectedCityName];
         TGCity *city = [[[TGMetaTool cities] filteredArrayUsingPredicate:predicate] firstObject];
         districtVc.regions = city.regions;
         
     }
    // 以便于在 districtVc 控制器中,可以 dismiss pop
    districtVc.pop = self.districtPopover;
}

/**
 *  排序点击
 */
-(void)sortDidClick
{
    self.sortPopover = [[UIPopoverController alloc] initWithContentViewController:[[TGSortViewController alloc] init]];
    [self.sortPopover presentPopoverFromBarButtonItem:self.sortItem permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    
}


#pragma mark -通知监听方法
/**
 *  城市改变
 */
-(void)cityDidChange:(NSNotification *)noti
{
//    TGLog(@"%@",noti.userInfo[NSDidSelectCityName]);
    NSString *cityName = noti.userInfo[TGSelectCityName];
    self.selectedCityName = cityName;
     // 1.更换顶部item的文字
    TGHomeTopItem *top = (TGHomeTopItem *)self.districtItem.customView;
    [top setTitle:[NSString stringWithFormat:@"%@ - 全部",cityName]];
    [top setSubTitle:nil];
    
    // 从服务器获取数据,刷新view
    [self.collectionView  headerBeginRefreshing];
    

}
/**
 *  分类改变
 */
-(void)categoryDidChange:(NSNotification *)noti
{
    TGCategory *category = noti.userInfo[TGSelectCategory];
    NSString *subcategoryName = noti.userInfo[TGSelectSubCategoryName];
    
    if(subcategoryName == nil || [subcategoryName isEqualToString:@"全部"]){
        
        self.selectedCategoryName = [category.name isEqualToString:@"全部分类"]?nil:category.name;
        
    }else{
        
        self.selectedCategoryName = subcategoryName;
    }
    
     // 更换顶部item的文字
    TGHomeTopItem *top = (TGHomeTopItem *)self.categoryItem.customView;
    [top setTitle:category.name];
    [top setIcon:category.icon highlightedIcon:category.highlighted_icon];
    [top setSubTitle:subcategoryName];
    // 关闭 popover
    [self.categoryPopover dismissPopoverAnimated:YES];
    
    // 从服务器获取数据,刷新view
    [self.collectionView  headerBeginRefreshing];
    
}
/**
 *  区域改变
 */
-(void)regionDidChange:(NSNotification *)noti
{
    TGRegion *region = noti.userInfo[TGSelectRegion];
    NSString *subregionName = noti.userInfo[TGSelectSubRegionName];
    
    if(subregionName == nil || [subregionName isEqualToString:@"全部"]){
        
        self.selectedRegionName = [region.name isEqualToString:@"全部"]? nil:region.name;
        
    }else{
        
        self.selectedRegionName = subregionName;
    }
    
     // 更换顶部item的文字
    TGHomeTopItem *top = (TGHomeTopItem *)self.districtItem.customView;
    [top setTitle:[NSString stringWithFormat:@"%@-%@",self.selectedCityName,region.name]];
    [top setSubTitle:subregionName];
    // 关闭 popover
    [self.districtPopover dismissPopoverAnimated:YES];
    
    // 从服务器获取数据,刷新view
    [self.collectionView  headerBeginRefreshing];
}
/**
 *  排序改变
 */
-(void)sortDidChange:(NSNotification *)noti
{
    TGSort *sort = noti.userInfo[TGSelectSort];
    self.selectedSort = sort;
    // 更换顶部item的文字
    TGHomeTopItem *top = (TGHomeTopItem *)self.sortItem.customView;
    [top setSubTitle:sort.label];
    // 关闭 popover
    [self.sortPopover dismissPopoverAnimated:YES];
    
    // 从服务器获取数据,刷新view
    [self.collectionView  headerBeginRefreshing];
}

#pragma mark - 实现父类方法,设置请求参数
-(void)setupRequestParas:(NSMutableDictionary *)paras
{
    paras[@"city"] = self.selectedCityName;
    // 分类参数
    if (self.selectedCategoryName) {
        paras[@"category"] = self.selectedCategoryName;
    }
    // 区域参数
    if (self.selectedRegionName) {
        paras[@"region"] = self.selectedRegionName;
    }
    // 排序参数
    if (self.selectedSort) {
        paras[@"sort"] = @(self.selectedSort.value);
    }
}



@end
