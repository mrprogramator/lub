//
//  ResultSnippet.swift
//  lub
//
//  Created by Luis Alberto Saucedo Quiroga on 4/5/20.
//  Copyright © 2020 Luis Alberto Saucedo Quiroga. All rights reserved.
//

import Foundation

public class ResultSnippet {
    var publishedAt: String!
    var channelId: String!
    var title: String!
    var description: String!
    var thumbnails: ThumbnailSet!
    var channelTitle: String!
    var liveBroadcastContent: String!
    
    init(dictionary: NSDictionary?) {
        if (dictionary != nil) {
            publishedAt = dictionary!["public"] as? String
            channelId = dictionary!["channelId"] as? String
            title = dictionary!["title"] as? String
            description = dictionary!["description"] as? String
            thumbnails = ThumbnailSet(dictionarySet: dictionary!["thumbnails"] as? NSDictionary)
            channelTitle = dictionary!["channelTitle"] as? String
            liveBroadcastContent = dictionary!["liveBroadcastContent"] as? String
            
        }
    }
}
