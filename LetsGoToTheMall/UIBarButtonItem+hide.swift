//
//  UIBarButtonItem+hide.swift
//  Snacktacular
//
//  Created by Claudine Haigian on 11/12/20.
//  Copyright © 2020 Claudine Haigian. All rights reserved.
//

import UIKit

extension UIBarButtonItem{
    func hide(){
        self.isEnabled = false
        self.tintColor = .clear
    }
}
