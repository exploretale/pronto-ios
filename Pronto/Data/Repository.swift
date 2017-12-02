//
//  Repository.swift
//  Pronto
//
//  Created by John Eris Villanueva on 12/2/17.
//  Copyright © 2017 John Eris Villanueva. All rights reserved.
//

import RxSwift
import Moya
import Moya_ObjectMapper

class Repository {
    
    static let instance: Repository = Repository()
    
    private let service: ApiService!
    
    init() {
        self.service = ApiService.instance
    }
    
    func search(param: FoodParam) -> Observable<Food> {
        return service
            .request(.search(param: param))
            .mapObject(Food.self)
    }
    
}
