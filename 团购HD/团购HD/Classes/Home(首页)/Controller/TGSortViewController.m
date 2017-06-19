//
//  TGSortViewController.m
//  团购HD
//
//  Created by BJT on 17/6/19.
//  Copyright © 2017年 BJT. All rights reserved.
//

#import "UIView+Extension.h"

#import "TGConst.h"
#import "TGSortViewController.h"
#import "TGMetaTool.h"
#import "TGSort.h"

/* 排序菜单的按钮  (只本控制器内部使用)***************/
@interface TGSortButton : UIButton
/**
 *  每个按钮绑定一个排序模型
 */
@property (nonatomic,strong) TGSort *sort;
@end

@implementation TGSortButton

-(instancetype)init
{
    self = [super init];
    if (self) {
        
        [self setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [self setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
        [self setBackgroundImage:[UIImage imageNamed:@"btn_filter_normal"] forState:UIControlStateNormal];
        [self setBackgroundImage:[UIImage imageNamed:@"btn_filter_selected"] forState:UIControlStateHighlighted];
    }
    return self;
}

-(void)setSort:(TGSort *)sort
{
    _sort = sort;
    
    [self setTitle:sort.label forState:UIControlStateNormal];
}

@end
/**********************************/


@interface TGSortViewController ()

@end

@implementation TGSortViewController




- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    NSArray *sorts = [TGMetaTool sorts];
    NSInteger sortCount = sorts.count;
    CGFloat btnW = 100;
    CGFloat btnH = 30;
    CGFloat btnX = 15;
    CGFloat btnStartY = 15;
    CGFloat btnMargin = 15;
    CGFloat height = 0;
    for (int i = 0; i < sortCount; i++) {
        
        TGSortButton *btn = [[TGSortButton alloc] init];
        btn.sort = sorts[i];
        btn.x = btnX;
        btn.y = btnStartY + i * (btnH + btnMargin);
        btn.width = btnW;
        btn.height = btnH;
        [btn addTarget:self action:@selector(btnDidClick:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:btn];
        height = CGRectGetMaxY(btn.frame);
        
    }
    
    CGFloat width = btnW + 2 * btnX;
    height += btnMargin;
    self.preferredContentSize = CGSizeMake(width, height);
    
}

-(void)btnDidClick:(TGSortButton *)btn
{
    // 发出切换排序的通知
    [TGNotificationCenter postNotificationName:TGSortDidChangeNotification object:nil userInfo:@{TGSelectSort:btn.sort}];
}


@end
