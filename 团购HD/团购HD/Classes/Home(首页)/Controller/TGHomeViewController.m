//
//  TGHomeViewController.m
//  团购HD
//
//  Created by BJT on 17/6/14.
//  Copyright © 2017年 BJT. All rights reserved.
//

#import "DPAPI.h"
#import "MJExtension.h"
#import "MJRefresh.h"
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
#import "TGDealCell.h"
#import "TGDeal.h"

@interface TGHomeViewController ()<DPRequestDelegate>

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

/** 订单数据 (存储TGDeal模型) */
@property (nonatomic,strong) NSMutableArray<TGDeal *> *deals;
/** 当前显示的数据对应的页码 */
@property (nonatomic,assign) NSInteger currentPage;

/** 最后一次网络请求,用于区别一个请求是否过期( 当网速慢时,有可能用户点击发送多个请求,只处理最后一次的请求) */
@property (nonatomic,weak) DPRequest *lastREquest;
/** 没有符合条件的团购时,显示的 view  */
@property (nonatomic,weak) UIImageView *noDataView;

/** 返回的团购总数 */
@property (nonatomic,assign) NSInteger totalCount;

@end

@implementation TGHomeViewController

static NSString * const reuseIdentifier = @"deal";

- (NSMutableArray *)deals
{
    if (_deals == nil) {
        _deals = [[NSMutableArray alloc] init];
    }
    return _deals;
}

- (UIImageView *)noDataView
{
    if (_noDataView == nil) {
        UIImageView *imgV = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon_deals_empty"]];
        [self.collectionView addSubview:imgV];
        [imgV autoCenterInSuperview];
        
        _noDataView = imgV;
        
    }
    return _noDataView;
}


-(instancetype)init
{
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    
    flowLayout.itemSize = CGSizeMake(305, 305);
    
    flowLayout.minimumLineSpacing = 20;
    return  [super initWithCollectionViewLayout:flowLayout];
}

-(void)dealloc
{
    [TGNotificationCenter removeObserver:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 设置背景颜色
    self.collectionView.backgroundColor = kTGColorRGB(230, 230, 230);
//    self.collectionView.alwaysBounceVertical = YES;
    
    // Uncomment the following line to preserve selection between presentations
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Register cell classes
    [self.collectionView registerNib:[UINib nibWithNibName:@"TGDealCell" bundle:nil] forCellWithReuseIdentifier:reuseIdentifier];
    
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

    // 集成  上拉刷新, 加载更多 / 下拉刷新,加载最新
    [self.collectionView addFooterWithTarget:self action:@selector(loadMoreDeals)];
    [self.collectionView addHeaderWithTarget:self action:@selector(loadNewDeals)];
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

#pragma mark - 服务器交互

- (void)loadDeals
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
    paras[@"page"] = @(self.currentPage);
    // 记录最后一次请求
     self.lastREquest = [dpApi requestWithURL:@"v1/deal/find_deals" params:paras delegate:self];
    TGLog(@"请求参数\n%@",paras);
}


/**
 *  上拉刷新加载更多
 */
-(void)loadMoreDeals
{
    // 从服务器加载下一页数据
    self.currentPage++;
    
    [self loadDeals];
    
    
}

/**
 *   加载新团购
 */
-(void)loadNewDeals
{
    // 新请求,只从服务器加载第一页的数据
    self.currentPage  = 1;
    
    [self loadDeals];
    
}
#pragma mark
/*  DPRequestDelegate 代理方法 */
-(void)request:(DPRequest *)request didFinishLoadingWithResult:(id)result
{
    if(self.lastREquest != request) return; // 过期请求,不处理
    
//    TGLog(@"%@",result);
    // 取出团购总数
    self.totalCount = [result[@"total_count"] integerValue];
    
    // 字典数组转模型数组
    NSArray *array = [TGDeal objectArrayWithKeyValuesArray:result[@"deals"]];
    if (self.currentPage == 1) { // loadNewdeals 加载新团购时, 清空之前团购数组
        [self.deals removeAllObjects];
    }
    [self.deals addObjectsFromArray:array];
    
    [self.collectionView reloadData];
    
    // 结束刷新
    [self.collectionView footerEndRefreshing];
    [self.collectionView headerEndRefreshing];
}

-(void)request:(DPRequest *)request didFailWithError:(NSError *)error
{
    if(self.lastREquest != request) return; // 过期请求,不处理
    
//    TGLog(@"%@",error);
    // toView不写时, hud 添加到window 上, window的原点坐标不会跟着屏幕旋转,hud视图会颠倒,所以要显示在self.collectionView上,横竖屏旋转时就没问题了
    [MBProgressHUD showError:@"网络繁忙,请稍后再试..." toView:self.collectionView];
    
    //  结束刷新
    [self.collectionView footerEndRefreshing];
    [self.collectionView headerEndRefreshing];
    
    // 上拉加载失败,页码要减1
    if(self.currentPage > 1)
        self.currentPage--;
}

#pragma mark - 屏幕将要旋转
-(void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
{
    TGLog(@"%@",NSStringFromCGSize(size));
    
    // 横屏 3 列,竖屏 2 列
    int cols = (size.width == 1024) ? 3 : 2;
    
   UICollectionViewFlowLayout * flowLayout = (UICollectionViewFlowLayout *)self.collectionViewLayout;
    
    CGFloat inset = (size.width - cols * flowLayout.itemSize.width)/(cols + 1);
    
    flowLayout.sectionInset = UIEdgeInsetsMake(inset, inset, inset, inset);
}


#pragma mark <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    
    // 只要数据一刷新就计算一下布局
    [self viewWillTransitionToSize:collectionView.size withTransitionCoordinator:nil];
    
    // 没有团购数据时,显示 noDataView
    self.noDataView.hidden = (self.deals.count != 0);
    // 全部团购数据已加载时,隐藏上拉刷新控件
    self.collectionView.footerHidden = (self.deals.count == self.totalCount);
    
    return 1;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
    return self.deals.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    TGDealCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    
    cell.deal = self.deals[indexPath.item];
    // Configure the cell
    
    return cell;
}

#pragma mark <UICollectionViewDelegate>


@end
