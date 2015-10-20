//
//  BillModel.h
//  ECIGARFAN
//
//  Created by renchunyu on 14-5-13.
//  Copyright (c) 2014年 renchunyu. All rights reserved.
//

#import "JRModel.h"

@interface BillModel : JRModel

@property (nonatomic, assign) NSInteger orderID;              //订单ID  not null
@property (nonatomic, strong) NSString  *orderNumber;         //订单编号  not null
@property (nonatomic, assign) NSInteger customerID;           //下单用户ID  not null
@property (nonatomic, strong) NSString *orderStatus;         //订单状态
@property (nonatomic, assign) float firstPay;               //订单原价
@property (nonatomic, assign) float vipPay;                  //订单会员价
@property (nonatomic, assign) float realPay;                 //成交价格
@property (nonatomic, assign) NSString *orderUnits;        //货币符号
@property (nonatomic, assign) NSInteger orderScores;       //订单可获积分
@property (nonatomic,strong)  NSString  *payType;            //支付形式:paypal或者货到付款
@property (nonatomic,strong)  NSString  *sendType;          //送货方式：0、快递 1、附近
@property (nonatomic,strong)  NSString  *receiveName;           //收货人姓名
@property (nonatomic,strong)  NSString  *receiveSex;            //收货人性别
@property (nonatomic,strong)  NSString  *receiveAddress;        //收货人地址
@property (nonatomic,strong)  NSString  *receivePhone;          //收货人电话
@property (nonatomic,strong)  NSString  *Remark;                //备注
@property (nonatomic,strong)  NSString  *orderTime;              //订单时间
@property (nonatomic,strong)  NSString  *sendTime;               //发货时间
@property (nonatomic,strong)  NSString  *expiredTime;            //订单过期时间


@property (nonatomic, assign) NSInteger detailID;                //订单详情ID  not null
@property (nonatomic, assign) NSInteger detailOrderId;            //订单      not null
@property (nonatomic, assign) NSInteger productID;               //产品ID
@property (nonatomic, assign) NSInteger productCount;            //产品数量
//增加两个参数
@property (nonatomic,strong)  NSString  *productColor;               //产品颜色
@property (nonatomic,strong)  NSString  *productClassID;          //产品类别


- (void)loadData:(NSDictionary *)dict;


@end



