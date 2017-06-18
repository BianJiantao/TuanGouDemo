//
//  TGHomeViewController.m
//  团购HD
//
//  Created by BJT on 17/6/14.
//  Copyright © 2017年 BJT. All rights reserved.
//


#import "UIBarButtonItem+Extension.h"
#import "UIView+Extension.h"

#import "TGMetaTool.h"
#import "TGHomeViewController.h"
#import "TGConst.h"
#import "TGHomeTopItem.h"
#import "TGCategoryViewController.h"
#import "TGDistrictViewController.h"
#import "TGCity.h"

@interface TGHomeViewController ()

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
 *  区域PopoverController
 */
@property (nonatomic,strong) UIPopoverController *districtPopover;

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
    [NSTGNotificationCenter removeObserver:self];
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
    
    [NSTGNotificationCenter addObserver:self selector:@selector(cityDidChange:) name:NSCityDidChangeNotification object:nil];
    
}
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
    UIPopoverController *pop = [[UIPopoverController alloc] initWithContentViewController:[[TGCategoryViewController alloc] init]];
    [pop presentPopoverFromBarButtonItem:self.categoryItem permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    
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
    TGLog(@"--");
}


#pragma mark -通知监听方法
-(void)cityDidChange:(NSNotification *)noti
{
//    TGLog(@"%@",noti.userInfo[NSDidSelectCityName]);
    NSString *cityName = noti.userInfo[NSDidSelectCityName];
    self.selectedCityName = cityName;
    
    TGHomeTopItem *top = (TGHomeTopItem *)self.districtItem.customView;
    [top setTitle:[NSString stringWithFormat:@"%@ - 全部",cityName]];
    [top setSubTitle:nil];

}

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
