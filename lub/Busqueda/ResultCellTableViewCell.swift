//
//  ResultCellTableViewCell.swift
//  lub
//
//  Created by Luis Alberto Saucedo Quiroga on 4/5/20.
//  Copyright © 2020 Luis Alberto Saucedo Quiroga. All rights reserved.
//

import UIKit

class ResultCell: UITableViewCell {
    @IBOutlet weak var thumbnailImg: UIImageView!
    @IBOutlet weak var tituloLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    static var nib:UINib {
        return UINib(nibName: identifier, bundle: nil)
    }
    
    static var identifier: String {
        return String(describing: self)
    }
    
    var item: Result?  {
        didSet {
            let thumbUrl = URL(string: (item?.snippet.thumbnails.highThumbnail.url)!)
            self.thumbnailImg.load(url: thumbUrl!)
            self.tituloLabel.text = item?.snippet.title
        }
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
