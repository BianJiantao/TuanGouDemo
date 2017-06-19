//
//  TGHomeDropDownMenu.h
//  团购HD
//
//  Created by BJT on 17/6/16.
//  Copyright © 2017年 BJT. All rights reserved.
// 导航栏点击弹出的下拉菜单

#import <UIKit/UIKit.h>

@class TGHomeDropDownMenu;
@protocol TGHomeDropDownMenuDataSource <NSObject>

@required
/**
 *  左边的主表 tableview 有多少行 (required)
 */
-(NSInteger)numberOfRowsInMainTable:(TGHomeDropDownMenu *)homeDropDownMenu;
/**
 *  主表的某一行对应的从表数据 (required)
 */
-(NSArray *)homeDropDownMenu:(TGHomeDropDownMenu *)homeDropDownMenu subdataForRowInMainTable:(NSInteger) row;
/**
 *  左侧主表某一行的标题文字 (required)
 */
- (NSString *)homeDropDownMenu:(TGHomeDropDownMenu *)homeDropDownMenu titleForRowInMainTable:(NSInteger) row;
@optional
/**
*  左侧主表某一行的图标 (optional)
*/
- (NSString *)homeDropDownMenu:(TGHomeDropDownMenu *)homeDropDownMenu  iconForRowInMainTable:(NSInteger) row;
/**
 *  左侧主表某一行的图标 (optional)
 */
- (NSString *)homeDropDownMenu:(TGHomeDropDownMenu *)homeDropDownMenu  highLightedIconForRowInMainTable:(NSInteger) row;

@end

@protocol TGHomeDropDownMenuDelegate <NSObject>
@optional
/**
 *  左侧主表选中某一行 (optional)
 */
-(void)homeDropDownMenu:(TGHomeDropDownMenu *)homeDropDownMenu didSelectRowInMainTable:(NSInteger)row;


/**
 *  右侧从表选中某一行 (optional)
 *  @param subRow           选中从表的行号
 *  @param mainRow          选中的从表对应的主表行号
 */
-(void)homeDropDownMenu:(TGHomeDropDownMenu *)homeDropDownMenu didSelectRowInSubTable:(NSInteger)subRow forMainTableRow:(NSInteger)mainRow;

@end


@interface TGHomeDropDownMenu : UIView

/**
 *  下拉菜单的数据源
 */
@property (nonatomic,weak) id<TGHomeDropDownMenuDataSource> dataSource;
/**
 *  下拉菜单的代理
 */
@property (nonatomic,weak) id<TGHomeDropDownMenuDelegate> delegate;

+(instancetype)dropDownMenu;



@end
