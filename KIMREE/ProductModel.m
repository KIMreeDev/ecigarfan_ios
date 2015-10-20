//
//  ProductModel.m
//  ECIGARFAN
//
//  Created by renchunyu on 14-5-13.
//  Copyright (c) 2014年 renchunyu. All rights reserved.
//

#import "ProductModel.h"

@implementation ProductModel


- (void)loadData:(NSDictionary *)dict
{
  
    self.productId = [[dict objectForKey:@"product_id"]integerValue];                   //产品ID值，not null
    self.productName = [dict objectForKey:@"product_name"];                             //产品名称
    self.productClassID = [[dict objectForKey:@"product_classId"]integerValue];         //产品所属类别，not null
    self.productClassName=[dict objectForKey:@"product_className"];                     //产品类别名称
    self.productImage = [dict objectForKey:@"product_image"];                           //产品图片路径
    self.productDescription = [dict objectForKey:@"product_description"];               //产品描述
    self.productUnits = [dict objectForKey:@"product_units"];                           //产品单位
    self.unitCost = [[dict objectForKey:@"unit_price"] floatValue];                     //产品单价
    self.vipCost = [[dict objectForKey:@"vip_price"] floatValue];                       //会员价格
    self.productSum = [[dict objectForKey:@"product_sum"]integerValue];                 //产品数量，库存数
    self.costUnits = [dict objectForKey:@"cost_units"];                                 //货币代码：USD
    self.productStatus = [dict objectForKey:@"product_status"];                         //产品状态：0、停售 1、在售
    self.salesCount = [[dict objectForKey:@"sales_count"]integerValue];                 //销售量
    self.collectCount = [[dict objectForKey:@"collect_count"]integerValue];             //收藏数
    self.buyScores = [[dict objectForKey:@"buy_scores"]integerValue];                   //购买可获积分
    self.publishTime = [dict objectForKey:@"publish_time"];                             //产品发布时间
    self.productKeywords=[dict objectForKey:@"product_keywords"];                       //搜索关键词
    self.productSlogan=[dict objectForKey:@"product_slogan"];                           //产品促销语
    self.promotionImage=[dict objectForKey:@"promotion_image"];                         //促销图片
    
}

@end









