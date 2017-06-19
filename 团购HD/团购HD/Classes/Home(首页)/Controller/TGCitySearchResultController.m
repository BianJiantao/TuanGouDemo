//
//  TGCitySearchResultController.m
//  团购HD
//
//  Created by BJT on 17/6/17.
//  Copyright © 2017年 BJT. All rights reserved.
//

#import "MJExtension.h"

#import "TGCitySearchResultController.h"
#import "TGCity.h"
#import "TGConst.h"

@interface TGCitySearchResultController ()
/**
 *  所有城市 TGCity 模型
 */
@property (nonatomic,strong) NSArray *cities;
/**
 *  由搜索文本得到的搜索结果
 */
@property (nonatomic,strong) NSArray *searchResult;

@end

@implementation TGCitySearchResultController

- (NSArray *)cities
{
    if (_cities == nil) {
        _cities = [TGCity objectArrayWithFilename:@"cities.plist"];
    }
    return _cities;
}


-(void)setSearchText:(NSString *)searchText
{
    _searchText = [searchText copy];
    
    // [c]不区分大小写,进行搜索
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"name CONTAINS [c] %@ OR pinYin CONTAINS [c] %@ OR pinYinHead CONTAINS [c]  %@",searchText,searchText,searchText];
    self.searchResult = [self.cities filteredArrayUsingPredicate:predicate];
    [self.tableView reloadData];
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.searchResult.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *ID = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:ID];
    }
    TGCity *city = self.searchResult[indexPath.row];
    cell.textLabel.text = city.name;
    
    return  cell;
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return [NSString stringWithFormat:@"共有%zd个搜索结果",self.searchResult.count];
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    TGCity *city = self.searchResult[indexPath.row];
     // 发出切换城市的通知
    [TGNotificationCenter postNotificationName:TGCityDidChangeNotification object:nil userInfo:@{TGSelectCityName:city.name}];
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
