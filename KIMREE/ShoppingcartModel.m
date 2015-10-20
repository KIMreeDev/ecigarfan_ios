//
//  ShoppingcartModel.m
//  ECIGARFAN
//
//  Created by renchunyu on 14-5-13.
//  Copyright (c) 2014年 renchunyu. All rights reserved.
//

#import "ShoppingcartModel.h"

@implementation ShoppingcartModel

- (void)loadData:(NSDictionary *)dict
{
    self.shoppingcartId = [[dict objectForKey:@"card_id"]integerValue];         //购物车ID值，自增长 not null
    self.customerId = [[dict objectForKey:@"customer_id"]integerValue];         //购物车所属人
    self.productId = [[dict objectForKey:@"pro_id"]integerValue];               //产品id
    //增加产品名称
    self.productName = [dict objectForKey:@"pro_name"];                         // 产品名称
    self.productCount = [[dict objectForKey:@"pro_count"]integerValue];         //产品数量
    self.uptime = [dict objectForKey:@"uptime"];                                //购物车最后更新时间
}

@end





