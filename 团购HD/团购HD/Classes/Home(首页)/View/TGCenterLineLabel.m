//
//  TGCenterLineLabel.m
//  团购HD
//
//  Created by BJT on 17/6/23.
//  Copyright © 2017年 BJT. All rights reserved.
//

#import "TGCenterLineLabel.h"

@implementation TGCenterLineLabel

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        self.clipsToBounds = YES;
    }
    return self;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.clipsToBounds = YES;
    }
    return self;
}


- (void)drawRect:(CGRect)rect {
    // Drawing code
    
    [super drawRect:rect];
    // 在中间画一条实心的宽度为1的矩形
    UIRectFill(CGRectMake(0, rect.size.height * 0.5, rect.size.width, 1));
    
    
}
@end
