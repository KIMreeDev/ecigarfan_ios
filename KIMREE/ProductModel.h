//
//  ProductModel.h
//  ECIGARFAN
//
//  Created by renchunyu on 14-5-13.
//  Copyright (c) 2014年 renchunyu. All rights reserved.
//

#import "JRModel.h"

@interface ProductModel : JRModel

@property (nonatomic, assign) NSInteger productId;
@property (nonatomic, strong) NSString *productName;
@property (nonatomic, assign) NSInteger productClassID;
@property (nonatomic, strong) NSString  *productClassName;
@property (nonatomic, strong) NSString *productImage;
@property (nonatomic, strong) NSString *productDescription;
@property (nonatomic, strong) NSString *productUnits;
@property (nonatomic, assign) float unitCost;
@property (nonatomic, assign) float vipCost;
@property (nonatomic, assign) NSInteger productSum;
@property (nonatomic, strong) NSString *costUnits;
@property (nonatomic, strong) NSString *productStatus;
@property (nonatomic, assign) NSInteger salesCount;
@property (nonatomic, assign) NSInteger collectCount;
@property (nonatomic, assign) NSInteger buyScores;
@property (nonatomic, strong) NSString *publishTime;
@property (nonatomic, strong) NSString *productKeywords;
@property (nonatomic, strong) NSString *productSlogan;
@property (nonatomic, strong) NSString *promotionImage;

- (void)loadData:(NSDictionary *)dict;
@end


