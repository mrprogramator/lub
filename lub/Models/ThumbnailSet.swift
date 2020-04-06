//
//  ThumbnailSet.swift
//  lub
//
//  Created by Luis Alberto Saucedo Quiroga on 4/5/20.
//  Copyright © 2020 Luis Alberto Saucedo Quiroga. All rights reserved.
//

import Foundation

public class ThumbnailSet {
    var defaultThumbnail : Thumbnail!
    var mediumThumbnail : Thumbnail!
    var highThumbnail : Thumbnail!
    
    init(dictionarySet: NSDictionary?) {
        if dictionarySet != nil {
            defaultThumbnail = Thumbnail(dictionary: dictionarySet!["default"] as? NSDictionary)
            mediumThumbnail = Thumbnail(dictionary: dictionarySet!["medium"] as? NSDictionary)
            highThumbnail = Thumbnail(dictionary: dictionarySet!["high"] as? NSDictionary)
        }
    }
}
