//
//  Food.swift
//  Pronto
//
//  Created by John Eris Villanueva on 12/3/17.
//  Copyright © 2017 John Eris Villanueva. All rights reserved.
//

import ObjectMapper

class Food: Mappable {
    
    var calories: Int!
    var name: String!
    var nutrients: [Nutrient]!
    var restaurants: [Restaurant]!
    var reviews: [Review]!
    
    required init?(map: Map) {
    }
    
    func mapping(map: Map) {
        calories <- map["calories"]
        name <- map["name"]
        nutrients <- map["nutrients"]
        restaurants <- map["restaurants"]
        reviews <- map["reviews"]
    }
    
}

class Nutrient: Mappable {
    
    var label: String!
    var quantity: Double!
    var unit: String!
    
    required init?(map: Map) {
    }
    
    func mapping(map: Map) {
        label <- map["label"]
        quantity <- map["quantity"]
        unit <- map["unit"]
    }
    
}

class Restaurant: Mappable {
    
    var address: String!
    var id: String!
    var merchantId: String!
    var image: String!
    var name: String!
    var url: String!
    var isProntoMerchant: Bool!
    var products: [Product]!
    var rating: Int?
    
    required init?(map: Map) {
    }
    
    func mapping(map: Map) {
        address <- map["address"]
        id <- map["id"]
        merchantId <- map["merchant_id"]
        image <- map["image"]
        name <- map["name"]
        url <- map["url"]
        isProntoMerchant <- map["is_pronto_merchant"]
        products <- map["products"]
        rating <- map["rating"]
    }
    
}

class Review: Mappable {
    
    var body: String!
    var rating: Int?
    var title: String!
    
    required init?(map: Map) {
    }
    
    func mapping(map: Map) {
        body <- map["body"]
        rating <- map["rating"]
        title <- map["title"]
    }
    
}

class Product: Mappable {
    
    var description: String!
    var id: Int!
    var name: String!
    var price: String!
    var sku: String!
    var image: String?
    
    required init?(map: Map) {
    }
    
    func mapping(map: Map) {
        description <- map["description"]
        id <- map["id"]
        name <- map["name"]
        price <- map["price"]
        sku <- map["sku"]
        image <- map["image"]
    }
    
}
