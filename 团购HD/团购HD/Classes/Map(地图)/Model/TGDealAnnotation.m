//
//  TGDealAnnotation.m
//  团购HD
//
//  Created by BJT on 17/6/28.
//  Copyright © 2017年 BJT. All rights reserved.
//

#import "TGDealAnnotation.h"

@implementation TGDealAnnotation

-(BOOL)isEqual:(TGDealAnnotation *)other
{
    // 大头针商家名一样,就认为两个大头针是一个
    return  [self.title isEqualToString:other.title];
}

@end
