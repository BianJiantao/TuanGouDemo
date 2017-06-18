//
//  TGHomeTopItem.m
//  团购HD
//
//  Created by BJT on 17/6/14.
//  Copyright © 2017年 BJT. All rights reserved.
//

#import "TGHomeTopItem.h"

@interface TGHomeTopItem ()
@property (weak, nonatomic) IBOutlet UIButton *iconButton;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *subtitleLabel;

@end


@implementation TGHomeTopItem

-(void)awakeFromNib
{
    self.autoresizingMask = UIViewAutoresizingNone;
}

+(instancetype)item
{
    return [[[NSBundle mainBundle] loadNibNamed:@"TGHomeTopItem" owner:nil options:nil] firstObject];
}

-(void)addTarget:(id)target action:(SEL)action
{
    [self.iconButton addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
}

/**
 *  设置标题
 */
-(void)setTitle:(NSString *)title
{
    self.titleLabel.text = title;
    
}
/**
 *  设置子标题
 */
-(void)setSubTitle:(NSString *)subTitle
{
    self.subtitleLabel.text = subTitle;
    
}
/**
 *  设置按钮图标
 */
-(void)setIcon:(NSString *)icon highlightedIcon:(NSString *)highlightedIcon
{
    
    [self.iconButton setImage:[UIImage imageNamed:icon] forState:UIControlStateNormal];
    [self.iconButton setImage:[UIImage imageNamed:highlightedIcon] forState:UIControlStateHighlighted];
}




@end
