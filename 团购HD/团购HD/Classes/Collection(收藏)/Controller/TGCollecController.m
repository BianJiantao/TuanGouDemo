//
//  TGCollecController.m
//  团购HD
//
//  Created by BJT on 17/6/23.
//  Copyright © 2017年 BJT. All rights reserved.
//

#import "UIView+Extension.h"
#import "UIView+AutoLayout.h"
#import "MJRefresh.h"

#import "UIBarButtonItem+Extension.h"
#import "TGCollecController.h"
#import "TGConst.h"
#import "TGDealCell.h"
#import "TGDealDetailViewController.h"
#import "TGDealTool.h"
#import "TGDeal.h"


static NSString *const TGEdit = @"编辑";
static NSString *const TGDone = @"完成";
// 添加间距效果
#define TGString(str) [NSString stringWithFormat:@"  %@  ",str]

@interface TGCollecController () <TGDealCellDelegate>
/** 收藏的订单 (存储TGDeal模型) */
@property (nonatomic,strong) NSMutableArray<TGDeal *> *deals;
/** 当前显示的数据对应的页码 */
@property (nonatomic,assign) NSInteger currentPage;
/** 没有收藏的团购时,显示的 view  */
@property (nonatomic,weak) UIImageView *noDataView;
/** 返回 */
@property (nonatomic, strong) UIBarButtonItem *backItem;
/** 全选 */
@property (nonatomic, strong) UIBarButtonItem *allSelectItem;
/** 全不选 */
@property (nonatomic, strong) UIBarButtonItem *allNotSelectItem;
/** 删除 */
@property (nonatomic, strong) UIBarButtonItem *deleteItem;
@end

@implementation TGCollecController

static NSString * const reuseIdentifier = @"deal";


- (UIBarButtonItem *)backItem
{
    if (_backItem == nil) {
        _backItem = [UIBarButtonItem itemWithTarget:self action:@selector(back) image:@"icon_back" highlightedImage:@"icon_back_highlighted"];
    }
    return _backItem;
}

- (UIBarButtonItem *)allSelectItem
{
    if (_allSelectItem == nil) {
        _allSelectItem = [[UIBarButtonItem alloc] initWithTitle:TGString(@"全选") style:UIBarButtonItemStyleDone target:self action:@selector(dealsAllSelect)];
    }
    return _allSelectItem;
}
- (UIBarButtonItem *)allNotSelectItem
{
    if (_allNotSelectItem == nil) {
        _allNotSelectItem = [[UIBarButtonItem alloc] initWithTitle:TGString(@"全不选") style:UIBarButtonItemStyleDone target:self action:@selector(dealsAllNotSelect)];
    }
    return _allNotSelectItem;
}

- (UIBarButtonItem *)deleteItem
{
    if (_deleteItem == nil) {
        _deleteItem = [[UIBarButtonItem alloc] initWithTitle:TGString(@"删除") style:UIBarButtonItemStyleDone target:self action:@selector(dealsDelete)];
        _deleteItem.enabled = NO;
    }
    return _deleteItem;
}

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
        UIImageView *imgV = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon_collects_empty"]];
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
    self.navigationItem.title = @"收藏的团购";
    // Register cell classes
    [self.collectionView registerNib:[UINib nibWithNibName:@"TGDealCell" bundle:nil] forCellWithReuseIdentifier:reuseIdentifier];
    
    // 设置导航栏按钮
    self.navigationItem.leftBarButtonItems = @[self.backItem];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:TGEdit style: UIBarButtonItemStyleDone target:self action:@selector(edit:)];
    
    // 监听订单收藏状态的改变
    [TGNotificationCenter addObserver:self selector:@selector(collectStateDidChange:) name:TGDealCollectStateDidChangeNotification object:nil];
    
    // 集成上拉刷新,加载更多
    [self.collectionView addFooterWithTarget:self action:@selector(loadMore)];
    [self loadMore];
    
}

-(void)dealloc
{
    [TGNotificationCenter removeObserver:self];
}

#pragma mark - TGDealCell代理方法
-(void)dealCellCheckStateDidChange:(TGDealCell *)cell
{
    // 当前订单数组中是否有选中的订单
    BOOL hasCheckedDeal = NO;
    for (TGDeal *deal in self.deals) {
        if (deal.isChecking) { // 只要有一个选中的订单,就标记为  yes
            hasCheckedDeal = YES;
            break;
        }
    }
    // 只要有选中状态的订单,删除按钮就可点击
    self.deleteItem.enabled = hasCheckedDeal;
}

#pragma mark - 导航栏按钮点击

/** 全选 */
-(void)dealsAllSelect
{
    for (TGDeal *deal in self.deals) {
        deal.checking = YES;
    }
    [self.collectionView reloadData];
    self.deleteItem.enabled = YES;
    
}
/** 全不选 */
-(void)dealsAllNotSelect
{
    for (TGDeal *deal in self.deals) {
        deal.checking = NO;
    }
    [self.collectionView reloadData];
    self.deleteItem.enabled = NO;
}
/** 删除选中 */
-(void)dealsDelete
{
    // 此处应注意数组遍历时,不要对其进行 添加/删除 操作,会出错.遍历完后,统一操作
    NSMutableArray *dealsToDelete = [NSMutableArray array];
    for (TGDeal *deal in self.deals) {
        if (deal.isChecking) {
            [TGDealTool removeDealFromCollect:deal];
            [dealsToDelete addObject:deal];
        }
    }
    
    [self.deals removeObjectsInArray:dealsToDelete];
    
    [self.collectionView reloadData];
    // 删除后,删除按钮不可点击
    self.deleteItem.enabled = NO;
}



/** 导航栏 编辑按钮 点击 */
-(void)edit:(UIBarButtonItem *)editItem
{
    if ([editItem.title isEqualToString:TGEdit]) { // 进入编辑状态
        editItem.title = TGDone;
        self.navigationItem.leftBarButtonItems = @[self.backItem,self.allSelectItem,self.allNotSelectItem,self.deleteItem];
#warning TIPS 编辑状态设置到模型中 , 可以绝对控制 cell 的显示,不用担心 cell 的循环利用引起的控件显示混乱问题. 经验:用模型区控制 cell 的显示
        
        for (TGDeal *deal in self.deals) {
            deal.editing = YES;
        }
        
    }else{  // 编辑完成
        editItem.title = TGEdit;
        self.navigationItem.leftBarButtonItems = @[self.backItem];
        
        for (TGDeal *deal in self.deals) {
            deal.editing = NO;
        }
    }
    
    [self.collectionView reloadData];
        
}

/**
 *  导航栏 返回按钮 点击
 */
-(void)back
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

/**
 *  加载更多
 */
-(void)loadMore
{
    self.currentPage++;
    
    NSArray *moreDeals = [TGDealTool dealsOfCollectWithPage:self.currentPage];
    // 如果是编辑状态, 设置新加载的订单的编辑属性
    if([self.navigationItem.rightBarButtonItem.title isEqualToString:TGDone]){ // 当前处于编辑状态
        
        for (TGDeal *deal in moreDeals) {
            deal.editing = YES;
        }
    }
    
    [ self.deals addObjectsFromArray:moreDeals];
    
    [self.collectionView reloadData];
    [self.collectionView footerEndRefreshing];
}

#pragma mark - 收藏状态改变的通知监听方法
-(void)collectStateDidChange:(NSNotification *)noti
{
    TGDeal *deal = noti.userInfo[TGDealDidCollectClicked];
    BOOL isCollect = [noti.userInfo[TGDealIsCollect] boolValue];
    if (isCollect) { // 收藏该订单,添加到数组第一个位置
        [self.deals insertObject:deal atIndex:0];
    }else{ // 取消收藏,从数组中移除,为防止 deal 的内存地址在其他文件被修改,移除失败,应在 TGDeal模型中重写 isEqual 方法,利用 deal_id进行删除
        [self.deals removeObject:deal];
    }
    [self.collectionView reloadData];
#warning  TIPS
    // 当取消收藏订单时,为保证内存数据与数据库的同步 ( 订单取消收藏,数据库记录数在减少,即总页数在减少,而 loadMore 时,内存数据的currentPage页码一直在增加,上拉时有可能加载不出数据库中的数据 )
    // 因此,可以对当前显示的数据页码重新计算赋值,解决上述问题
    // PageSzie = 10
    // 8 10 , 1
    // 12 20 , 2
    self.currentPage = (self.deals.count - 1 + PageSize) / PageSize ;
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
    
    // 没有团购数据时,显示 noDataView , rightBarButtonItem不能点击
    self.noDataView.hidden = (self.deals.count != 0);
    UIBarButtonItem *editItem = self.navigationItem.rightBarButtonItem;
    editItem.enabled = (self.deals.count != 0);
    if (editItem.enabled == NO) {
        editItem.title = TGEdit;
    }
    // 全部收藏订单已加载时,隐藏上拉刷新控件
    self.collectionView.footerHidden = (self.deals.count == [TGDealTool dealCollectTotalCount]);
    
    return 1;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
    return self.deals.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    TGDealCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    cell.delegate = self;
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
