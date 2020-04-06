//
//  Result.swift
//  lub
//
//  Created by Luis Alberto Saucedo Quiroga on 4/5/20.
//  Copyright © 2020 Luis Alberto Saucedo Quiroga. All rights reserved.
//

import Foundation

public class Result {
    var kind: String!
    var etag: String!
    var id: ResultId!
    var snippet: ResultSnippet!
    
    init(dictionary: NSDictionary?) {
        if dictionary != nil {
            kind = dictionary!["kind"] as? String
            etag = dictionary!["etag"] as? String
            
            let idDictionary = dictionary!["id"] as? NSDictionary
            self.id = ResultId(dictionary: idDictionary)
            
            let snippetDictionary = dictionary!["snippet"] as? NSDictionary
            self.snippet = ResultSnippet(dictionary: snippetDictionary)
        }
    }
}
