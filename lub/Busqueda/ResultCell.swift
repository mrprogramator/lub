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
    @IBOutlet weak var canalLabel: UILabel!
    @IBOutlet weak var percentLabel: UILabel!
    
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
            
            //let titleCount = item?.snippet.title.count
            //let rowsCount = Int(titleCount! / 26)
            //let tituloLabelHeight = CGFloat(rowsCount * 24)
            
            //var tituloLabelFrame = self.tituloLabel.frame
            //tituloLabelFrame = CGRect(x: self.tituloLabel.frame.origin.x, y: self.tituloLabel.frame.origin.y, width: self.tituloLabel.frame.width, height: tituloLabelHeight)
            //self.tituloLabel.frame = tituloLabelFrame
            
            //let canalLabelY = self.tituloLabel.frame.origin.y + self.tituloLabel.frame.height - 24.0
            
            //var canalLabelFrame = self.canalLabel.frame
            //canalLabelFrame = CGRect(x: self.canalLabel.frame.origin.x, y: canalLabelY, width: self.canalLabel.frame.width, height: self.canalLabel.frame.height)
            //self.canalLabel.frame = canalLabelFrame
            
            
            self.canalLabel.text = item?.snippet.channelTitle
            self.percentLabel.isHidden = true
        }
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
