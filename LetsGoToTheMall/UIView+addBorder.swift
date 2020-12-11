//
//  UIView+addBorder.swift
//  Snacktacular
//
//  Created by Claudine Haigian on 11/12/20.
//  Copyright © 2020 Claudine Haigian. All rights reserved.
//

import UIKit

extension UIView {
    func addBorder(width: CGFloat, radius: CGFloat, color: UIColor){
        self.layer.borderWidth = width
        self.layer.borderColor = color.cgColor
        self.layer.cornerRadius = radius
    }
    
    func noBorder(){
        self.layer.borderWidth = 0.0
    }
}
