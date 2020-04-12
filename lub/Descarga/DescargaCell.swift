//
//  DescargaCell.swift
//  lub
//
//  Created by Luis Alberto Saucedo Quiroga on 4/11/20.
//  Copyright © 2020 Luis Alberto Saucedo Quiroga. All rights reserved.
//

import UIKit

class DescargaCell: UITableViewCell {
    @IBOutlet weak var lbTitulo: UILabel!
    @IBOutlet weak var lbProgreso: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    static var nib:UINib {
        return UINib(nibName: identifier, bundle: nil)
    }
    
    static var identifier: String {
        return String(describing: self)
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    var item: DescargaLub?  {
        didSet {
            self.lbTitulo.text = item?.selectedResult.snippet.title
            
            if item!.pendienteDescarga {
                self.lbProgreso.text = "0%"
            }
            else {
                self.lbProgreso.text = "100%"
            }
        }
    }
}
