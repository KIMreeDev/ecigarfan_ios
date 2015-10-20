//
//  Product.h
//  ECIGARFAN
//
//  Created by cool on 14-5-5.
//  Copyright (c) 2014年 cool. All rights reserved.
//

#import "JRModel.h"

//临时使用数据，后期去除

@interface Product : JRModel


@property (nonatomic,assign) NSInteger productID;         //产品id
@property(nonatomic,strong) NSString *productImage; //产品图片
@property(nonatomic,strong) NSString *productName; //产品名称
@property(nonatomic,assign) NSInteger productClassID; //产品类别id
@property(nonatomic,strong) NSString *productClassName; //产品类别名称



@end
