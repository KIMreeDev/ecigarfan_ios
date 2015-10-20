//
//  Product.m
//  ECIGARFAN
//
//  Created by cool on 14-5-5.
//  Copyright (c) 2014年 cool. All rights reserved.
//

#import "Product.h"
//#import <objc/runtime.h>



@implementation Product
@synthesize productID,productImage,productName,productClassID,productClassName;


- (void)loadData:(NSDictionary *)dict
{
    self.productID = [[dict valueForKey:@"productID"]integerValue];
    self.productImage = [dict valueForKey:@"productImage"];
    self.productName = [dict valueForKey:@"productName"];
    self.productClassID = [[dict valueForKey:@"productClassID"]integerValue];
    self.productClassName = [dict valueForKey:@"productClassName"];
}






@end
