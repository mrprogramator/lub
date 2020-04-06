//
//  Thumbnail.swift
//  lub
//
//  Created by Luis Alberto Saucedo Quiroga on 4/5/20.
//  Copyright © 2020 Luis Alberto Saucedo Quiroga. All rights reserved.
//

import Foundation

public class Thumbnail {
    var url: String!
    var width: Int!
    var height: Int!
    
    init(dictionary: NSDictionary?) {
        if dictionary != nil {
            url = dictionary!["url"] as? String
            width = dictionary!["width"] as? Int
            height = dictionary!["height"] as? Int
        }
    }
}
