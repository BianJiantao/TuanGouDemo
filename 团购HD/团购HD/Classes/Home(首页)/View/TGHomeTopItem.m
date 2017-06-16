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

@end


@implementation TGHomeTopItem

+(instancetype)item
{
    return [[[NSBundle mainBundle] loadNibNamed:@"TGHomeTopItem" owner:nil options:nil] firstObject];
}

-(void)addTarget:(id)target action:(SEL)action
{
    [self.iconButton addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
}

-(void)awakeFromNib
{
    self.autoresizingMask = UIViewAutoresizingNone;
}


@end
