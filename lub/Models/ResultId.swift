//
//  ResultId.swift
//  lub
//
//  Created by Luis Alberto Saucedo Quiroga on 4/5/20.
//  Copyright © 2020 Luis Alberto Saucedo Quiroga. All rights reserved.
//

import Foundation

public class ResultId {
    var kind: String!
    var videoId: String!
    
    init(dictionary: NSDictionary?) {
        if dictionary != nil {
            kind = dictionary!["kind"] as? String
            videoId = dictionary!["videoId"] as? String
        }
    }
}
