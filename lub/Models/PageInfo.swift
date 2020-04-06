//
//  PageInfo.swift
//  lub
//
//  Created by Luis Alberto Saucedo Quiroga on 4/5/20.
//  Copyright © 2020 Luis Alberto Saucedo Quiroga. All rights reserved.
//

import Foundation

public class PageInfo {
    var totalResults: Int!
    var resultsPerPage: Int!
    
    init(dictionary: NSDictionary?) {
        if dictionary != nil {
            totalResults = dictionary!["totalResults"] as? Int
            resultsPerPage = dictionary!["resultsPerPage"] as? Int
        }
    }
}
