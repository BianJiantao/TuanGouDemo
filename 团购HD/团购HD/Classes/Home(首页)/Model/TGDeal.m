//
//  TGDeal.m
//  团购HD
//
//  Created by BJT on 17/6/22.
//  Copyright © 2017年 BJT. All rights reserved.
//

#import "MJExtension.h"

#import "TGDeal.h"
#import "TGBusiness.h"


@implementation TGDeal

MJCodingImplementation

+(NSDictionary *)replacedKeyFromPropertyName
{// 映射  属性名 与 字典key
    return @{@"desc":@"description"};
}

+(NSDictionary *)objectClassInArray
{
    return @{@"businesses":[TGBusiness class]};
}


-(BOOL)isEqual:(TGDeal *)other
{
    // deal_id 相等,就认为两个 deal 一样,用于数组删除
    return [self.deal_id isEqualToString:other.deal_id];
}

@end
