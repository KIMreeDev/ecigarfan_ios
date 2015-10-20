//
//  BillModel.m
//  ECIGARFAN
//
//  Created by renchunyu on 14-5-13.
//  Copyright (c) 2014年 renchunyu. All rights reserved.
//

#import "BillModel.h"

@implementation BillModel

- (void)loadData:(NSDictionary *)dict
{
    self.orderID = [[dict objectForKey:@"order_id"]integerValue];  //订单ID
    self.orderNumber = [dict objectForKey:@"order_number"];       //订单编号
    self.customerID = [[dict objectForKey:@"customer_id"]integerValue];    //下单用户ID
    self.orderStatus = [dict objectForKey:@"order_status"];        //订单状态
    self.firstPay = [[dict objectForKey:@"first_pay"] floatValue];  //订单原价
    self.vipPay =  [[dict objectForKey:@"vip_pay"] floatValue];     //订单会员价
    self.realPay =  [[dict objectForKey:@"real_pay"] floatValue];    //成交价格
    self.orderUnits = [dict objectForKey:@"order_units"];            //货币符号
    self.orderScores = [[dict objectForKey:@"order_scores"]integerValue];   //订单可获积分
    self.payType = [dict objectForKey:@"pay_type"];           //支付形式:paypal或者货到付款
    self.sendType = [dict objectForKey:@"send_type"];        //送货方式：0、快递 1、附近
    self.receiveName = [dict objectForKey:@"rec_name"];      //收货人姓名
    self.receiveSex = [dict objectForKey:@"rec_sex"];          //收货人性别
    self.receiveAddress = [dict objectForKey:@"rec_address"];   //收货人地址
    self.receivePhone = [dict objectForKey:@"rec_phone"];       //收货人电话
     self.Remark = [dict objectForKey:@"remark"];               //备注
    self.orderTime = [dict objectForKey:@"order_tm"];          //订单时间
    self.sendTime = [dict objectForKey:@"send_tm"];           //发货时间
    self.expiredTime = [dict objectForKey:@"expired_tm"];     //订单过期时间
    
  
    self.detailID = [[dict objectForKey:@"detail_id"]integerValue];   //订单详情ID
    self.detailOrderId = [[dict objectForKey:@"detailorder_id"]integerValue];   //订单
    self.productID = [[dict objectForKey:@"pro_id"]integerValue];       //产品ID
    self.productCount = [[dict objectForKey:@"pro_count"]integerValue];    //产品数量
   

    self.productColor = [dict objectForKey:@"pro_color"];    //产品颜色
    self.productClassID = [dict objectForKey:@"pro_classid"];       //产品类别


}


@end
