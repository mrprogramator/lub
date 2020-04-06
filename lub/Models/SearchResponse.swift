//
//  SearchResponse.swift
//  lub
//
//  Created by Luis Alberto Saucedo Quiroga on 4/5/20.
//  Copyright © 2020 Luis Alberto Saucedo Quiroga. All rights reserved.
//

import Foundation

public class SearchResponse {
    var kind: String!
    var etag: String!
    var nextPageToken: String!
    var regionCode: String!
    var pageInfo: PageInfo!
    var items: [Result]!
    
    init(dictionary: NSDictionary?) {
        if dictionary != nil {
            kind = dictionary!["kind"] as? String
            etag = dictionary!["etag"] as? String
            nextPageToken = dictionary!["nextPageToken"] as? String
            regionCode = dictionary!["regionCode"] as? String
            
            let pageInfoDictionary = dictionary!["pageInfo"] as? NSDictionary
            pageInfo = PageInfo(dictionary: pageInfoDictionary)
            
            let itemsDictionary = dictionary!["items"] as? [NSDictionary]
            items = [Result]()
            
            if itemsDictionary != nil {
                for itemDict in itemsDictionary! {
                    let item = Result(dictionary: itemDict)
                    items.append(item)
                }
            }
        }
    }
}
