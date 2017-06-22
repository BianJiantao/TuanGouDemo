//
//  TGDeal.m
//  团购HD
//
//  Created by BJT on 17/6/22.
//  Copyright © 2017年 BJT. All rights reserved.
//

#import "MJExtension.h"

#import "TGDeal.h"


@implementation TGDeal


+(NSDictionary *)replacedKeyFromPropertyName
{// 映射  属性名 与 字典key
    return @{@"desc":@"description"};
}

@end
