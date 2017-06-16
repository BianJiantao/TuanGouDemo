//
//  TGCategoryViewController.m
//  团购HD
//
//  Created by BJT on 17/6/16.
//  Copyright © 2017年 BJT. All rights reserved.
//

#import "MJExtension.h"
#import "UIView+Extension.h"

#import "TGCategoryViewController.h"
#import "TGHomeDropDownMenu.h"
#import "TGConst.h"
#import "TGCategory.h"

@interface TGCategoryViewController ()

@end

@implementation TGCategoryViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSArray *categories = [TGCategory objectArrayWithFilename:@"categories.plist"];
    
    TGHomeDropDownMenu *dropDownMenu = [TGHomeDropDownMenu dropDownMenu];
    dropDownMenu.categories = categories;
    self.view = dropDownMenu;
    
    // 设置控制器在 popover 中的尺寸
    self.preferredContentSize = dropDownMenu.size;
    
    
}
//
//-(void)viewWillAppear:(BOOL)animated
//{
//    [super viewWillAppear:animated];
//    
//    
//    TGLog(@"%@",self.view);
//    TGLog(@"preferredContentSize%@",NSStringFromCGSize(self.preferredContentSize));
//}

@end
