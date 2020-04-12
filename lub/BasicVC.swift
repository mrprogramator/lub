//
//  BasicVC.swift
//  lub
//
//  Created by Luis Alberto Saucedo Quiroga on 4/5/20.
//  Copyright © 2020 Luis Alberto Saucedo Quiroga. All rights reserved.
//

import UIKit

class BasicVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func configureTextField(_ textField:UITextField, _ placeHolder: String) {
        textField.layer.masksToBounds = true
        textField.layer.cornerRadius = 14.0
        //textField.layer.borderWidth = 0
        //textField.borderStyle = .roundedRect
        textField.borderStyle = .none
        //textField.layer.borderColor = UIColor.darkGray.cgColor
        //textField.layer.borderWidth = 1.0
        
        textField.attributedPlaceholder = NSAttributedString(string: placeHolder,
                                                             attributes: [NSAttributedString.Key.foregroundColor: UIColor(displayP3Red: 147, green: 146, blue: 151, alpha: 1)])
    }
}
