//
//  TGCity.m
//  团购HD
//
//  Created by BJT on 17/6/17.
//  Copyright © 2017年 BJT. All rights reserved.
//

#import "MJExtension.h"

#import "TGCity.h"
#import "TGRegion.h"

@implementation TGCity

+(NSDictionary *)objectClassInArray
{
    return @{@"regions":[TGRegion class]};
}

@end
