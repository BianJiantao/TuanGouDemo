//
//  TGSearchController.m
//  团购HD
//
//  Created by BJT on 17/6/23.
//  Copyright © 2017年 BJT. All rights reserved.
//

#import "UIBarButtonItem+Extension.h"
#import "MJRefresh.h"
#import "UIView+Extension.h"

#import "TGSearchController.h"

@interface TGSearchController ()<UISearchBarDelegate>
@end

@implementation TGSearchController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 设置返回按钮
    UIBarButtonItem *backBtnItem = [UIBarButtonItem itemWithTarget:self action:@selector(back) image:@"icon_back" highlightedImage:@"icon_back_highlighted"];
    self.navigationItem.leftBarButtonItem = backBtnItem;
    
//    UIView *titleView = [[UIView alloc] init];
//    titleView.width = 300;
//    titleView.height = 35;
//    titleView.backgroundColor = [UIColor redColor];
    
    // 设置搜索框
    UISearchBar *searchBar = [[UISearchBar alloc] init];
    searchBar.placeholder = @"请输入关键词";
    searchBar.backgroundImage = [UIImage imageNamed:@"bg_login_textfield"];
//    searchBar.backgroundColor  =[UIColor clearColor];
    searchBar.delegate = self;
    
//    searchBar.frame = titleView.bounds;
//    [titleView addSubview:searchBar];
    
    self.navigationItem.titleView = searchBar;

}

-(void)back
{
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    // 开始刷新数据
    [self.collectionView headerBeginRefreshing];
    
    // 退下键盘
    [searchBar resignFirstResponder];
    
}

#pragma mark - 实现父类方法,设置请求参数
-(void)setupRequestParas:(NSMutableDictionary *)paras
{
    paras[@"city"] = self.searchCityNmae;
    // 取出搜索框内输入的文本
    UISearchBar *searchBar = (UISearchBar *)self.navigationItem.titleView;
    
    paras[@"keyword"] = searchBar.text;
    
}


@end
