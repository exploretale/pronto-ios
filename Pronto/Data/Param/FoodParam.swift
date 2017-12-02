//
//  FoodParam.swift
//  Pronto
//
//  Created by John Eris Villanueva on 12/2/17.
//  Copyright © 2017 John Eris Villanueva. All rights reserved.
//

import ObjectMapper

class FoodParam: Mappable {
    
    private var food: String?
    
    init(food: String) {
        self.food = food
    }
    
    required init?(map: Map) {
    }
    
    func mapping(map: Map) {
        food <- map["food"]
    }
    
}
