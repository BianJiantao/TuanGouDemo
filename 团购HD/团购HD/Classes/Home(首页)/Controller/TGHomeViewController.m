//
//  TGHomeViewController.m
//  团购HD
//
//  Created by BJT on 17/6/14.
//  Copyright © 2017年 BJT. All rights reserved.
//

#import "DPAPI.h"

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

@interface TGHomeViewController ()<DPRequestDelegate>

/**
 *  分类
 */
@property (nonatomic,weak) UIBarButtonItem *categoryItem;
/**
 *  地区
 */
@property (nonatomic,weak) UIBarButtonItem *districtItem;
/**
 *  排序
 */
@property (nonatomic,weak) UIBarButtonItem *sortItem;

/**
 *  当前选中的城市名字
 */
@property (nonatomic,copy) NSString *selectedCityName;
/**
 *  当前选中的分类名字
 */
@property (nonatomic,copy) NSString *selectedCategoryName;
/**
 *  当前选中的区域名字
 */
@property (nonatomic,copy) NSString *selectedRegionName;
/**
 *  当前选中的排序
 */
@property (nonatomic,strong) TGSort *selectedSort;



/**
 *  分类PopoverController
 */
@property (nonatomic,strong) UIPopoverController * categoryPopover;
/**
 *  区域PopoverController
 */
@property (nonatomic,strong) UIPopoverController *districtPopover;
/**
 *  排序PopoverController
 */
@property (nonatomic,strong) UIPopoverController * sortPopover;

@end

@implementation TGHomeViewController

static NSString * const reuseIdentifier = @"Cell";


-(instancetype)init
{
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    
    return  [super initWithCollectionViewLayout:flowLayout];
}

-(void)dealloc
{
    [TGNotificationCenter removeObserver:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.collectionView.backgroundColor = kTGColorRGB(230, 230, 230);
    
    // Uncomment the following line to preserve selection between presentations
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Register cell classes
    [self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:reuseIdentifier];
    
    // 设置导航条左侧内容
    [self setupNavBarLeft];
    // 设置导航条右侧内容
    [self setupNavBarRight];
    
    // 监听城市切换
    [TGNotificationCenter addObserver:self selector:@selector(cityDidChange:) name:TGCityDidChangeNotification object:nil];
    // 监听分类切换
    [TGNotificationCenter addObserver:self selector:@selector(categoryDidChange:) name:TGCategoryDidChangeNotification object:nil];
    // 监听区域切换
    [TGNotificationCenter addObserver:self selector:@selector(regionDidChange:) name:TGRegionDidChangeNotification object:nil];
    // 监听排序切换
    [TGNotificationCenter addObserver:self selector:@selector( sortDidChange:) name:TGSortDidChangeNotification object:nil];
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
    [categoryTopItem addTarget:self action:@selector(categoryDidClick)];
    UIBarButtonItem *categoryItem = [[UIBarButtonItem alloc] initWithCustomView:categoryTopItem];
    self.categoryItem = categoryItem;
    
    // 3. 地区
    TGHomeTopItem *districtTopItem = [TGHomeTopItem item];
    [districtTopItem setIcon:@"icon_district" highlightedIcon:@"icon_district_highlighted"];
    [districtTopItem addTarget:self action:@selector(districtDidClick)];
    UIBarButtonItem *districtItem = [[UIBarButtonItem alloc] initWithCustomView:districtTopItem];
    self.districtItem = districtItem;
    
    // 4. 排序
    TGHomeTopItem *sortTopItem = [TGHomeTopItem item];
    [sortTopItem setIcon:@"icon_sort" highlightedIcon:@"icon_sort_highlighted"];
    [sortTopItem setTitle:@"排序"];
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
    UIBarButtonItem *mapItem = [UIBarButtonItem itemWithTarget:nil action:nil image:@"icon_map" highlightedImage:@"icon_map_highlighted"];
//    mapItem.customView.backgroundColor = kTGColorRandom;
    mapItem.customView.width = 50; // 设置宽度,拉开两个 item 之间的间距
    
    // 2.搜索
    UIBarButtonItem *searchItem = [UIBarButtonItem itemWithTarget:nil action:nil image:@"icon_search" highlightedImage:@"icon_search_highlighted"];
//    searchItem.customView.backgroundColor = kTGColorRandom;
    searchItem.customView.width = 50;
    self.navigationItem.rightBarButtonItems = @[mapItem,searchItem];
}


#pragma mark - 导航栏点击监听方法
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
    [self loadNewDeals];

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
    [self loadNewDeals];
    
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
    [self loadNewDeals];
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
    [self loadNewDeals];
}

#pragma mark - 服务器交互

-(void)loadNewDeals
{
    DPAPI *dpApi = [[DPAPI alloc] init];
    
    // 设置请求参数
    NSMutableDictionary *paras = [NSMutableDictionary dictionary];
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
    
    // 每页的条数
    paras[@"limit"] = @5;
    [dpApi requestWithURL:@"v1/deal/find_deals" params:paras delegate:self];
    
    
    TGLog(@"请求参数\n%@",paras);
}
#pragma mark
/*  DPRequestDelegate 代理方法 */
-(void)request:(DPRequest *)request didFinishLoadingWithResult:(id)result
{
    TGLog(@"%@",result);
}

-(void)request:(DPRequest *)request didFailWithError:(NSError *)error
{
    TGLog(@"%@",error);
}
/*************************/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
#warning Incomplete implementation, return the number of sections
    return 0;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
#warning Incomplete implementation, return the number of items
    return 0;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    
    // Configure the cell
    
    return cell;
}

#pragma mark <UICollectionViewDelegate>

/*
// Uncomment this method to specify if the specified item should be highlighted during tracking
- (BOOL)collectionView:(UICollectionView *)collectionView shouldHighlightItemAtIndexPath:(NSIndexPath *)indexPath {
	return YES;
}
*/

/*
// Uncomment this method to specify if the specified item should be selected
- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}
*/

/*
// Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
- (BOOL)collectionView:(UICollectionView *)collectionView shouldShowMenuForItemAtIndexPath:(NSIndexPath *)indexPath {
	return NO;
}

- (BOOL)collectionView:(UICollectionView *)collectionView canPerformAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
	return NO;
}

- (void)collectionView:(UICollectionView *)collectionView performAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
	
}
*/

@end
