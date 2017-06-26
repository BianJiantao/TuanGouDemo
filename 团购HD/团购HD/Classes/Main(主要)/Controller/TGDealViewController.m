//
//  TGDealViewController.m
//  团购HD
//
//  Created by BJT on 17/6/23.
//  Copyright © 2017年 BJT. All rights reserved.
//

#import "DPAPI.h"
#import "MJExtension.h"
#import "MJRefresh.h"
#import "UIView+AutoLayout.h"
#import "MBProgressHUD+MJ.h"

#import "UIBarButtonItem+Extension.h"
#import "UIView+Extension.h"

#import "TGDealViewController.h"
#import "TGConst.h"
#import "TGDealCell.h"
#import "TGDeal.h"
#import "TGDealDetailViewController.h"

@interface TGDealViewController ()<DPRequestDelegate>

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

@implementation TGDealViewController

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


- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 设置背景颜色
    self.collectionView.backgroundColor = kTGGlobalBackGroundColor;
    self.collectionView.alwaysBounceVertical = YES;
    
    // Register cell classes
    [self.collectionView registerNib:[UINib nibWithNibName:@"TGDealCell" bundle:nil] forCellWithReuseIdentifier:reuseIdentifier];
    
    // 集成  上拉刷新, 加载更多 / 下拉刷新,加载最新
    [self.collectionView addFooterWithTarget:self action:@selector(loadMoreDeals)];
    [self.collectionView addHeaderWithTarget:self action:@selector(loadNewDeals)];
}


#pragma mark - 服务器交互

- (void)loadDeals
{
    
    DPAPI *dpApi = [[DPAPI alloc] init];
    
    
    // 设置请求参数
    NSMutableDictionary *paras = [NSMutableDictionary dictionary];
    // 之所以可以去子类找到 setupRequestParas: 方法,因为 self 其实指向的是子类
//    TGLog(@"%@",self);
    [self setupRequestParas:paras];
    
    // 每页的条数
    paras[@"limit"] = @10;
    paras[@"page"] = @(self.currentPage);
    // 记录最后一次请求
    self.lastREquest = [dpApi requestWithURL:@"v1/deal/find_deals" params:paras delegate:self];
    //    TGLog(@"请求参数\n%@",paras);
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
    //    TGLog(@"%@",NSStringFromCGSize(size));
    
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
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    // 展示订单详情
    TGDealDetailViewController *detailVc = [[TGDealDetailViewController alloc] init];
    // 设置要展示的订单
    detailVc.deal = self.deals[indexPath.item];
    [self presentViewController:detailVc animated:YES completion:nil];
    
}



@end
