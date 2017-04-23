//
//  Repository.swift
//  RxSwiftPractice
//
//  Created by Dinh Thanh An on 4/21/17.
//  Copyright © 2017 Dinh Thanh An. All rights reserved.
//

import ObjectMapper

class Repository: Mappable {
    var identifier: Int!
    var language: String!
    var url: String!
    var name: String!
    
    required init?(map: Map) { }
    
    func mapping(map: Map) {
        identifier <- map["id"]
        language <- map["language"]
        url <- map["url"]
        name <- map["name"]
    }
}
