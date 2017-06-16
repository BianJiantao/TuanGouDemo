//
//  TGHomeDropDownMenu.m
//  团购HD
//
//  Created by BJT on 17/6/16.
//  Copyright © 2017年 BJT. All rights reserved.
//

#import "TGHomeDropDownMenu.h"
#import "TGCategory.h"
#import "TGHomeDropDownMainCell.h"
#import "TGHomeDropDownSubCell.h"


@interface TGHomeDropDownMenu () <UITableViewDataSource,UITableViewDelegate>
#warning 记得在 xib 中设置 tableview 的代理和数据源
/**
 *  菜单左侧主表
 */
@property (weak, nonatomic) IBOutlet UITableView *mainTable;
/**
 *  菜单右侧从表
 */
@property (weak, nonatomic) IBOutlet UITableView *subTable;

/**
 *  当前主表选中的分类
 */
@property (nonatomic,weak) TGCategory *selectedCategory;

@end


@implementation TGHomeDropDownMenu

+(instancetype)dropDownMenu
{
    return [[[NSBundle mainBundle] loadNibNamed:@"TGHomeDropDownMenu" owner:nil options:nil] firstObject];
}

-(void)awakeFromNib
{
    // 禁止跟随父控件调整大小
    self.autoresizingMask = UIViewAutoresizingNone;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView == self.mainTable) {
        return self.categories.count;
    }else{
        return self.selectedCategory.subcategories.count;
    }
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = nil;
    if(tableView == self.mainTable){  // 主表
        
        cell = [TGHomeDropDownMainCell cellWithTableView:tableView];
        TGCategory *category = self.categories[indexPath.row];
        cell.textLabel.text = category.name;
        cell.imageView.image = [UIImage imageNamed:category.small_icon];
        if (category.subcategories) {
            // 设置 cell 右侧箭头
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }else{
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
        
    }else{  // 从表
        
        cell = [TGHomeDropDownSubCell cellWithTableView:tableView];
        cell.textLabel.text = self.selectedCategory.subcategories[indexPath.row];
        
    }
    
    return cell;
    
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(tableView == self.mainTable){
        
        // 设置当前选中分类
        self.selectedCategory = self.categories[indexPath.row];
        // 刷新从表数据
        [self.subTable reloadData];
    }
}


@end
