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
    
    NSString *currentPrice = deal.current_price.description;
    
    // 当服务器返回数据小数位数很长时,四舍五入保留2位小数
//    currentPrice = @"12.34567";
    NSInteger dotLoc = [currentPrice rangeOfString:@"."].location;
    if (dotLoc != NSNotFound ) { // 有小数位
        
        if (currentPrice.length - dotLoc > 3) { // 大于2位小数
//            currentPrice = [currentPrice substringToIndex:dotLoc + 4];
//            newPrice = (int)(100 * [currentPrice floatValue] + 0.5) / 100.0;
            currentPrice = [NSString stringWithFormat:@"¥ %.2f",[currentPrice floatValue]];
        }
    }
    
    self.currentPriceLabel.text = currentPrice;
    
    self.listPriceLabel.text = [NSString stringWithFormat:@"¥ %@",deal.list_price];
    self.purchaseCountLabel.text = [NSString stringWithFormat:@"已售%d",deal.purchase_count];
    
    NSDateFormatter *fmt = [[NSDateFormatter alloc] init];
    fmt.dateFormat = @"yyyy-MM-dd";  // 2017-06-22
    NSString *nowStr = [fmt stringFromDate:[NSDate date]];
    // 当前日期的团购显示 新单view
    self.dealNewView.hidden = ([nowStr compare:deal.publish_date] == NSOrderedDescending);}

-(void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    /** 平铺 -- 画背景图片 */
//    [[UIImage imageNamed:@"bg_dealcell"] drawAsPatternInRect:rect];
    /** 拉伸 -- 画背景图片 */
    [[UIImage imageNamed:@"bg_dealcell"]  drawInRect:rect];
}

@end
