//
//  CheckoutResp.swift
//  Pronto
//
//  Created by John Eris Villanueva on 12/3/17.
//  Copyright © 2017 John Eris Villanueva. All rights reserved.
//

import ObjectMapper

class CheckoutResp: Mappable {
    
    var checkoutUrl: String!
    
    required init?(map: Map) {
    }
    
    func mapping(map: Map) {
        checkoutUrl <- map["checkout_url"]
    }
    
}
