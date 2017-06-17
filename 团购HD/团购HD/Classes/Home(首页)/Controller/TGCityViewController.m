//
//  TGCityViewController.m
//  团购HD
//
//  Created by BJT on 17/6/16.
//  Copyright © 2017年 BJT. All rights reserved.
//


#import "MJExtension.h"
#import "UIView+AutoLayout.h"

#import "UIBarButtonItem+Extension.h"

#import "TGConst.h"
#import "TGCityViewController.h"
#import "TGCityGroup.h"
#import "TGCitySearchResultController.h"


@interface TGCityViewController () <UITableViewDataSource,UITableViewDelegate,UISearchBarDelegate>
/**
 *  显示城市组的 TableView
 */
@property (weak, nonatomic) IBOutlet UITableView *cityTable;
/**
 *  遮盖
 */
@property (weak, nonatomic) IBOutlet UIButton *cover;
- (IBAction)coverClick;
/**
 *  搜索框
 */
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;

/**
 *  存放 TGCityGroup 模型
 */
@property (nonatomic,strong) NSArray<TGCityGroup *> *cityGroups;
/**
 *  城市搜索结果控制器
 */
@property (nonatomic,weak) TGCitySearchResultController *citySearchResultVc;

@end

@implementation TGCityViewController


- (TGCitySearchResultController *)citySearchResultVc
{
    if (_citySearchResultVc == nil) {
        TGCitySearchResultController *resultVc = [[TGCitySearchResultController alloc] init];
        [self addChildViewController:resultVc]; // 添加到子控制器
        self.citySearchResultVc = resultVc;
        
        [self.view addSubview:_citySearchResultVc.view];
        [_citySearchResultVc.view autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsZero excludingEdge:ALEdgeTop];
        [_citySearchResultVc.view autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:self.searchBar withOffset:15];
        
    }
    return _citySearchResultVc;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"切换城市";
    
    self.navigationItem.leftBarButtonItem = [UIBarButtonItem itemWithTarget:self action:@selector(close) image:@"btn_navigation_close" highlightedImage:@"btn_navigation_close_hl"];
    self.cityGroups = [TGCityGroup objectArrayWithFilename:@"cityGroups.plist"];
    // 设置 tableView 右侧 section 索引文字的颜色
    self.cityTable.sectionIndexColor = [UIColor blackColor];
    // 设置搜索框取消按钮颜色
    self.searchBar.tintColor = kTGColorRGB(32, 191, 179);
    
}


-(void)close
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - searchBar 代理方法

/**
 *  搜索框文本改变
 */
-(void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    if (searchText.length) { // 搜索框有输入文字
        
        self.citySearchResultVc.view.hidden = NO;
        self.citySearchResultVc.searchText = searchText;
    
    }else{  // 搜索框为空
        
        self.citySearchResultVc.view.hidden = YES;
        
    }
}

/**
 *  键盘弹出,搜索框开始编辑
 */
-(BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar
{
    // 隐藏导航栏
    self.navigationController.navigationBarHidden = YES;
     // 改变搜索框背景图片
    searchBar.backgroundImage = [UIImage imageNamed:@"bg_login_textfield_hl"];
    // 显示搜索框取消按钮
    [searchBar setShowsCancelButton:YES animated:NO];
    // 显示遮盖
    [UIView animateWithDuration:0.5 animations:^{
        
        self.cover.alpha = 0.5;
        
    } completion:nil];
    
    return YES;
}
/**
 *  键盘退下,结束编辑
 */
-(BOOL)searchBarShouldEndEditing:(UISearchBar *)searchBar
{
//    NSLog(@"searchBarShouldEndEditing");
    // 显示导航栏
    self.navigationController.navigationBarHidden = NO;
    // 改变搜索框背景图片
    searchBar.backgroundImage = [UIImage imageNamed:@"bg_login_textfield"];
    // 隐藏取消按钮
    [searchBar setShowsCancelButton:NO animated:YES];
    // 隐藏遮盖
    [UIView animateWithDuration:0.5 animations:^{
        
        self.cover.alpha = 0;
        
    } completion:nil];
    
    //  隐藏搜索结果控制器 view
    self.citySearchResultVc.view.hidden = YES;
    // 清空搜索文本
    searchBar.text = nil;
    
    return YES;
}
/**
 *  点击搜索框取消按钮
 */
-(void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    [searchBar resignFirstResponder];
}

#pragma mark -tableView 数据源方法

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.cityGroups.count;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    TGCityGroup *group = self.cityGroups[section];
    return group.cities.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *ID = @"CityGroup";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:ID];
    }
    
    TGCityGroup *group = self.cityGroups[indexPath.section];
    cell.textLabel.text = group.cities[indexPath.row];
    
    return  cell;
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    TGCityGroup *group = self.cityGroups[section];
    return group.title;
}

-(NSArray<NSString *> *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
   
    return  [self.cityGroups valueForKeyPath:@"title"];
}

/**
 *  点击遮盖,改变遮盖透明度
 */
- (IBAction)coverClick
{
    // 退下键盘
    [self.searchBar resignFirstResponder];
}
@end
