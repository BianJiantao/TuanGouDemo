//
//  TGDealCell.m
//  团购HD
//
//  Created by BJT on 17/6/22.
//  Copyright © 2017年 BJT. All rights reserved.
// 

#import "TGDealCell.h"
#import "TGDeal.h"
#import "UIImageView+WebCache.h"

@interface TGDealCell()
/**  团购图标 */
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
/**  团购标题 */
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
/**  团购描述 */
@property (weak, nonatomic) IBOutlet UILabel *descLabel;
/**  团购现价 */
@property (weak, nonatomic) IBOutlet UILabel *currentPriceLabel;
/**  团购原价 */
@property (weak, nonatomic) IBOutlet UILabel *listPriceLabel;
/**  团购购买数 */
@property (weak, nonatomic) IBOutlet UILabel *purchaseCountLabel;
#warning 属性名不能以new开头 
/**  新单 view */
@property (weak, nonatomic) IBOutlet UIImageView *dealNewView;
/** 进入编辑状态时的遮盖 */
@property (weak, nonatomic) IBOutlet UIButton *cover;
/** 遮盖点击 */
- (IBAction)coverDidClick;
/** 是否选中的标记 */
@property (weak, nonatomic) IBOutlet UIImageView *checkView;

@end

@implementation TGDealCell

-(void)awakeFromNib
{
    
    /**
     * uiview设置背景图片
     * 1> 添加一个 imageView ,设置图片
     * 2> drawRect方法,绘制图片
     */
//    self.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bg_dealcell"]];
}

-(void)setDeal:(TGDeal *)deal
{
    _deal = deal;
    
    
    [self.imageView sd_setImageWithURL:[NSURL URLWithString:deal.s_image_url] placeholderImage:[UIImage imageNamed:@"placeholder_deal"]];
    
    self.titleLabel.text = deal.title;
    self.descLabel.text = deal.desc;
    
    NSString *priceStr = self.deal.current_price.description;
    NSString *currentPrice = [NSString stringWithFormat:@"¥ %@",priceStr];
    // 当服务器返回数据小数位数很长时,四舍五入保留2位小数
    //    priceStr = @"12.34567";
    NSInteger dotLoc = [priceStr rangeOfString:@"."].location;
    if (dotLoc != NSNotFound ) { // 有小数位
        
        if (priceStr.length - dotLoc > 3) { // 大于2位小数
            //            currentPrice = [currentPrice substringToIndex:dotLoc + 4];
            //            newPrice = (int)(100 * [currentPrice floatValue] + 0.5) / 100.0;
            currentPrice = [NSString stringWithFormat:@"¥ %.2f",[priceStr floatValue]];
        }
    }
    
    self.currentPriceLabel.text = currentPrice;
    
    self.listPriceLabel.text = [NSString stringWithFormat:@"¥ %@",deal.list_price];
    self.purchaseCountLabel.text = [NSString stringWithFormat:@"已售%d",deal.purchase_count];
    
    NSDateFormatter *fmt = [[NSDateFormatter alloc] init];
    fmt.dateFormat = @"yyyy-MM-dd";  // 2017-06-22
    NSString *nowStr = [fmt stringFromDate:[NSDate date]];
    // 当前日期的团购显示 新单view
    self.dealNewView.hidden = ([nowStr compare:deal.publish_date] == NSOrderedDescending);
    
    // 设置遮盖的显示 (处于编辑状态就显示遮盖)
    self.cover.hidden = !deal.isEditing;
    // 设置选中标记的显示 (选中状态就显示标记)
    self.checkView.hidden = !deal.isChecking;
}


-(void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    /** 平铺 -- 画背景图片 */
//    [[UIImage imageNamed:@"bg_dealcell"] drawAsPatternInRect:rect];
    /** 拉伸 -- 画背景图片 */
    [[UIImage imageNamed:@"bg_dealcell"]  drawInRect:rect];
}

- (IBAction)coverDidClick
{
    // 设置选中标记的显示
    self.checkView.hidden = !self.checkView.hidden;
    // 设置选中状态到模型中 , 避免 cell 循环利用时, 选中标记显示混乱
    self.deal.checking = !self.deal.checking;
    // 选中状态改变,通知代理
    if ([self.delegate respondsToSelector:@selector(dealCellCheckStateDidChange:)]) {
        [self.delegate dealCellCheckStateDidChange:self];
    }
}
@end
