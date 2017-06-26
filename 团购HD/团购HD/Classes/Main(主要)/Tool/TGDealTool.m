//
//  TGDealTool.m
//  团购HD
//
//  Created by BJT on 17/6/25.
//  Copyright © 2017年 BJT. All rights reserved.
//

#import "FMDB.h"

#import "TGDealTool.h"
#import "TGDeal.h"

static FMDatabase *_db;
@implementation TGDealTool

+(void)initialize
{
    // 打开数据库
    NSString *filePath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:@"deal_sqlite"];
    
    _db = [FMDatabase databaseWithPath:filePath];
    if ([_db open]) {
        // 创建收藏订单表
        [_db executeUpdate:@"CREATE TABLE IF NOT EXISTS t_collect_deal (id integer primary key autoincrement,deal blob not null,deal_id text not null);"];
        // 创建浏览历史记录订单表
        [_db executeUpdate:@"CREATE TABLE IF NOT EXISTS t_scanHistory_deal (id integer primary key autoincrement,deal blob not null,deal_id text not null);"];
        
    }
}


/**  获取指定页码的收藏订单, page 从 1 开始 */
+(NSArray *)dealsOfCollectWithPage:(NSInteger)page
{
    // page 页对应的第一条数据位置
    NSInteger loc = PageSize * (page -1);
    FMResultSet *set = [_db executeQueryWithFormat:@"SELECT * FROM t_collect_deal ORDER BY id DESC LIMIT %d,%d ;",loc,PageSize];
    
    NSMutableArray *deals = [NSMutableArray array];
    while ([set next]) {
        NSData *dealData = [set dataForColumn:@"deal"];
        TGDeal *deal = [NSKeyedUnarchiver unarchiveObjectWithData:dealData];
        [deals addObject:deal];
    }
    
    return deals;
}

/***  添加一个收藏订单 */
+(void)addDealToCollect:(TGDeal *)deal
{
    if ([TGDealTool isCollected:deal]) return; // 已经收藏,直接退出
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:deal];
    [_db executeUpdateWithFormat:@"INSERT INTO t_collect_deal (deal,deal_id) VALUES (%@,%@) ;",data,deal.deal_id];
}
/**  取消一个收藏订单 */
+(void)removeDealFromCollect:(TGDeal *)deal
{
    [_db executeUpdateWithFormat:@"DELETE FROM t_collect_deal WHERE deal_id = %@;",deal.deal_id];
}
/**  判断一个订单是否已收藏 */
+(BOOL)isCollected:(TGDeal *)deal
{
    FMResultSet *set = [_db executeQueryWithFormat:@"SELECT COUNT(*) FROM t_collect_deal WHERE deal_id = %@;",deal.deal_id];
    [set next];
    
    return [set intForColumnIndex:0] == 1;
}

+(NSInteger)dealCollectTotalCount
{
    FMResultSet *set = [_db executeQueryWithFormat:@"SELECT COUNT(*) FROM t_collect_deal;"];
    [set next];
    
    return [set intForColumnIndex:0];
}


@end
