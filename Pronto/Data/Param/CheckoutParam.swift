//
//  CheckoutParam.swift
//  Pronto
//
//  Created by John Eris Villanueva on 12/3/17.
//  Copyright © 2017 John Eris Villanueva. All rights reserved.
//

import ObjectMapper

class CheckoutParam: Mappable {
    
    private var merchantId: String!
    private var productId: String!
    private var quantity: String!
    
    init(restaurant: Restaurant,
         product: Product) {
        self.merchantId = "\(restaurant.merchantId!)"
        self.productId = "\(product.id!)"
        self.quantity = "1"
    }
    
    required init?(map: Map) {
    }
    
    func mapping(map: Map) {
        merchantId <- map["merchant_id"]
        productId <- map["product_id"]
        quantity <- map["quantity"]
    }
    
}
