//
//  ShoppingcartModel.h
//  ECIGARFAN
//
//  Created by renchunyu on 14-5-13.
//  Copyright (c) 2014年 renchunyu. All rights reserved.
//

#import "JRModel.h"

@interface ShoppingcartModel : JRModel



@property (nonatomic, assign) NSInteger shoppingcartId;
@property (nonatomic, assign) NSInteger customerId;
@property (nonatomic, assign) NSInteger  productId;
@property (nonatomic, strong) NSString *productName;
@property (nonatomic, assign) NSInteger productCount;
@property (nonatomic, strong) NSString *uptime;

- (void)loadData:(NSDictionary *)dict;
@end


